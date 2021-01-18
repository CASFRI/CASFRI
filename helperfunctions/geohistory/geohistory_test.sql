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
CREATE SCHEMA IF NOT EXISTS geohistory;
---------------------------------------------
-- Create a test table
-- 2,3 and 4 polygons test table below cover most of the test_0 table but we keep it in order to test very specific cases
DROP TABLE IF EXISTS geohistory.test_0 CASCADE;
CREATE TABLE geohistory.test_0 AS
SELECT 0 idx, 1998 valid_year, '1' att, ST_GeomFromText('POLYGON((24 13, 24 23, 34 23, 34 13, 24 13))') geom
UNION ALL
SELECT 1 idx, 2000 valid_year, '2' att, ST_GeomFromText('POLYGON((13 13, 13 23, 23 23, 23 13, 13 13))') geom
UNION ALL
SELECT 2 idx, 2010 valid_year, '3' att, ST_GeomFromText('POLYGON((9 19, 9 21, 11 21, 11 19, 9 19))') geom
UNION ALL
SELECT 3 idx, 2010 valid_year, '4' att, ST_GeomFromText('POLYGON((10 10, 10 20, 20 20, 20 10, 10 10))') geom
UNION ALL
SELECT 4 idx, 2020 valid_year, '5' att, ST_GeomFromText('POLYGON((7 7, 7 17, 17 17, 17 7, 7 7))') geom
UNION ALL
SELECT 5 idx, 1998 valid_year, '6' att, ST_GeomFromText('POLYGON((26 15, 26 19, 30 19, 30 15, 26 15))') geom
UNION ALL
SELECT 6 idx, 1998 valid_year, '7' att, ST_GeomFromText('POLYGON((25 14, 25 21, 32 21, 32 14, 25 14))') geom
;
------------------------------------------------------------------
-- TT_HasPrecedence()
--
-- Determine if the first polygon has precedence over the second one based on:
--
  -- 1) their inventory rank: an established priority rank among inventories 
  --    determines which polygon has priority.
  -- 2) their unique ID: when inventory ranks are equivalent for both polygons, 
  --    the polygon with the highest ID has priority.
  --
  -- numInv and numUid can be used to specify if inv1 and inv2 and uid1 and uid2 
  -- must be treated as numerical values. They both default to FALSE.
------------------------------------------------------------------
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
    refInv text = 'AA00';
    refUID text = 'A';
  BEGIN
    -- Assign default hardcoded values
    IF inv1 IS NULL THEN
      RAISE NOTICE 'TT_HasPrecedence() WARNING : inv1 for polygon ''%'' is NULL. Assigning %...', uid1, refInv;
      inv1 = refInv;
    END IF;
    IF inv2 IS NULL THEN
      RAISE NOTICE 'TT_HasPrecedence() WARNING : inv2 for polygon ''%'' is NULL. Assigning %...', uid2, refInv;
      inv2 = refInv;
    END IF;
    IF inv1 = inv2 THEN
      IF uid1 IS NULL THEN
        RAISE NOTICE 'TT_HasPrecedence() WARNING : uid1 is NULL. Assigning %...', refUID;
        uid1 = refUID;
      END IF;
      IF uid2 IS NULL THEN
        RAISE NOTICE 'TT_HasPrecedence() WARNING : uid2 is NULL. Assigning %...', refUID;
        uid2 = refUID;
      END IF;
      IF uid1 = uid2 THEN
        RAISE NOTICE 'TT_HasPrecedence() WARNING : uid1 and uid2 are equal (%). Can''t give precedence to a polygon. Returning FALSE...', uid1;
        RETURN FALSE;
      END IF;
    END IF;
IF inv1 != inv2 THEN
  RAISE NOTICE 'inv1 (%) % precedence over inv2 (%)', inv1, CASE WHEN (numInv AND inv1::decimal > inv2::decimal) OR (NOT numInv AND inv1 > inv2) 
                                                                  THEN 'has' ELSE 'does not have' END, inv2;
ELSE
  RAISE NOTICE 'uid1 (%) % precedence over uid2 (%)', uid1, CASE WHEN (numUid AND uid1::decimal > uid2::decimal) OR (NOT numUid AND uid1 > uid2) 
                                                     THEN 'has' ELSE 'does not have' END, uid2;
