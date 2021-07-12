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
CREATE SCHEMA IF NOT EXISTS casfri50_history_test;
------------------------------------------------------------------------------
-- Create a table of inventory precedence rank. Polygons from inventories with 
-- higher ranks have precedence over polygons from inventories having lower 
-- ranks. 
-- This table is used by TT_HasPrecedence() to establish a precedence when two 
-- overlapping polygons have
--
--   1) the same photo_year and
--   2) all their attributes are meaningful (not NULL or '')
--
-- Inventory precedence rank is hence the third criteria when deciding which 
-- polygon has precedence over the other one when they are overlapping. This 
-- criteria is evidently useful only when two polygons are from two different 
-- overlapping inventories. Otherwise more recent polygons and more meaningful 
-- ones have precedence over older ones and less meaningful ones. The fourth 
-- criteria, if all other are equal or equivalent, is the unique identifier 
-- of the two polygons with polygons having higher ids having precedence over 
-- polygons having lower ones.
------------------------------------------------------------------------------
DROP TABLE IF EXISTS casfri50_history.inv_precedence;
CREATE TABLE casfri50_history.inv_precedence AS 
SELECT 'AB03' inv, 3 rank
UNION ALL
SELECT 'AB06', 6
UNION ALL
SELECT 'AB07', 7
UNION ALL
SELECT 'AB08', 8
UNION ALL
SELECT 'AB10', 10
UNION ALL
SELECT 'AB11', 11
UNION ALL
SELECT 'AB16', 16
UNION ALL
SELECT 'AB25', 25
UNION ALL
SELECT 'AB29', 29
UNION ALL
SELECT 'AB30', 30
UNION ALL
SELECT 'BC08', 8
UNION ALL
SELECT 'BC10', 10
UNION ALL
SELECT 'BC11', 11
UNION ALL
SELECT 'BC12', 12
UNION ALL
SELECT 'MB01', 1
UNION ALL
SELECT 'MB02', 2
UNION ALL
SELECT 'MB04', 4
UNION ALL
SELECT 'MB05', 5
UNION ALL
SELECT 'MB06', 6
UNION ALL
SELECT 'MB07', 7
UNION ALL
SELECT 'NB01', 1
UNION ALL
SELECT 'NB02', 2
UNION ALL
SELECT 'NL01', 1
UNION ALL
SELECT 'NS01', 1
UNION ALL
SELECT 'NS02', 2
UNION ALL
SELECT 'NS03', 3
UNION ALL
SELECT 'NT01', 1
UNION ALL
SELECT 'NT03', 3
UNION ALL
SELECT 'ON01', 1
UNION ALL
SELECT 'ON02', 2
UNION ALL
SELECT 'PC01', 1
UNION ALL
SELECT 'PC02', 2
UNION ALL
SELECT 'PE01', 1
UNION ALL
SELECT 'QC01', 1
UNION ALL
SELECT 'QC02', 2
UNION ALL
SELECT 'QC03', 3
UNION ALL
SELECT 'QC04', 4
UNION ALL
SELECT 'QC05', 5
UNION ALL
SELECT 'QC06', 6
UNION ALL
SELECT 'QC07', 7
UNION ALL
SELECT 'SK01', 1
UNION ALL
SELECT 'SK02', 2
UNION ALL
SELECT 'SK03', 3
UNION ALL
SELECT 'SK04', 5
UNION ALL
SELECT 'SK05', 4 -- SK05 has lower precedence than SK04
UNION ALL
SELECT 'SK06', 6
UNION ALL
SELECT 'YT01', 1
UNION ALL
SELECT 'YT02', 2
UNION ALL
SELECT 'YT03', 3;

-- Overwrite development and test TT_HasPrecedence() function to something
-- more simple and efficient taking inventory precedence into account as 
-- numbers and uid as text. Both are never NULLs. numInv and numUid are ignored.
DROP FUNCTION IF EXISTS TT_HasPrecedence(text, text, text, text, boolean, boolean);
CREATE OR REPLACE FUNCTION TT_HasPrecedence(
  inv1 text, 
  uid1 text,
  inv2 text,
  uid2 text,
  numInv boolean DEFAULT FALSE,
  numUid boolean DEFAULT FALSE
)
RETURNS boolean AS $$
  DECLARE
    inv1_num int = 0;
    inv2_num int = 0;
  BEGIN
    IF inv1 != inv2 THEN
      SELECT rank FROM casfri50_history.inv_precedence WHERE inv = inv1 INTO inv1_num;
      SELECT rank FROM casfri50_history.inv_precedence WHERE inv = inv2 INTO inv2_num;
    END IF;
    RETURN inv1_num > inv2_num OR (inv1_num = inv2_num AND uid1 > uid2);
  END
$$ LANGUAGE plpgsql IMMUTABLE;

--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AA'); -- false
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AB'); -- false
--SELECT TT_HasPrecedence('AB06', 'AB', 'AB06', 'AA'); -- true
--SELECT TT_HasPrecedence('AB06', '2', 'AB06', '3'); -- false
--SELECT TT_HasPrecedence('AB06', '3', 'AB06', '2'); -- true
--SELECT TT_HasPrecedence('AB06', '3', 'AB16', '3'); -- false
--SELECT TT_HasPrecedence('AB06', '3', 'AB16', '2'); -- false
--SELECT TT_HasPrecedence('AB16', '3', 'AB06', '3'); -- true
--SELECT TT_HasPrecedence('AB16', '3', 'AB06', '2'); -- true
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
