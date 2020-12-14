------------------------------------------------------------------------------
-- CASFRI Inventory coverage production script for CASFRI v5 beta
-- For use with PostgreSQL Table Tranlation Engine v0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
-- https://github.com/edwardsmarc/casfri
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
------------------------------------------------------------------------------
-- This script attempt to generate the area covered by each inventory using 
-- different techniques. It is generally not sufficient to simply ST_Union()
-- all the geometry from an inventory to produce a polygon representing it's
-- complete geographical coverage. Most inventories have too many polygons
-- which make PostGIS to fail on ST_Union() because of memory overflow. 
------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_coverage;
------------------------------------------------------------------------------
-- TT_RemoveHoles
--
-- Remove all hole from a polygon or a multipolygon
-- Used by TT_IsSurrounded_FinalFN2()
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RemoveHoles(geometry);
CREATE OR REPLACE FUNCTION TT_RemoveHoles(
  inGeom geometry
)
RETURNS geometry AS $$
  DECLARE
    returnGeom geometry;
  BEGIN
    IF ST_IsEmpty(inGeom) OR (ST_GeometryType(inGeom) != 'ST_Polygon' AND ST_GeometryType(inGeom) != 'ST_MultiPolygon') THEN
      RETURN inGeom;
	  END IF;
--RAISE NOTICE 'inGeom is %', CASE WHEN ST_IsValid(inGeom) THEN 'VALID' ELSE 'INVALID' END;
    WITH polygons AS (
	  SELECT ST_MakePolygon(
             ST_ExteriorRing(
               ST_GeometryN(ST_Multi(inGeom), 
                            generate_series(1, ST_NumGeometries(ST_Multi(inGeom)))
							 )
             )
	         ) geom
    )
    SELECT ST_Union(geom) geom
    FROM polygons INTO returnGeom;
	RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;
------------------------------------------------------------------------------
-- TT_IsSurrounded_StateFN
--
-- TT_IsSurrounded() aggregate state function.
-- ST_Union() all polygons surrounding 
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_IsSurrounded_StateFN(geometry[], geometry, geometry) CASCADE;
CREATE OR REPLACE FUNCTION TT_IsSurrounded_StateFN(
  stateGeom geometry[],
  surroundedGeom geometry,
  surroundingGeom geometry
)
RETURNS geometry[] AS $$
    SELECT ARRAY[ST_Union(
                   CASE WHEN stateGeom IS NULL
                          THEN ST_SetSRID(ST_GeomFromText('MULTIPOLYGON EMPTY'), ST_SRID(surroundedGeom))
                        ELSE stateGeom[1]
                   END,
                   CASE WHEN ST_Equals(surroundingGeom, surroundedGeom) OR surroundingGeom IS NULL
                          THEN ST_SetSRID(ST_GeomFromText('MULTIPOLYGON EMPTY'), ST_SRID(surroundedGeom))
                        ELSE surroundingGeom
                   END
                 ), surroundedGeom];
$$ LANGUAGE sql IMMUTABLE;

--DROP FUNCTION IF EXISTS TT_IsSurrounded_FinalFN(geometry[]) CASCADE;
CREATE OR REPLACE FUNCTION TT_IsSurrounded_FinalFN(
  stateGeom geometry[]
)
RETURNS boolean AS $$
  SELECT CASE WHEN stateGeom IS NULL OR stateGeom[1] IS NULL THEN
           NULL
         ELSE
           ST_Contains(TT_RemoveHoles(ST_CollectionExtract(ST_MakeValid(ST_Buffer(ST_CollectionExtract(stateGeom[1], 3), -0.00001)), 3)), stateGeom[2])
           --ST_Contains(TT_RemoveHoles(ST_Buffer(ST_CollectionExtract(stateGeom[1], 3), -0.00001)), stateGeom[2])
           --ST_Contains(TT_RemoveHoles(ST_CollectionExtract(stateGeom[1], 3)), stateGeom[2])
         END;
$$ LANGUAGE sql IMMUTABLE;

