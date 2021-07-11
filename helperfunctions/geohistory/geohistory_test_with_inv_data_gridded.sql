------------------------------------------------------------------------------
-- CASFRI Sample workflow file for CASFRI v5 beta
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
-------------------------------------------------------------------------------
-- CAUTION! This test requires the versions of TT_RowIsValid() and 
-- TT_HasPrecedence() from the workflow 01_PrepareGeoHistory.sql file to be 
-- instanciated in order to work properly (not the one implemented in geohistory_test.sql)
---------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_history_test;
--------------------------------------------------------------------------------------
-- Sampling area NB1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb1_gridded;
CREATE TABLE casfri50_history_test.sampling_area_nb1_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_nb1
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_nb1_gridded_geom_idx ON casfri50_history_test.sampling_area_nb1_gridded USING gist(geometry);
CREATE INDEX sampling_area_nb1_gridded_casid_idx ON casfri50_history_test.sampling_area_nb1_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_nb1_gridded;

-- Generate history on gridded table - 796 rows, pg11: 1m09, pg13: 18s
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb1_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nb1_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_nb1_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_nb1_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nb1_gridded_history_new
-- WHERE valid_year_begin <= 2008 AND 2008 <= valid_year_end
-- WHERE valid_year_begin <= 2009 AND 2009 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
ORDER BY id, valid_year_begin;
*/

--------------------------------------------------------------------------------------
-- Sampling area NB2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb2_gridded;
CREATE TABLE casfri50_history_test.sampling_area_nb2_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_nb2
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_nb2_gridded_geom_idx ON casfri50_history_test.sampling_area_nb2_gridded USING gist(geometry);
CREATE INDEX sampling_area_nb2_gridded_casid_idx ON casfri50_history_test.sampling_area_nb2_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_nb2_gridded;

-- Generate history on gridded table - 6693 rows, pg11: 3m54, pg13: 45s
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb2_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nb2_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_nb2_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_nb2_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nb2_gridded_history_new
-- WHERE valid_year_begin <= 2003 AND 2003 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
-- WHERE valid_year_begin <= 2020 AND 2020 <= valid_year_end
ORDER BY id, valid_year_begin;
*/

--------------------------------------------------------------------------------------
-- Sampling area 'NT1'
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt1_gridded;
CREATE TABLE casfri50_history_test.sampling_area_nt1_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_nt1
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_nt1_gridded_geom_idx ON casfri50_history_test.sampling_area_nt1_gridded USING gist(geometry);
CREATE INDEX sampling_area_nt1_gridded_casid_idx ON casfri50_history_test.sampling_area_nt1_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_nt1_gridded;

-- Generate history on gridded table - 1253 rows, pg11: 1m36, pg13: 16s 
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt1_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nt1_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_nt1_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_nt1_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nt1_gridded_history_new
-- WHERE valid_year_begin <= 1960 AND 1960 <= valid_year_end
-- WHERE valid_year_begin <= 1980 AND 1980 <= valid_year_end
ORDER BY id, valid_year_begin;
*/

--------------------------------------------------------------------------------------
-- Sampling area 'NT2'
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt2_gridded;
CREATE TABLE casfri50_history_test.sampling_area_nt2_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_nt2
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_nt2_gridded_geom_idx ON casfri50_history_test.sampling_area_nt2_gridded USING gist(geometry);
CREATE INDEX sampling_area_nt2_gridded_casid_idx ON casfri50_history_test.sampling_area_nt2_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_nt2_gridded;

-- Generate history on gridded table - 1040 rows, pg11: 2m10, pg13: 22s 
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt2_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nt2_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_nt2_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_nt2_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nt2_gridded_history_new
-- WHERE valid_year_begin <= 2000 AND 2000 <= valid_year_end
-- WHERE valid_year_begin <= 2004 AND 2004 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
--------------------------------------------------------------------------------------
-- Sampling area BC1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc1_gridded;
CREATE TABLE casfri50_history_test.sampling_area_bc1_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_bc1
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_bc1_gridded_geom_idx ON casfri50_history_test.sampling_area_bc1_gridded USING gist(geometry);
CREATE INDEX sampling_area_bc1_gridded_casid_idx ON casfri50_history_test.sampling_area_bc1_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_bc1_gridded;