END IF;
      RETURN ((numInv AND inv1::decimal > inv2::decimal) OR (NOT numInv AND inv1 > inv2)) OR 
           (inv1 = inv2 AND ((numUid AND uid1::decimal > uid2::decimal) OR (NOT numUid AND uid1 > uid2)));
  END
$$ LANGUAGE plpgsql VOLATILE;

--SELECT TT_HasPrecedence(NULL, NULL, NULL, NULL); -- false
--SELECT TT_HasPrecedence('AB06', NULL, NULL, NULL); -- true
--SELECT TT_HasPrecedence('AB06', NULL, 'AB06', NULL); -- false
--SELECT TT_HasPrecedence('AB06', NULL, 'AB16', NULL); -- false
--SELECT TT_HasPrecedence('AB16', NULL, 'AB06', NULL); -- true
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', NULL); -- true
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AA'); -- false
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AB'); -- false
--SELECT TT_HasPrecedence('AB06', 'AB', 'AB06', 'AA'); -- true
--SELECT TT_HasPrecedence('AB06', '2', 'AB06', '3'); -- false
--SELECT TT_HasPrecedence('AB06', '3', 'AB06', '2'); -- true
--SELECT TT_HasPrecedence('2', '2', '13', '13');  -- true
--SELECT TT_HasPrecedence('2', '2', '13', '13', true, true); -- false
--SELECT TT_HasPrecedence('13', '2', '2', '13', true, true); -- true

--SELECT TT_HasPrecedence('1', '2', '1', '13', true, false); -- true
--SELECT TT_HasPrecedence('1', '13', '1', '2', true, false); -- false
--SELECT TT_HasPrecedence('1', '2', '1', '13', true, true); -- false
--SELECT TT_HasPrecedence('1', '13', '1', '2', true, true); -- true

-- Create a test table for TT_TableGeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_0_without_validity_new;
CREATE TABLE geohistory.test_0_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_0', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_0_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_0_without_validity_new;

-- Create a test table for TT_TableGeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_0_with_validity_new;
CREATE TABLE geohistory.test_0_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_0', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_0_with_validity_new 
ADD PRIMARY KEY (id, poly_id);

-- SELECT * FROM geohistory.test_0_with_validity_new;

---------------------------------------------
-- Display test table flat
SELECT idx, att, valid_year, 
       geom, ST_AsText(geom),
       idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_0;

-- Display oblique
SELECT idx, att, valid_year,
       TT_GeoOblique(geom, valid_year, 0.4, 0.4), 
       idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_0;

-- Display geohistory flat 

-- Without taking validity into account
SELECT * FROM geohistory.test_0_without_validity_new;

-- Taking validity into account
SELECT * FROM geohistory.test_0_with_validity_new;

-- Display geohistory oblique 

-- Without taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.4, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_0_without_validity_new;

-- Taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.4, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_0_with_validity_new;

---------------------------------------------
-- test_1 - Only one polygon
---------------------------------------------
DROP TABLE IF EXISTS geohistory.test_1 CASCADE;
CREATE TABLE geohistory.test_1 AS
WITH validities AS (
  SELECT 1 v_order, '' a1
  UNION ALL
  SELECT 2,         '1' a1
), all_tests AS (
  SELECT 1 idx1, a1, 2000 y1,
         ST_Buffer(ST_GeomFromText('POINT(0 0)'), sqrt(2.0), 1) geom
  FROM validities
  ORDER BY v_order
), numbered_tests AS (
  SELECT ROW_NUMBER() OVER() all_test_nb, *
  FROM all_tests
)
SELECT all_test_nb test, idx1 idx, a1 att, y1 valid_year,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), (all_test_nb - 1) * 6, 0) geom
FROM numbered_tests
ORDER BY test;

-- Display flat
SELECT *,
       idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_1;

-- Display oblique
SELECT TT_GeoOblique(geom, valid_year),
       idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_1;

-- Display flat history
SELECT * FROM TT_TableGeoHistory('geohistory', 'test_1', 'idx', 'geom', 'valid_year', 'idx');

-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique('geohistory', 'test_1', 'idx', 'geom', 'valid_year', 'idx');

