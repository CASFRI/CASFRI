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
-- TT_PrintMessage
--
-- Print debug information when executing SQL
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_PrintMessage(text);
CREATE OR REPLACE FUNCTION TT_PrintMessage(
  msg text
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    RAISE NOTICE '%', msg;
    RETURN TRUE;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;
------------------------------------------------------------------------------
-- TT_BufferedSmooth
--
-- Simplify a polygon by adding and removing a buffer around it
------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_BufferedSmooth(
    geom geometry,
    bufsize double precision DEFAULT 0
)
RETURNS geometry AS $$
  SELECT ST_Buffer(ST_Buffer($1, $2), -$2)
$$ LANGUAGE sql IMMUTABLE;
------------------------------------------------------------------------------
-- TT_RemoveHoles
--
-- Remove all hole from a polygon or a multipolygon
-- Used by TT_IsSurrounded_FinalFN2()
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RemoveHoles(geometry);
CREATE OR REPLACE FUNCTION TT_RemoveHoles(
  inGeom geometry,
  minArea double precision DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    returnGeom geometry;
  BEGIN
    IF inGeom IS NULL OR ST_IsEmpty(inGeom) OR (ST_GeometryType(inGeom) != 'ST_Polygon' AND ST_GeometryType(inGeom) != 'ST_MultiPolygon') THEN
      RETURN inGeom;
    END IF;
--RAISE NOTICE 'inGeom is %', CASE WHEN ST_IsValid(inGeom) THEN 'VALID' ELSE 'INVALID' END;
    WITH all_geoms AS (
      SELECT ST_GeometryN(ST_Multi(inGeom), generate_series(1, ST_NumGeometries(ST_Multi(inGeom)))) AS geom
    ), polygons AS (
      SELECT ST_MakePolygon(ST_ExteriorRing(a.geom),  
                       ARRAY(SELECT ST_ExteriorRing(b.geom) inner_ring
                             FROM (SELECT (ST_DumpRings(geom)).*) b 
                             WHERE b.path[1] > 0 AND
                                   CASE WHEN minArea IS NULL OR minArea = 0 THEN FALSE ELSE TRUE END AND
                                   ST_Area(b.geom) >= minArea
                            )
                           ) final_geom
      FROM all_geoms a
    )
    SELECT ST_BuildArea(ST_Union(final_geom)) geom
    FROM polygons INTO returnGeom;

    RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
------------------------------------------------------------------------------
-- TT_BiggestSubPolygons
--
-- Return only the biggest polygons from a multipolygon
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_BiggestSubPolygons(geometry, doubleprecision);
CREATE OR REPLACE FUNCTION TT_BiggestSubPolygons(
  inGeom geometry,
  minArea double precision DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    returnGeom geometry;
  BEGIN
    IF inGeom IS NULL OR ST_IsEmpty(inGeom) OR (ST_GeometryType(inGeom) != 'ST_Polygon' AND ST_GeometryType(inGeom) != 'ST_MultiPolygon') THEN
      RETURN inGeom;
    END IF;
    WITH all_geoms AS (
      SELECT ST_GeometryN(ST_Multi(inGeom), generate_series(1, ST_NumGeometries(ST_Multi(inGeom)))) AS geom
    )
    SELECT ST_Union(geom) geom
    FROM all_geoms
    WHERE ST_Area(geom) >= minArea INTO returnGeom;

    RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_SplitByGrid
--
--   geom geometry - Geometry to split.
--
--   xgridsize double precision  - Horizontal grid cell size.
--
--   ygridsize double precision  - Vertical grid cell size.
--
--   xgridoffset double precision  - Horizontal grid offset.
--
--   ygridoffset double precision  - Vertical grid offset.
--
--   RETURNS TABLE (geom geometry, tid int8, x int, y int, tgeom geometry)
--
-- Set function returnings the geometry splitted in multiple parts by a grid of the
-- specified size and optionnaly shifted by the specified offset. Each part comes
-- with a unique identifier for each cell of the grid it intersects with, the x and
-- y coordinate of the cell and a geometry representin the cell itself.
-- The unique identifier returned remains the same for any subsequent call to the
-- function so that all geometry parts inside the same cell, from call to call get
-- the same uid.
--
-- This function is usefull to parallelize some queries.
--
--
-- Self contained and typical example:
--
-- WITH splittable AS (
--   SELECT 1 id, ST_GeomFromText('POLYGON((0 1, 3 2, 3 0, 0 1))') geom
--   UNION ALL
--   SELECT 2 id, ST_GeomFromText('POLYGON((1 1, 4 2, 4 0, 1 1))')
--   UNION ALL
--   SELECT 3 id, ST_GeomFromText('POLYGON((2 1, 5 2, 5 0, 2 1))')
--   UNION ALL
--   SELECT 4 id, ST_GeomFromText('POLYGON((3 1, 6 2, 6 0, 3 1))')
-- )
-- SELECT (TT_SplitByGrid(geom, 0.5)).* FROM splittable
--
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION TT_SplitByGrid(
    ingeom geometry,
    xgridsize double precision,
    ygridsize double precision DEFAULT NULL,
    xgridoffset double precision DEFAULT 0.0,
    ygridoffset double precision DEFAULT 0.0
)
RETURNS TABLE (geom geometry, tid int8, x int, y int, tgeom geometry) AS $$
    DECLARE
        width int;
        height int;
        xminrounded double precision;
        yminrounded double precision;
        xmaxrounded double precision;
        ymaxrounded double precision;
        xmin double precision := ST_XMin(ingeom);
        ymin double precision := ST_YMin(ingeom);
        xmax double precision := ST_XMax(ingeom);
        ymax double precision := ST_YMax(ingeom);
        x int;
        y int;
        env geometry;
        xfloor int;
        yfloor int;
    BEGIN
        IF ingeom IS NULL OR ST_IsEmpty(ingeom) THEN
            RETURN QUERY SELECT ingeom, NULL::int8, NULL::int, NULL::int, NULL::geometry ;
            RETURN;
        END IF;
        IF xgridsize IS NULL OR xgridsize <= 0 THEN
            RAISE NOTICE 'Defaulting xgridsize to 1...';
            xgridsize = 1;
        END IF;
        IF ygridsize IS NULL OR ygridsize <= 0 THEN
            ygridsize = xgridsize;
        END IF;
        xfloor = floor((xmin - xgridoffset) / xgridsize);
        xminrounded = xfloor * xgridsize + xgridoffset;
        xmaxrounded = ceil((xmax - xgridoffset) / xgridsize) * xgridsize + xgridoffset;
        yfloor = floor((ymin - ygridoffset) / ygridsize);
        yminrounded = yfloor * ygridsize + ygridoffset;
        ymaxrounded = ceil((ymax - ygridoffset) / ygridsize) * ygridsize + ygridoffset;

        width = round((xmaxrounded - xminrounded) / xgridsize);
        height = round((ymaxrounded - yminrounded) / ygridsize);

        FOR x IN 1..width LOOP
            FOR y IN 1..height LOOP
                env = ST_MakeEnvelope(xminrounded + (x - 1) * xgridsize, yminrounded + (y - 1) * ygridsize, xminrounded + x * xgridsize, yminrounded + y * ygridsize, ST_SRID(ingeom));
                IF ST_Intersects(env, ingeom) THEN
                     RETURN QUERY SELECT ST_Intersection(ingeom, env), ((xfloor::int8 + x) * 10000000 + (yfloor::int8 + y))::int8, xfloor + x, yfloor + y, env
                            WHERE ST_Dimension(ST_Intersection(ingeom, env)) = ST_Dimension(ingeom) OR
                                  ST_GeometryType(ST_Intersection(ingeom, env)) = ST_GeometryType(ingeom);
                 END IF;
            END LOOP;
        END LOOP;
    RETURN;
    END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------------------------
-- TT_SuperUnion
--
-- ST_Union() all polygons in a two stage process 
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SuperUnion(name, name, name, text) CASCADE;
CREATE OR REPLACE FUNCTION TT_SuperUnion(
  schemaName name,
  tableName name,
  geomColumnName name,
  filterStr text DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    queryStr text;
    returnGeom geometry;
  BEGIN
    queryStr = 'WITH gridded AS (' ||
                  'SELECT TT_SplitByGrid(' || geomColumnName ||', 10000) split ' ||
                  'FROM ' || TT_FullTableName(schemaName, tableName) ||
                  CASE WHEN NOT filterStr IS NULL THEN ' WHERE ' || filterStr ELSE '' END ||
               '), first_level_union AS (' ||
                  'SELECT ST_Union((split).geom) geom ' ||
                  'FROM gridded ' ||
                  'GROUP BY (split).tid' ||
               ') ' ||
               'SELECT ST_Union(geom) geom ' ||
               'FROM first_level_union;';
    --RAISE NOTICE 'queryStr=%', queryStr;
    EXECUTE queryStr INTO returnGeom;
    RETURN returnGeom;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
-- Test
-- SELECT TT_SuperUnion('casfri50', 'geo_all', 'left(cas_id, 4) = ''SK03''');
------------------------------------------------------------------------------
-- Create a table of polygon counts
--DROP TABLE IF EXISTS casfri50_coverage.inv_counts;
CREATE TABLE casfri50_coverage.inv_counts AS
SELECT left(cas_id, 4) inv, count(*) cnt
FROM casfri50.geo_all
GROUP BY left(cas_id, 4);
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ProduceDerivedCoverages(text, geometry) CASCADE;
CREATE OR REPLACE FUNCTION TT_ProduceDerivedCoverages(
  fromInv text,
  detailedGeom geometry
)
RETURNS boolean AS $$
  DECLARE
    tableNameArr text[] = ARRAY['detailed', 'noholes', 'noislands', 'simplified', 'smoothed'];
    tableName text;
    queryStr text;
    outGeom geometry;
    --detailedGeom geometry;
    noHolesGeom geometry;
    noIslandsGeom geometry;
    simplifiedGeom geometry;
    smoothedGeom geometry;
    cnt int;
  BEGIN
    noHolesGeom = TT_RemoveHoles(detailedGeom, 10000000);
    noIslandsGeom = TT_BiggestSubPolygons(noHolesGeom, 10000000);
    simplifiedGeom = ST_SimplifyPreserveTopology(noIslandsGeom, 10);
    smoothedGeom = TT_BiggestSubPolygons(TT_BufferedSmooth(simplifiedGeom, 100), 10000000);
    SELECT a.cnt FROM casfri50_coverage.inv_counts a WHERE inv = fromInv INTO cnt;
    --detailedGeom = TT_SuperUnion('casfri50', 'geo_all', 'left(cas_id, 4) = ''' || upper(fromInv) || '''');
    FOREACH tableName IN ARRAY tableNameArr LOOP
      outGeom = CASE WHEN tableName = 'detailed' THEN detailedGeom
                     WHEN tableName = 'noholes' THEN noHolesGeom
                     WHEN tableName = 'noislands' THEN noIslandsGeom
                     WHEN tableName = 'simplified' THEN simplifiedGeom
                     WHEN tableName = 'smoothed' THEN smoothedGeom
                END;
      queryStr = 'CREATE TABLE IF NOT EXISTS casfri50_coverage.' || tableName || '
                 (inv text, nb_polys int, nb_points int, geom geometry);
                 DELETE FROM casfri50_coverage.' || tableName || '
                 WHERE inv = ''' || upper(fromInv) || ''';
                 INSERT INTO casfri50_coverage.' || tableName || ' (inv, nb_polys, nb_points, geom) VALUES ($2, $3, $4, $5);';
      EXECUTE queryStr USING tableName, upper(fromInv), cnt, ST_NPoints(outGeom), outGeom;
    END LOOP;
    RETURN TRUE;
  END
$$ LANGUAGE plpgsql VOLATILE;

------------------------------------------------------------------------------
-- Union by grid with a single query - 49s
SELECT TT_ProduceDerivedCoverages('AB03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB03''')); --   61633, pg11:  1m45, pg13:   28s
SELECT TT_ProduceDerivedCoverages('AB06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB06''')); --   11484, pg11:  1m45, pg13:   21s
SELECT TT_ProduceDerivedCoverages('AB07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB07''')); --   23268, pg11:  xmxx, pg13:   21s
SELECT TT_ProduceDerivedCoverages('AB08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB08''')); --   34474, pg11:  xmxx, pg13:  1m31
SELECT TT_ProduceDerivedCoverages('AB10', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB10''')); --  194696, pg11:  xmxx, pg13: 10m22
SELECT TT_ProduceDerivedCoverages('AB11', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB11''')); --  118624, pg11:  xmxx, pg13:  2m45
SELECT TT_ProduceDerivedCoverages('AB16', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB16''')); --  120476, pg11:  9m50, pg13:  3m05
SELECT TT_ProduceDerivedCoverages('AB25', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB25''')); --  527038, pg11:  xmxx, pg13: 15m03
SELECT TT_ProduceDerivedCoverages('AB29', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB29''')); --  620944, pg11:  xmxx, pg13: 20m50
SELECT TT_ProduceDerivedCoverages('AB30', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB30''')); --    4555, pg11:  xmxx, pg13:   56s
SELECT TT_ProduceDerivedCoverages('BC08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC08''')); -- 4677411, pg11:  5h21, pg13:  2h26
SELECT TT_ProduceDerivedCoverages('BC10', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC10''')); -- 5151772, pg11:  6h13, pg13:  3h01
SELECT TT_ProduceDerivedCoverages('MB01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB01''')); --  134790, pg11:  xmxx, pg13:  3m38
SELECT TT_ProduceDerivedCoverages('MB02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB02''')); --   60370, pg11:  xmxx, pg13:  2m46
SELECT TT_ProduceDerivedCoverages('MB04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB04''')); --   27221, pg11:  xmxx, pg13:  1m20
SELECT TT_ProduceDerivedCoverages('MB05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB05''')); --  514157, pg11:  3h06, pg13: 45m38
SELECT TT_ProduceDerivedCoverages('MB06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB06''')); --  160218, pg11: 43m28, pg13:  6m44
SELECT TT_ProduceDerivedCoverages('MB07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB07''')); --  219682, pg11:  xmxx, pg13: 14m00
SELECT TT_ProduceDerivedCoverages('NB01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NB01''')); --  927177, pg11:   BUG, pg13: 33m51
SELECT TT_ProduceDerivedCoverages('NB02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NB02''')); -- 1123893, pg11:  BUG, infinite time, pg13: 31m48
SELECT TT_ProduceDerivedCoverages('NL01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NL01''')); -- 1863664, pg11:     ?, pg13: 49m23
SELECT TT_ProduceDerivedCoverages('NT01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NT01''')); -- 1127926, pg11: 27m38, pg13:  7m36
SELECT TT_ProduceDerivedCoverages('NT03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NT03''')); -- 1090671, pg11: 39m24, pg13: 13m10
SELECT TT_ProduceDerivedCoverages('NS01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS01''')); --  995886, pg11:  xmxx, pg13: 35m48
SELECT TT_ProduceDerivedCoverages('NS02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS02''')); --  281388, pg11:  xmxx, pg13: 26m16
SELECT TT_ProduceDerivedCoverages('NS03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS03''')); --  320944, pg11:  1h11, pg13: 24m55
SELECT TT_ProduceDerivedCoverages('ON02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''ON02''')); -- 3629072, pg11: BUG ERROR, pg13: 4h45
SELECT TT_ProduceDerivedCoverages('PC01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PC01''')); --    8094, pg11:  xmxx, pg13:   14s
SELECT TT_ProduceDerivedCoverages('PC02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PC02''')); --    1053, pg11:  xmxx, pg13:   11s
SELECT TT_ProduceDerivedCoverages('PE01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PE01''')); --  107220, pg11:  4m23, pg13:  3m32
SELECT TT_ProduceDerivedCoverages('QC03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC03''')); --  401188, pg11:      , pg13:  8m45
SELECT TT_ProduceDerivedCoverages('QC04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC04''')); -- 2487519, pg11:     ?, pg13: 59m12
SELECT TT_ProduceDerivedCoverages('QC05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC05''')); -- 6768074, pg11:     ?, pg13:  2h07
SELECT TT_ProduceDerivedCoverages('QC06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC06''')); -- 2487519, pg11:     ?, pg13:  2h07
SELECT TT_ProduceDerivedCoverages('SK01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK01''')); -- 1501667, pg11:  3h13, pg13: 41m53
SELECT TT_ProduceDerivedCoverages('SK02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK02''')); --   27312, pg11:  2m03, pg13:   49s
SELECT TT_ProduceDerivedCoverages('SK03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK03''')); --    8964, pg11:   49s, pg13:   23s
SELECT TT_ProduceDerivedCoverages('SK04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK04''')); --  633522, pg11:  2h11, pg13: 31m33
SELECT TT_ProduceDerivedCoverages('SK05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK05''')); --  421977, pg11:  1h13, pg13: 16m55 
SELECT TT_ProduceDerivedCoverages('SK06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK06''')); --  211482, pg11: 40m04, pg13: 11m08
SELECT TT_ProduceDerivedCoverages('YT01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT01''')); --  249636, pg11:  xmxx, pg13:  9m03
SELECT TT_ProduceDerivedCoverages('YT02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT02''')); --  231137, pg11: 25m11, pg13:  9m07

