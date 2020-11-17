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
-- SK03 - 645 - 1m05
DROP TABLE IF EXISTS casfri50_coverage.sk03_bu_10_10;
CREATE TABLE casfri50_coverage.sk03_bu_10_10 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK03';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.sk03;
------------------------------------------------------------------------------
-- AB06 - 11484 - 2m13
DROP TABLE IF EXISTS casfri50_coverage.ab06;
CREATE TABLE casfri50_coverage.ab06 AS
SELECT ST_BufferedUnion(geometry, 10, 10 ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB06';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.ab06;
------------------------------------------------------------------------------
-- SK02
-- Best method is ST_Union(). Returns 19858 points in 4m08
DROP TABLE IF EXISTS casfri50_coverage.sk02;
CREATE TABLE casfri50_coverage.sk02 AS
SELECT ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK02';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.sk02;
------------------------------------------------------------------------------
-- PE01 - 107220 - 12m06
DROP TABLE IF EXISTS casfri50_coverage.pe01;
CREATE TABLE casfri50_coverage.pe01 AS
SELECT ST_BufferedSmooth(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'PE01';

SELECT ST_NPoints(geometry) nb
FROM casfri50_coverage.pe01;
------------------------------------------------------------------------------
-- AB16 - 120476 - 30m
DROP TABLE IF EXISTS casfri50_coverage.ab16;
CREATE TABLE casfri50_coverage.ab16 AS
SELECT ST_BufferedSmooth(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB16';

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
DROP TABLE IF EXISTS casfri50_coverage.yt02;
CREATE TABLE casfri50_coverage.yt02 AS
SELECT ST_BufferedSmooth(ST_Union(geometry ORDER BY ST_X(ST_Centroid(geometry)), ST_Y(ST_Centroid(geometry))), 10) geometry
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'YT02';

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
