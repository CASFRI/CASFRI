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

-- Display flat
SELECT *, 
       idx || '_' || valid_year lbl 
FROM geohistory.test_0;

-- Display oblique
SELECT TT_GeoOblique(geom, valid_year), 
       idx || '_' || valid_year lbl 
FROM geohistory.test_0;

-- Display flat history
SELECT * FROM TT_GeoHistory('geohistory', 'test_0', 'idx', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistory2('geohistory', 'test_0', 'idx', 'geom', 'valid_year', 'idx');

-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique('geohistory', 'test_0', 'idx', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistoryOblique2('geohistory', 'test_0', 'idx', 'geom', 'valid_year', 'idx');

CREATE VIEW geohistory.test_0_0 AS
SELECT * FROM geohistory.test_0
WHERE idx = 0;

CREATE VIEW geohistory.test_0_1_3 AS
SELECT * FROM geohistory.test_0
WHERE idx = 1 OR idx = 3;

CREATE VIEW geohistory.test_0_2_3 AS
SELECT * FROM geohistory.test_0
WHERE idx = 2 OR idx = 3;

CREATE VIEW geohistory.test_0_0_5 AS
SELECT * FROM geohistory.test_0
WHERE idx = 0 OR idx = 5;

CREATE VIEW geohistory.test_0_5_6 AS
SELECT * FROM geohistory.test_0
WHERE idx = 5 OR idx = 6;

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
SELECT * FROM TT_GeoHistory2('geohistory', 'test_1', 'idx', 'geom', 'valid_year', 'idx');

-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique2('geohistory', 'test_1', 'idx', 'geom', 'valid_year', 'idx');

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

-- Create a test table for TT_GeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_2_without_validity_new;
CREATE TABLE geohistory.test_2_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory2('geohistory', 'test_2', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_2_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_2_without_validity_new;

-- Create a test table for TT_GeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_2_with_validity_new;
CREATE TABLE geohistory.test_2_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory2('geohistory', 'test_2', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
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
FROM geohistory.test_2_without_validity_new;

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

-- Create a test table for TT_GeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_3_without_validity_new;
CREATE TABLE geohistory.test_3_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory2('geohistory', 'test_3', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_3_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_3_without_validity_new;

-- Create a test table for TT_GeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_3_with_validity_new;
CREATE TABLE geohistory.test_3_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory2('geohistory', 'test_3', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
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
FROM geohistory.test_3_without_validity_new;

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

-- Create a test table for TT_GeoHistory() without taking validity into account
DROP TABLE IF EXISTS geohistory.test_4_without_validity_new;
CREATE TABLE geohistory.test_4_without_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory2('geohistory', 'test_4', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id, poly_id) foo;

ALTER TABLE geohistory.test_4_without_validity_new 
ADD PRIMARY KEY (row_id, id, poly_id);
      
-- SELECT * FROM geohistory.test_4_without_validity_new;

-- Create a test table for TT_GeoHistory() taking validity into account
DROP TABLE IF EXISTS geohistory.test_4_with_validity_new;
CREATE TABLE geohistory.test_4_with_validity_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id::int, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory2('geohistory', 'test_4', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
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
FROM geohistory.test_4_without_validity_new;

---------------------------------------------
-- Debug procedure
---------------------------------------------
-- -- 1) Create a view limiting polygon to the ones 
-- --    in the same test as the faulty polygon
-- CREATE OR REPLACE VIEW geohistory.test_bug AS
-- SELECT * FROM geohistory.test_3
-- WHERE test = (SELECT test FROM geohistory.test_3 WHERE idx = 144);

-- SELECT * FROM geohistory.test_bug;

-- -- 2) Modify the WHERE clause of TT_GeoHistory2() currentPolyQuery to 
-- --    ' WHERE ' || quote_ident(idColName) || '::text = ''144'' '
-- --    and activate the RAISE NOTICEs

-- -- 3) Run this query
-- SELECT *
-- FROM TT_GeoHistory2('geohistory', 'test_bug', 'idx', 'geom', 'valid_year', 'idx');

---------------------------------------------
-- Begin tests
---------------------------------------------
SELECT * FROM (
SELECT '1.1a'::text number,
       'TT_GeoHistory'::text function_tested,
       'One polygon'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13))' AND
        ref_year = 1998 AND
        valid_year_begin = 1990 AND 
        valid_year_end = 3000 passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_0', 'idx', 'geom', 'valid_year')
---------------------------------------------------------
UNION ALL
SELECT '1.1b'::text number,
       'TT_GeoHistory'::text function_tested,
       'One polygon'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13))' AND
        ref_year = 1998 AND
        valid_year_begin = 1990 AND 
        valid_year_end = 3000 passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_0', 'idx', 'geom', 'valid_year', 'att')
---------------------------------------------------------
UNION ALL
SELECT '1.2a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((13 20,13 23,23 23,23 13,20 13,20 20,13 20)), POLYGON((13 13,13 23,23 23,23 13,13 13))' AND
        string_agg(ref_year::text, ', ') = '2000, 2000' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_1_3', 'idx', 'geom', 'valid_year')
WHERE id = '1'
---------------------------------------------------------
UNION ALL
SELECT '1.2b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((13 20,13 23,23 23,23 13,20 13,20 20,13 20)), POLYGON((13 13,13 23,23 23,23 13,13 13))' AND
        string_agg(ref_year::text, ', ') = '2000, 2000' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_1_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '1'
---------------------------------------------------------
UNION ALL
SELECT '1.3a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10)), POLYGON((10 10,10 20,13 20,13 13,20 13,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010, 2010' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_1_3', 'idx', 'geom', 'valid_year')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.3b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10)), POLYGON((10 10,10 20,13 20,13 13,20 13,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010, 2010' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_1_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.4a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((9 19,9 21,11 21,11 20,10 20,10 19,9 19))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_2_3', 'idx', 'geom', 'valid_year')
WHERE id = '2'
---------------------------------------------------------
UNION ALL
SELECT '1.4b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((9 19,9 21,11 21,11 20,10 20,10 19,9 19))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_2_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '2'
---------------------------------------------------------
UNION ALL
SELECT '1.5a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_2_3', 'idx', 'geom', 'valid_year')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.5b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_2_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.6a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 1)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13),(26 15,30 15,30 19,26 19,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_0_5', 'idx', 'geom', 'valid_year')
WHERE id = '0'
---------------------------------------------------------
UNION ALL
SELECT '1.6b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 1)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13),(26 15,30 15,30 19,26 19,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_0_5', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '0'
---------------------------------------------------------
UNION ALL
SELECT '1.7a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 2)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((26 15,26 19,30 19,30 15,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_0_5', 'idx', 'geom', 'valid_year')
WHERE id = '5'
---------------------------------------------------------
UNION ALL
SELECT '1.7b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 2)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((26 15,26 19,30 19,30 15,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_0_5', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '5'
---------------------------------------------------------
UNION ALL
SELECT '1.8a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one with lower priority completely inside the other'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((25 14,25 21,32 21,32 14,25 14))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_0_5_6', 'idx', 'geom', 'valid_year')
---------------------------------------------------------
UNION ALL
SELECT '1.8b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one with lower priority completely inside the other'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((25 14,25 21,32 21,32 14,25 14))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed,
        '' check_query
