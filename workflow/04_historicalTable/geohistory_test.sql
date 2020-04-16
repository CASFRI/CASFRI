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
-- Create a test table
DROP TABLE IF EXISTS test_geohistory CASCADE;
CREATE TABLE test_geohistory AS
SELECT 0 idx, 1998 valid_year, 'aa' att, ST_GeomFromText('POLYGON((24 13, 24 23, 34 23, 34 13, 24 13))') geom
UNION ALL
SELECT 1 idx, 2000 valid_year, 'bb' att, ST_GeomFromText('POLYGON((13 13, 13 23, 23 23, 23 13, 13 13))') geom
UNION ALL
SELECT 2 idx, 2010 valid_year, 'cc' att, ST_GeomFromText('POLYGON((9 19, 9 21, 11 21, 11 19, 9 19))') geom
UNION ALL
SELECT 3 idx, 2010 valid_year, 'dd' att, ST_GeomFromText('POLYGON((10 10, 10 20, 20 20, 20 10, 10 10))') geom
UNION ALL
SELECT 4 idx, 2020 valid_year, 'ee' att, ST_GeomFromText('POLYGON((7 7, 7 17, 17 17, 17 7, 7 7))') geom
UNION ALL
SELECT 5 idx, 1998 valid_year, 'ff' att, ST_GeomFromText('POLYGON((26 15, 26 19, 30 19, 30 15, 26 15))') geom
UNION ALL
SELECT 6 idx, 1998 valid_year, 'gg' att, ST_GeomFromText('POLYGON((25 14, 25 21, 32 21, 32 14, 25 14))') geom
;

-- Display flat
SELECT *, 
       idx || '_' || valid_year lbl 
FROM test_geohistory;

-- Display oblique
SELECT TT_GeoOblique(geom, valid_year), 
       idx || '_' || valid_year lbl 
FROM test_geohistory;

-- Display flat history
SELECT * FROM TT_GeoHistory('public', 'test_geohistory', 'idx', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistory2('public', 'test_geohistory', 'idx', 'geom', 'valid_year', 'idx');

-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory', 'idx', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory', 'idx', 'geom', 'valid_year', 'idx');

CREATE VIEW test_geohistory_0 AS
SELECT * FROM test_geohistory
WHERE idx = 0;

CREATE VIEW test_geohistory_1_3 AS
SELECT * FROM test_geohistory
WHERE idx = 1 OR idx = 3;

CREATE VIEW test_geohistory_2_3 AS
SELECT * FROM test_geohistory
WHERE idx = 2 OR idx = 3;

CREATE VIEW test_geohistory_0_5 AS
SELECT * FROM test_geohistory
WHERE idx = 0 OR idx = 5;

CREATE VIEW test_geohistory_5_6 AS
SELECT * FROM test_geohistory
WHERE idx = 5 OR idx = 6;