---------------------------------------------
-- test_2 - Pairs of polygons representing 
-- all permutations of valid/invalid attributes, years and ids
---------------------------------------------
DROP TABLE IF EXISTS geohistory.test_2 CASCADE;
CREATE TABLE geohistory.test_2 AS
WITH validities AS (
  -- all permutations of validity for two polygons
  SELECT 1 v_order, '' a1, '' a2
  UNION ALL
  SELECT 2,         '' a1, '1' a2
  UNION ALL
  SELECT 3,         '1' a1, '' a2
  UNION ALL
  SELECT 4,         '1' a1, '1' a2
), years AS (
  -- all permutations of years for two polygons
  SELECT 1 y_order, 2000 y1, 2000 y2
  UNION ALL
  SELECT 2,         2000 y1, 2010 y2
), ids AS (
  -- all permutations of ids for two polygons
  SELECT 0 idx1, 1 idx2
  UNION ALL
  SELECT 1 idx1, 0 idx2
), all_tests AS (
  SELECT idx1, idx2, a1, a2, y1, y2,
         -- generate a square that will have to be rotated later
         ST_Buffer(ST_GeomFromText('POINT(0 0)'), sqrt(2.0), 1) geom
  FROM validities, years, ids
  -- order them by year, validities and ids so they are numbered properly later
  ORDER BY y_order, v_order, idx1
), numbered_tests AS (
  SELECT ROW_NUMBER() OVER() - 1 all_test_nb, *
  FROM all_tests
)
-- Generate the first square with the first set of values.
-- Square are rotated arounf their centroid and snapped to a 
-- grid so that its coordinates becomes integers.
SELECT all_test_nb test, idx1 + all_test_nb * 2 idx, a1 att, y1 valid_year,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 8) * 10, (all_test_nb  / 8) * 20) geom
FROM numbered_tests
UNION ALL
-- Generate the second square with the second set of values 
-- (a little bit translated to the upper right)
SELECT all_test_nb, idx2 + all_test_nb * 2, a2, y2,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 8) * 10 + 1, (all_test_nb / 8) * 20 + 1) geom
FROM numbered_tests
ORDER BY test, idx;

-- SELECT * FROM geohistory.test_2;

-- Create a test table for TT_TableGeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_2_without_validity_new;
CREATE TABLE geohistory.test_2_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_2', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_2_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_2_without_validity_new;

-- Create a test table for TT_TableGeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_2_with_validity_new;
CREATE TABLE geohistory.test_2_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_2', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_2_with_validity_new 
ADD PRIMARY KEY (id, poly_id);

-- SELECT * FROM geohistory.test_2_with_validity_new;

---------------------------------------------
-- Display test table flat
SELECT test, idx, att, valid_year, 
       geom, ST_AsText(geom),
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_2;

-- Display oblique
SELECT test, idx, att, valid_year,
       TT_GeoOblique(geom, valid_year, 0.2, 0.4), 
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_2;

-- Display geohistory flat 

-- Without taking validity into account
SELECT * FROM geohistory.test_2_without_validity_new;

-- Taking validity into account
SELECT * FROM geohistory.test_2_with_validity_new;

-- Display geohistory oblique 

-- Without taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.2, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_2_without_validity_new;

-- Taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.2, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_2_with_validity_new;