-- Recompute derived only if needed
SELECT TT_ProduceDerivedCoverages('SK03', (SELECT geom FROM casfri50_coverage.detailed WHERE inv = 'SK03'));

-- Display 
SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.detailed 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.noholes 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.noislands 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.simplified 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.smoothed 
ORDER BY nb_polys;

-- Create a table of all intersection in the coverages
CREATE OR REPLACE FUNCTION sig_digits(n anyelement, digits int) 
RETURNS numeric
AS $$
    SELECT round(n::numeric, digits - 1 - floor(log(abs(n)))::int)
$$ LANGUAGE sql IMMUTABLE STRICT;

--SELECT sig_digits(0.0000372537::double precision, 3)
--SELECT sig_digits(12353263256525, 5)

DROP TABLE IF EXISTS casfri50_coverage.intersections;
CREATE TABLE casfri50_coverage.intersections AS
WITH unnested AS (
  SELECT a.inv, unnest(ST_SplitAgg(a.geom, b.geom, 0.00001)) geom
  FROM casfri50_coverage.simplified a,
       casfri50_coverage.simplified b
  WHERE ST_Equals(a.geom, b.geom) OR
        ST_Contains(a.geom, b.geom) OR
        ST_Contains(b.geom, a.geom) OR
        ST_Overlaps(a.geom, b.geom)
  GROUP BY a.inv, ST_AsEWKB(a.geom)
)
SELECT string_agg(inv, '-') invs, 
       count(*) nb, 
       sig_digits(ST_Area(geom), 8) area,
       min(geom)::geometry geom
FROM unnested
GROUP BY sig_digits(ST_Area(geom), 8)
HAVING count(*) > 1
ORDER BY area DESC;

-- Display
SELECT * FROM casfri50_coverage.intersections;