---------------------------------------------
-- test_geohistory_1 - Only one polygon
---------------------------------------------
DROP TABLE IF EXISTS test_geohistory_1 CASCADE;
CREATE TABLE test_geohistory_1 AS
WITH validities AS (
  SELECT 1 v_order, '' a1
  UNION ALL
  SELECT 2,         'aa' a1
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
FROM test_geohistory_1;

-- Display oblique
SELECT TT_GeoOblique(geom, valid_year),
       idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM test_geohistory_1;

-- Display flat history
SELECT * FROM TT_GeoHistory('public', 'test_geohistory_1', 'idx', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistory2('public', 'test_geohistory_1', 'idx', 'geom', 'valid_year', 'idx');

-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory_1', 'idx', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory_1', 'idx', 'geom', 'valid_year', 'idx');

---------------------------------------------
-- test_geohistory_2 - Pairs of polygons representing all the permutations of valid/invalid and year
---------------------------------------------
DROP TABLE IF EXISTS test_geohistory_2 CASCADE;
CREATE TABLE test_geohistory_2 AS
WITH validities AS (
  SELECT 1 v_order, '' a1, '' a2
  UNION ALL
  SELECT 2,       '' a1, 'aa' a2
  UNION ALL
  SELECT 3,       'aa' a1, '' a2
  UNION ALL
  SELECT 4,        'aa' a1, 'aa' a2
), years AS (
  SELECT 1 y_order, 2000 y1, 2000 y2
  UNION ALL
  SELECT 2,       2000 y1, 2010 y2
), ids AS (
  SELECT 0 idx1, 1 idx2
  UNION ALL
  SELECT 1 idx1, 0 idx2
), all_tests AS (
  SELECT idx1, idx2, a1, a2, y1, y2,
         ST_Buffer(ST_GeomFromText('POINT(0 0)'), sqrt(2.0), 1) geom
  FROM validities, years, ids
  ORDER BY y_order, v_order, idx1
), numbered_tests AS (
  SELECT ROW_NUMBER() OVER() - 1 all_test_nb, *
  FROM all_tests
)
SELECT all_test_nb test, idx1 + all_test_nb * 2 idx, a1 att, y1 valid_year,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 8) * 10, (all_test_nb  / 8) * 20) geom
FROM numbered_tests
UNION ALL
SELECT all_test_nb, idx2 + all_test_nb * 2, a2, y2,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb, 8) * 10 + 1, (all_test_nb / 8) * 20 + 1) geom
FROM numbered_tests
ORDER BY test;

-- Create a test table for TT_GeoHistory() without taking validity into account
DROP TABLE IF EXISTS test_geohistory_2_results_without_validity;
CREATE TABLE test_geohistory_2_results_without_validity AS
SELECT *
FROM TT_GeoHistory2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx')
ORDER BY id::int;

-- Create a test table for TT_GeoHistory() taking validity into account
DROP TABLE IF EXISTS test_geohistory_2_results_with_validity;
CREATE TABLE test_geohistory_2_results_with_validity AS
SELECT *
FROM TT_GeoHistory2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
ORDER BY id::int;

-- Display flat
SELECT test, idx, att, valid_year, 
       geom, ST_AsText(geom),
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM test_geohistory_2;

-- Display oblique
SELECT test, idx, att, valid_year,
       TT_GeoOblique(geom, valid_year, 0.2, 0.4), 
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM test_geohistory_2;

-- Display flat history
SELECT * FROM TT_GeoHistory('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year');

-- Without taking validity into account (should be the same as TT_GeoHistory())
SELECT * FROM TT_GeoHistory2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx');

-- Taking validity into account
SELECT * FROM TT_GeoHistory2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att']);


-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 0.2, 0.4);

SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx', NULL, 0.2, 0.4);

SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'], 0.2, 0.4);


---------------------------------------------
-- test_geohistory_3 - Triplet of polygons representing all the permutation of valid/invalid and year
---------------------------------------------
DROP TABLE IF EXISTS test_geohistory_3 CASCADE;
CREATE TABLE test_geohistory_3 AS
WITH validities AS (
  SELECT 1 v_order, '' a1, '' a2, '' a3
  UNION ALL
  SELECT 2,         '' a1, '' a2, 'aa' a3
  UNION ALL
  SELECT 3,         '' a1, 'aa' a2, '' a3
  UNION ALL
  SELECT 4,         '' a1, 'aa' a2, 'aa' a3
  UNION ALL
  SELECT 5,         'aa' a1, '' a2, '' a3
  UNION ALL
  SELECT 6,         'aa' a1, '' a2, 'aa' a3
  UNION ALL
  SELECT 7,         'aa' a1, 'aa' a2, '' a3
  UNION ALL
  SELECT 8,         'aa' a1, 'aa' a2, 'aa' a3
), years AS (
  SELECT 1 y_order, 2000 y1, 2000 y2, 2000 y3
  UNION ALL
  SELECT 2,         2000 y1, 2000 y2, 2010 y3
  UNION ALL
  SELECT 3,         2000 y1, 2010 y2, 2010 y3
  UNION ALL
  SELECT 4,         2000 y1, 2010 y2, 2020 y3
), ids AS (
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
         ST_Buffer(ST_GeomFromText('POINT(0 0)'), 2*sqrt(2.0), 1) geom
  FROM validities, years, ids
  ORDER BY y_order, v_order, i_order
), numbered_tests AS (
  SELECT ROW_NUMBER() OVER() all_test_nb, *
  FROM all_tests
  ORDER BY y_order, v_order, i_order
)
SELECT 1 poly_nb, all_test_nb test, idx1 idx, a1 att, y1 valid_year,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb - 1, 6) * 16, ((all_test_nb - 1) / 6) * 30) geom
FROM numbered_tests
UNION ALL
SELECT 2, all_test_nb, idx2, a2, y2,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb - 1, 6) * 16 + 1, ((all_test_nb - 1) / 6) * 30 + 2) geom
FROM numbered_tests
UNION ALL
SELECT 3, all_test_nb, idx3, a3, y3,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb - 1, 6) * 16 + 2, ((all_test_nb - 1) / 6) * 30 + 1) geom
FROM numbered_tests
ORDER BY test, poly_nb;