--DROP AGGREGATE IF EXISTS TT_IsSurroundedAgg(geometry, geometry);
CREATE AGGREGATE TT_IsSurroundedAgg(geometry, geometry)
(
  SFUNC = TT_IsSurrounded_StateFN,
  STYPE = geometry[],
  FINALFUNC = TT_IsSurrounded_FinalFN
);
------------------------------------------------------------------
-- Test TT_IsSurroundedAgg() on real data before using it
DROP TABLE IF EXISTS casfri50_coverage.sk03;
CREATE TABLE casfri50_coverage.sk03 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK03';

CREATE INDEX sk03_geom_idx ON casfri50_coverage.sk03 USING gist(geometry);

-- 3min for 8964 rows, 1000000 should be 333min = 5 hours

DROP TABLE IF EXISTS casfri50_coverage.sk03_only_surrounded;
CREATE TABLE casfri50_coverage.sk03_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.sk03 a, casfri50_coverage.sk03 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

-- Display
SELECT * FROM casfri50_coverage.sk03_only_surrounded;

-- Union them
DROP TABLE IF EXISTS casfri50_coverage.sk03_notsurroundedunion;
CREATE TABLE casfri50_coverage.sk03_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.sk03_only_surrounded;

SELECT ST_Area(geom) FROM casfri50_coverage.sk03_notsurroundedunion
UNION ALL
SELECT ST_Area(geometry) FROM casfri50_coverage.sk03_union;
------------------------------------------------------------------------------
-- SK03 - DONE
-- ST_Union() - 3623 points in 2m BEST
-- ST_BufferedUnion(, 10) - 4672 points in 4m50 
-- ST_BufferedUnion(, 10, 10) - 645 points in 1m05
DROP TABLE IF EXISTS casfri50_coverage.sk03_bu_10_10;
CREATE TABLE casfri50_coverage.sk03_bu_10_10 AS
SELECT ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK03';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.sk03;
------------------------------------------------------------------------------
-- AB06 - DONE
-- ST_Union() - 1964 points in 2m13
-- ST_BufferedUnion(, 10) - 2807 points in 12m05
-- ST_BufferedUnion(, 10, 10) - 95 points 2m54 Best
DROP TABLE IF EXISTS casfri50_coverage.ab06;
CREATE TABLE casfri50_coverage.ab06 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB06';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.ab06;
------------------------------------------------------------------------------
-- SK02 - DONE
-- ST_Union() - 19858 points in 4m28
-- ST_Simplify(ST_Union()) - 2463 points in 4m33 BEST
-- ST_BufferedUnion(, 10) - 21796 points in 50m19
-- ST_BufferedUnion(, 10, 10) - 2288 points 10 min 54
DROP TABLE IF EXISTS casfri50_coverage.sk02;
CREATE TABLE casfri50_coverage.sk02 AS
SELECT ST_Simplify(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK02';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.sk02;
------------------------------------------------------------------------------
-- PE01 - DONE
-- ST_Simplify(ST_Union(),10) -  19538 points in 11m27
-- ST_BufferedUnion(, 10) - ERROR
-- ST_BufferedUnion(, 10, 10) - ERROR
DROP TABLE IF EXISTS casfri50_coverage.pe01_union;
CREATE TABLE casfri50_coverage.pe01_union AS
SELECT ST_Simplify(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'PE01';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.pe01;
------------------------------------------------------------------------------
-- AB16 - DONE
-- ST_Union() - 58283 points in 29m36
-- ST_Simplify(ST_Union(),10) -  2826 points in 29m36 BEST
-- ST_BufferedUnion(, 10) - 41584 points in 12 hr 42
-- ST_BufferedUnion(, 10, 10) - ERROR
DROP TABLE IF EXISTS casfri50_coverage.ab16_union;
CREATE TABLE casfri50_coverage.ab16_union AS
SELECT ST_Simplify(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('ab16');

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.ab16;
------------------------------------------------------------------------------
-- MB06 - 160218 - 1h10 - DONE
DROP TABLE IF EXISTS casfri50_coverage.mb06;
CREATE TABLE casfri50_coverage.mb06 AS
SELECT ST_BufferedSmooth(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB06';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.mb06;

-- Try with TT_IsSurrounded -- 160000 rows
DROP TABLE IF EXISTS casfri50_coverage.mb06;
CREATE TABLE casfri50_coverage.mb06 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB06';

CREATE INDEX cov_mb06_geom_idx ON casfri50_coverage.mb06 USING gist(geometry);

-- 28 hr 48
DROP TABLE IF EXISTS casfri50_coverage.mb06_only_surrounded;
CREATE TABLE casfri50_coverage.mb06_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.mb06 a, casfri50_coverage.mb06 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

-- 44540
SELECT count(*) FROM casfri50_coverage.mb06_only_surrounded;

CREATE INDEX cov_mb06_only_surrounded_geom_idx ON casfri50_coverage.mb06_only_surrounded USING gist(geom);

-- Display
SELECT * FROM casfri50_coverage.mb06_only_surrounded;

-- Union them. 2h Works!
DROP TABLE IF EXISTS casfri50_coverage.mb06_notsurroundedunion;
CREATE TABLE casfri50_coverage.mb06_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.mb06_only_surrounded;

-- Count the number of points 990823!
SELECT ST_NPoints(geom) nb
FROM casfri50_coverage.mb06_notsurroundedunion;

-- Display
SELECT * FROM casfri50_coverage.mb06_notsurroundedunion;
------------------------------------------------------------------------------
-- SK06 - DONE
-- ST_Union() - ERROR
-- ST_Simplify(ST_Union(),10) - ERROR
-- ST_BufferedUnion(, 10) - 86005 points in 62 hr 43
-- ST_BufferedUnion(, 10, 10) - ERROR
-- IsSurroundedAgg() - 1h50
DROP TABLE IF EXISTS casfri50_coverage.sk06;
CREATE TABLE casfri50_coverage.sk06 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK06';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.sk06;

-- Try with TT_IsSurrounded -- 211482 rows
DROP TABLE IF EXISTS casfri50_coverage.sk06;
CREATE TABLE casfri50_coverage.sk06 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('sk06');

CREATE INDEX cov_sk06_geom_idx ON casfri50_coverage.sk06 USING gist(geometry);

-- 1h49
DROP TABLE IF EXISTS casfri50_coverage.sk06_only_surrounded;
CREATE TABLE casfri50_coverage.sk06_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.sk06 a, casfri50_coverage.sk06 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

-- Display
SELECT * FROM casfri50_coverage.sk06_only_surrounded;

-- Union them. Works!
DROP TABLE IF EXISTS casfri50_coverage.sk06_notsurroundedunion;
CREATE TABLE casfri50_coverage.sk06_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.sk06_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.sk06_notsurroundedunion;

------------------------------------------------------------------------------
-- YT02 - 231137 - 1h02 - DONE
-- ST_Union() - 7489 points in 1h02
-- ST_Simplify(ST_Union(),10) -  675 points in 1h02 - BEST
-- ST_BufferedUnion(, 10) - 7755 points in 158h
-- ST_BufferedUnion(, 10, 10) - ERROR
DROP TABLE IF EXISTS casfri50_coverage.yt02_union_simplify;
CREATE TABLE casfri50_coverage.yt02_union_simplify AS
SELECT ST_Simplify(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('yt02');

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.yt02;
------------------------------------------------------------------------------
-- NT01 - DONE
-- ST_Union() - 145495 points in 7 hr 23
-- ST_Simplify(ST_Union(), 10) - 27689 points in 7 hr 22
-- ST_BufferedUnion(, 10) - 133324 points in 115 hr 25
-- ST_BufferedUnion(, 10, 10) - ERROR lwgeom_union: GEOS Error: TopologyException: Input geom 0 is invalid: Hole lies outside shell at or near point -1201782.5273627562 2581810.9876105641 at -1201782.5273627562 2581810.9876105641
DROP TABLE IF EXISTS casfri50_coverage.nt01;
CREATE TABLE casfri50_coverage.nt01 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT01';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.nt01;
------------------------------------------------------------------------------
-- NT02 - In progress
-- ST_Union() - ERROR
-- ST_Simplify(ST_Union(),10) - ERROR
-- ST_BufferedUnion(, 10) - 80310 points in 107h45
-- ST_BufferedUnion(, 10, 10) - ERROR
DROP TABLE IF EXISTS casfri50_coverage.nt02;
CREATE TABLE casfri50_coverage.nt02 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT02';

-- Try with TT_IsSurrounded -- 320944 rows
DROP TABLE IF EXISTS casfri50_coverage.nt02;
CREATE TABLE casfri50_coverage.nt02 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('nt02');

CREATE INDEX cov_nt02_geom_idx ON casfri50_coverage.nt02 USING gist(geometry);

SELECT count(*)
FROM casfri50_coverage.nt02;

-- 1h49
DROP TABLE IF EXISTS casfri50_coverage.nt02_only_surrounded;
CREATE TABLE casfri50_coverage.nt02_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.nt02 a, casfri50_coverage.nt02 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

-- Display
SELECT * FROM casfri50_coverage.nt02_only_surrounded;

-- Union them
DROP TABLE IF EXISTS casfri50_coverage.nt02_notsurroundedunion;
CREATE TABLE casfri50_coverage.nt02_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.nt02_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.nt02_notsurroundedunion;
------------------------------------------------------------------------------
-- SK05 - 421977 - DONE
DROP TABLE IF EXISTS casfri50_coverage.sk05;
CREATE TABLE casfri50_coverage.sk05 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK05';

-- Try with TT_IsSurrounded -- 421977 rows
DROP TABLE IF EXISTS casfri50_coverage.sk05;
CREATE TABLE casfri50_coverage.sk05 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('sk05');

CREATE INDEX cov_sk05_geom_idx ON casfri50_coverage.sk05 USING gist(geometry);

-- 3h23
DROP TABLE IF EXISTS casfri50_coverage.sk05_only_surrounded;
CREATE TABLE casfri50_coverage.sk05_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.sk05 a, casfri50_coverage.sk05 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

SELECT count(*)
FROM casfri50_coverage.sk05_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.sk05_only_surrounded;

-- Union them 24m
DROP TABLE IF EXISTS casfri50_coverage.sk05_notsurroundedunion;
CREATE TABLE casfri50_coverage.sk05_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.sk05_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.sk05_notsurroundedunion;

-- 329248 points
SELECT ST_NPoints(geom) nb
FROM casfri50_coverage.sk05_notsurroundedunion;

DROP TABLE IF EXISTS casfri50_coverage.sk05_notsurroundedunion_simplified;
CREATE TABLE casfri50_coverage.sk05_notsurroundedunion_simplified AS
SELECT ST_NPoints(ST_Simplify(geom, 10)) geom
FROM casfri50_coverage.sk05_notsurroundedunion;
------------------------------------------------------------------------------
-- MB05 - 514157 - In progress
DROP TABLE IF EXISTS casfri50_coverage.mb05;
CREATE TABLE casfri50_coverage.mb05 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB05';

-- Try with TT_IsSurrounded -- 514157 rows
DROP TABLE IF EXISTS casfri50_coverage.mb05;
CREATE TABLE casfri50_coverage.mb05 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('mb05');

CREATE INDEX cov_mb05_geom_idx ON casfri50_coverage.mb05 USING gist(geometry);

-- 
DROP TABLE IF EXISTS casfri50_coverage.mb05_only_surrounded;
CREATE TABLE casfri50_coverage.mb05_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.mb05 a, casfri50_coverage.mb05 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

SELECT count(*)
FROM casfri50_coverage.mb05_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.mb05_only_surrounded;

-- Union them 24m
DROP TABLE IF EXISTS casfri50_coverage.mb05_notsurroundedunion;
CREATE TABLE casfri50_coverage.mb05_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.mb05_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.mb05_notsurroundedunion;
------------------------------------------------------------------------------
-- SK04 - 633522 - In progress
DROP TABLE IF EXISTS casfri50_coverage.sk04;
CREATE TABLE casfri50_coverage.sk04 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK04';

-- Try with TT_IsSurrounded
DROP TABLE IF EXISTS casfri50_coverage.sk04;
CREATE TABLE casfri50_coverage.sk04 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('sk04');

CREATE INDEX cov_sk04_geom_idx ON casfri50_coverage.sk04 USING gist(geometry);

--
DROP TABLE IF EXISTS casfri50_coverage.sk04_only_surrounded;
CREATE TABLE casfri50_coverage.sk04_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.sk04 a, casfri50_coverage.sk04 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

SELECT count(*)
FROM casfri50_coverage.sk04_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.sk04_only_surrounded;

-- Union them 24m
DROP TABLE IF EXISTS casfri50_coverage.sk04_notsurroundedunion;
CREATE TABLE casfri50_coverage.sk04_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.mb05_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.sk04_notsurroundedunion;
------------------------------------------------------------------------------
-- NB01 - 927177 - In progress
DROP TABLE IF EXISTS casfri50_coverage.nb01;
CREATE TABLE casfri50_coverage.nb01 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB01';

-- Try with TT_IsSurrounded
DROP TABLE IF EXISTS casfri50_coverage.nb01;
CREATE TABLE casfri50_coverage.nb01 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('nb01');

CREATE INDEX cov_nb01_geom_idx ON casfri50_coverage.nb01 USING gist(geometry);

--
DROP TABLE IF EXISTS casfri50_coverage.nb01_only_surrounded;
CREATE TABLE casfri50_coverage.nb01_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.nb01 a, casfri50_coverage.nb01 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

SELECT count(*)
FROM casfri50_coverage.nb01_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.nb01_only_surrounded;

-- Union them 24m
DROP TABLE IF EXISTS casfri50_coverage.nb01_notsurroundedunion;
CREATE TABLE casfri50_coverage.nb01_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.nb01_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.nb01_notsurroundedunion;
------------------------------------------------------------------------------
-- NS03 - 995886 - In progress
DROP TABLE IF EXISTS casfri50_coverage.ns03;
CREATE TABLE casfri50_coverage.ns03 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NS03';

-- Try with TT_IsSurrounded
DROP TABLE IF EXISTS casfri50_coverage.ns03;
CREATE TABLE casfri50_coverage.ns03 AS
SELECT cas_id, geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = upper('ns03');

CREATE INDEX cov_ns03_geom_idx ON casfri50_coverage.ns03 USING gist(geometry);

--
DROP TABLE IF EXISTS casfri50_coverage.ns03_only_surrounded;
CREATE TABLE casfri50_coverage.ns03_only_surrounded AS
SELECT a.cas_id id, a.geometry geom
FROM casfri50_coverage.ns03 a, casfri50_coverage.ns03 b
WHERE ST_Intersects(a.geometry, b.geometry)
GROUP BY a.cas_id, a.geometry
HAVING NOT TT_IsSurroundedAgg(a.geometry, b.geometry);

SELECT count(*)
FROM casfri50_coverage.ns03_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.ns03_only_surrounded;

-- Union them 24m
DROP TABLE IF EXISTS casfri50_coverage.ns03_notsurroundedunion;
CREATE TABLE casfri50_coverage.ns03_notsurroundedunion AS
SELECT TT_RemoveHoles(ST_Union(geom)) geom
FROM casfri50_coverage.ns03_only_surrounded;

-- Display
SELECT * FROM casfri50_coverage.ns03_notsurroundedunion;
------------------------------------------------------------------------------
-- NB02 - 1123893 - TODO
DROP TABLE IF EXISTS casfri50_coverage.nb02;
CREATE TABLE casfri50_coverage.nb02 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB02';
------------------------------------------------------------------------------
-- SK01 - 1501667 - TODO
DROP TABLE IF EXISTS casfri50_coverage.sk01;
CREATE TABLE casfri50_coverage.sk01 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK01';
------------------------------------------------------------------------------
-- ON02 - 3629072 - TODO
DROP TABLE IF EXISTS casfri50_coverage.sk03;
CREATE TABLE casfri50_coverage.on02 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'ON02';
------------------------------------------------------------------------------
-- BC08 - 4677411 - TODO
DROP TABLE IF EXISTS casfri50_coverage.bc08;
CREATE TABLE casfri50_coverage.bc08 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC08';
------------------------------------------------------------------------------
-- BC10 - 5151772 - TODO
DROP TABLE IF EXISTS casfri50_coverage.bc10;
CREATE TABLE casfri50_coverage.bc10 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC10';