---------------------------------------------
-- test_3 - Triplet of polygons representing
-- all permutations of valid/invalid attributes, years and ids
---------------------------------------------
DROP TABLE IF EXISTS geohistory.test_3 CASCADE;
CREATE TABLE geohistory.test_3 AS
WITH validities AS (
  -- all permutations of validity for three polygons
  SELECT 1 v_order, '' a1, '' a2, '' a3
  UNION ALL
  SELECT 2,         '' a1, '' a2, '1' a3
  UNION ALL
  SELECT 3,         '' a1, '1' a2, '' a3
  UNION ALL
  SELECT 4,         '' a1, '1' a2, '1' a3
  UNION ALL
  SELECT 5,         '1' a1, '' a2, '' a3
  UNION ALL
  SELECT 6,         '1' a1, '' a2, '1' a3
  UNION ALL
  SELECT 7,         '1' a1, '1' a2, '' a3
  UNION ALL
  SELECT 8,         '1' a1, '1' a2, '1' a3
), years AS (
  -- all permutations of years for three polygons
  SELECT 1 y_order, 2000 y1, 2000 y2, 2000 y3
  UNION ALL
  SELECT 2,         2000 y1, 2000 y2, 2010 y3
  UNION ALL
  SELECT 3,         2000 y1, 2010 y2, 2010 y3
  UNION ALL
  SELECT 4,         2000 y1, 2010 y2, 2020 y3
), ids AS (
  -- all permutations of ids for three polygons
  SELECT 1 i_order, 0 idx1, 1 idx2, 2 idx3
  UNION ALL
  SELECT 2,         0 idx1, 2 idx2, 1 idx3
  UNION ALL
  SELECT 3,         1 idx1, 0 idx2, 2 idx3
  UNION ALL
  SELECT 4,         1 idx1, 2 idx2, 0 idx3
  UNION ALL
  SELECT 5,         2 idx1, 0 idx2, 1 idx3
  UNION ALL
  SELECT 6,         2 idx1, 1 idx2, 0 idx3
), all_tests AS (
  SELECT y_order, v_order, i_order,
         idx1, idx2, idx3, a1, a2, a3, y1, y2, y3,
         -- generate a square that will have to be rotated later
         ST_Buffer(ST_GeomFromText('POINT(0 0)'), 2*sqrt(2.0), 1) geom
  FROM validities, years, ids
  -- order them by year, validities and ids so they are numbered properly later
  ORDER BY y_order, v_order, i_order
), numbered_tests AS (
  SELECT ROW_NUMBER() OVER() - 1 all_test_nb, *
  FROM all_tests
  ORDER BY y_order, v_order, i_order
)
-- Generate the first square with the first set of values.
-- Squares are rotated around their centroids and snapped to a 
-- grid so that their coordinates become integers.
SELECT all_test_nb test, idx1 + all_test_nb * 3 idx, a1 att, y1 valid_year,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 6) * 16, (all_test_nb / 6) * 30) geom
FROM numbered_tests
UNION ALL
-- Generate the second square with the second set of values 
-- (a little bit translated to the upper right)
SELECT all_test_nb, idx2 + all_test_nb * 3, a2, y2,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 6) * 16 + 1, (all_test_nb / 6) * 30 + 2) geom
FROM numbered_tests
UNION ALL
-- Generate the third square with the third set of values 
-- (a little bit translated to the right in between the two first squares so that the three intersects)
SELECT all_test_nb, idx3 + all_test_nb * 3, a3, y3,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 6) * 16 + 2, (all_test_nb / 6) * 30 + 1) geom
FROM numbered_tests
ORDER BY test, idx;

-- SELECT * FROM geohistory.test_3;

-- Create a test table for TT_TableGeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_3_without_validity_new;
CREATE TABLE geohistory.test_3_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_3', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_3_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_3_without_validity_new;

-- Create a test table for TT_TableGeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_3_with_validity_new;
CREATE TABLE geohistory.test_3_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_3', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_3_with_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);

-- SELECT * FROM geohistory.test_3_with_validity_new;

---------------------------------------------
-- Display test table flat
SELECT test, idx, att, valid_year, 
       geom, ST_AsText(geom),
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_3;

-- Display oblique
SELECT test, idx, att, valid_year,
       TT_GeoOblique(geom, valid_year, 0.2, 0.4), 
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_3;

-- Display geohistory flat 

-- Without taking validity into account
SELECT * FROM geohistory.test_3_without_validity_new;

-- Taking validity into account
SELECT * FROM geohistory.test_3_with_validity_new;

-- Display geohistory oblique 

-- Without taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.2, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_3_without_validity_new;

-- Taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.2, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_3_with_validity_new;