-- Display flat
SELECT test, idx, att, valid_year, 
       geom, ST_AsText(geom),
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM test_geohistory_3;

-- Display oblique
SELECT test, idx, att, valid_year,
       TT_GeoOblique(geom, valid_year, 0.2, 0.4), 
       test || '_' || idx || '_' || CASE WHEN att = '' THEN 'I' ELSE 'V' END || '_' || valid_year lbl
FROM test_geohistory_3;

-- Display flat history
SELECT * FROM TT_GeoHistory('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year');

-- Without taking validity into account (should be the same as TT_GeoHistory())
SELECT * FROM TT_GeoHistory2('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 'idx');

-- Taking validity into account
SELECT * FROM TT_GeoHistory2('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att']);


-- Display oblique history
SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 0.2, 0.4);

SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 'idx', NULL, 0.2, 0.4);

SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'], 0.2, 0.4);


---------------------------------------------
-- Begin tests
---------------------------------------------
SELECT '1.1a'::text number,
       'TT_GeoHistory'::text function_tested,
       'One polygon'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13))' AND
        ref_year = 1998 AND
        valid_year_begin = 1990 AND 
        valid_year_end = 3000 passed
FROM TT_GeoHistory('public', 'test_geohistory_0', 'idx', 'geom', 'valid_year')
---------------------------------------------------------
UNION ALL
SELECT '1.1b'::text number,
       'TT_GeoHistory'::text function_tested,
       'One polygon'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13))' AND
        ref_year = 1998 AND
        valid_year_begin = 1990 AND 
        valid_year_end = 3000 passed
FROM TT_GeoHistory2('public', 'test_geohistory_0', 'idx', 'geom', 'valid_year', 'att')
---------------------------------------------------------
UNION ALL
SELECT '1.2a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((13 20,13 23,23 23,23 13,20 13,20 20,13 20)), POLYGON((13 13,13 23,23 23,23 13,13 13))' AND
        string_agg(ref_year::text, ', ') = '2000, 2000' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed
FROM TT_GeoHistory('public', 'test_geohistory_1_3', 'idx', 'geom', 'valid_year')
WHERE id = '1'
---------------------------------------------------------
UNION ALL
SELECT '1.2b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((13 20,13 23,23 23,23 13,20 13,20 20,13 20)), POLYGON((13 13,13 23,23 23,23 13,13 13))' AND
        string_agg(ref_year::text, ', ') = '2000, 2000' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed
FROM TT_GeoHistory2('public', 'test_geohistory_1_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '1'
---------------------------------------------------------
UNION ALL
SELECT '1.3a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10)), POLYGON((10 10,10 20,13 20,13 13,20 13,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010, 2010' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed
FROM TT_GeoHistory('public', 'test_geohistory_1_3', 'idx', 'geom', 'valid_year')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.3b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10)), POLYGON((10 10,10 20,13 20,13 13,20 13,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010, 2010' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed
FROM TT_GeoHistory2('public', 'test_geohistory_1_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.4a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((9 19,9 21,11 21,11 20,10 20,10 19,9 19))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_2_3', 'idx', 'geom', 'valid_year')
WHERE id = '2'
---------------------------------------------------------
UNION ALL
SELECT '1.4b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((9 19,9 21,11 21,11 20,10 20,10 19,9 19))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed
FROM TT_GeoHistory2('public', 'test_geohistory_2_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '2'
---------------------------------------------------------
UNION ALL
SELECT '1.5a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_2_3', 'idx', 'geom', 'valid_year')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.5b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed
FROM TT_GeoHistory2('public', 'test_geohistory_2_3', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '1.6a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 1)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13),(26 15,30 15,30 19,26 19,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_0_5', 'idx', 'geom', 'valid_year')
WHERE id = '0'
---------------------------------------------------------
UNION ALL
SELECT '1.6b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 1)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13),(26 15,30 15,30 19,26 19,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory2('public', 'test_geohistory_0_5', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '0'
---------------------------------------------------------
UNION ALL
SELECT '1.7a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 2)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((26 15,26 19,30 19,30 15,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_0_5', 'idx', 'geom', 'valid_year')
WHERE id = '5'
---------------------------------------------------------
UNION ALL
SELECT '1.7b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 2)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((26 15,26 19,30 19,30 15,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory2('public', 'test_geohistory_0_5', 'idx', 'geom', 'valid_year', 'att')
WHERE id = '5'
---------------------------------------------------------
UNION ALL
SELECT '1.8a'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one with lower priority completely inside the other'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((25 14,25 21,32 21,32 14,25 14))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_5_6', 'idx', 'geom', 'valid_year')
---------------------------------------------------------
UNION ALL
SELECT '1.8b'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one with lower priority completely inside the other'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((25 14,25 21,32 21,32 14,25 14))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory2('public', 'test_geohistory_5_6', 'idx', 'geom', 'valid_year', 'att')
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two single polygons'::text description,
       string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((1 1,1 -1,-1 -1,-1 1,1 1)), POLYGON((7 1,7 -1,5 -1,5 1,7 1))' AND
       string_agg(ref_year::text, ', ') = '2000, 2000' AND
       string_agg(valid_year_begin::text, ', ') = '1990, 1990' AND 
       string_agg(valid_year_end::text, ', ') = '3000, 3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_1', 'idx', 'geom', 'valid_year')
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (0, 1) and (2, 3) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((1 0,1 -1,-1 -1,-1 1,0 1,0 0,1 0)), POLYGON((2 2,2 0,0 0,0 2,2 2)), POLYGON((12 2,12 0,11 0,11 1,10 1,10 2,12 2)), POLYGON((11 1,11 -1,9 -1,9 1,11 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (0, 1, 2, 3)
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (4, 5) and (6, 7) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((21 0,21 -1,19 -1,19 1,20 1,20 0,21 0)), POLYGON((22 2,22 0,20 0,20 2,22 2)), POLYGON((32 2,32 0,31 0,31 1,30 1,30 2,32 2)), POLYGON((31 1,31 -1,29 -1,29 1,31 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (4, 5, 6, 7)
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (8, 9) and (10, 11) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((41 0,41 -1,39 -1,39 1,40 1,40 0,41 0)), POLYGON((42 2,42 0,40 0,40 2,42 2)), POLYGON((52 2,52 0,51 0,51 1,50 1,50 2,52 2)), POLYGON((51 1,51 -1,49 -1,49 1,51 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (8, 9, 10, 11)
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (12, 13) and (14, 15) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((61 0,61 -1,59 -1,59 1,60 1,60 0,61 0)), POLYGON((62 2,62 0,60 0,60 2,62 2)), POLYGON((72 2,72 0,71 0,71 1,70 1,70 2,72 2)), POLYGON((71 1,71 -1,69 -1,69 1,71 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (12, 13, 14, 15)
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (16, 17) and (18, 19) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((1 20,1 19,-1 19,-1 21,0 21,0 20,1 20)), POLYGON((1 21,1 19,-1 19,-1 21,1 21)), POLYGON((2 22,2 20,0 20,0 22,2 22)), POLYGON((2 22,2 20,1 20,1 21,0 21,0 22,2 22)), POLYGON((12 22,12 20,10 20,10 22,12 22)), POLYGON((12 22,12 20,11 20,11 21,10 21,10 22,12 22)), POLYGON((11 20,11 19,9 19,9 21,10 21,10 20,11 20)), POLYGON((11 21,11 19,9 19,9 21,11 21))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2010, 2010, 2010, 2010, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '2010, 1990, 2010, 1990, 2010, 1990, 2010, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 2009, 3000, 2009, 3000, 2009, 3000, 2009' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (16, 17, 18, 19)
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (20, 21) and (22, 23) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((21 20,21 19,19 19,19 21,20 21,20 20,21 20)), POLYGON((21 21,21 19,19 19,19 21,21 21)), POLYGON((22 22,22 20,20 20,20 22,22 22)), POLYGON((22 22,22 20,21 20,21 21,20 21,20 22,22 22)), POLYGON((32 22,32 20,30 20,30 22,32 22)), POLYGON((32 22,32 20,31 20,31 21,30 21,30 22,32 22)), POLYGON((31 21,31 19,29 19,29 21,31 21)), POLYGON((31 20,31 19,29 19,29 21,30 21,30 20,31 20))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2010, 2010, 2010, 2010, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '2010, 1990, 2010, 1990, 2010, 1990, 1990, 2010' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 2009, 3000, 2009, 3000, 2009, 2009, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (20, 21, 22, 23)
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (24, 25) and (26, 27) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((41 20,41 19,39 19,39 21,40 21,40 20,41 20)), POLYGON((41 21,41 19,39 19,39 21,41 21)), POLYGON((42 22,42 20,41 20,41 21,40 21,40 22,42 22)), POLYGON((42 22,42 20,40 20,40 22,42 22)), POLYGON((52 22,52 20,50 20,50 22,52 22)), POLYGON((52 22,52 20,51 20,51 21,50 21,50 22,52 22)), POLYGON((51 21,51 19,49 19,49 21,51 21)), POLYGON((51 20,51 19,49 19,49 21,50 21,50 20,51 20))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2010, 2010, 2010, 2010, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '2010, 1990, 1990, 2010, 2010, 1990, 1990, 2010' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 2009, 2009, 3000, 3000, 2009, 2009, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (24, 25, 26, 27)
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (28, 29) and (30, 31) (without validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((61 21,61 19,59 19,59 21,61 21)), POLYGON((61 20,61 19,59 19,59 21,60 21,60 20,61 20)), POLYGON((62 22,62 20,60 20,60 22,62 22)), POLYGON((62 22,62 20,61 20,61 21,60 21,60 22,62 22)), POLYGON((72 22,72 20,71 20,71 21,70 21,70 22,72 22)), POLYGON((72 22,72 20,70 20,70 22,72 22)), POLYGON((71 21,71 19,69 19,69 21,71 21)), POLYGON((71 20,71 19,69 19,69 21,70 21,70 20,71 20))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2010, 2010, 2010, 2010, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 2010, 2010, 1990, 1990, 2010, 1990, 2010' AND 
        string_agg(valid_year_end::text, ', ')    = '2009, 3000, 3000, 2009, 2009, 3000, 2009, 3000' passed       
FROM public.test_geohistory_2_results_without_validity
WHERE id::int IN (28, 29, 30, 31)
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (0, 1) and (2, 3) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((1 0,1 -1,-1 -1,-1 1,0 1,0 0,1 0)), POLYGON((2 2,2 0,0 0,0 2,2 2)), POLYGON((12 2,12 0,11 0,11 1,10 1,10 2,12 2)), POLYGON((11 1,11 -1,9 -1,9 1,11 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (0, 1, 2, 3)
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (4, 5) and (6, 7) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((21 0,21 -1,19 -1,19 1,20 1,20 0,21 0)), POLYGON((22 2,22 0,20 0,20 2,22 2)), POLYGON((32 2,32 0,30 0,30 2,32 2)), POLYGON((31 0,31 -1,29 -1,29 1,30 1,30 0,31 0))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (4, 5, 6, 7)
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (8, 9) and (10, 11) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((41 1,41 -1,39 -1,39 1,41 1)), POLYGON((42 2,42 0,41 0,41 1,40 1,40 2,42 2)), POLYGON((52 2,52 0,51 0,51 1,50 1,50 2,52 2)), POLYGON((51 1,51 -1,49 -1,49 1,51 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (8, 9, 10, 11)
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (12, 13) and (14, 15) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((61 0,61 -1,59 -1,59 1,60 1,60 0,61 0)), POLYGON((62 2,62 0,60 0,60 2,62 2)), POLYGON((72 2,72 0,71 0,71 1,70 1,70 2,72 2)), POLYGON((71 1,71 -1,69 -1,69 1,71 1))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (12, 13, 14, 15)
---------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (16, 17) and (18, 19) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((1 20,1 19,-1 19,-1 21,0 21,0 20,1 20)), POLYGON((2 22,2 20,0 20,0 22,2 22)), POLYGON((12 22,12 20,10 20,10 22,12 22)), POLYGON((11 20,11 19,9 19,9 21,10 21,10 20,11 20))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2010, 2010, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (16, 17, 18, 19)
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (20, 21) and (22, 23) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((21 20,21 19,19 19,19 21,20 21,20 20,21 20)), POLYGON((22 22,22 20,20 20,20 22,22 22)), POLYGON((32 22,32 20,30 20,30 22,32 22)), POLYGON((31 20,31 19,29 19,29 21,30 21,30 20,31 20))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2010, 2010, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (20, 21, 22, 23)
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (24, 25) and (26, 27) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((41 21,41 19,39 19,39 21,41 21)), POLYGON((42 22,42 20,41 20,41 21,40 21,40 22,42 22)), POLYGON((52 22,52 20,51 20,51 21,50 21,50 22,52 22)), POLYGON((51 21,51 19,49 19,49 21,51 21))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2010, 2010, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 1990, 1990, 1990' AND 
        string_agg(valid_year_end::text, ', ')    = '3000, 3000, 3000, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (24, 25, 26, 27)
---------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Table of polygon couples with ids (28, 29) and (30, 31) (with validity check)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((61 21,61 19,59 19,59 21,61 21)), POLYGON((61 20,61 19,59 19,59 21,60 21,60 20,61 20)), POLYGON((62 22,62 20,60 20,60 22,62 22)), POLYGON((62 22,62 20,61 20,61 21,60 21,60 22,62 22)), POLYGON((72 22,72 20,70 20,70 22,72 22)), POLYGON((72 22,72 20,71 20,71 21,70 21,70 22,72 22)), POLYGON((71 21,71 19,69 19,69 21,71 21)), POLYGON((71 20,71 19,69 19,69 21,70 21,70 20,71 20))' AND
        string_agg(ref_year::text, ', ')          = '2000, 2000, 2010, 2010, 2010, 2010, 2000, 2000' AND
        string_agg(valid_year_begin::text, ', ')  = '1990, 2010, 2010, 1990, 2010, 1990, 1990, 2010' AND 
        string_agg(valid_year_end::text, ', ')    = '2009, 3000, 3000, 2009, 3000, 2009, 2009, 3000' passed       
FROM public.test_geohistory_2_results_with_validity
WHERE id::int IN (28, 29, 30, 31)
;