-- Generate history on gridded table - 6951 rows, pg13: 2m08
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc1_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_bc1_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_bc1_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_bc1_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_bc1_gridded_history_new
-- WHERE valid_year_begin <= 2004 AND 2004 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
-- WHERE valid_year_begin <= 2016 AND 2016 <= valid_year_end
-- WHERE valid_year_begin <= 2020 AND 2020 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
--------------------------------------------------------------------------------------
-- Sampling area BC2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc2_gridded;
CREATE TABLE casfri50_history_test.sampling_area_bc2_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_bc2
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_bc2_gridded_geom_idx ON casfri50_history_test.sampling_area_bc2_gridded USING gist(geometry);
CREATE INDEX sampling_area_bc2_gridded_casid_idx ON casfri50_history_test.sampling_area_bc2_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_bc2_gridded;

-- Generate history on gridded table - 9158 rows, pg13: 1m57
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc2_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_bc2_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_bc2_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_bc2_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_bc2_gridded_history_new
-- WHERE valid_year_begin <= 2000 AND 2000 <= valid_year_end
-- WHERE valid_year_begin <= 2015 AND 2015 <= valid_year_end
-- WHERE valid_year_begin <= 2017 AND 2017 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
--------------------------------------------------------------------------------------
-- Sampling area SK1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk1_gridded;
CREATE TABLE casfri50_history_test.sampling_area_sk1_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_sk1
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_sk1_gridded_geom_idx ON casfri50_history_test.sampling_area_sk1_gridded USING gist(geometry);
CREATE INDEX sampling_area_sk1_gridded_casid_idx ON casfri50_history_test.sampling_area_sk1_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_sk1_gridded;

-- Generate history on gridded table - 3688 rows, pg11: 1m17, pg13: 16s 
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk1_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk1_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_sk1_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_sk1_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk1_gridded_history_new
-- WHERE valid_year_begin <= 2000 AND 2000 <= valid_year_end
-- WHERE valid_year_begin <= 2002 AND 2002 <= valid_year_end
-- WHERE valid_year_begin <= 2015 AND 2015 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
--------------------------------------------------------------------------------------
-- Sampling area SK2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk2_gridded;
CREATE TABLE casfri50_history_test.sampling_area_sk2_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_sk2
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_sk2_gridded_geom_idx ON casfri50_history_test.sampling_area_sk2_gridded USING gist(geometry);
CREATE INDEX sampling_area_sk2_gridded_casid_idx ON casfri50_history_test.sampling_area_sk2_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_sk2_gridded;

-- Generate history on gridded table - 4617 rows, pg11: 2m33, pg13: 40s
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk2_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk2_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_sk2_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_sk2_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk2_gridded_history_new
-- WHERE valid_year_begin <= 1980 AND 1980 <= valid_year_end
-- WHERE valid_year_begin <= 2000 AND 2000 <= valid_year_end
-- WHERE valid_year_begin <= 2005 AND 2005 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
--------------------------------------------------------------------------------------
-- Sampling area SK3
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk3_gridded;
CREATE TABLE casfri50_history_test.sampling_area_sk3_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_sk3
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_sk3_gridded_geom_idx ON casfri50_history_test.sampling_area_sk3_gridded USING gist(geometry);
CREATE INDEX sampling_area_sk3_gridded_casid_idx ON casfri50_history_test.sampling_area_sk3_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_sk3_gridded;

-- Generate history on gridded table - 3462 rows, pg11: 1m41, pg13: 22s
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk3_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk3_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_sk3_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_sk3_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk3_gridded_history_new
-- WHERE valid_year_begin <= 1990 AND 1990 <= valid_year_end
-- WHERE valid_year_begin <= 2004 AND 2004 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
--------------------------------------------------------------------------------------
-- Sampling area SK4
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk4_gridded;
CREATE TABLE casfri50_history_test.sampling_area_sk4_gridded AS
SELECT inventory_id, cas_id, photo_year, (TT_SplitByGrid(geometry, 1000)).geom geometry
FROM casfri50_history_test.sampling_area_sk4
ORDER BY inventory_id, cas_id, photo_year, geometry;