---------------------------------------------
-- test_4 - Quatriplet of polygons representing
-- all permutations of valid/invalid attributes, years and ids
---------------------------------------------
DROP TABLE IF EXISTS geohistory.test_4 CASCADE;
CREATE TABLE geohistory.test_4 AS
WITH validities AS (
  -- all permutations of validity for three polygons
  SELECT 1 v_order, '' a1, '' a2, '' a3, '' a4
  UNION ALL
  SELECT 2,         '' a1, '' a2, '' a3, '1' a4
  UNION ALL
  SELECT 3,         '' a1, '' a2, '1' a3, '' a4
  UNION ALL
  SELECT 4,         '' a1, '' a2, '1' a3, '1' a4
  UNION ALL
  SELECT 5,         '' a1, '1' a2, '' a3, '' a4
  UNION ALL
  SELECT 6,         '' a1, '1' a2, '' a3, '1' a4
  UNION ALL
  SELECT 7,         '' a1, '1' a2, '1' a3, '' a4
  UNION ALL
  SELECT 8,         '' a1, '1' a2, '1' a3, '1' a4
  UNION ALL
  SELECT 9,         '1' a1, '' a2, '' a3, '' a4
  UNION ALL
  SELECT 10,        '1' a1, '' a2, '' a3, '1' a4
  UNION ALL
  SELECT 11,        '1' a1, '' a2, '1' a3, '' a4
  UNION ALL
  SELECT 12,        '1' a1, '' a2, '1' a3, '1' a4
  UNION ALL
  SELECT 13,        '1' a1, '1' a2, '' a3, '' a4
  UNION ALL
  SELECT 14,        '1' a1, '1' a2, '' a3, '1' a4
  UNION ALL
  SELECT 15,        '1' a1, '1' a2, '1' a3, '' a4
  UNION ALL
  SELECT 16,        '1' a1, '1' a2, '1' a3, '1' a4
), years AS (
  -- all permutations of years for three polygons
  SELECT 1 y_order, 1990 y1, 1990 y2, 1990 y3, 1990 y4
  UNION ALL
  SELECT 2,         1990 y1, 1990 y2, 1990 y3, 2000 y4
  UNION ALL
  SELECT 3,         1990 y1, 1990 y2, 2000 y3, 2000 y4
  UNION ALL
  SELECT 4,         1990 y1, 1990 y2, 2000 y3, 2010 y4
  UNION ALL
  SELECT 5,         1990 y1, 2000 y2, 2000 y3, 2000 y4
  UNION ALL
  SELECT 6,         1990 y1, 2000 y2, 2000 y3, 2010 y4
  UNION ALL
  SELECT 7,         1990 y1, 2000 y2, 2010 y3, 2010 y4
  UNION ALL
  SELECT 8,         1990 y1, 2000 y2, 2010 y3, 2020 y4
), ids AS (
  -- all permutations of ids for three polygons
  SELECT 1 i_order, 0 idx1, 1 idx2, 2 idx3, 3 idx4
  UNION ALL
  SELECT 2,         0 idx1, 1 idx2, 3 idx3, 2 idx4
  UNION ALL
  SELECT 3,         0 idx1, 2 idx2, 1 idx3, 3 idx4
  UNION ALL
  SELECT 4,         0 idx1, 2 idx2, 3 idx3, 1 idx4
  UNION ALL
  SELECT 5,         0 idx1, 3 idx2, 1 idx3, 2 idx4
  UNION ALL
  SELECT 6,         0 idx1, 3 idx2, 2 idx3, 1 idx4
  UNION ALL
  SELECT 7,         1 idx1, 0 idx2, 2 idx3, 3 idx4
  UNION ALL
  SELECT 8,         1 idx1, 0 idx2, 3 idx3, 2 idx4
  UNION ALL
  SELECT 9,         1 idx1, 2 idx2, 0 idx3, 3 idx4
  UNION ALL
  SELECT 10,        1 idx1, 2 idx2, 3 idx3, 0 idx4
  UNION ALL
  SELECT 11,        1 idx1, 3 idx2, 0 idx3, 2 idx4
  UNION ALL
  SELECT 12,        1 idx1, 3 idx2, 2 idx3, 0 idx4
  UNION ALL
  SELECT 13,        2 idx1, 0 idx2, 1 idx3, 3 idx4
  UNION ALL
  SELECT 14,        2 idx1, 0 idx2, 3 idx3, 1 idx4
  UNION ALL
  SELECT 15,        2 idx1, 1 idx2, 0 idx3, 3 idx4
  UNION ALL
  SELECT 16,        2 idx1, 1 idx2, 3 idx3, 0 idx4
  UNION ALL
  SELECT 17,        2 idx1, 3 idx2, 0 idx3, 1 idx4
  UNION ALL
  SELECT 18,        2 idx1, 3 idx2, 1 idx3, 0 idx4
  UNION ALL
  SELECT 19,        3 idx1, 0 idx2, 1 idx3, 2 idx4
  UNION ALL
  SELECT 20,        3 idx1, 0 idx2, 2 idx3, 1 idx4
  UNION ALL
  SELECT 21,        3 idx1, 1 idx2, 0 idx3, 2 idx4
  UNION ALL
  SELECT 22,        3 idx1, 1 idx2, 2 idx3, 0 idx4
  UNION ALL
  SELECT 23,        3 idx1, 2 idx2, 0 idx3, 1 idx4
  UNION ALL
  SELECT 24,        3 idx1, 2 idx2, 1 idx3, 0 idx4
), all_tests AS (
  SELECT y_order, v_order, i_order,
         idx1, idx2, idx3, idx4, a1, a2, a3, a4, y1, y2, y3, y4,
         -- Generate a square that will have to be rotated later
         ST_Buffer(ST_GeomFromText('POINT(0 0)'), 2*sqrt(2.0), 1) geom
  FROM validities, years, ids
  -- Order them by year, validities and ids so they are numbered properly later
  ORDER BY y_order, v_order, i_order
), numbered_tests AS (
  SELECT ROW_NUMBER() OVER() - 1 all_test_nb, *
  FROM all_tests
  ORDER BY y_order, v_order, i_order
)
-- Generate the first square with the first set of values.
-- Squares are rotated around their centroids and snapped to a 
-- grid so that their coordinates become integers.
SELECT all_test_nb test, idx1 + all_test_nb * 4 idx, a1 att, y1 valid_year,
       ST_Translate(ST_Scale(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), 1, 2.5), mod(all_test_nb, 24) * 25, (all_test_nb / 24) * 50) geom