FROM TT_GeoHistory2('geohistory', 'test_0_5_6', 'idx', 'geom', 'valid_year', 'att')
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two single polygons'::text description,
       string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((1 1,1 -1,-1 -1,-1 1,1 1)), POLYGON((7 1,7 -1,5 -1,5 1,7 1))' AND
       string_agg(ref_year::text, ', ') = '2000, 2000' AND
       string_agg(valid_year_begin::text, ', ') = '1990, 1990' AND 
       string_agg(valid_year_end::text, ', ') = '3000, 3000' passed,
        '' check_query
FROM TT_GeoHistory('geohistory', 'test_1', 'idx', 'geom', 'valid_year')
---------------------------------------------------------
-- Compare new with old tables
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "test_2_without_validity_new" and "test_2_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_2_without_validity_new'', ''geohistory'' , ''test_2_without_validity'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.test_2_without_validity_new a 
      FULL OUTER JOIN geohistory.test_2_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "test_2_with_validity_new" and "test_2_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_2_with_validity_new'', ''geohistory'' , ''test_2_with_validity'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.test_2_without_validity_new a 
      FULL OUTER JOIN geohistory.test_2_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "test_3_without_validity_new" and "test_3_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_3_without_validity_new'', ''geohistory'' , ''test_3_without_validity'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.test_3_without_validity_new a 
      FULL OUTER JOIN geohistory.test_3_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "test_3_with_validity_new" and "test_3_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_3_with_validity_new'', ''geohistory'' , ''test_3_with_validity'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.test_3_without_validity_new a 
      FULL OUTER JOIN geohistory.test_3_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "test_4_without_validity_new" and "test_4_without_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_4_without_validity_new'', ''geohistory'' , ''test_4_without_validity'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.test_4_without_validity_new a 
      FULL OUTER JOIN geohistory.test_4_without_validity b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "test_4_with_validity_new" and "test_4_with_validity"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''test_4_with_validity_new'', ''geohistory'' , ''test_4_with_validity'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.test_4_without_validity_new a 
      FULL OUTER JOIN geohistory.test_4_without_validity b USING (row_id)) foo
---------------------------------------------------------
) foo WHERE NOT passed;