CREATE INDEX sampling_area_sk4_gridded_geom_idx ON casfri50_history_test.sampling_area_sk4_gridded USING gist(geometry);
CREATE INDEX sampling_area_sk4_gridded_casid_idx ON casfri50_history_test.sampling_area_sk4_gridded USING btree(cas_id);

-- Display
--SELECT * FROM casfri50_history_test.sampling_area_sk4_gridded;

-- Generate history on gridded table - 4734 rows, pg11: 2m11, pg13: 28s 
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk4_gridded_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk4_gridded_history_new AS
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                               'casfri50_history_test', 'sampling_area_sk4_gridded', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
  FROM casfri50_history_test.sampling_area_sk4_gridded
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded
  GROUP BY id
)
SELECT id, lowerval valid_year_begin, upperval valid_year_end, ST_AsText(geom) wkt_geometry
FROM wkb_version
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk4_gridded_history_new
-- WHERE valid_year_begin <= 1990 AND 1990 <= valid_year_end
-- WHERE valid_year_begin <= 1998 AND 1998 <= valid_year_end
-- WHERE valid_year_begin <= 2004 AND 2004 <= valid_year_end
-- WHERE valid_year_begin <= 2010 AND 2010 <= valid_year_end
ORDER BY id, valid_year_begin;
*/
---------------------------------------------
-- Begin tests
---------------------------------------------
--SELECT * FROM (
SELECT '1.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nb1_gridded_history_new" and "sampling_area_nb1_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_nb1_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_nb1_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_nb1_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nb1_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nb1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nb1', TRUE) check_query
FROM TT_AreasForSignificantYears('nb1', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nb2_gridded_history_new" and "sampling_area_nb2_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_nb2_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_nb2_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_nb2_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nb2_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nb2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nb2', TRUE) check_query
FROM TT_AreasForSignificantYears('nb2', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nt1_gridded_history_new" and "sampling_area_nt1_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_nt1_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_nt1_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_nt1_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nt1_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nt1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nt1', TRUE) check_query
FROM TT_AreasForSignificantYears('nt1', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nt2_gridded_history_new" and "sampling_area_nt2_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_nt2_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_nt2_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_nt2_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nt2_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nt2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nt2', TRUE) check_query
FROM TT_AreasForSignificantYears('nt2', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_bc1_gridded_history_new" and "sampling_area_bc1_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_bc1_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_bc1_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_bc1_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_bc1_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_bc1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('bc1', TRUE) check_query
FROM TT_AreasForSignificantYears('bc1', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_bc2_gridded_history_new" and "sampling_area_bc2_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_bc2_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_bc2_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_bc2_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_bc2_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_bc2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('bc2', TRUE) check_query
FROM TT_AreasForSignificantYears('bc2', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk1_gridded_history_new" and "sampling_area_sk1_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_sk1_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_sk1_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_sk1_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk1_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk1', TRUE) check_query
FROM TT_AreasForSignificantYears('sk1', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk2_gridded_history_new" and "sampling_area_sk2_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_sk2_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_sk2_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_sk2_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk2_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk2', TRUE) check_query
FROM TT_AreasForSignificantYears('sk2', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk3_gridded_history_new" and "sampling_area_sk3_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_sk3_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_sk3_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_sk3_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk3_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk3_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk3', TRUE) check_query
FROM TT_AreasForSignificantYears('sk3', TRUE)
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk4_gridded_history_new" and "sampling_area_sk4_gridded_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'', ''sampling_area_sk4_gridded_history_new'', ''casfri50_history_test'', ''sampling_area_sk4_gridded_history'', ''id, valid_year_begin'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM casfri50_history_test.sampling_area_sk4_gridded_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk4_gridded_history b USING (id, valid_year_begin)) foo
---------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk4_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk4', TRUE) check_query
FROM TT_AreasForSignificantYears('sk4', TRUE)
---------------------------------------------------------
--) foo WHERE NOT passed;