FROM numbered_tests
UNION ALL
-- Generate the second square with the second set of values 
-- (a little bit translated to the upper right)
SELECT all_test_nb, idx2 + all_test_nb * 4, a2, y2,
       ST_Translate(ST_Scale(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), 1, 2), mod(all_test_nb, 24) * 25 + 2, (all_test_nb / 24) * 50 + 1) geom
FROM numbered_tests
UNION ALL
-- Generate the third square with the third set of values 
-- (a little bit translated to the right in between the two first squares so that the three intersects)
SELECT all_test_nb, idx3 + all_test_nb * 4, a3, y3,
       ST_Translate(ST_Scale(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), 2, 1), mod(all_test_nb, 24) * 25 + 2, (all_test_nb / 24) * 50 + 2) geom
FROM numbered_tests
UNION ALL
-- Generate the fourth square with the fourth set of values 
-- (a little bit translated to the right in between the two first squares so that the three intersects)
SELECT all_test_nb, idx4 + all_test_nb * 4, a4, y4,
       ST_Translate(ST_Scale(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), 2.5, 1), mod(all_test_nb, 24) * 25 + 3, (all_test_nb / 24) * 50 + 3) geom
FROM numbered_tests
ORDER BY test, idx;

CREATE INDEX test_4_idx_idx
  ON geohistory.test_4 USING btree(idx);

CREATE INDEX test_4_geom_idx
  ON geohistory.test_4 USING gist(geom);

-- SELECT * FROM geohistory.test_4;

-- Create a test table for TT_TableGeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_4_without_validity_new;
CREATE TABLE geohistory.test_4_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_4', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_4_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_4_without_validity_new;

-- Create a test table for TT_TableGeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_4_with_validity_new;
CREATE TABLE geohistory.test_4_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_TableGeoHistory('geohistory', 'test_4', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_4_with_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);

-- SELECT * FROM geohistory.test_4_with_validity_new;

---------------------------------------------
-- Display test table flat
SELECT test, idx, att, valid_year, 
       geom, ST_AsText(geom),
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_4;

-- Display oblique
SELECT test, idx, att, valid_year,
       TT_GeoOblique(geom, valid_year, 0.4, 0.4), 
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM geohistory.test_4;

-- Display geohistory flat 

-- Without taking validity into account
SELECT * FROM geohistory.test_4_without_validity_new;

-- Taking validity into account
SELECT * FROM geohistory.test_4_with_validity_new;

-- Display geohistory oblique 

