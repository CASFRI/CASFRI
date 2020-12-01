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
--DROP FUNCTION ST_IsSurrounded(geometry, name, name,name);
-- Used to filter out polygons strictly inside an aggregate 
-- of polygons in order to union only the surrounding polygon together (way faster).
CREATE OR REPLACE FUNCTION ST_IsSurrounded1(
  geom geometry, 
  schemaname name, 
  tablename name,
  geomcolumnname name DEFAULT 'geom',
  filter text DEFAULT NULL
) 
RETURNS boolean AS $$ 
  DECLARE
	  surrounding geometry;
	  inpoly geometry;
	  query text;
	  fqtn text;
	  debug boolean;
  BEGIN
    debug = true;
	  -- Determine the complete name of the table
    fqtn := '';
    IF length(schemaname) > 0 THEN
      fqtn := quote_ident(schemaname) || '.';
    END IF;
    fqtn := fqtn || quote_ident(tablename);
    inpoly = ST_CollectionExtract(geom, 3);

    query = 'WITH polys AS (SELECT ST_CollectionExtract(' || geomcolumnname || ', 3) geom FROM ' || fqtn;
    IF NOT filter IS NULL THEN
      query = query || ' WHERE ' || filter;
    END IF;
    query = query || ' ) SELECT ST_Union(ST_Intersection(ST_Boundary($1), b.geom)) border FROM polys b WHERE NOT ST_Equals($1, b.geom) AND ST_Intersects($1, b.geom) GROUP BY $1;';
RAISE NOTICE 'ST_IsSurrounded() - query = %', query;

    EXECUTE query INTO surrounding USING inpoly;

    RETURN CASE WHEN surrounding IS NULL THEN false
                ELSE ST_Equals(ST_Boundary(inpoly), ST_CollectionExtract(surrounding, 2))
           END;
    END; 
$$ LANGUAGE 'plpgsql' VOLATILE;

CREATE OR REPLACE FUNCTION ST_IsSurrounded2(
  geom geometry, 
  schemaname name, 
  tablename name,
  geomcolumnname name DEFAULT 'geom',
  filter text DEFAULT NULL
) 
RETURNS boolean AS $$ 
  DECLARE
	  surrounding geometry;
	  inpoly geometry;
	  query text;
	  fqtn text;
	  debug boolean;
  BEGIN
    debug = true;
	  -- Determine the complete name of the table
    fqtn := '';
    IF length(schemaname) > 0 THEN
      fqtn := quote_ident(schemaname) || '.';
    END IF;
    fqtn := fqtn || quote_ident(tablename);
    inpoly = ST_CollectionExtract(geom, 3);

    query = 'WITH polys AS (' ||
            '  SELECT ST_CollectionExtract(' || geomcolumnname || ', 3) geom ' ||
            '  FROM ' || fqtn ||
            '  WHERE NOT ST_Equals($1, b.geom) AND ST_Intersects(' || geomcolumnname || ', $1)';
    IF NOT filter IS NULL THEN
      query = query || ' AND ' || filter;
    END IF;
    query = query || ' ) SELECT ST_Union(ST_Intersection(ST_Boundary($2), b.geom)) border FROM polys b';
RAISE NOTICE 'ST_IsSurrounded() - query = %', query;

    EXECUTE query INTO surrounding USING geom, inpoly;

    RETURN CASE WHEN surrounding IS NULL THEN false
                ELSE ST_Equals(ST_Boundary(inpoly), ST_CollectionExtract(surrounding, 2))
           END;
    END; 
$$ LANGUAGE 'plpgsql' VOLATILE;
CREATE SCHEMA IF NOT EXISTS casfri50_coverage;
------------------------------------------------------------------------------
-- SK03
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
-- AB06
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
-- SK02
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
-- PE01
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
-- AB16
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
-- MB06 - 160218 - 1h10
DROP TABLE IF EXISTS casfri50_coverage.mb06;
CREATE TABLE casfri50_coverage.mb06 AS
SELECT ST_BufferedSmooth(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB06';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.mb06;
------------------------------------------------------------------------------
-- SK06 - 211482 - 8h35
DROP TABLE IF EXISTS casfri50_coverage.sk06;
CREATE TABLE casfri50_coverage.sk06 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK06';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.sk06;
------------------------------------------------------------------------------
-- YT02 - 231137 - 1h02
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
-- NT01 - 281388 - 37h32
DROP TABLE IF EXISTS casfri50_coverage.nt01;
CREATE TABLE casfri50_coverage.nt01 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT01';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.nt01;
------------------------------------------------------------------------------
-- NT02 - 320944 - testing
DROP TABLE IF EXISTS casfri50_coverage.nt02;
CREATE TABLE casfri50_coverage.nt02 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT02';
------------------------------------------------------------------------------
-- SK05 - 421977 - testing
DROP TABLE IF EXISTS casfri50_coverage.sk05;
CREATE TABLE casfri50_coverage.sk05 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK05';
------------------------------------------------------------------------------
-- MB05 - 514157 - testing
DROP TABLE IF EXISTS casfri50_coverage.mb05;
CREATE TABLE casfri50_coverage.mb05 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB05';
------------------------------------------------------------------------------
-- SK04 - 633522 - testing
DROP TABLE IF EXISTS casfri50_coverage.sk04;
CREATE TABLE casfri50_coverage.sk04 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK04';
------------------------------------------------------------------------------
-- NB01 - 927177 - testing
DROP TABLE IF EXISTS casfri50_coverage.nb01;
CREATE TABLE casfri50_coverage.nb01 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB01';
------------------------------------------------------------------------------
-- NS03 - 995886 - no
DROP TABLE IF EXISTS casfri50_coverage.ns03;
CREATE TABLE casfri50_coverage.ns03 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NS03';
------------------------------------------------------------------------------
-- NB02 - 1123893 - no
DROP TABLE IF EXISTS casfri50_coverage.nb02;
CREATE TABLE casfri50_coverage.nb02 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB02';
------------------------------------------------------------------------------
-- SK01 - 1501667 - no
DROP TABLE IF EXISTS casfri50_coverage.sk01;
CREATE TABLE casfri50_coverage.sk01 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK01';
------------------------------------------------------------------------------
-- ON02 - 3629072 - no
DROP TABLE IF EXISTS casfri50_coverage.sk03;
CREATE TABLE casfri50_coverage.on02 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'ON02';
------------------------------------------------------------------------------
-- BC08 - 4677411 - no
DROP TABLE IF EXISTS casfri50_coverage.bc08;
CREATE TABLE casfri50_coverage.bc08 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC08';
------------------------------------------------------------------------------
-- BC10 - 5151772 - no
DROP TABLE IF EXISTS casfri50_coverage.bc10;
CREATE TABLE casfri50_coverage.bc10 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_GeoHash(ST_Centroid(ST_Transform(geometry, 4269)))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC10';