-- Without taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.4, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_4_without_validity_new;

-- Taking validity into account
SELECT row_id, id, poly_id, isvalid, 
       TT_GeoOblique(ST_GeomFromText(wkt_geometry), valid_year_begin, 0.4, 0.4) wkb_geometry, 
       poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
FROM geohistory.test_4_with_validity_new;

---------------------------------------------
-- Debug procedure
---------------------------------------------
-- -- 1) Create a view limiting polygon to the ones 
-- --    in the same test as the faulty polygon
-- CREATE OR REPLACE VIEW geohistory.test_bug AS
-- SELECT * FROM geohistory.test_3
-- WHERE test = (SELECT test FROM geohistory.test_3 WHERE idx = 144);

-- SELECT * FROM geohistory.test_bug;

-- -- 2) Modify the WHERE clause of TT_TableGeoHistory() currentPolyQuery to 
-- --    ' WHERE ' || quote_ident(idColName) || '::text = ''144'' '
-- --    and activate the RAISE NOTICEs

-- -- 3) Run this query
-- SELECT *
-- FROM TT_TableGeoHistory('geohistory', 'test_bug', 'idx', 'geom', 'valid_year', 'idx');

---------------------------------------------
-- Begin tests
---------------------------------------------
SELECT * FROM (
SELECT '1.1'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_0_without_validity_new" and "test_0_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_0_without_validity_new'', ''geohistory'' , ''test_0_without_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_0_without_validity_new a 
      FULL OUTER JOIN geohistory.test_0_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_0_with_validity_new" and "test_0_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_0_with_validity_new'', ''geohistory'' , ''test_0_with_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_0_without_validity_new a 
      FULL OUTER JOIN geohistory.test_0_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_TableGeoHistory'::text function_tested,
       'Two single polygons'::text description,
       string_agg(ST_AsText(wkb_geometry), ', ') = 'MULTIPOLYGON(((1 1,1 -1,-1 -1,-1 1,1 1))), MULTIPOLYGON(((7 1,7 -1,5 -1,5 1,7 1)))' AND
       string_agg(ref_year::text, ', ') = '2000, 2000' AND
       string_agg(valid_year_begin::text, ', ') = '1930, 1930' AND 
       string_agg(valid_year_end::text, ', ') = '2030, 2030' passed,
        '' check_query
FROM TT_TableGeoHistory('geohistory', 'test_1', 'idx', 'geom', 'valid_year', 'idx')
---------------------------------------------------------
-- Compare new with old tables
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_2_without_validity_new" and "test_2_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_2_without_validity_new'', ''geohistory'' , ''test_2_without_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_2_without_validity_new a 
      FULL OUTER JOIN geohistory.test_2_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_2_with_validity_new" and "test_2_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_2_with_validity_new'', ''geohistory'' , ''test_2_with_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_2_without_validity_new a 
      FULL OUTER JOIN geohistory.test_2_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_3_without_validity_new" and "test_3_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_3_without_validity_new'', ''geohistory'' , ''test_3_without_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_3_without_validity_new a 
      FULL OUTER JOIN geohistory.test_3_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_3_with_validity_new" and "test_3_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_3_with_validity_new'', ''geohistory'' , ''test_3_with_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_3_without_validity_new a 
      FULL OUTER JOIN geohistory.test_3_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_4_without_validity_new" and "test_4_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_4_without_validity_new'', ''geohistory'' , ''test_4_without_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_4_without_validity_new a 
      FULL OUTER JOIN geohistory.test_4_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_TableGeoHistory'::text function_tested, 
       'Compare "test_4_with_validity_new" and "test_4_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_4_with_validity_new'', ''geohistory'' , ''test_4_with_validity'', ''row_id'', TRUE, TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b), TRUE)).*
      FROM geohistory.test_4_without_validity_new a 
      FULL OUTER JOIN geohistory.test_4_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_ValidYearUnion'::text function_tested, 
       'NULL values' description, 
       TT_ValidYearUnion(NUll, NULL, NULL) = '{}'::geomlowuppval[] passed,
       '' check_query
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_ValidYearUnion'::text function_tested, 
       'Badly ordered values' description, 
       TT_IsError('SELECT TT_ValidYearUnion(ST_GeomFromText(''POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))''), 2010, 2000)') = 'TT_ValidYearUnion() ERROR: Lower value is higher than higher value...' passed,
       '' check_query
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_ValidYearUnion'::text function_tested, 
       'Simple, unique non-NULL values' description, 
       TT_ValidYearUnion(ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'), 2000, 2000) = ARRAY[(ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))'), 2000, 2000)]::geomlowuppval[] passed,
       '' check_query
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2005 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.4'::text number,
        'TT_ValidYearUnion'::text function_tested, 
       'Mutually exclusive year ranges. Case 333' description, 
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval,
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2005 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2020 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2005 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.5'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Same as previous (6.4) but in reverse order. Case 444.1' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval,
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2005 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2020 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2010 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.6'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Overlapping year ranges. Case 777' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval,
        --ST_AsText((vyu)[3].geom), (vyu)[3].lowerval, (vyu)[3].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        ST_Equals((vyu)[3].geom, ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2009 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2010 AND
        (vyu)[3].lowerval = 2011 AND (vyu)[3].upperval = 2020 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2010 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.7'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Same as previous (6.6) but in reverse order. Case 444.2' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval,
        --ST_AsText((vyu)[3].geom), (vyu)[3].lowerval, (vyu)[3].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        ST_Equals((vyu)[3].geom, ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2009 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2010 AND
        (vyu)[3].lowerval = 2011 AND (vyu)[3].upperval = 2020 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2020 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.8'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Overlapping year ranges (the second finishing when the first finishes) Case 444.3' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2009 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2020 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2020 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.9'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Same as previous (6.8) but in reverse order. Case 666.2' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2009 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2020 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2030 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.10'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Overlapping year ranges (the second finishing after the first finishes) Case 444.3' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval
        --ST_AsText((vyu)[3].geom), (vyu)[3].lowerval, (vyu)[3].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        ST_Equals((vyu)[3].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2009 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2020 AND
        (vyu)[3].lowerval = 2021 AND (vyu)[3].upperval = 2030 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2000 lowerval, 2030 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2020 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.11'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Same as previous (6.10) but in reverse order. Case 666.1' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval
        --ST_AsText((vyu)[3].geom), (vyu)[3].lowerval, (vyu)[3].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        ST_Equals((vyu)[3].geom, ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))')) AND
        (vyu)[1].lowerval = 2000 AND (vyu)[1].upperval = 2009 AND
        (vyu)[2].lowerval = 2010 AND (vyu)[2].upperval = 2020 AND
        (vyu)[3].lowerval = 2021 AND (vyu)[3].upperval = 2030 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2030 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2010 lowerval, 2020 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.12'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Overlapping year ranges (the new one finishing before the second finishes) Case 555.1' description,
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))')) AND
        (vyu)[1].lowerval = 2010 AND (vyu)[1].upperval = 2020 AND
        (vyu)[2].lowerval = 2021 AND (vyu)[2].upperval = 2030 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
UNION ALL
(WITH polys AS (
   SELECT ST_GeomFromText('POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))') geom, 2010 lowerval, 2020 upperval
   UNION ALL
   SELECT ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))') geom, 2010 lowerval, 2030 upperval
 ), validyearunion AS (
   SELECT TT_ValidYearUnion(geom, lowerval, upperval) vyu
   FROM polys
 )
 SELECT '6.13'::text number,
        'TT_ValidYearUnion'::text function_tested, 
        'Same as previous (6.12) but in reverse order. Case 555.2' description, 
        --ST_AsText((vyu)[1].geom), (vyu)[1].lowerval, (vyu)[1].upperval,
        --ST_AsText((vyu)[2].geom), (vyu)[2].lowerval, (vyu)[2].upperval
        ST_Equals((vyu)[1].geom, ST_GeomFromText('POLYGON((0 1,1 1,2 1,2 0,1 0,0 0,0 1))')) AND
        ST_Equals((vyu)[2].geom, ST_GeomFromText('POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))')) AND
        (vyu)[1].lowerval = 2010 AND (vyu)[1].upperval = 2020 AND
        (vyu)[2].lowerval = 2021 AND (vyu)[2].upperval = 2030 passed,
        '' check_query
 FROM validyearunion
)
---------------------------------------------------------
) foo WHERE NOT passed;
