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
-- test_geohistory_2 - Pairs of polygons representing 
-- all permutations of valid/invalid attributes, years and ids
---------------------------------------------
DROP TABLE IF EXISTS test_geohistory_2 CASCADE;
CREATE TABLE test_geohistory_2 AS
WITH validities AS (
  -- all permutations of validity for two polygons
  SELECT 1 v_order, '' a1, '' a2
  UNION ALL
  SELECT 2,         '' a1, 'aa' a2
  UNION ALL
  SELECT 3,         'aa' a1, '' a2
  UNION ALL
  SELECT 4,         'aa' a1, 'aa' a2
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

-- SELECT * FROM test_geohistory_2;

-- Create a test table for TT_GeoHistory() without taking validity into account
DROP TABLE IF EXISTS test_geohistory_2_results_without_validity;
CREATE TABLE test_geohistory_2_results_without_validity AS
SELECT ROW_NUMBER() OVER() - 1 rownum, *
FROM (SELECT *
      FROM TT_GeoHistory2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id::int) foo;

-- Create a test table for TT_GeoHistory() taking validity into account
DROP TABLE IF EXISTS test_geohistory_2_results_with_validity;
CREATE TABLE test_geohistory_2_results_with_validity AS
SELECT ROW_NUMBER() OVER() - 1 rownum, *
FROM (SELECT *
      FROM TT_GeoHistory2('public', 'test_geohistory_2', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
      ORDER BY id::int) foo;
---------------------------------------------
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
-- test_geohistory_3 - Triplet of polygons representing
-- all permutations of valid/invalid attributes, years and ids
---------------------------------------------
DROP TABLE IF EXISTS test_geohistory_3 CASCADE;
CREATE TABLE test_geohistory_3 AS
WITH validities AS (
  -- all permutations of validity for three polygons
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
-- Square are rotated arounf their centroid and snapped to a 
-- grid so that its coordinates becomes integers.
SELECT all_test_nb test, idx1 + all_test_nb * 3 idx, a1 att, y1 valid_year,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb - 1, 6) * 16, ((all_test_nb - 1) / 6) * 30) geom
FROM numbered_tests
UNION ALL
-- Generate the second square with the second set of values 
-- (a little bit translated to the upper right)
SELECT all_test_nb, idx2 + all_test_nb * 3, a2, y2,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb - 1, 6) * 16 + 1, ((all_test_nb - 1) / 6) * 30 + 2) geom
FROM numbered_tests
UNION ALL
-- Generate the third square with the third set of values 
-- (a little bit translated to the right in between the two first squares so that the three intersects)
SELECT all_test_nb, idx3 + all_test_nb * 3, a3, y3,
       ST_Translate(ST_SnapToGrid(ST_Rotate(geom, pi()/4, ST_Centroid(geom)), 0.001), mod(all_test_nb - 1, 6) * 16 + 2, ((all_test_nb - 1) / 6) * 30 + 1) geom
FROM numbered_tests
ORDER BY test, idx;

-- SELECT * FROM test_geohistory_3;

-- Create a test table for TT_GeoHistory() without taking validity into account
DROP TABLE IF EXISTS test_geohistory_3_results_without_validity;
CREATE TABLE test_geohistory_3_results_without_validity AS
SELECT ROW_NUMBER() OVER() - 1 rownum, *
FROM (SELECT *
      FROM TT_GeoHistory2('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 'idx')
      ORDER BY id::int) foo;
      
-- SELECT * FROM test_geohistory_3_results_without_validity;

-- Create a test table for TT_GeoHistory() taking validity into account
DROP TABLE IF EXISTS test_geohistory_3_results_with_validity;
CREATE TABLE test_geohistory_3_results_with_validity AS
SELECT ROW_NUMBER() OVER() - 1 rownum, *
FROM (SELECT *
      FROM TT_GeoHistory2('public', 'test_geohistory_3', 'idx', 'geom', 'valid_year', 'idx', ARRAY['att'])
      ORDER BY id::int) foo;

-- SELECT * FROM test_geohistory_3_results_with_validity;

---------------------------------------------
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
-- Declare TT_GenerateTestsForTable()
---------------------------------------------
DROP FUNCTION IF EXISTS TT_GenerateTestsForTable(name, name, int);
CREATE OR REPLACE FUNCTION TT_GenerateTestsForTable(
  schemaName name,
  tableName name,
  majNum int DEFAULT 1
)
RETURNS text AS $$
  DECLARE
    testStr text = '';
    finalStr text = '';
    testRow RECORD;
    minorNum int = 1;
  BEGIN
    -- SELECT * FROM test_geohistory_2_results_with_validity
RAISE NOTICE '111';
    FOR testRow IN EXECUTE 'SELECT * FROM ' || TT_FullTableName(schemaName, tableName) LOOP
RAISE NOTICE '222';
      IF minorNum != 1 THEN
        finalStr = finalStr || 'UNION ALL
';
      END IF;
      testStr = 'SELECT ''' || majNum::text || '.' || minorNum::text || '''::text number,
       ''TT_GeoHistory''::text function_tested,
       ''Test TT_GeoHistory() on polygon ID ''''' || testRow.id::text || ''''' ''::text description,
        ST_AsText(wkb_geometry) ' || coalesce(' = ''' || ST_AsText(testRow.wkb_geometry) || '''', 'IS NULL') || ' AND
        ref_year::text = ''' || testRow.ref_year || ''' AND
        valid_year_begin::text = ''' || testRow.valid_year_begin || ''' AND 
        valid_year_end::text = ''' || testRow.valid_year_end || ''' passed
FROM ' ||  TT_FullTableName(schemaName, tableName) || '
WHERE rownum = ' || testRow.rownum || '
---------------------------------------------------------
';
RAISE NOTICE '333 testStr = %', testStr;
      finalStr = finalStr || testStr;
      minorNum = minorNum + 1;
    END LOOP;
RAISE NOTICE '444';
    RETURN finalStr;
  END
$$ LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS TT_GenerateTestsForTable(name, int);
CREATE OR REPLACE FUNCTION TT_GenerateTestsForTable(
  tableName name,
  majNum int DEFAULT 1
)
RETURNS text AS $$
  SELECT TT_GenerateTestsForTable('public', tableName, majNum);
$$ LANGUAGE sql VOLATILE;

--SELECT TT_GenerateTestsForTable('test_geohistory_3_results_with_validity', 5);
SELECT * FROM (
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
-- The 3.x test seires was generated using 
-- SELECT TT_GenerateTestsForTable('test_geohistory_2_results_with_validity', 3);
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''0'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((1 0,1 -1,-1 -1,-1 1,0 1,0 0,1 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 0
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''1'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((2 2,2 0,0 0,0 2,2 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 1
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''2'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((12 2,12 0,11 0,11 1,10 1,10 2,12 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 2
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''3'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((11 1,11 -1,9 -1,9 1,11 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 3
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''4'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((21 0,21 -1,19 -1,19 1,20 1,20 0,21 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 4
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''5'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((22 2,22 0,20 0,20 2,22 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 5
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''6'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((32 2,32 0,30 0,30 2,32 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 6
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''7'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((31 0,31 -1,29 -1,29 1,30 1,30 0,31 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 7
---------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''8'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((41 1,41 -1,39 -1,39 1,41 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 8
---------------------------------------------------------
UNION ALL
SELECT '3.10'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''9'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((42 2,42 0,41 0,41 1,40 1,40 2,42 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 9
---------------------------------------------------------
UNION ALL
SELECT '3.11'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''10'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((52 2,52 0,51 0,51 1,50 1,50 2,52 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 10
---------------------------------------------------------
UNION ALL
SELECT '3.12'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''11'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((51 1,51 -1,49 -1,49 1,51 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 11
---------------------------------------------------------
UNION ALL
SELECT '3.13'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''12'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((61 0,61 -1,59 -1,59 1,60 1,60 0,61 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 12
---------------------------------------------------------
UNION ALL
SELECT '3.14'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''13'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((62 2,62 0,60 0,60 2,62 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 13
---------------------------------------------------------
UNION ALL
SELECT '3.15'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''14'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((72 2,72 0,71 0,71 1,70 1,70 2,72 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 14
---------------------------------------------------------
UNION ALL
SELECT '3.16'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''15'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((71 1,71 -1,69 -1,69 1,71 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 15
---------------------------------------------------------
UNION ALL
SELECT '3.17'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''16'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((1 20,1 19,-1 19,-1 21,0 21,0 20,1 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 16
---------------------------------------------------------
UNION ALL
SELECT '3.18'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''17'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((2 22,2 20,0 20,0 22,2 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 17
---------------------------------------------------------
UNION ALL
SELECT '3.19'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''18'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((12 22,12 20,10 20,10 22,12 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 18
---------------------------------------------------------
UNION ALL
SELECT '3.20'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''19'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((11 20,11 19,9 19,9 21,10 21,10 20,11 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 19
---------------------------------------------------------
UNION ALL
SELECT '3.21'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''20'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((21 20,21 19,19 19,19 21,20 21,20 20,21 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 20
---------------------------------------------------------
UNION ALL
SELECT '3.22'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''21'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((22 22,22 20,20 20,20 22,22 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 21
---------------------------------------------------------
UNION ALL
SELECT '3.23'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''22'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((32 22,32 20,30 20,30 22,32 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 22
---------------------------------------------------------
UNION ALL
SELECT '3.24'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''23'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((31 20,31 19,29 19,29 21,30 21,30 20,31 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 23
---------------------------------------------------------
UNION ALL
SELECT '3.25'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''24'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((41 21,41 19,39 19,39 21,41 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 24
---------------------------------------------------------
UNION ALL
SELECT '3.26'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''25'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((42 22,42 20,41 20,41 21,40 21,40 22,42 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 25
---------------------------------------------------------
UNION ALL
SELECT '3.27'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''26'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((52 22,52 20,51 20,51 21,50 21,50 22,52 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 26
---------------------------------------------------------
UNION ALL
SELECT '3.28'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''27'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((51 21,51 19,49 19,49 21,51 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 27
---------------------------------------------------------
UNION ALL
SELECT '3.29'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''28'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((61 21,61 19,59 19,59 21,61 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 28
---------------------------------------------------------
UNION ALL
SELECT '3.30'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''28'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((61 20,61 19,59 19,59 21,60 21,60 20,61 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 29
---------------------------------------------------------
UNION ALL
SELECT '3.31'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''29'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((62 22,62 20,60 20,60 22,62 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 30
---------------------------------------------------------
UNION ALL
SELECT '3.32'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''29'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((62 22,62 20,61 20,61 21,60 21,60 22,62 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 31
---------------------------------------------------------
UNION ALL
SELECT '3.33'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''30'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((72 22,72 20,71 20,71 21,70 21,70 22,72 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 32
---------------------------------------------------------
UNION ALL
SELECT '3.34'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''30'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((72 22,72 20,70 20,70 22,72 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 33
---------------------------------------------------------
UNION ALL
SELECT '3.35'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''31'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((71 21,71 19,69 19,69 21,71 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 34
---------------------------------------------------------
UNION ALL
SELECT '3.36'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''31'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((71 20,71 19,69 19,69 21,70 21,70 20,71 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_with_validity
WHERE rownum = 35
---------------------------------------------------------
-- The 4.x test series was generated using
-- SELECT TT_GenerateTestsForTable('test_geohistory_2_results_without_validity', 4);
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''0'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((1 0,1 -1,-1 -1,-1 1,0 1,0 0,1 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 0
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''1'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((2 2,2 0,0 0,0 2,2 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 1
---------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''2'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((12 2,12 0,11 0,11 1,10 1,10 2,12 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 2
---------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''3'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((11 1,11 -1,9 -1,9 1,11 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 3
---------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''4'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((21 0,21 -1,19 -1,19 1,20 1,20 0,21 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 4
---------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''5'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((22 2,22 0,20 0,20 2,22 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 5
---------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''6'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((32 2,32 0,31 0,31 1,30 1,30 2,32 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 6
---------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''7'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((31 1,31 -1,29 -1,29 1,31 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 7
---------------------------------------------------------
UNION ALL
SELECT '4.9'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''8'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((41 0,41 -1,39 -1,39 1,40 1,40 0,41 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 8
---------------------------------------------------------
UNION ALL
SELECT '4.10'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''9'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((42 2,42 0,40 0,40 2,42 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 9
---------------------------------------------------------
UNION ALL
SELECT '4.11'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''10'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((52 2,52 0,51 0,51 1,50 1,50 2,52 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 10
---------------------------------------------------------
UNION ALL
SELECT '4.12'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''11'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((51 1,51 -1,49 -1,49 1,51 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 11
---------------------------------------------------------
UNION ALL
SELECT '4.13'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''12'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((61 0,61 -1,59 -1,59 1,60 1,60 0,61 0))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 12
---------------------------------------------------------
UNION ALL
SELECT '4.14'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''13'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((62 2,62 0,60 0,60 2,62 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 13
---------------------------------------------------------
UNION ALL
SELECT '4.15'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''14'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((72 2,72 0,71 0,71 1,70 1,70 2,72 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 14
---------------------------------------------------------
UNION ALL
SELECT '4.16'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''15'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((71 1,71 -1,69 -1,69 1,71 1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 15
---------------------------------------------------------
UNION ALL
SELECT '4.17'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''16'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((1 20,1 19,-1 19,-1 21,0 21,0 20,1 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 16
---------------------------------------------------------
UNION ALL
SELECT '4.18'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''16'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((1 21,1 19,-1 19,-1 21,1 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 17
---------------------------------------------------------
UNION ALL
SELECT '4.19'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''17'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((2 22,2 20,0 20,0 22,2 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 18
---------------------------------------------------------
UNION ALL
SELECT '4.20'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''17'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((2 22,2 20,1 20,1 21,0 21,0 22,2 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 19
---------------------------------------------------------
UNION ALL
SELECT '4.21'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''18'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((12 22,12 20,10 20,10 22,12 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 20
---------------------------------------------------------
UNION ALL
SELECT '4.22'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''18'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((12 22,12 20,11 20,11 21,10 21,10 22,12 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 21
---------------------------------------------------------
UNION ALL
SELECT '4.23'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''19'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((11 21,11 19,9 19,9 21,11 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 22
---------------------------------------------------------
UNION ALL
SELECT '4.24'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''19'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((11 20,11 19,9 19,9 21,10 21,10 20,11 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 23
---------------------------------------------------------
UNION ALL
SELECT '4.25'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''20'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((21 21,21 19,19 19,19 21,21 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 24
---------------------------------------------------------
UNION ALL
SELECT '4.26'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''20'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((21 20,21 19,19 19,19 21,20 21,20 20,21 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 25
---------------------------------------------------------
UNION ALL
SELECT '4.27'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''21'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((22 22,22 20,21 20,21 21,20 21,20 22,22 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 26
---------------------------------------------------------
UNION ALL
SELECT '4.28'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''21'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((22 22,22 20,20 20,20 22,22 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 27
---------------------------------------------------------
UNION ALL
SELECT '4.29'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''22'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((32 22,32 20,30 20,30 22,32 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 28
---------------------------------------------------------
UNION ALL
SELECT '4.30'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''22'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((32 22,32 20,31 20,31 21,30 21,30 22,32 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 29
---------------------------------------------------------
UNION ALL
SELECT '4.31'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''23'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((31 20,31 19,29 19,29 21,30 21,30 20,31 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 30
---------------------------------------------------------
UNION ALL
SELECT '4.32'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''23'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((31 21,31 19,29 19,29 21,31 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 31
---------------------------------------------------------
UNION ALL
SELECT '4.33'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''24'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((41 20,41 19,39 19,39 21,40 21,40 20,41 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 32
---------------------------------------------------------
UNION ALL
SELECT '4.34'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''24'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((41 21,41 19,39 19,39 21,41 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 33
---------------------------------------------------------
UNION ALL
SELECT '4.35'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''25'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((42 22,42 20,41 20,41 21,40 21,40 22,42 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 34
---------------------------------------------------------
UNION ALL
SELECT '4.36'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''25'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((42 22,42 20,40 20,40 22,42 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 35
---------------------------------------------------------
UNION ALL
SELECT '4.37'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''26'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((52 22,52 20,51 20,51 21,50 21,50 22,52 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 36
---------------------------------------------------------
UNION ALL
SELECT '4.38'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''26'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((52 22,52 20,50 20,50 22,52 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 37
---------------------------------------------------------
UNION ALL
SELECT '4.39'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''27'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((51 21,51 19,49 19,49 21,51 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 38
---------------------------------------------------------
UNION ALL
SELECT '4.40'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''27'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((51 20,51 19,49 19,49 21,50 21,50 20,51 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 39
---------------------------------------------------------
UNION ALL
SELECT '4.41'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''28'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((61 20,61 19,59 19,59 21,60 21,60 20,61 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 40
---------------------------------------------------------
UNION ALL
SELECT '4.42'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''28'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((61 21,61 19,59 19,59 21,61 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 41
---------------------------------------------------------
UNION ALL
SELECT '4.43'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''29'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((62 22,62 20,60 20,60 22,62 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 42
---------------------------------------------------------
UNION ALL
SELECT '4.44'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''29'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((62 22,62 20,61 20,61 21,60 21,60 22,62 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 43
---------------------------------------------------------
UNION ALL
SELECT '4.45'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''30'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((72 22,72 20,71 20,71 21,70 21,70 22,72 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 44
---------------------------------------------------------
UNION ALL
SELECT '4.46'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''30'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((72 22,72 20,70 20,70 22,72 22))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 45
---------------------------------------------------------
UNION ALL
SELECT '4.47'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''31'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((71 20,71 19,69 19,69 21,70 21,70 20,71 20))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 46
---------------------------------------------------------
UNION ALL
SELECT '4.48'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''31'' '::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((71 21,71 19,69 19,69 21,71 21))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_2_results_without_validity
WHERE rownum = 47
---------------------------------------------------------
-- The 5.x test series was generated using
-- SELECT TT_GenerateTestsForTable('test_geohistory_3_results_without_validity', 5);
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''0'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((-14 -1,-14 -2,-18 -2,-18 2,-17 2,-17 0,-16 0,-16 -1,-14 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 0
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''1'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((-13 4,-13 3,-16 3,-16 0,-17 0,-17 4,-13 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 1
---------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''2'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((-12 3,-12 -1,-16 -1,-16 3,-12 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 2
---------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''3'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 -1,2 -2,-2 -2,-2 2,-1 2,-1 0,0 0,0 -1,2 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 3
---------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''4'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 3,4 -1,0 -1,0 0,3 0,3 3,4 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 4
---------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''5'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 4,3 0,-1 0,-1 4,3 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 5
---------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''6'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 4,19 3,16 3,16 2,15 2,15 4,19 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 6
---------------------------------------------------------
UNION ALL
SELECT '5.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''7'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 -1,18 -2,14 -2,14 2,16 2,16 -1,18 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 7
---------------------------------------------------------
UNION ALL
SELECT '5.9'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''8'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 3,20 -1,16 -1,16 3,20 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 8
---------------------------------------------------------
UNION ALL
SELECT '5.10'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''9'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 3,36 -1,32 -1,32 3,36 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 9
---------------------------------------------------------
UNION ALL
SELECT '5.11'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''10'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 -1,34 -2,30 -2,30 2,31 2,31 0,32 0,32 -1,34 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 10
---------------------------------------------------------
UNION ALL
SELECT '5.12'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''11'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 4,35 3,32 3,32 0,31 0,31 4,35 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 11
---------------------------------------------------------
UNION ALL
SELECT '5.13'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''12'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 4,51 3,48 3,48 2,47 2,47 4,51 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 12
---------------------------------------------------------
UNION ALL
SELECT '5.14'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''13'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 3,52 -1,50 -1,50 2,48 2,48 3,52 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 13
---------------------------------------------------------
UNION ALL
SELECT '5.15'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''14'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 2,50 -2,46 -2,46 2,50 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 14
---------------------------------------------------------
UNION ALL
SELECT '5.16'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''15'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 3,68 -1,66 -1,66 0,67 0,67 3,68 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 15
---------------------------------------------------------
UNION ALL
SELECT '5.17'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''16'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 4,67 0,66 0,66 2,63 2,63 4,67 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 16
---------------------------------------------------------
UNION ALL
SELECT '5.18'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''17'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 2,66 -2,62 -2,62 2,66 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 17
---------------------------------------------------------
UNION ALL
SELECT '5.19'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''18'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 -1,82 -2,78 -2,78 2,79 2,79 0,80 0,80 -1,82 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 18
---------------------------------------------------------
UNION ALL
SELECT '5.20'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''19'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 4,83 3,80 3,80 0,79 0,79 4,83 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 19
---------------------------------------------------------
UNION ALL
SELECT '5.21'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''20'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 3,84 -1,80 -1,80 3,84 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 20
---------------------------------------------------------
UNION ALL
SELECT '5.22'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''21'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 29,2 28,-2 28,-2 32,-1 32,-1 30,0 30,0 29,2 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 21
---------------------------------------------------------
UNION ALL
SELECT '5.23'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''22'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 33,4 29,0 29,0 33,4 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 22
---------------------------------------------------------
UNION ALL
SELECT '5.24'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''23'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 34,3 33,0 33,0 30,-1 30,-1 34,3 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 23
---------------------------------------------------------
UNION ALL
SELECT '5.25'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''24'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 34,19 33,16 33,16 32,15 32,15 34,19 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 24
---------------------------------------------------------
UNION ALL
SELECT '5.26'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''25'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 29,18 28,14 28,14 32,16 32,16 29,18 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 25
---------------------------------------------------------
UNION ALL
SELECT '5.27'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''26'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 33,20 29,16 29,16 33,20 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 26
---------------------------------------------------------
UNION ALL
SELECT '5.28'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''27'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 33,36 29,32 29,32 33,36 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 27
---------------------------------------------------------
UNION ALL
SELECT '5.29'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''28'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 29,34 28,30 28,30 32,31 32,31 30,32 30,32 29,34 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 28
---------------------------------------------------------
UNION ALL
SELECT '5.30'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''29'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 34,35 33,32 33,32 30,31 30,31 34,35 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 29
---------------------------------------------------------
UNION ALL
SELECT '5.31'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''30'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 34,51 33,48 33,48 32,47 32,47 34,51 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 30
---------------------------------------------------------
UNION ALL
SELECT '5.32'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''31'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 33,52 29,48 29,48 33,52 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 31
---------------------------------------------------------
UNION ALL
SELECT '5.33'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''32'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 29,50 28,46 28,46 32,48 32,48 29,50 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 32
---------------------------------------------------------
UNION ALL
SELECT '5.34'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''33'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 33,68 29,64 29,64 33,68 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 33
---------------------------------------------------------
UNION ALL
SELECT '5.35'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''34'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 34,67 33,64 33,64 32,63 32,63 34,67 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 34
---------------------------------------------------------
UNION ALL
SELECT '5.36'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''35'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 29,66 28,62 28,62 32,64 32,64 29,66 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 35
---------------------------------------------------------
UNION ALL
SELECT '5.37'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''36'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 29,82 28,78 28,78 32,79 32,79 30,80 30,80 29,82 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 36
---------------------------------------------------------
UNION ALL
SELECT '5.38'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''37'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 34,83 30,79 30,79 34,83 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 37
---------------------------------------------------------
UNION ALL
SELECT '5.39'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''38'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 33,84 29,80 29,80 30,83 30,83 33,84 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 38
---------------------------------------------------------
UNION ALL
SELECT '5.40'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''39'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 59,2 58,-2 58,-2 62,-1 62,-1 60,0 60,0 59,2 59))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 39
---------------------------------------------------------
UNION ALL
SELECT '5.41'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''40'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 63,4 59,0 59,0 60,3 60,3 63,4 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 40
---------------------------------------------------------
UNION ALL
SELECT '5.42'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''41'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 64,3 60,-1 60,-1 64,3 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 41
---------------------------------------------------------
UNION ALL
SELECT '5.43'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''42'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 64,19 60,15 60,15 64,19 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 42
---------------------------------------------------------
UNION ALL
SELECT '5.44'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''43'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 59,18 58,14 58,14 62,15 62,15 60,16 60,16 59,18 59))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 43
---------------------------------------------------------
UNION ALL
SELECT '5.45'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''44'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 63,20 59,16 59,16 60,19 60,19 63,20 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 44
---------------------------------------------------------
UNION ALL
SELECT '5.46'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''45'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 63,36 59,34 59,34 60,35 60,35 63,36 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 45
---------------------------------------------------------
UNION ALL
SELECT '5.47'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''46'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 60,34 58,30 58,30 62,31 62,31 60,34 60))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 46
---------------------------------------------------------
UNION ALL
SELECT '5.48'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''47'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 64,35 60,31 60,31 64,35 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 47
---------------------------------------------------------
UNION ALL
SELECT '5.49'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''48'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 64,51 60,47 60,47 64,51 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 48
---------------------------------------------------------
UNION ALL
SELECT '5.50'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''49'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 63,52 59,50 59,50 60,51 60,51 63,52 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 49
---------------------------------------------------------
UNION ALL
SELECT '5.51'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''50'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 60,50 58,46 58,46 62,47 62,47 60,50 60))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 50
---------------------------------------------------------
UNION ALL
SELECT '5.52'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''51'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 63,68 59,66 59,66 60,67 60,67 63,68 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 51
---------------------------------------------------------
UNION ALL
SELECT '5.53'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''52'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 64,67 60,63 60,63 64,67 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 52
---------------------------------------------------------
UNION ALL
SELECT '5.54'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''53'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 60,66 58,62 58,62 62,63 62,63 60,66 60))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 53
---------------------------------------------------------
UNION ALL
SELECT '5.55'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''54'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 59,82 58,78 58,78 62,79 62,79 60,80 60,80 59,82 59))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 54
---------------------------------------------------------
UNION ALL
SELECT '5.56'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''55'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 64,83 63,80 63,80 60,79 60,79 64,83 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 55
---------------------------------------------------------
UNION ALL
SELECT '5.57'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''56'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 63,84 59,80 59,80 63,84 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 56
---------------------------------------------------------
UNION ALL
SELECT '5.58'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''57'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 89,2 88,-2 88,-2 92,-1 92,-1 90,0 90,0 89,2 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 57
---------------------------------------------------------
UNION ALL
SELECT '5.59'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''58'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 93,4 89,0 89,0 90,3 90,3 93,4 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 58
---------------------------------------------------------
UNION ALL
SELECT '5.60'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''59'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 94,3 90,-1 90,-1 94,3 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 59
---------------------------------------------------------
UNION ALL
SELECT '5.61'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''60'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 94,19 93,16 93,16 90,15 90,15 94,19 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 60
---------------------------------------------------------
UNION ALL
SELECT '5.62'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''61'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 89,18 88,14 88,14 92,15 92,15 90,16 90,16 89,18 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 61
---------------------------------------------------------
UNION ALL
SELECT '5.63'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''62'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 93,20 89,16 89,16 93,20 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 62
---------------------------------------------------------
UNION ALL
SELECT '5.64'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''63'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 93,36 89,32 89,32 90,35 90,35 93,36 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 63
---------------------------------------------------------
UNION ALL
SELECT '5.65'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''64'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 89,34 88,30 88,30 92,31 92,31 90,32 90,32 89,34 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 64
---------------------------------------------------------
UNION ALL
SELECT '5.66'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''65'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 94,35 90,31 90,31 94,35 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 65
---------------------------------------------------------
UNION ALL
SELECT '5.67'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''66'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 94,51 93,48 93,48 90,47 90,47 94,51 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 66
---------------------------------------------------------
UNION ALL
SELECT '5.68'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''67'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 93,52 89,48 89,48 93,52 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 67
---------------------------------------------------------
UNION ALL
SELECT '5.69'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''68'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 89,50 88,46 88,46 92,47 92,47 90,48 90,48 89,50 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 68
---------------------------------------------------------
UNION ALL
SELECT '5.70'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''69'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 93,68 89,64 89,64 90,67 90,67 93,68 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 69
---------------------------------------------------------
UNION ALL
SELECT '5.71'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''70'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 94,67 90,63 90,63 94,67 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 70
---------------------------------------------------------
UNION ALL
SELECT '5.72'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''71'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 89,66 88,62 88,62 92,63 92,63 90,64 90,64 89,66 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 71
---------------------------------------------------------
UNION ALL
SELECT '5.73'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''72'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 92,82 88,78 88,78 92,82 92))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 72
---------------------------------------------------------
UNION ALL
SELECT '5.74'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''73'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 94,83 93,80 93,80 92,79 92,79 94,83 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 73
---------------------------------------------------------
UNION ALL
SELECT '5.75'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''74'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 93,84 89,82 89,82 92,80 92,80 93,84 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 74
---------------------------------------------------------
UNION ALL
SELECT '5.76'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''75'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 122,2 118,-2 118,-2 122,2 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 75
---------------------------------------------------------
UNION ALL
SELECT '5.77'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''76'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 123,4 119,2 119,2 120,3 120,3 123,4 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 76
---------------------------------------------------------
UNION ALL
SELECT '5.78'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''77'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 124,3 120,2 120,2 122,-1 122,-1 124,3 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 77
---------------------------------------------------------
UNION ALL
SELECT '5.79'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''78'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 124,19 123,16 123,16 122,15 122,15 124,19 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 78
---------------------------------------------------------
UNION ALL
SELECT '5.80'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''79'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 122,18 118,14 118,14 122,18 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 79
---------------------------------------------------------
UNION ALL
SELECT '5.81'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''80'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 123,20 119,18 119,18 122,16 122,16 123,20 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 80
---------------------------------------------------------
UNION ALL
SELECT '5.82'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''81'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 123,36 119,34 119,34 120,35 120,35 123,36 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 81
---------------------------------------------------------
UNION ALL
SELECT '5.83'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''82'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 122,34 118,30 118,30 122,34 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 82
---------------------------------------------------------
UNION ALL
SELECT '5.84'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''83'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 124,35 120,34 120,34 122,31 122,31 124,35 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 83
---------------------------------------------------------
UNION ALL
SELECT '5.85'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''84'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 124,51 123,48 123,48 122,47 122,47 124,51 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 84
---------------------------------------------------------
UNION ALL
SELECT '5.86'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''85'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 123,52 119,50 119,50 122,48 122,48 123,52 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 85
---------------------------------------------------------
UNION ALL
SELECT '5.87'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''86'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 122,50 118,46 118,46 122,50 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 86
---------------------------------------------------------
UNION ALL
SELECT '5.88'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''87'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 123,68 119,66 119,66 120,67 120,67 123,68 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 87
---------------------------------------------------------
UNION ALL
SELECT '5.89'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''88'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 124,67 120,66 120,66 122,63 122,63 124,67 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 88
---------------------------------------------------------
UNION ALL
SELECT '5.90'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''89'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 122,66 118,62 118,62 122,66 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 89
---------------------------------------------------------
UNION ALL
SELECT '5.91'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''90'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 119,82 118,78 118,78 122,80 122,80 119,82 119))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 90
---------------------------------------------------------
UNION ALL
SELECT '5.92'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''91'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 124,83 123,80 123,80 122,79 122,79 124,83 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 91
---------------------------------------------------------
UNION ALL
SELECT '5.93'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''92'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 123,84 119,80 119,80 123,84 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 92
---------------------------------------------------------
UNION ALL
SELECT '5.94'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''93'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 149,2 148,-2 148,-2 152,0 152,0 149,2 149))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 93
---------------------------------------------------------
UNION ALL
SELECT '5.95'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''94'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 153,4 149,0 149,0 153,4 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 94
---------------------------------------------------------
UNION ALL
SELECT '5.96'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''95'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 154,3 153,0 153,0 152,-1 152,-1 154,3 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 95
---------------------------------------------------------
UNION ALL
SELECT '5.97'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''96'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 154,19 153,16 153,16 152,15 152,15 154,19 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 96
---------------------------------------------------------
UNION ALL
SELECT '5.98'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''97'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 149,18 148,14 148,14 152,16 152,16 149,18 149))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 97
---------------------------------------------------------
UNION ALL
SELECT '5.99'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''98'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 153,20 149,16 149,16 153,20 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 98
---------------------------------------------------------
UNION ALL
SELECT '5.100'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''99'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 153,36 149,32 149,32 153,36 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 99
---------------------------------------------------------
UNION ALL
SELECT '5.101'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''100'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 149,34 148,30 148,30 152,32 152,32 149,34 149))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 100
---------------------------------------------------------
UNION ALL
SELECT '5.102'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''101'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 154,35 153,32 153,32 152,31 152,31 154,35 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 101
---------------------------------------------------------
UNION ALL
SELECT '5.103'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''102'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 154,51 153,48 153,48 152,47 152,47 154,51 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 102
---------------------------------------------------------
UNION ALL
SELECT '5.104'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''103'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 153,52 149,50 149,50 152,48 152,48 153,52 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 103
---------------------------------------------------------
UNION ALL
SELECT '5.105'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''104'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 152,50 148,46 148,46 152,50 152))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 104
---------------------------------------------------------
UNION ALL
SELECT '5.106'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''105'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 153,68 149,66 149,66 152,64 152,64 153,68 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 105
---------------------------------------------------------
UNION ALL
SELECT '5.107'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''106'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 154,67 153,64 153,64 152,63 152,63 154,67 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 106
---------------------------------------------------------
UNION ALL
SELECT '5.108'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''107'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 152,66 148,62 148,62 152,66 152))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 107
---------------------------------------------------------
UNION ALL
SELECT '5.109'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''108'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 150,82 148,78 148,78 152,79 152,79 150,82 150))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 108
---------------------------------------------------------
UNION ALL
SELECT '5.110'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''109'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 154,83 150,79 150,79 154,83 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 109
---------------------------------------------------------
UNION ALL
SELECT '5.111'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''110'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 153,84 149,82 149,82 150,83 150,83 153,84 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 110
---------------------------------------------------------
UNION ALL
SELECT '5.112'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''111'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 180,2 178,-2 178,-2 182,-1 182,-1 180,2 180))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 111
---------------------------------------------------------
UNION ALL
SELECT '5.113'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''112'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 183,4 179,2 179,2 180,3 180,3 183,4 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 112
---------------------------------------------------------
UNION ALL
SELECT '5.114'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''113'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 184,3 180,-1 180,-1 184,3 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 113
---------------------------------------------------------
UNION ALL
SELECT '5.115'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''114'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 184,19 180,18 180,18 182,15 182,15 184,19 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 114
---------------------------------------------------------
UNION ALL
SELECT '5.116'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''115'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 182,18 178,14 178,14 182,18 182))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 115
---------------------------------------------------------
UNION ALL
SELECT '5.117'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''116'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 183,20 179,18 179,18 180,19 180,19 183,20 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 116
---------------------------------------------------------
UNION ALL
SELECT '5.118'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''117'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 183,36 179,34 179,34 180,35 180,35 183,36 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 117
---------------------------------------------------------
UNION ALL
SELECT '5.119'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''118'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 180,34 178,30 178,30 182,31 182,31 180,34 180))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 118
---------------------------------------------------------
UNION ALL
SELECT '5.120'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''119'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 184,35 180,31 180,31 184,35 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 119
---------------------------------------------------------
UNION ALL
SELECT '5.121'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''120'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 184,51 180,50 180,50 182,47 182,47 184,51 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 120
---------------------------------------------------------
UNION ALL
SELECT '5.122'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''121'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 183,52 179,50 179,50 180,51 180,51 183,52 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 121
---------------------------------------------------------
UNION ALL
SELECT '5.123'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''122'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 182,50 178,46 178,46 182,50 182))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 122
---------------------------------------------------------
UNION ALL
SELECT '5.124'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''123'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 183,68 179,66 179,66 180,67 180,67 183,68 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 123
---------------------------------------------------------
UNION ALL
SELECT '5.125'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''124'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 184,67 180,66 180,66 182,63 182,63 184,67 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 124
---------------------------------------------------------
UNION ALL
SELECT '5.126'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''125'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 182,66 178,62 178,62 182,66 182))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 125
---------------------------------------------------------
UNION ALL
SELECT '5.127'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''126'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 179,82 178,78 178,78 182,79 182,79 180,80 180,80 179,82 179))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 126
---------------------------------------------------------
UNION ALL
SELECT '5.128'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''127'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 184,83 183,80 183,80 180,79 180,79 184,83 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 127
---------------------------------------------------------
UNION ALL
SELECT '5.129'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''128'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 183,84 179,80 179,80 183,84 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 128
---------------------------------------------------------
UNION ALL
SELECT '5.130'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''129'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 209,2 208,-2 208,-2 212,-1 212,-1 210,0 210,0 209,2 209))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 129
---------------------------------------------------------
UNION ALL
SELECT '5.131'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''130'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 213,4 209,0 209,0 210,3 210,3 213,4 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 130
---------------------------------------------------------
UNION ALL
SELECT '5.132'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''131'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 214,3 210,-1 210,-1 214,3 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 131
---------------------------------------------------------
UNION ALL
SELECT '5.133'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''132'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 214,19 213,16 213,16 212,15 212,15 214,19 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 132
---------------------------------------------------------
UNION ALL
SELECT '5.134'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''133'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 209,18 208,14 208,14 212,16 212,16 209,18 209))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 133
---------------------------------------------------------
UNION ALL
SELECT '5.135'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''134'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 213,20 209,16 209,16 213,20 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 134
---------------------------------------------------------
UNION ALL
SELECT '5.136'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''135'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 213,36 209,34 209,34 210,35 210,35 213,36 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 135
---------------------------------------------------------
UNION ALL
SELECT '5.137'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''136'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 210,34 208,30 208,30 212,31 212,31 210,34 210))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 136
---------------------------------------------------------
UNION ALL
SELECT '5.138'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''137'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 214,35 210,31 210,31 214,35 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 137
---------------------------------------------------------
UNION ALL
SELECT '5.139'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''138'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 214,51 213,48 213,48 212,47 212,47 214,51 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 138
---------------------------------------------------------
UNION ALL
SELECT '5.140'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''139'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 213,52 209,50 209,50 212,48 212,48 213,52 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 139
---------------------------------------------------------
UNION ALL
SELECT '5.141'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''140'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 212,50 208,46 208,46 212,50 212))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 140
---------------------------------------------------------
UNION ALL
SELECT '5.142'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''141'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 213,68 209,66 209,66 210,67 210,67 213,68 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 141
---------------------------------------------------------
UNION ALL
SELECT '5.143'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''142'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 214,67 210,66 210,66 212,63 212,63 214,67 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 142
---------------------------------------------------------
UNION ALL
SELECT '5.144'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''143'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 212,66 208,62 208,62 212,66 212))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 143
---------------------------------------------------------
UNION ALL
SELECT '5.145'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''144'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 209,82 208,78 208,78 212,79 212,79 210,80 210,80 209,82 209))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 144
---------------------------------------------------------
UNION ALL
SELECT '5.146'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''145'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 214,83 213,80 213,80 210,79 210,79 214,83 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 145
---------------------------------------------------------
UNION ALL
SELECT '5.147'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''146'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 213,84 209,80 209,80 213,84 213))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 146
---------------------------------------------------------
UNION ALL
SELECT '5.148'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''147'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 239,2 238,-2 238,-2 242,-1 242,-1 240,0 240,0 239,2 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 147
---------------------------------------------------------
UNION ALL
SELECT '5.149'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''148'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 243,4 239,0 239,0 243,4 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 148
---------------------------------------------------------
UNION ALL
SELECT '5.150'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''149'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 244,3 243,0 243,0 240,-1 240,-1 244,3 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 149
---------------------------------------------------------
UNION ALL
SELECT '5.151'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''150'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 244,19 243,16 243,16 242,15 242,15 244,19 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 150
---------------------------------------------------------
UNION ALL
SELECT '5.152'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''151'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 239,18 238,14 238,14 242,16 242,16 239,18 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 151
---------------------------------------------------------
UNION ALL
SELECT '5.153'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''152'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 243,20 239,16 239,16 243,20 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 152
---------------------------------------------------------
UNION ALL
SELECT '5.154'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''153'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 243,36 239,32 239,32 243,36 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 153
---------------------------------------------------------
UNION ALL
SELECT '5.155'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''154'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 239,34 238,30 238,30 242,31 242,31 240,32 240,32 239,34 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 154
---------------------------------------------------------
UNION ALL
SELECT '5.156'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''155'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 244,35 243,32 243,32 240,31 240,31 244,35 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 155
---------------------------------------------------------
UNION ALL
SELECT '5.157'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''156'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 244,51 243,48 243,48 242,47 242,47 244,51 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 156
---------------------------------------------------------
UNION ALL
SELECT '5.158'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''157'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 243,52 239,48 239,48 243,52 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 157
---------------------------------------------------------
UNION ALL
SELECT '5.159'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''158'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 239,50 238,46 238,46 242,48 242,48 239,50 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 158
---------------------------------------------------------
UNION ALL
SELECT '5.160'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''159'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 243,68 239,64 239,64 243,68 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 159
---------------------------------------------------------
UNION ALL
SELECT '5.161'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''160'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 244,67 243,64 243,64 242,63 242,63 244,67 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 160
---------------------------------------------------------
UNION ALL
SELECT '5.162'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''161'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 239,66 238,62 238,62 242,64 242,64 239,66 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 161
---------------------------------------------------------
UNION ALL
SELECT '5.163'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''162'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 239,82 238,78 238,78 242,79 242,79 240,80 240,80 239,82 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 162
---------------------------------------------------------
UNION ALL
SELECT '5.164'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''163'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 244,83 243,80 243,80 240,79 240,79 244,83 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 163
---------------------------------------------------------
UNION ALL
SELECT '5.165'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''164'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 243,84 239,80 239,80 243,84 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 164
---------------------------------------------------------
UNION ALL
SELECT '5.166'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''165'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 269,2 268,-2 268,-2 272,-1 272,-1 270,0 270,0 269,2 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 165
---------------------------------------------------------
UNION ALL
SELECT '5.167'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''166'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 273,4 269,0 269,0 273,4 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 166
---------------------------------------------------------
UNION ALL
SELECT '5.168'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''167'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 274,3 273,0 273,0 270,-1 270,-1 274,3 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 167
---------------------------------------------------------
UNION ALL
SELECT '5.169'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''168'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 274,19 273,16 273,16 272,15 272,15 274,19 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 168
---------------------------------------------------------
UNION ALL
SELECT '5.170'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''169'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 269,18 268,14 268,14 272,16 272,16 269,18 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 169
---------------------------------------------------------
UNION ALL
SELECT '5.171'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''170'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 273,20 269,16 269,16 273,20 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 170
---------------------------------------------------------
UNION ALL
SELECT '5.172'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''171'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 273,36 269,32 269,32 273,36 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 171
---------------------------------------------------------
UNION ALL
SELECT '5.173'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''172'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 269,34 268,30 268,30 272,31 272,31 270,32 270,32 269,34 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 172
---------------------------------------------------------
UNION ALL
SELECT '5.174'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''173'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 274,35 273,32 273,32 270,31 270,31 274,35 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 173
---------------------------------------------------------
UNION ALL
SELECT '5.175'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''174'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 274,51 273,48 273,48 272,47 272,47 274,51 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 174
---------------------------------------------------------
UNION ALL
SELECT '5.176'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''175'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 273,52 269,48 269,48 273,52 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 175
---------------------------------------------------------
UNION ALL
SELECT '5.177'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''176'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 269,50 268,46 268,46 272,48 272,48 269,50 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 176
---------------------------------------------------------
UNION ALL
SELECT '5.178'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''177'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 273,68 269,64 269,64 273,68 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 177
---------------------------------------------------------
UNION ALL
SELECT '5.179'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''178'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 274,67 273,64 273,64 272,63 272,63 274,67 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 178
---------------------------------------------------------
UNION ALL
SELECT '5.180'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''179'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 269,66 268,62 268,62 272,64 272,64 269,66 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 179
---------------------------------------------------------
UNION ALL
SELECT '5.181'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''180'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 269,82 268,78 268,78 272,79 272,79 270,80 270,80 269,82 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 180
---------------------------------------------------------
UNION ALL
SELECT '5.182'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''181'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 274,83 270,79 270,79 274,83 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 181
---------------------------------------------------------
UNION ALL
SELECT '5.183'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''182'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 273,84 269,80 269,80 270,83 270,83 273,84 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 182
---------------------------------------------------------
UNION ALL
SELECT '5.184'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''183'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 299,2 298,-2 298,-2 302,-1 302,-1 300,0 300,0 299,2 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 183
---------------------------------------------------------
UNION ALL
SELECT '5.185'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''184'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 303,4 299,0 299,0 300,3 300,3 303,4 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 184
---------------------------------------------------------
UNION ALL
SELECT '5.186'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''185'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 304,3 300,-1 300,-1 304,3 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 185
---------------------------------------------------------
UNION ALL
SELECT '5.187'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''186'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 304,19 300,15 300,15 304,19 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 186
---------------------------------------------------------
UNION ALL
SELECT '5.188'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''187'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 299,18 298,14 298,14 302,15 302,15 300,16 300,16 299,18 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 187
---------------------------------------------------------
UNION ALL
SELECT '5.189'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''188'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 303,20 299,16 299,16 300,19 300,19 303,20 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 188
---------------------------------------------------------
UNION ALL
SELECT '5.190'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''189'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 303,36 299,32 299,32 300,35 300,35 303,36 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 189
---------------------------------------------------------
UNION ALL
SELECT '5.191'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''190'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 299,34 298,30 298,30 302,31 302,31 300,32 300,32 299,34 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 190
---------------------------------------------------------
UNION ALL
SELECT '5.192'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''191'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 304,35 300,31 300,31 304,35 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 191
---------------------------------------------------------
UNION ALL
SELECT '5.193'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''192'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 304,51 300,47 300,47 304,51 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 192
---------------------------------------------------------
UNION ALL
SELECT '5.194'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''193'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 303,52 299,48 299,48 300,51 300,51 303,52 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 193
---------------------------------------------------------
UNION ALL
SELECT '5.195'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''194'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 299,50 298,46 298,46 302,47 302,47 300,48 300,48 299,50 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 194
---------------------------------------------------------
UNION ALL
SELECT '5.196'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''195'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 303,68 299,64 299,64 300,67 300,67 303,68 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 195
---------------------------------------------------------
UNION ALL
SELECT '5.197'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''196'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 304,67 300,63 300,63 304,67 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 196
---------------------------------------------------------
UNION ALL
SELECT '5.198'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''197'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 299,66 298,62 298,62 302,63 302,63 300,64 300,64 299,66 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 197
---------------------------------------------------------
UNION ALL
SELECT '5.199'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''198'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 299,82 298,78 298,78 302,79 302,79 300,80 300,80 299,82 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 198
---------------------------------------------------------
UNION ALL
SELECT '5.200'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''199'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 199
---------------------------------------------------------
UNION ALL
SELECT '5.201'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''199'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 304,83 300,79 300,79 304,83 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 200
---------------------------------------------------------
UNION ALL
SELECT '5.202'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''199'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 304,83 303,80 303,80 300,79 300,79 304,83 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 201
---------------------------------------------------------
UNION ALL
SELECT '5.203'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''200'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 303,84 299,80 299,80 303,84 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 202
---------------------------------------------------------
UNION ALL
SELECT '5.204'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''200'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 303,84 299,80 299,80 300,83 300,83 303,84 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 203
---------------------------------------------------------
UNION ALL
SELECT '5.205'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''201'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 329,2 328,-2 328,-2 332,-1 332,-1 330,0 330,0 329,2 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 204
---------------------------------------------------------
UNION ALL
SELECT '5.206'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''202'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 333,4 329,0 329,0 333,4 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 205
---------------------------------------------------------
UNION ALL
SELECT '5.207'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''202'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 333,4 329,0 329,0 330,3 330,3 333,4 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 206
---------------------------------------------------------
UNION ALL
SELECT '5.208'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''203'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 334,3 333,0 333,0 330,-1 330,-1 334,3 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 207
---------------------------------------------------------
UNION ALL
SELECT '5.209'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''203'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 334,3 330,-1 330,-1 334,3 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 208
---------------------------------------------------------
UNION ALL
SELECT '5.210'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''203'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 209
---------------------------------------------------------
UNION ALL
SELECT '5.211'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''204'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 334,19 333,16 333,16 330,15 330,15 334,19 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 210
---------------------------------------------------------
UNION ALL
SELECT '5.212'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''204'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 334,19 330,15 330,15 334,19 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 211
---------------------------------------------------------
UNION ALL
SELECT '5.213'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''204'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 212
---------------------------------------------------------
UNION ALL
SELECT '5.214'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''205'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 329,18 328,14 328,14 332,15 332,15 330,16 330,16 329,18 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 213
---------------------------------------------------------
UNION ALL
SELECT '5.215'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''206'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 333,20 329,16 329,16 330,19 330,19 333,20 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 214
---------------------------------------------------------
UNION ALL
SELECT '5.216'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''206'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 333,20 329,16 329,16 333,20 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 215
---------------------------------------------------------
UNION ALL
SELECT '5.217'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''207'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 333,36 329,32 329,32 330,35 330,35 333,36 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 216
---------------------------------------------------------
UNION ALL
SELECT '5.218'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''207'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 333,36 329,32 329,32 333,36 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 217
---------------------------------------------------------
UNION ALL
SELECT '5.219'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''208'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 329,34 328,30 328,30 332,31 332,31 330,32 330,32 329,34 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 218
---------------------------------------------------------
UNION ALL
SELECT '5.220'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''209'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 219
---------------------------------------------------------
UNION ALL
SELECT '5.221'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''209'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 334,35 333,32 333,32 330,31 330,31 334,35 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 220
---------------------------------------------------------
UNION ALL
SELECT '5.222'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''209'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 334,35 330,31 330,31 334,35 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 221
---------------------------------------------------------
UNION ALL
SELECT '5.223'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''210'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 222
---------------------------------------------------------
UNION ALL
SELECT '5.224'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''210'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 334,51 333,48 333,48 330,47 330,47 334,51 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 223
---------------------------------------------------------
UNION ALL
SELECT '5.225'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''210'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 334,51 330,47 330,47 334,51 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 224
---------------------------------------------------------
UNION ALL
SELECT '5.226'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''211'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 333,52 329,48 329,48 333,52 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 225
---------------------------------------------------------
UNION ALL
SELECT '5.227'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''211'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 333,52 329,48 329,48 330,51 330,51 333,52 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 226
---------------------------------------------------------
UNION ALL
SELECT '5.228'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''212'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 329,50 328,46 328,46 332,47 332,47 330,48 330,48 329,50 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 227
---------------------------------------------------------
UNION ALL
SELECT '5.229'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''213'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 333,68 329,64 329,64 330,67 330,67 333,68 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 228
---------------------------------------------------------
UNION ALL
SELECT '5.230'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''213'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 333,68 329,64 329,64 333,68 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 229
---------------------------------------------------------
UNION ALL
SELECT '5.231'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''214'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 230
---------------------------------------------------------
UNION ALL
SELECT '5.232'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''214'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 334,67 330,63 330,63 334,67 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 231
---------------------------------------------------------
UNION ALL
SELECT '5.233'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''214'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 334,67 333,64 333,64 330,63 330,63 334,67 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 232
---------------------------------------------------------
UNION ALL
SELECT '5.234'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''215'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 329,66 328,62 328,62 332,63 332,63 330,64 330,64 329,66 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 233
---------------------------------------------------------
UNION ALL
SELECT '5.235'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''216'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 332,82 328,78 328,78 332,82 332))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 234
---------------------------------------------------------
UNION ALL
SELECT '5.236'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''217'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 334,83 333,80 333,80 332,79 332,79 334,83 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 235
---------------------------------------------------------
UNION ALL
SELECT '5.237'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''218'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 333,84 329,82 329,82 332,80 332,80 333,84 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 236
---------------------------------------------------------
UNION ALL
SELECT '5.238'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''219'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 362,2 358,-2 358,-2 362,2 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 237
---------------------------------------------------------
UNION ALL
SELECT '5.239'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''220'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 363,4 359,2 359,2 362,0 362,0 363,4 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 238
---------------------------------------------------------
UNION ALL
SELECT '5.240'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''221'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 364,3 363,0 363,0 362,-1 362,-1 364,3 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 239
---------------------------------------------------------
UNION ALL
SELECT '5.241'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''222'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 364,19 363,16 363,16 362,15 362,15 364,19 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 240
---------------------------------------------------------
UNION ALL
SELECT '5.242'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''223'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 362,18 358,14 358,14 362,18 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 241
---------------------------------------------------------
UNION ALL
SELECT '5.243'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''224'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 363,20 359,18 359,18 362,16 362,16 363,20 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 242
---------------------------------------------------------
UNION ALL
SELECT '5.244'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''225'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 363,36 359,34 359,34 362,32 362,32 363,36 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 243
---------------------------------------------------------
UNION ALL
SELECT '5.245'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''226'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 362,34 358,30 358,30 362,34 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 244
---------------------------------------------------------
UNION ALL
SELECT '5.246'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''227'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 364,35 363,32 363,32 362,31 362,31 364,35 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 245
---------------------------------------------------------
UNION ALL
SELECT '5.247'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''228'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 364,51 363,48 363,48 362,47 362,47 364,51 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 246
---------------------------------------------------------
UNION ALL
SELECT '5.248'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''229'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 363,52 359,50 359,50 362,48 362,48 363,52 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 247
---------------------------------------------------------
UNION ALL
SELECT '5.249'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''230'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 362,50 358,46 358,46 362,50 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 248
---------------------------------------------------------
UNION ALL
SELECT '5.250'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''231'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 363,68 359,66 359,66 362,64 362,64 363,68 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 249
---------------------------------------------------------
UNION ALL
SELECT '5.251'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''232'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 364,67 363,64 363,64 362,63 362,63 364,67 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 250
---------------------------------------------------------
UNION ALL
SELECT '5.252'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''233'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 362,66 358,62 358,62 362,66 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 251
---------------------------------------------------------
UNION ALL
SELECT '5.253'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''234'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 362,82 358,78 358,78 362,82 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 252
---------------------------------------------------------
UNION ALL
SELECT '5.254'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''234'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 253
---------------------------------------------------------
UNION ALL
SELECT '5.255'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''234'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 359,82 358,78 358,78 362,80 362,80 359,82 359))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 254
---------------------------------------------------------
UNION ALL
SELECT '5.256'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''235'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 364,83 363,80 363,80 362,79 362,79 364,83 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 255
---------------------------------------------------------
UNION ALL
SELECT '5.257'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''236'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 363,84 359,80 359,80 363,84 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 256
---------------------------------------------------------
UNION ALL
SELECT '5.258'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''236'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 363,84 359,82 359,82 362,80 362,80 363,84 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 257
---------------------------------------------------------
UNION ALL
SELECT '5.259'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''237'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 392,2 388,-2 388,-2 392,2 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 258
---------------------------------------------------------
UNION ALL
SELECT '5.260'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''237'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 259
---------------------------------------------------------
UNION ALL
SELECT '5.261'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''237'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 389,2 388,-2 388,-2 392,0 392,0 389,2 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 260
---------------------------------------------------------
UNION ALL
SELECT '5.262'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''238'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 393,4 389,0 389,0 393,4 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 261
---------------------------------------------------------
UNION ALL
SELECT '5.263'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''238'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 393,4 389,2 389,2 392,0 392,0 393,4 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 262
---------------------------------------------------------
UNION ALL
SELECT '5.264'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''239'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 394,3 393,0 393,0 392,-1 392,-1 394,3 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 263
---------------------------------------------------------
UNION ALL
SELECT '5.265'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''240'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 394,19 393,16 393,16 392,15 392,15 394,19 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 264
---------------------------------------------------------
UNION ALL
SELECT '5.266'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''241'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 265
---------------------------------------------------------
UNION ALL
SELECT '5.267'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''241'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 389,18 388,14 388,14 392,16 392,16 389,18 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 266
---------------------------------------------------------
UNION ALL
SELECT '5.268'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''241'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 392,18 388,14 388,14 392,18 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 267
---------------------------------------------------------
UNION ALL
SELECT '5.269'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''242'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 393,20 389,18 389,18 392,16 392,16 393,20 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 268
---------------------------------------------------------
UNION ALL
SELECT '5.270'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''242'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 393,20 389,16 389,16 393,20 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 269
---------------------------------------------------------
UNION ALL
SELECT '5.271'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''243'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 393,36 389,32 389,32 393,36 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 270
---------------------------------------------------------
UNION ALL
SELECT '5.272'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''243'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 393,36 389,34 389,34 392,32 392,32 393,36 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 271
---------------------------------------------------------
UNION ALL
SELECT '5.273'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''244'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 389,34 388,30 388,30 392,32 392,32 389,34 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 272
---------------------------------------------------------
UNION ALL
SELECT '5.274'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''244'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 273
---------------------------------------------------------
UNION ALL
SELECT '5.275'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''244'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 392,34 388,30 388,30 392,34 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 274
---------------------------------------------------------
UNION ALL
SELECT '5.276'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''245'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 394,35 393,32 393,32 392,31 392,31 394,35 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 275
---------------------------------------------------------
UNION ALL
SELECT '5.277'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''246'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 394,51 393,48 393,48 392,47 392,47 394,51 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 276
---------------------------------------------------------
UNION ALL
SELECT '5.278'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''247'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 393,52 389,48 389,48 393,52 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 277
---------------------------------------------------------
UNION ALL
SELECT '5.279'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''247'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 393,52 389,50 389,50 392,48 392,48 393,52 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 278
---------------------------------------------------------
UNION ALL
SELECT '5.280'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''248'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 389,50 388,46 388,46 392,48 392,48 389,50 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 279
---------------------------------------------------------
UNION ALL
SELECT '5.281'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''248'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 392,50 388,46 388,46 392,50 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 280
---------------------------------------------------------
UNION ALL
SELECT '5.282'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''248'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 281
---------------------------------------------------------
UNION ALL
SELECT '5.283'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''249'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 393,68 389,64 389,64 393,68 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 282
---------------------------------------------------------
UNION ALL
SELECT '5.284'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''249'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 393,68 389,66 389,66 392,64 392,64 393,68 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 283
---------------------------------------------------------
UNION ALL
SELECT '5.285'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''250'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 394,67 393,64 393,64 392,63 392,63 394,67 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 284
---------------------------------------------------------
UNION ALL
SELECT '5.286'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''251'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 392,66 388,62 388,62 392,66 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 285
---------------------------------------------------------
UNION ALL
SELECT '5.287'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''251'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 389,66 388,62 388,62 392,64 392,64 389,66 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 286
---------------------------------------------------------
UNION ALL
SELECT '5.288'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''251'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 287
---------------------------------------------------------
UNION ALL
SELECT '5.289'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''252'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 390,82 388,78 388,78 392,79 392,79 390,82 390))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 288
---------------------------------------------------------
UNION ALL
SELECT '5.290'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''253'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 394,83 390,79 390,79 394,83 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 289
---------------------------------------------------------
UNION ALL
SELECT '5.291'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''254'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 393,84 389,82 389,82 390,83 390,83 393,84 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 290
---------------------------------------------------------
UNION ALL
SELECT '5.292'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''255'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 420,2 418,-2 418,-2 422,-1 422,-1 420,2 420))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 291
---------------------------------------------------------
UNION ALL
SELECT '5.293'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''256'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 423,4 419,2 419,2 420,3 420,3 423,4 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 292
---------------------------------------------------------
UNION ALL
SELECT '5.294'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''257'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 424,3 420,-1 420,-1 424,3 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 293
---------------------------------------------------------
UNION ALL
SELECT '5.295'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''258'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 424,19 420,18 420,18 422,15 422,15 424,19 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 294
---------------------------------------------------------
UNION ALL
SELECT '5.296'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''259'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 422,18 418,14 418,14 422,18 422))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 295
---------------------------------------------------------
UNION ALL
SELECT '5.297'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''260'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 423,20 419,18 419,18 420,19 420,19 423,20 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 296
---------------------------------------------------------
UNION ALL
SELECT '5.298'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''261'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 423,36 419,34 419,34 420,35 420,35 423,36 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 297
---------------------------------------------------------
UNION ALL
SELECT '5.299'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''262'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 420,34 418,30 418,30 422,31 422,31 420,34 420))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 298
---------------------------------------------------------
UNION ALL
SELECT '5.300'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''263'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 424,35 420,31 420,31 424,35 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 299
---------------------------------------------------------
UNION ALL
SELECT '5.301'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''264'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 424,51 420,50 420,50 422,47 422,47 424,51 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 300
---------------------------------------------------------
UNION ALL
SELECT '5.302'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''265'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 423,52 419,50 419,50 420,51 420,51 423,52 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 301
---------------------------------------------------------
UNION ALL
SELECT '5.303'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''266'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 422,50 418,46 418,46 422,50 422))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 302
---------------------------------------------------------
UNION ALL
SELECT '5.304'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''267'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 423,68 419,66 419,66 420,67 420,67 423,68 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 303
---------------------------------------------------------
UNION ALL
SELECT '5.305'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''268'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 424,67 420,66 420,66 422,63 422,63 424,67 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 304
---------------------------------------------------------
UNION ALL
SELECT '5.306'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''269'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 422,66 418,62 418,62 422,66 422))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 305
---------------------------------------------------------
UNION ALL
SELECT '5.307'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''270'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 420,82 418,78 418,78 422,79 422,79 420,82 420))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 306
---------------------------------------------------------
UNION ALL
SELECT '5.308'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''270'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 419,82 418,78 418,78 422,79 422,79 420,80 420,80 419,82 419))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 307
---------------------------------------------------------
UNION ALL
SELECT '5.309'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''270'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 308
---------------------------------------------------------
UNION ALL
SELECT '5.310'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''271'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 424,83 423,80 423,80 420,79 420,79 424,83 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 309
---------------------------------------------------------
UNION ALL
SELECT '5.311'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''271'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 424,83 420,79 420,79 424,83 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 310
---------------------------------------------------------
UNION ALL
SELECT '5.312'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''271'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 311
---------------------------------------------------------
UNION ALL
SELECT '5.313'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''272'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 423,84 419,82 419,82 420,83 420,83 423,84 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 312
---------------------------------------------------------
UNION ALL
SELECT '5.314'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''272'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 423,84 419,80 419,80 423,84 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 313
---------------------------------------------------------
UNION ALL
SELECT '5.315'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''273'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 449,2 448,-2 448,-2 452,-1 452,-1 450,0 450,0 449,2 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 314
---------------------------------------------------------
UNION ALL
SELECT '5.316'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''273'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 315
---------------------------------------------------------
UNION ALL
SELECT '5.317'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''273'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 450,2 448,-2 448,-2 452,-1 452,-1 450,2 450))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 316
---------------------------------------------------------
UNION ALL
SELECT '5.318'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''274'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 453,4 449,0 449,0 453,4 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 317
---------------------------------------------------------
UNION ALL
SELECT '5.319'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''274'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 453,4 449,2 449,2 450,3 450,3 453,4 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 318
---------------------------------------------------------
UNION ALL
SELECT '5.320'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''275'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 454,3 453,0 453,0 450,-1 450,-1 454,3 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 319
---------------------------------------------------------
UNION ALL
SELECT '5.321'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''275'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 454,3 450,-1 450,-1 454,3 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 320
---------------------------------------------------------
UNION ALL
SELECT '5.322'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''275'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 321
---------------------------------------------------------
UNION ALL
SELECT '5.323'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''276'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 322
---------------------------------------------------------
UNION ALL
SELECT '5.324'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''276'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 454,19 453,16 453,16 452,15 452,15 454,19 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 323
---------------------------------------------------------
UNION ALL
SELECT '5.325'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''276'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 454,19 450,18 450,18 452,15 452,15 454,19 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 324
---------------------------------------------------------
UNION ALL
SELECT '5.326'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''277'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 449,18 448,14 448,14 452,16 452,16 449,18 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 325
---------------------------------------------------------
UNION ALL
SELECT '5.327'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''277'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 326
---------------------------------------------------------
UNION ALL
SELECT '5.328'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''277'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 452,18 448,14 448,14 452,18 452))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 327
---------------------------------------------------------
UNION ALL
SELECT '5.329'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''278'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 453,20 449,16 449,16 453,20 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 328
---------------------------------------------------------
UNION ALL
SELECT '5.330'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''278'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 453,20 449,18 449,18 450,19 450,19 453,20 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 329
---------------------------------------------------------
UNION ALL
SELECT '5.331'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''279'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 453,36 449,34 449,34 450,35 450,35 453,36 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 330
---------------------------------------------------------
UNION ALL
SELECT '5.332'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''279'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 453,36 449,32 449,32 453,36 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 331
---------------------------------------------------------
UNION ALL
SELECT '5.333'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''280'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 449,34 448,30 448,30 452,31 452,31 450,32 450,32 449,34 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 332
---------------------------------------------------------
UNION ALL
SELECT '5.334'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''280'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 333
---------------------------------------------------------
UNION ALL
SELECT '5.335'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''280'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 450,34 448,30 448,30 452,31 452,31 450,34 450))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 334
---------------------------------------------------------
UNION ALL
SELECT '5.336'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''281'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 335
---------------------------------------------------------
UNION ALL
SELECT '5.337'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''281'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 454,35 450,31 450,31 454,35 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 336
---------------------------------------------------------
UNION ALL
SELECT '5.338'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''281'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 454,35 453,32 453,32 450,31 450,31 454,35 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 337
---------------------------------------------------------
UNION ALL
SELECT '5.339'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''282'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 454,51 453,48 453,48 452,47 452,47 454,51 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 338
---------------------------------------------------------
UNION ALL
SELECT '5.340'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''282'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 339
---------------------------------------------------------
UNION ALL
SELECT '5.341'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''282'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 454,51 450,50 450,50 452,47 452,47 454,51 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 340
---------------------------------------------------------
UNION ALL
SELECT '5.342'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''283'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 453,52 449,50 449,50 450,51 450,51 453,52 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 341
---------------------------------------------------------
UNION ALL
SELECT '5.343'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''283'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 453,52 449,48 449,48 453,52 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 342
---------------------------------------------------------
UNION ALL
SELECT '5.344'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''284'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 343
---------------------------------------------------------
UNION ALL
SELECT '5.345'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''284'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 449,50 448,46 448,46 452,48 452,48 449,50 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 344
---------------------------------------------------------
UNION ALL
SELECT '5.346'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''284'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 452,50 448,46 448,46 452,50 452))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 345
---------------------------------------------------------
UNION ALL
SELECT '5.347'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''285'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 453,68 449,66 449,66 450,67 450,67 453,68 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 346
---------------------------------------------------------
UNION ALL
SELECT '5.348'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''285'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 453,68 449,64 449,64 453,68 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 347
---------------------------------------------------------
UNION ALL
SELECT '5.349'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''286'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 454,67 453,64 453,64 452,63 452,63 454,67 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 348
---------------------------------------------------------
UNION ALL
SELECT '5.350'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''286'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 454,67 450,66 450,66 452,63 452,63 454,67 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 349
---------------------------------------------------------
UNION ALL
SELECT '5.351'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''286'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 350
---------------------------------------------------------
UNION ALL
SELECT '5.352'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''287'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 449,66 448,62 448,62 452,64 452,64 449,66 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 351
---------------------------------------------------------
UNION ALL
SELECT '5.353'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''287'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 452,66 448,62 448,62 452,66 452))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 352
---------------------------------------------------------
UNION ALL
SELECT '5.354'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''287'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 353
---------------------------------------------------------
UNION ALL
SELECT '5.355'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''288'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 449,82 448,78 448,78 452,79 452,79 450,80 450,80 449,82 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 354
---------------------------------------------------------
UNION ALL
SELECT '5.356'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''289'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 454,83 453,80 453,80 450,79 450,79 454,83 454))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 355
---------------------------------------------------------
UNION ALL
SELECT '5.357'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''290'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 453,84 449,80 449,80 453,84 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 356
---------------------------------------------------------
UNION ALL
SELECT '5.358'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''291'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 479,2 478,-2 478,-2 482,-1 482,-1 480,0 480,0 479,2 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 357
---------------------------------------------------------
UNION ALL
SELECT '5.359'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''292'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 483,4 479,0 479,0 480,3 480,3 483,4 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 358
---------------------------------------------------------
UNION ALL
SELECT '5.360'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''293'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 484,3 480,-1 480,-1 484,3 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 359
---------------------------------------------------------
UNION ALL
SELECT '5.361'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''294'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 484,19 483,16 483,16 480,15 480,15 484,19 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 360
---------------------------------------------------------
UNION ALL
SELECT '5.362'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''295'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 479,18 478,14 478,14 482,15 482,15 480,16 480,16 479,18 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 361
---------------------------------------------------------
UNION ALL
SELECT '5.363'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''296'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 483,20 479,16 479,16 483,20 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 362
---------------------------------------------------------
UNION ALL
SELECT '5.364'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''297'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 483,36 479,32 479,32 480,35 480,35 483,36 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 363
---------------------------------------------------------
UNION ALL
SELECT '5.365'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''298'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 479,34 478,30 478,30 482,31 482,31 480,32 480,32 479,34 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 364
---------------------------------------------------------
UNION ALL
SELECT '5.366'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''299'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 484,35 480,31 480,31 484,35 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 365
---------------------------------------------------------
UNION ALL
SELECT '5.367'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''300'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 484,51 483,48 483,48 480,47 480,47 484,51 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 366
---------------------------------------------------------
UNION ALL
SELECT '5.368'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''301'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 483,52 479,48 479,48 483,52 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 367
---------------------------------------------------------
UNION ALL
SELECT '5.369'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''302'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 479,50 478,46 478,46 482,47 482,47 480,48 480,48 479,50 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 368
---------------------------------------------------------
UNION ALL
SELECT '5.370'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''303'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 483,68 479,64 479,64 480,67 480,67 483,68 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 369
---------------------------------------------------------
UNION ALL
SELECT '5.371'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''304'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 484,67 480,63 480,63 484,67 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 370
---------------------------------------------------------
UNION ALL
SELECT '5.372'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''305'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 479,66 478,62 478,62 482,63 482,63 480,64 480,64 479,66 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 371
---------------------------------------------------------
UNION ALL
SELECT '5.373'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''306'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 479,82 478,78 478,78 482,79 482,79 480,80 480,80 479,82 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 372
---------------------------------------------------------
UNION ALL
SELECT '5.374'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''307'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 484,83 483,80 483,80 480,79 480,79 484,83 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 373
---------------------------------------------------------
UNION ALL
SELECT '5.375'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''308'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 483,84 479,80 479,80 483,84 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 374
---------------------------------------------------------
UNION ALL
SELECT '5.376'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''309'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 509,2 508,-2 508,-2 512,-1 512,-1 510,0 510,0 509,2 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 375
---------------------------------------------------------
UNION ALL
SELECT '5.377'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''310'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 513,4 509,0 509,0 513,4 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 376
---------------------------------------------------------
UNION ALL
SELECT '5.378'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''311'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 514,3 513,0 513,0 510,-1 510,-1 514,3 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 377
---------------------------------------------------------
UNION ALL
SELECT '5.379'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''312'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 514,19 513,16 513,16 510,15 510,15 514,19 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 378
---------------------------------------------------------
UNION ALL
SELECT '5.380'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''313'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 509,18 508,14 508,14 512,15 512,15 510,16 510,16 509,18 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 379
---------------------------------------------------------
UNION ALL
SELECT '5.381'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''314'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 513,20 509,16 509,16 513,20 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 380
---------------------------------------------------------
UNION ALL
SELECT '5.382'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''315'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 513,36 509,32 509,32 513,36 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 381
---------------------------------------------------------
UNION ALL
SELECT '5.383'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''316'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 509,34 508,30 508,30 512,31 512,31 510,32 510,32 509,34 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 382
---------------------------------------------------------
UNION ALL
SELECT '5.384'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''317'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 514,35 513,32 513,32 510,31 510,31 514,35 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 383
---------------------------------------------------------
UNION ALL
SELECT '5.385'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''318'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 514,51 513,48 513,48 510,47 510,47 514,51 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 384
---------------------------------------------------------
UNION ALL
SELECT '5.386'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''319'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 513,52 509,48 509,48 513,52 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 385
---------------------------------------------------------
UNION ALL
SELECT '5.387'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''320'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 509,50 508,46 508,46 512,47 512,47 510,48 510,48 509,50 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 386
---------------------------------------------------------
UNION ALL
SELECT '5.388'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''321'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 513,68 509,64 509,64 513,68 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 387
---------------------------------------------------------
UNION ALL
SELECT '5.389'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''322'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 514,67 513,64 513,64 510,63 510,63 514,67 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 388
---------------------------------------------------------
UNION ALL
SELECT '5.390'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''323'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 509,66 508,62 508,62 512,63 512,63 510,64 510,64 509,66 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 389
---------------------------------------------------------
UNION ALL
SELECT '5.391'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''324'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 509,82 508,78 508,78 512,79 512,79 510,80 510,80 509,82 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 390
---------------------------------------------------------
UNION ALL
SELECT '5.392'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''325'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 514,83 510,79 510,79 514,83 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 391
---------------------------------------------------------
UNION ALL
SELECT '5.393'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''326'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 513,84 509,80 509,80 510,83 510,83 513,84 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 392
---------------------------------------------------------
UNION ALL
SELECT '5.394'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''327'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 539,2 538,-2 538,-2 542,-1 542,-1 540,0 540,0 539,2 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 393
---------------------------------------------------------
UNION ALL
SELECT '5.395'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''328'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 543,4 539,0 539,0 540,3 540,3 543,4 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 394
---------------------------------------------------------
UNION ALL
SELECT '5.396'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''329'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 544,3 540,-1 540,-1 544,3 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 395
---------------------------------------------------------
UNION ALL
SELECT '5.397'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''330'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 544,19 540,15 540,15 544,19 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 396
---------------------------------------------------------
UNION ALL
SELECT '5.398'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''331'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 539,18 538,14 538,14 542,15 542,15 540,16 540,16 539,18 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 397
---------------------------------------------------------
UNION ALL
SELECT '5.399'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''332'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 543,20 539,16 539,16 540,19 540,19 543,20 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 398
---------------------------------------------------------
UNION ALL
SELECT '5.400'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''333'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 543,36 539,32 539,32 540,35 540,35 543,36 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 399
---------------------------------------------------------
UNION ALL
SELECT '5.401'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''334'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 539,34 538,30 538,30 542,31 542,31 540,32 540,32 539,34 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 400
---------------------------------------------------------
UNION ALL
SELECT '5.402'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''335'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 544,35 540,31 540,31 544,35 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 401
---------------------------------------------------------
UNION ALL
SELECT '5.403'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''336'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 544,51 540,47 540,47 544,51 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 402
---------------------------------------------------------
UNION ALL
SELECT '5.404'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''337'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 543,52 539,48 539,48 540,51 540,51 543,52 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 403
---------------------------------------------------------
UNION ALL
SELECT '5.405'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''338'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 539,50 538,46 538,46 542,47 542,47 540,48 540,48 539,50 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 404
---------------------------------------------------------
UNION ALL
SELECT '5.406'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''339'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 543,68 539,64 539,64 540,67 540,67 543,68 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 405
---------------------------------------------------------
UNION ALL
SELECT '5.407'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''340'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 544,67 540,63 540,63 544,67 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 406
---------------------------------------------------------
UNION ALL
SELECT '5.408'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''341'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 539,66 538,62 538,62 542,63 542,63 540,64 540,64 539,66 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 407
---------------------------------------------------------
UNION ALL
SELECT '5.409'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''342'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 539,82 538,78 538,78 542,79 542,79 540,80 540,80 539,82 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 408
---------------------------------------------------------
UNION ALL
SELECT '5.410'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''343'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 544,83 543,80 543,80 540,79 540,79 544,83 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 409
---------------------------------------------------------
UNION ALL
SELECT '5.411'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''344'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 543,84 539,80 539,80 543,84 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 410
---------------------------------------------------------
UNION ALL
SELECT '5.412'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''345'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 569,2 568,-2 568,-2 572,-1 572,-1 570,0 570,0 569,2 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 411
---------------------------------------------------------
UNION ALL
SELECT '5.413'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''346'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 573,4 569,0 569,0 570,3 570,3 573,4 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 412
---------------------------------------------------------
UNION ALL
SELECT '5.414'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''347'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 574,3 570,-1 570,-1 574,3 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 413
---------------------------------------------------------
UNION ALL
SELECT '5.415'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''348'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 574,19 573,16 573,16 570,15 570,15 574,19 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 414
---------------------------------------------------------
UNION ALL
SELECT '5.416'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''349'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 569,18 568,14 568,14 572,15 572,15 570,16 570,16 569,18 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 415
---------------------------------------------------------
UNION ALL
SELECT '5.417'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''350'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 573,20 569,16 569,16 573,20 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 416
---------------------------------------------------------
UNION ALL
SELECT '5.418'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''351'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 573,36 569,32 569,32 570,35 570,35 573,36 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 417
---------------------------------------------------------
UNION ALL
SELECT '5.419'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''352'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 569,34 568,30 568,30 572,31 572,31 570,32 570,32 569,34 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 418
---------------------------------------------------------
UNION ALL
SELECT '5.420'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''353'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 574,35 570,31 570,31 574,35 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 419
---------------------------------------------------------
UNION ALL
SELECT '5.421'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''354'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 574,51 573,48 573,48 570,47 570,47 574,51 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 420
---------------------------------------------------------
UNION ALL
SELECT '5.422'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''355'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 573,52 569,48 569,48 573,52 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 421
---------------------------------------------------------
UNION ALL
SELECT '5.423'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''356'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 569,50 568,46 568,46 572,47 572,47 570,48 570,48 569,50 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 422
---------------------------------------------------------
UNION ALL
SELECT '5.424'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''357'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 573,68 569,64 569,64 570,67 570,67 573,68 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 423
---------------------------------------------------------
UNION ALL
SELECT '5.425'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''358'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 574,67 570,63 570,63 574,67 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 424
---------------------------------------------------------
UNION ALL
SELECT '5.426'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''359'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 569,66 568,62 568,62 572,63 572,63 570,64 570,64 569,66 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 425
---------------------------------------------------------
UNION ALL
SELECT '5.427'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''360'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 572,82 568,78 568,78 572,82 572))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 426
---------------------------------------------------------
UNION ALL
SELECT '5.428'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''361'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 574,83 573,80 573,80 572,79 572,79 574,83 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 427
---------------------------------------------------------
UNION ALL
SELECT '5.429'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''362'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 573,84 569,82 569,82 572,80 572,80 573,84 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 428
---------------------------------------------------------
UNION ALL
SELECT '5.430'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''363'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 602,2 598,-2 598,-2 602,2 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 429
---------------------------------------------------------
UNION ALL
SELECT '5.431'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''364'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 603,4 599,2 599,2 600,3 600,3 603,4 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 430
---------------------------------------------------------
UNION ALL
SELECT '5.432'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''365'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 604,3 600,2 600,2 602,-1 602,-1 604,3 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 431
---------------------------------------------------------
UNION ALL
SELECT '5.433'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''366'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 604,19 603,16 603,16 602,15 602,15 604,19 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 432
---------------------------------------------------------
UNION ALL
SELECT '5.434'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''367'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 602,18 598,14 598,14 602,18 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 433
---------------------------------------------------------
UNION ALL
SELECT '5.435'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''368'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 603,20 599,18 599,18 602,16 602,16 603,20 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 434
---------------------------------------------------------
UNION ALL
SELECT '5.436'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''369'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 603,36 599,34 599,34 600,35 600,35 603,36 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 435
---------------------------------------------------------
UNION ALL
SELECT '5.437'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''370'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 602,34 598,30 598,30 602,34 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 436
---------------------------------------------------------
UNION ALL
SELECT '5.438'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''371'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 604,35 600,34 600,34 602,31 602,31 604,35 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 437
---------------------------------------------------------
UNION ALL
SELECT '5.439'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''372'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 604,51 603,48 603,48 602,47 602,47 604,51 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 438
---------------------------------------------------------
UNION ALL
SELECT '5.440'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''373'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 603,52 599,50 599,50 602,48 602,48 603,52 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 439
---------------------------------------------------------
UNION ALL
SELECT '5.441'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''374'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 602,50 598,46 598,46 602,50 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 440
---------------------------------------------------------
UNION ALL
SELECT '5.442'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''375'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 603,68 599,66 599,66 600,67 600,67 603,68 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 441
---------------------------------------------------------
UNION ALL
SELECT '5.443'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''376'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 604,67 600,66 600,66 602,63 602,63 604,67 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 442
---------------------------------------------------------
UNION ALL
SELECT '5.444'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''377'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 602,66 598,62 598,62 602,66 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 443
---------------------------------------------------------
UNION ALL
SELECT '5.445'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''378'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 599,82 598,78 598,78 602,80 602,80 599,82 599))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 444
---------------------------------------------------------
UNION ALL
SELECT '5.446'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''378'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 602,82 598,78 598,78 602,82 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 445
---------------------------------------------------------
UNION ALL
SELECT '5.447'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''379'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 604,83 603,80 603,80 602,79 602,79 604,83 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 446
---------------------------------------------------------
UNION ALL
SELECT '5.448'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''380'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 603,84 599,80 599,80 603,84 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 447
---------------------------------------------------------
UNION ALL
SELECT '5.449'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''380'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 603,84 599,82 599,82 602,80 602,80 603,84 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 448
---------------------------------------------------------
UNION ALL
SELECT '5.450'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''381'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 632,2 628,-2 628,-2 632,2 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 449
---------------------------------------------------------
UNION ALL
SELECT '5.451'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''381'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 629,2 628,-2 628,-2 632,0 632,0 629,2 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 450
---------------------------------------------------------
UNION ALL
SELECT '5.452'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''382'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 633,4 629,0 629,0 633,4 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 451
---------------------------------------------------------
UNION ALL
SELECT '5.453'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''382'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 633,4 629,2 629,2 632,0 632,0 633,4 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 452
---------------------------------------------------------
UNION ALL
SELECT '5.454'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''383'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 634,3 633,0 633,0 632,-1 632,-1 634,3 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 453
---------------------------------------------------------
UNION ALL
SELECT '5.455'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''384'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 634,19 633,16 633,16 632,15 632,15 634,19 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 454
---------------------------------------------------------
UNION ALL
SELECT '5.456'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''385'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 632,18 628,14 628,14 632,18 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 455
---------------------------------------------------------
UNION ALL
SELECT '5.457'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''385'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 629,18 628,14 628,14 632,16 632,16 629,18 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 456
---------------------------------------------------------
UNION ALL
SELECT '5.458'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''386'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 633,20 629,16 629,16 633,20 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 457
---------------------------------------------------------
UNION ALL
SELECT '5.459'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''386'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 633,20 629,18 629,18 632,16 632,16 633,20 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 458
---------------------------------------------------------
UNION ALL
SELECT '5.460'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''387'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 633,36 629,32 629,32 633,36 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 459
---------------------------------------------------------
UNION ALL
SELECT '5.461'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''387'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 633,36 629,34 629,34 632,32 632,32 633,36 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 460
---------------------------------------------------------
UNION ALL
SELECT '5.462'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''388'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 632,34 628,30 628,30 632,34 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 461
---------------------------------------------------------
UNION ALL
SELECT '5.463'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''388'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 629,34 628,30 628,30 632,32 632,32 629,34 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 462
---------------------------------------------------------
UNION ALL
SELECT '5.464'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''389'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 634,35 633,32 633,32 632,31 632,31 634,35 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 463
---------------------------------------------------------
UNION ALL
SELECT '5.465'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''390'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 634,51 633,48 633,48 632,47 632,47 634,51 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 464
---------------------------------------------------------
UNION ALL
SELECT '5.466'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''391'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 633,52 629,50 629,50 632,48 632,48 633,52 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 465
---------------------------------------------------------
UNION ALL
SELECT '5.467'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''391'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 633,52 629,48 629,48 633,52 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 466
---------------------------------------------------------
UNION ALL
SELECT '5.468'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''392'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 629,50 628,46 628,46 632,48 632,48 629,50 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 467
---------------------------------------------------------
UNION ALL
SELECT '5.469'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''392'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 632,50 628,46 628,46 632,50 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 468
---------------------------------------------------------
UNION ALL
SELECT '5.470'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''393'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 633,68 629,66 629,66 632,64 632,64 633,68 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 469
---------------------------------------------------------
UNION ALL
SELECT '5.471'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''393'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 633,68 629,64 629,64 633,68 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 470
---------------------------------------------------------
UNION ALL
SELECT '5.472'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''394'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 634,67 633,64 633,64 632,63 632,63 634,67 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 471
---------------------------------------------------------
UNION ALL
SELECT '5.473'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''395'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 632,66 628,62 628,62 632,66 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 472
---------------------------------------------------------
UNION ALL
SELECT '5.474'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''395'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 629,66 628,62 628,62 632,64 632,64 629,66 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 473
---------------------------------------------------------
UNION ALL
SELECT '5.475'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''396'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 630,82 628,78 628,78 632,79 632,79 630,82 630))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 474
---------------------------------------------------------
UNION ALL
SELECT '5.476'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''396'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 632,82 628,78 628,78 632,82 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 475
---------------------------------------------------------
UNION ALL
SELECT '5.477'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''397'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 634,83 630,82 630,82 632,79 632,79 634,83 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 476
---------------------------------------------------------
UNION ALL
SELECT '5.478'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''397'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 634,83 630,79 630,79 634,83 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 477
---------------------------------------------------------
UNION ALL
SELECT '5.479'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''398'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 633,84 629,82 629,82 630,83 630,83 633,84 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 478
---------------------------------------------------------
UNION ALL
SELECT '5.480'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''399'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 660,2 658,-2 658,-2 662,-1 662,-1 660,2 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 479
---------------------------------------------------------
UNION ALL
SELECT '5.481'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''399'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 662,2 658,-2 658,-2 662,2 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 480
---------------------------------------------------------
UNION ALL
SELECT '5.482'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''400'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 663,4 659,2 659,2 660,3 660,3 663,4 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 481
---------------------------------------------------------
UNION ALL
SELECT '5.483'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''401'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 664,3 660,2 660,2 662,-1 662,-1 664,3 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 482
---------------------------------------------------------
UNION ALL
SELECT '5.484'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''401'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 664,3 660,-1 660,-1 664,3 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 483
---------------------------------------------------------
UNION ALL
SELECT '5.485'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''402'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 664,19 660,15 660,15 664,19 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 484
---------------------------------------------------------
UNION ALL
SELECT '5.486'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''402'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 664,19 660,18 660,18 662,15 662,15 664,19 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 485
---------------------------------------------------------
UNION ALL
SELECT '5.487'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''403'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 660,18 658,14 658,14 662,15 662,15 660,18 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 486
---------------------------------------------------------
UNION ALL
SELECT '5.488'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''403'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 662,18 658,14 658,14 662,18 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 487
---------------------------------------------------------
UNION ALL
SELECT '5.489'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''404'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 663,20 659,18 659,18 660,19 660,19 663,20 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 488
---------------------------------------------------------
UNION ALL
SELECT '5.490'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''405'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 663,36 659,34 659,34 660,35 660,35 663,36 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 489
---------------------------------------------------------
UNION ALL
SELECT '5.491'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''406'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 660,34 658,30 658,30 662,31 662,31 660,34 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 490
---------------------------------------------------------
UNION ALL
SELECT '5.492'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''406'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 662,34 658,30 658,30 662,34 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 491
---------------------------------------------------------
UNION ALL
SELECT '5.493'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''407'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 664,35 660,34 660,34 662,31 662,31 664,35 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 492
---------------------------------------------------------
UNION ALL
SELECT '5.494'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''407'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 664,35 660,31 660,31 664,35 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 493
---------------------------------------------------------
UNION ALL
SELECT '5.495'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''408'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 664,51 660,50 660,50 662,47 662,47 664,51 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 494
---------------------------------------------------------
UNION ALL
SELECT '5.496'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''408'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 664,51 660,47 660,47 664,51 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 495
---------------------------------------------------------
UNION ALL
SELECT '5.497'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''409'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 663,52 659,50 659,50 660,51 660,51 663,52 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 496
---------------------------------------------------------
UNION ALL
SELECT '5.498'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''410'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 660,50 658,46 658,46 662,47 662,47 660,50 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 497
---------------------------------------------------------
UNION ALL
SELECT '5.499'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''410'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 662,50 658,46 658,46 662,50 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 498
---------------------------------------------------------
UNION ALL
SELECT '5.500'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''411'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 663,68 659,66 659,66 660,67 660,67 663,68 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 499
---------------------------------------------------------
UNION ALL
SELECT '5.501'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''412'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 664,67 660,63 660,63 664,67 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 500
---------------------------------------------------------
UNION ALL
SELECT '5.502'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''412'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 664,67 660,66 660,66 662,63 662,63 664,67 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 501
---------------------------------------------------------
UNION ALL
SELECT '5.503'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''413'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 662,66 658,62 658,62 662,66 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 502
---------------------------------------------------------
UNION ALL
SELECT '5.504'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''413'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 660,66 658,62 658,62 662,63 662,63 660,66 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 503
---------------------------------------------------------
UNION ALL
SELECT '5.505'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''414'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 659,82 658,78 658,78 662,79 662,79 660,80 660,80 659,82 659))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 504
---------------------------------------------------------
UNION ALL
SELECT '5.506'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''414'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 662,82 658,78 658,78 662,82 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 505
---------------------------------------------------------
UNION ALL
SELECT '5.507'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''415'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 664,83 663,80 663,80 660,79 660,79 664,83 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 506
---------------------------------------------------------
UNION ALL
SELECT '5.508'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''415'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 664,83 663,80 663,80 662,79 662,79 664,83 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 507
---------------------------------------------------------
UNION ALL
SELECT '5.509'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''416'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 663,84 659,80 659,80 663,84 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 508
---------------------------------------------------------
UNION ALL
SELECT '5.510'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''416'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 663,84 659,82 659,82 662,80 662,80 663,84 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 509
---------------------------------------------------------
UNION ALL
SELECT '5.511'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''417'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 689,2 688,-2 688,-2 692,-1 692,-1 690,0 690,0 689,2 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 510
---------------------------------------------------------
UNION ALL
SELECT '5.512'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''417'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 692,2 688,-2 688,-2 692,2 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 511
---------------------------------------------------------
UNION ALL
SELECT '5.513'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''418'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 693,4 689,2 689,2 690,3 690,3 693,4 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 512
---------------------------------------------------------
UNION ALL
SELECT '5.514'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''418'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 693,4 689,0 689,0 690,3 690,3 693,4 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 513
---------------------------------------------------------
UNION ALL
SELECT '5.515'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''419'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 694,3 690,-1 690,-1 694,3 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 514
---------------------------------------------------------
UNION ALL
SELECT '5.516'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''419'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 694,3 690,2 690,2 692,-1 692,-1 694,3 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 515
---------------------------------------------------------
UNION ALL
SELECT '5.517'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''420'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 694,19 693,16 693,16 690,15 690,15 694,19 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 516
---------------------------------------------------------
UNION ALL
SELECT '5.518'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''420'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 694,19 693,16 693,16 692,15 692,15 694,19 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 517
---------------------------------------------------------
UNION ALL
SELECT '5.519'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''421'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 692,18 688,14 688,14 692,18 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 518
---------------------------------------------------------
UNION ALL
SELECT '5.520'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''421'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 689,18 688,14 688,14 692,15 692,15 690,16 690,16 689,18 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 519
---------------------------------------------------------
UNION ALL
SELECT '5.521'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''422'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 693,20 689,16 689,16 693,20 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 520
---------------------------------------------------------
UNION ALL
SELECT '5.522'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''422'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 693,20 689,18 689,18 692,16 692,16 693,20 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 521
---------------------------------------------------------
UNION ALL
SELECT '5.523'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''423'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 693,36 689,34 689,34 690,35 690,35 693,36 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 522
---------------------------------------------------------
UNION ALL
SELECT '5.524'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''423'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 693,36 689,32 689,32 690,35 690,35 693,36 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 523
---------------------------------------------------------
UNION ALL
SELECT '5.525'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''424'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 689,34 688,30 688,30 692,31 692,31 690,32 690,32 689,34 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 524
---------------------------------------------------------
UNION ALL
SELECT '5.526'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''424'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 692,34 688,30 688,30 692,34 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 525
---------------------------------------------------------
UNION ALL
SELECT '5.527'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''425'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 694,35 690,34 690,34 692,31 692,31 694,35 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 526
---------------------------------------------------------
UNION ALL
SELECT '5.528'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''425'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 694,35 690,31 690,31 694,35 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 527
---------------------------------------------------------
UNION ALL
SELECT '5.529'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''426'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 694,51 693,48 693,48 690,47 690,47 694,51 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 528
---------------------------------------------------------
UNION ALL
SELECT '5.530'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''426'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 694,51 693,48 693,48 692,47 692,47 694,51 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 529
---------------------------------------------------------
UNION ALL
SELECT '5.531'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''427'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 693,52 689,48 689,48 693,52 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 530
---------------------------------------------------------
UNION ALL
SELECT '5.532'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''427'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 693,52 689,50 689,50 692,48 692,48 693,52 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 531
---------------------------------------------------------
UNION ALL
SELECT '5.533'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''428'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 692,50 688,46 688,46 692,50 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 532
---------------------------------------------------------
UNION ALL
SELECT '5.534'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''428'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 689,50 688,46 688,46 692,47 692,47 690,48 690,48 689,50 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 533
---------------------------------------------------------
UNION ALL
SELECT '5.535'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''429'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 693,68 689,66 689,66 690,67 690,67 693,68 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 534
---------------------------------------------------------
UNION ALL
SELECT '5.536'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''429'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 693,68 689,64 689,64 690,67 690,67 693,68 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 535
---------------------------------------------------------
UNION ALL
SELECT '5.537'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''430'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 694,67 690,63 690,63 694,67 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 536
---------------------------------------------------------
UNION ALL
SELECT '5.538'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''430'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 694,67 690,66 690,66 692,63 692,63 694,67 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 537
---------------------------------------------------------
UNION ALL
SELECT '5.539'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''431'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 692,66 688,62 688,62 692,66 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 538
---------------------------------------------------------
UNION ALL
SELECT '5.540'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''431'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 689,66 688,62 688,62 692,63 692,63 690,64 690,64 689,66 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 539
---------------------------------------------------------
UNION ALL
SELECT '5.541'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''432'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 689,82 688,78 688,78 692,79 692,79 690,80 690,80 689,82 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 540
---------------------------------------------------------
UNION ALL
SELECT '5.542'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''433'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 694,83 693,80 693,80 690,79 690,79 694,83 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 541
---------------------------------------------------------
UNION ALL
SELECT '5.543'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''434'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 693,84 689,80 689,80 693,84 693))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 542
---------------------------------------------------------
UNION ALL
SELECT '5.544'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''435'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 719,2 718,-2 718,-2 722,-1 722,-1 720,0 720,0 719,2 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 543
---------------------------------------------------------
UNION ALL
SELECT '5.545'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''436'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 723,4 719,0 719,0 723,4 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 544
---------------------------------------------------------
UNION ALL
SELECT '5.546'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''437'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 724,3 723,0 723,0 720,-1 720,-1 724,3 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 545
---------------------------------------------------------
UNION ALL
SELECT '5.547'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''438'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 724,19 723,16 723,16 720,15 720,15 724,19 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 546
---------------------------------------------------------
UNION ALL
SELECT '5.548'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''439'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 719,18 718,14 718,14 722,15 722,15 720,16 720,16 719,18 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 547
---------------------------------------------------------
UNION ALL
SELECT '5.549'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''440'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 723,20 719,16 719,16 723,20 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 548
---------------------------------------------------------
UNION ALL
SELECT '5.550'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''441'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 723,36 719,32 719,32 723,36 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 549
---------------------------------------------------------
UNION ALL
SELECT '5.551'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''442'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 719,34 718,30 718,30 722,31 722,31 720,32 720,32 719,34 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 550
---------------------------------------------------------
UNION ALL
SELECT '5.552'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''443'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 724,35 723,32 723,32 720,31 720,31 724,35 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 551
---------------------------------------------------------
UNION ALL
SELECT '5.553'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''444'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 724,51 723,48 723,48 720,47 720,47 724,51 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 552
---------------------------------------------------------
UNION ALL
SELECT '5.554'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''445'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 723,52 719,48 719,48 723,52 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 553
---------------------------------------------------------
UNION ALL
SELECT '5.555'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''446'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 719,50 718,46 718,46 722,47 722,47 720,48 720,48 719,50 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 554
---------------------------------------------------------
UNION ALL
SELECT '5.556'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''447'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 723,68 719,64 719,64 723,68 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 555
---------------------------------------------------------
UNION ALL
SELECT '5.557'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''448'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 724,67 723,64 723,64 720,63 720,63 724,67 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 556
---------------------------------------------------------
UNION ALL
SELECT '5.558'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''449'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 719,66 718,62 718,62 722,63 722,63 720,64 720,64 719,66 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 557
---------------------------------------------------------
UNION ALL
SELECT '5.559'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''450'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 719,82 718,78 718,78 722,79 722,79 720,80 720,80 719,82 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 558
---------------------------------------------------------
UNION ALL
SELECT '5.560'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''451'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 724,83 723,80 723,80 720,79 720,79 724,83 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 559
---------------------------------------------------------
UNION ALL
SELECT '5.561'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''452'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 723,84 719,80 719,80 723,84 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 560
---------------------------------------------------------
UNION ALL
SELECT '5.562'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''453'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 749,2 748,-2 748,-2 752,-1 752,-1 750,0 750,0 749,2 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 561
---------------------------------------------------------
UNION ALL
SELECT '5.563'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''454'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 753,4 749,0 749,0 753,4 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 562
---------------------------------------------------------
UNION ALL
SELECT '5.564'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''455'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 754,3 753,0 753,0 750,-1 750,-1 754,3 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 563
---------------------------------------------------------
UNION ALL
SELECT '5.565'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''456'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 754,19 753,16 753,16 750,15 750,15 754,19 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 564
---------------------------------------------------------
UNION ALL
SELECT '5.566'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''457'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 749,18 748,14 748,14 752,15 752,15 750,16 750,16 749,18 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 565
---------------------------------------------------------
UNION ALL
SELECT '5.567'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''458'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 753,20 749,16 749,16 753,20 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 566
---------------------------------------------------------
UNION ALL
SELECT '5.568'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''459'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 753,36 749,32 749,32 753,36 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 567
---------------------------------------------------------
UNION ALL
SELECT '5.569'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''460'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 749,34 748,30 748,30 752,31 752,31 750,32 750,32 749,34 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 568
---------------------------------------------------------
UNION ALL
SELECT '5.570'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''461'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 754,35 753,32 753,32 750,31 750,31 754,35 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 569
---------------------------------------------------------
UNION ALL
SELECT '5.571'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''462'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 754,51 753,48 753,48 750,47 750,47 754,51 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 570
---------------------------------------------------------
UNION ALL
SELECT '5.572'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''463'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 753,52 749,48 749,48 753,52 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 571
---------------------------------------------------------
UNION ALL
SELECT '5.573'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''464'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 749,50 748,46 748,46 752,47 752,47 750,48 750,48 749,50 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 572
---------------------------------------------------------
UNION ALL
SELECT '5.574'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''465'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 753,68 749,64 749,64 753,68 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 573
---------------------------------------------------------
UNION ALL
SELECT '5.575'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''466'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 754,67 753,64 753,64 750,63 750,63 754,67 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 574
---------------------------------------------------------
UNION ALL
SELECT '5.576'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''467'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 749,66 748,62 748,62 752,63 752,63 750,64 750,64 749,66 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 575
---------------------------------------------------------
UNION ALL
SELECT '5.577'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''468'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 749,82 748,78 748,78 752,79 752,79 750,80 750,80 749,82 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 576
---------------------------------------------------------
UNION ALL
SELECT '5.578'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''469'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 754,83 750,79 750,79 754,83 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 577
---------------------------------------------------------
UNION ALL
SELECT '5.579'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''470'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 753,84 749,80 749,80 750,83 750,83 753,84 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 578
---------------------------------------------------------
UNION ALL
SELECT '5.580'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''471'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 779,2 778,-2 778,-2 782,-1 782,-1 780,0 780,0 779,2 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 579
---------------------------------------------------------
UNION ALL
SELECT '5.581'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''472'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 783,4 779,0 779,0 780,3 780,3 783,4 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 580
---------------------------------------------------------
UNION ALL
SELECT '5.582'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''473'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 784,3 780,-1 780,-1 784,3 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 581
---------------------------------------------------------
UNION ALL
SELECT '5.583'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''474'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 784,19 780,15 780,15 784,19 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 582
---------------------------------------------------------
UNION ALL
SELECT '5.584'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''475'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 779,18 778,14 778,14 782,15 782,15 780,16 780,16 779,18 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 583
---------------------------------------------------------
UNION ALL
SELECT '5.585'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''476'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 783,20 779,16 779,16 780,19 780,19 783,20 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 584
---------------------------------------------------------
UNION ALL
SELECT '5.586'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''477'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 783,36 779,32 779,32 780,35 780,35 783,36 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 585
---------------------------------------------------------
UNION ALL
SELECT '5.587'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''478'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 779,34 778,30 778,30 782,31 782,31 780,32 780,32 779,34 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 586
---------------------------------------------------------
UNION ALL
SELECT '5.588'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''479'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 784,35 780,31 780,31 784,35 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 587
---------------------------------------------------------
UNION ALL
SELECT '5.589'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''480'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 784,51 780,47 780,47 784,51 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 588
---------------------------------------------------------
UNION ALL
SELECT '5.590'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''481'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 783,52 779,48 779,48 780,51 780,51 783,52 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 589
---------------------------------------------------------
UNION ALL
SELECT '5.591'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''482'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 779,50 778,46 778,46 782,47 782,47 780,48 780,48 779,50 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 590
---------------------------------------------------------
UNION ALL
SELECT '5.592'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''483'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 783,68 779,64 779,64 780,67 780,67 783,68 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 591
---------------------------------------------------------
UNION ALL
SELECT '5.593'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''484'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 784,67 780,63 780,63 784,67 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 592
---------------------------------------------------------
UNION ALL
SELECT '5.594'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''485'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 779,66 778,62 778,62 782,63 782,63 780,64 780,64 779,66 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 593
---------------------------------------------------------
UNION ALL
SELECT '5.595'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''486'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 779,82 778,78 778,78 782,79 782,79 780,80 780,80 779,82 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 594
---------------------------------------------------------
UNION ALL
SELECT '5.596'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''487'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 784,83 783,80 783,80 780,79 780,79 784,83 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 595
---------------------------------------------------------
UNION ALL
SELECT '5.597'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''487'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 596
---------------------------------------------------------
UNION ALL
SELECT '5.598'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''487'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 784,83 780,79 780,79 784,83 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 597
---------------------------------------------------------
UNION ALL
SELECT '5.599'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''488'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 783,84 779,80 779,80 783,84 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 598
---------------------------------------------------------
UNION ALL
SELECT '5.600'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''488'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 783,84 779,80 779,80 780,83 780,83 783,84 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 599
---------------------------------------------------------
UNION ALL
SELECT '5.601'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''489'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 809,2 808,-2 808,-2 812,-1 812,-1 810,0 810,0 809,2 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 600
---------------------------------------------------------
UNION ALL
SELECT '5.602'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''490'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 813,4 809,0 809,0 813,4 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 601
---------------------------------------------------------
UNION ALL
SELECT '5.603'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''490'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 813,4 809,0 809,0 810,3 810,3 813,4 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 602
---------------------------------------------------------
UNION ALL
SELECT '5.604'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''491'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 814,3 810,-1 810,-1 814,3 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 603
---------------------------------------------------------
UNION ALL
SELECT '5.605'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''491'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 814,3 813,0 813,0 810,-1 810,-1 814,3 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 604
---------------------------------------------------------
UNION ALL
SELECT '5.606'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''491'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 605
---------------------------------------------------------
UNION ALL
SELECT '5.607'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''492'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 814,19 813,16 813,16 810,15 810,15 814,19 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 606
---------------------------------------------------------
UNION ALL
SELECT '5.608'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''492'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 814,19 810,15 810,15 814,19 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 607
---------------------------------------------------------
UNION ALL
SELECT '5.609'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''492'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 608
---------------------------------------------------------
UNION ALL
SELECT '5.610'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''493'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 809,18 808,14 808,14 812,15 812,15 810,16 810,16 809,18 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 609
---------------------------------------------------------
UNION ALL
SELECT '5.611'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''494'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 813,20 809,16 809,16 813,20 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 610
---------------------------------------------------------
UNION ALL
SELECT '5.612'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''494'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 813,20 809,16 809,16 810,19 810,19 813,20 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 611
---------------------------------------------------------
UNION ALL
SELECT '5.613'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''495'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 813,36 809,32 809,32 813,36 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 612
---------------------------------------------------------
UNION ALL
SELECT '5.614'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''495'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 813,36 809,32 809,32 810,35 810,35 813,36 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 613
---------------------------------------------------------
UNION ALL
SELECT '5.615'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''496'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 809,34 808,30 808,30 812,31 812,31 810,32 810,32 809,34 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 614
---------------------------------------------------------
UNION ALL
SELECT '5.616'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''497'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 814,35 813,32 813,32 810,31 810,31 814,35 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 615
---------------------------------------------------------
UNION ALL
SELECT '5.617'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''497'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 616
---------------------------------------------------------
UNION ALL
SELECT '5.618'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''497'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 814,35 810,31 810,31 814,35 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 617
---------------------------------------------------------
UNION ALL
SELECT '5.619'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''498'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 814,51 813,48 813,48 810,47 810,47 814,51 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 618
---------------------------------------------------------
UNION ALL
SELECT '5.620'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''498'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 619
---------------------------------------------------------
UNION ALL
SELECT '5.621'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''498'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 814,51 810,47 810,47 814,51 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 620
---------------------------------------------------------
UNION ALL
SELECT '5.622'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''499'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 813,52 809,48 809,48 813,52 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 621
---------------------------------------------------------
UNION ALL
SELECT '5.623'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''499'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 813,52 809,48 809,48 810,51 810,51 813,52 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 622
---------------------------------------------------------
UNION ALL
SELECT '5.624'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''500'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 809,50 808,46 808,46 812,47 812,47 810,48 810,48 809,50 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 623
---------------------------------------------------------
UNION ALL
SELECT '5.625'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''501'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 813,68 809,64 809,64 813,68 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 624
---------------------------------------------------------
UNION ALL
SELECT '5.626'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''501'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 813,68 809,64 809,64 810,67 810,67 813,68 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 625
---------------------------------------------------------
UNION ALL
SELECT '5.627'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''502'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 626
---------------------------------------------------------
UNION ALL
SELECT '5.628'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''502'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 814,67 810,63 810,63 814,67 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 627
---------------------------------------------------------
UNION ALL
SELECT '5.629'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''502'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 814,67 813,64 813,64 810,63 810,63 814,67 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 628
---------------------------------------------------------
UNION ALL
SELECT '5.630'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''503'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 809,66 808,62 808,62 812,63 812,63 810,64 810,64 809,66 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 629
---------------------------------------------------------
UNION ALL
SELECT '5.631'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''504'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 812,82 808,78 808,78 812,82 812))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 630
---------------------------------------------------------
UNION ALL
SELECT '5.632'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''505'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 814,83 813,80 813,80 812,79 812,79 814,83 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 631
---------------------------------------------------------
UNION ALL
SELECT '5.633'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''506'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 813,84 809,82 809,82 812,80 812,80 813,84 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 632
---------------------------------------------------------
UNION ALL
SELECT '5.634'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''507'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 842,2 838,-2 838,-2 842,2 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 633
---------------------------------------------------------
UNION ALL
SELECT '5.635'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''508'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 843,4 839,2 839,2 842,0 842,0 843,4 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 634
---------------------------------------------------------
UNION ALL
SELECT '5.636'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''509'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 844,3 843,0 843,0 842,-1 842,-1 844,3 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 635
---------------------------------------------------------
UNION ALL
SELECT '5.637'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''510'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 844,19 843,16 843,16 842,15 842,15 844,19 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 636
---------------------------------------------------------
UNION ALL
SELECT '5.638'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''511'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 842,18 838,14 838,14 842,18 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 637
---------------------------------------------------------
UNION ALL
SELECT '5.639'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''512'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 843,20 839,18 839,18 842,16 842,16 843,20 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 638
---------------------------------------------------------
UNION ALL
SELECT '5.640'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''513'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 843,36 839,34 839,34 842,32 842,32 843,36 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 639
---------------------------------------------------------
UNION ALL
SELECT '5.641'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''514'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 842,34 838,30 838,30 842,34 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 640
---------------------------------------------------------
UNION ALL
SELECT '5.642'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''515'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 844,35 843,32 843,32 842,31 842,31 844,35 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 641
---------------------------------------------------------
UNION ALL
SELECT '5.643'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''516'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 844,51 843,48 843,48 842,47 842,47 844,51 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 642
---------------------------------------------------------
UNION ALL
SELECT '5.644'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''517'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 843,52 839,50 839,50 842,48 842,48 843,52 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 643
---------------------------------------------------------
UNION ALL
SELECT '5.645'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''518'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 842,50 838,46 838,46 842,50 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 644
---------------------------------------------------------
UNION ALL
SELECT '5.646'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''519'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 843,68 839,66 839,66 842,64 842,64 843,68 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 645
---------------------------------------------------------
UNION ALL
SELECT '5.647'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''520'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 844,67 843,64 843,64 842,63 842,63 844,67 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 646
---------------------------------------------------------
UNION ALL
SELECT '5.648'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''521'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 842,66 838,62 838,62 842,66 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 647
---------------------------------------------------------
UNION ALL
SELECT '5.649'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''522'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 839,82 838,78 838,78 842,80 842,80 839,82 839))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 648
---------------------------------------------------------
UNION ALL
SELECT '5.650'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''522'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 649
---------------------------------------------------------
UNION ALL
SELECT '5.651'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''522'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 842,82 838,78 838,78 842,82 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 650
---------------------------------------------------------
UNION ALL
SELECT '5.652'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''523'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 844,83 843,80 843,80 842,79 842,79 844,83 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 651
---------------------------------------------------------
UNION ALL
SELECT '5.653'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''524'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 843,84 839,82 839,82 842,80 842,80 843,84 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 652
---------------------------------------------------------
UNION ALL
SELECT '5.654'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''524'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 843,84 839,80 839,80 843,84 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 653
---------------------------------------------------------
UNION ALL
SELECT '5.655'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''525'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 872,2 868,-2 868,-2 872,2 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 654
---------------------------------------------------------
UNION ALL
SELECT '5.656'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''525'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 869,2 868,-2 868,-2 872,0 872,0 869,2 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 655
---------------------------------------------------------
UNION ALL
SELECT '5.657'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''525'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 656
---------------------------------------------------------
UNION ALL
SELECT '5.658'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''526'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 873,4 869,2 869,2 872,0 872,0 873,4 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 657
---------------------------------------------------------
UNION ALL
SELECT '5.659'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''526'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 873,4 869,0 869,0 873,4 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 658
---------------------------------------------------------
UNION ALL
SELECT '5.660'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''527'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 874,3 873,0 873,0 872,-1 872,-1 874,3 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 659
---------------------------------------------------------
UNION ALL
SELECT '5.661'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''528'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 874,19 873,16 873,16 872,15 872,15 874,19 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 660
---------------------------------------------------------
UNION ALL
SELECT '5.662'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''529'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 872,18 868,14 868,14 872,18 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 661
---------------------------------------------------------
UNION ALL
SELECT '5.663'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''529'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 662
---------------------------------------------------------
UNION ALL
SELECT '5.664'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''529'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 869,18 868,14 868,14 872,16 872,16 869,18 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 663
---------------------------------------------------------
UNION ALL
SELECT '5.665'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''530'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 873,20 869,18 869,18 872,16 872,16 873,20 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 664
---------------------------------------------------------
UNION ALL
SELECT '5.666'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''530'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 873,20 869,16 869,16 873,20 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 665
---------------------------------------------------------
UNION ALL
SELECT '5.667'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''531'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 873,36 869,32 869,32 873,36 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 666
---------------------------------------------------------
UNION ALL
SELECT '5.668'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''531'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 873,36 869,34 869,34 872,32 872,32 873,36 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 667
---------------------------------------------------------
UNION ALL
SELECT '5.669'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''532'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 872,34 868,30 868,30 872,34 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 668
---------------------------------------------------------
UNION ALL
SELECT '5.670'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''532'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 869,34 868,30 868,30 872,32 872,32 869,34 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 669
---------------------------------------------------------
UNION ALL
SELECT '5.671'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''532'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 670
---------------------------------------------------------
UNION ALL
SELECT '5.672'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''533'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 874,35 873,32 873,32 872,31 872,31 874,35 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 671
---------------------------------------------------------
UNION ALL
SELECT '5.673'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''534'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 874,51 873,48 873,48 872,47 872,47 874,51 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 672
---------------------------------------------------------
UNION ALL
SELECT '5.674'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''535'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 873,52 869,50 869,50 872,48 872,48 873,52 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 673
---------------------------------------------------------
UNION ALL
SELECT '5.675'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''535'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 873,52 869,48 869,48 873,52 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 674
---------------------------------------------------------
UNION ALL
SELECT '5.676'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''536'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 869,50 868,46 868,46 872,48 872,48 869,50 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 675
---------------------------------------------------------
UNION ALL
SELECT '5.677'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''536'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 872,50 868,46 868,46 872,50 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 676
---------------------------------------------------------
UNION ALL
SELECT '5.678'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''536'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 677
---------------------------------------------------------
UNION ALL
SELECT '5.679'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''537'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 873,68 869,64 869,64 873,68 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 678
---------------------------------------------------------
UNION ALL
SELECT '5.680'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''537'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 873,68 869,66 869,66 872,64 872,64 873,68 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 679
---------------------------------------------------------
UNION ALL
SELECT '5.681'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''538'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 874,67 873,64 873,64 872,63 872,63 874,67 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 680
---------------------------------------------------------
UNION ALL
SELECT '5.682'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''539'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 681
---------------------------------------------------------
UNION ALL
SELECT '5.683'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''539'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 869,66 868,62 868,62 872,64 872,64 869,66 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 682
---------------------------------------------------------
UNION ALL
SELECT '5.684'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''539'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 872,66 868,62 868,62 872,66 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 683
---------------------------------------------------------
UNION ALL
SELECT '5.685'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''540'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 872,82 868,78 868,78 872,82 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 684
---------------------------------------------------------
UNION ALL
SELECT '5.686'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''540'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 870,82 868,78 868,78 872,79 872,79 870,82 870))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 685
---------------------------------------------------------
UNION ALL
SELECT '5.687'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''541'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 874,83 870,79 870,79 874,83 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 686
---------------------------------------------------------
UNION ALL
SELECT '5.688'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''541'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 874,83 870,82 870,82 872,79 872,79 874,83 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 687
---------------------------------------------------------
UNION ALL
SELECT '5.689'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''542'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 873,84 869,82 869,82 870,83 870,83 873,84 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 688
---------------------------------------------------------
UNION ALL
SELECT '5.690'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''543'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 900,2 898,-2 898,-2 902,-1 902,-1 900,2 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 689
---------------------------------------------------------
UNION ALL
SELECT '5.691'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''543'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 902,2 898,-2 898,-2 902,2 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 690
---------------------------------------------------------
UNION ALL
SELECT '5.692'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''544'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 903,4 899,2 899,2 900,3 900,3 903,4 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 691
---------------------------------------------------------
UNION ALL
SELECT '5.693'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''545'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 904,3 900,-1 900,-1 904,3 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 692
---------------------------------------------------------
UNION ALL
SELECT '5.694'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''545'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 904,3 900,2 900,2 902,-1 902,-1 904,3 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 693
---------------------------------------------------------
UNION ALL
SELECT '5.695'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''546'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 904,19 900,18 900,18 902,15 902,15 904,19 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 694
---------------------------------------------------------
UNION ALL
SELECT '5.696'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''546'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 904,19 900,15 900,15 904,19 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 695
---------------------------------------------------------
UNION ALL
SELECT '5.697'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''547'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 900,18 898,14 898,14 902,15 902,15 900,18 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 696
---------------------------------------------------------
UNION ALL
SELECT '5.698'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''547'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 902,18 898,14 898,14 902,18 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 697
---------------------------------------------------------
UNION ALL
SELECT '5.699'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''548'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 903,20 899,18 899,18 900,19 900,19 903,20 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 698
---------------------------------------------------------
UNION ALL
SELECT '5.700'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''549'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 903,36 899,34 899,34 900,35 900,35 903,36 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 699
---------------------------------------------------------
UNION ALL
SELECT '5.701'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''550'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 900,34 898,30 898,30 902,31 902,31 900,34 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 700
---------------------------------------------------------
UNION ALL
SELECT '5.702'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''550'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 902,34 898,30 898,30 902,34 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 701
---------------------------------------------------------
UNION ALL
SELECT '5.703'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''551'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 904,35 900,31 900,31 904,35 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 702
---------------------------------------------------------
UNION ALL
SELECT '5.704'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''551'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 904,35 900,34 900,34 902,31 902,31 904,35 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 703
---------------------------------------------------------
UNION ALL
SELECT '5.705'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''552'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 904,51 900,50 900,50 902,47 902,47 904,51 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 704
---------------------------------------------------------
UNION ALL
SELECT '5.706'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''552'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 904,51 900,47 900,47 904,51 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 705
---------------------------------------------------------
UNION ALL
SELECT '5.707'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''553'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 903,52 899,50 899,50 900,51 900,51 903,52 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 706
---------------------------------------------------------
UNION ALL
SELECT '5.708'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''554'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 900,50 898,46 898,46 902,47 902,47 900,50 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 707
---------------------------------------------------------
UNION ALL
SELECT '5.709'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''554'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 902,50 898,46 898,46 902,50 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 708
---------------------------------------------------------
UNION ALL
SELECT '5.710'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''555'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 903,68 899,66 899,66 900,67 900,67 903,68 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 709
---------------------------------------------------------
UNION ALL
SELECT '5.711'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''556'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 904,67 900,63 900,63 904,67 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 710
---------------------------------------------------------
UNION ALL
SELECT '5.712'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''556'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 904,67 900,66 900,66 902,63 902,63 904,67 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 711
---------------------------------------------------------
UNION ALL
SELECT '5.713'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''557'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 902,66 898,62 898,62 902,66 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 712
---------------------------------------------------------
UNION ALL
SELECT '5.714'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''557'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 900,66 898,62 898,62 902,63 902,63 900,66 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 713
---------------------------------------------------------
UNION ALL
SELECT '5.715'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''558'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 899,82 898,78 898,78 902,79 902,79 900,80 900,80 899,82 899))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 714
---------------------------------------------------------
UNION ALL
SELECT '5.716'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''558'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 902,82 898,78 898,78 902,82 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 715
---------------------------------------------------------
UNION ALL
SELECT '5.717'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''558'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 900,82 898,78 898,78 902,79 902,79 900,82 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 716
---------------------------------------------------------
UNION ALL
SELECT '5.718'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''559'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 904,83 903,80 903,80 900,79 900,79 904,83 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 717
---------------------------------------------------------
UNION ALL
SELECT '5.719'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''559'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 904,83 900,82 900,82 902,79 902,79 904,83 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 718
---------------------------------------------------------
UNION ALL
SELECT '5.720'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''559'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 904,83 900,79 900,79 904,83 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 719
---------------------------------------------------------
UNION ALL
SELECT '5.721'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''560'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 903,84 899,80 899,80 903,84 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 720
---------------------------------------------------------
UNION ALL
SELECT '5.722'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''560'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 903,84 899,82 899,82 900,83 900,83 903,84 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 721
---------------------------------------------------------
UNION ALL
SELECT '5.723'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''561'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 929,2 928,-2 928,-2 932,-1 932,-1 930,0 930,0 929,2 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 722
---------------------------------------------------------
UNION ALL
SELECT '5.724'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''561'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 932,2 928,-2 928,-2 932,2 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 723
---------------------------------------------------------
UNION ALL
SELECT '5.725'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''561'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 930,2 928,-2 928,-2 932,-1 932,-1 930,2 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 724
---------------------------------------------------------
UNION ALL
SELECT '5.726'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''562'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 933,4 929,2 929,2 930,3 930,3 933,4 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 725
---------------------------------------------------------
UNION ALL
SELECT '5.727'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''562'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 933,4 929,0 929,0 933,4 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 726
---------------------------------------------------------
UNION ALL
SELECT '5.728'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''563'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 934,3 933,0 933,0 930,-1 930,-1 934,3 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 727
---------------------------------------------------------
UNION ALL
SELECT '5.729'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''563'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 934,3 930,2 930,2 932,-1 932,-1 934,3 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 728
---------------------------------------------------------
UNION ALL
SELECT '5.730'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''563'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 934,3 930,-1 930,-1 934,3 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 729
---------------------------------------------------------
UNION ALL
SELECT '5.731'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''564'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 934,19 930,18 930,18 932,15 932,15 934,19 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 730
---------------------------------------------------------
UNION ALL
SELECT '5.732'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''564'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 934,19 930,15 930,15 934,19 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 731
---------------------------------------------------------
UNION ALL
SELECT '5.733'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''564'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 934,19 933,16 933,16 930,15 930,15 934,19 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 732
---------------------------------------------------------
UNION ALL
SELECT '5.734'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''565'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 929,18 928,14 928,14 932,15 932,15 930,16 930,16 929,18 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 733
---------------------------------------------------------
UNION ALL
SELECT '5.735'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''565'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 932,18 928,14 928,14 932,18 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 734
---------------------------------------------------------
UNION ALL
SELECT '5.736'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''565'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 930,18 928,14 928,14 932,15 932,15 930,18 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 735
---------------------------------------------------------
UNION ALL
SELECT '5.737'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''566'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 933,20 929,16 929,16 933,20 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 736
---------------------------------------------------------
UNION ALL
SELECT '5.738'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''566'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 933,20 929,18 929,18 930,19 930,19 933,20 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 737
---------------------------------------------------------
UNION ALL
SELECT '5.739'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''567'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 933,36 929,32 929,32 933,36 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 738
---------------------------------------------------------
UNION ALL
SELECT '5.740'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''567'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 933,36 929,34 929,34 930,35 930,35 933,36 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 739
---------------------------------------------------------
UNION ALL
SELECT '5.741'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''568'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 929,34 928,30 928,30 932,31 932,31 930,32 930,32 929,34 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 740
---------------------------------------------------------
UNION ALL
SELECT '5.742'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''568'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 932,34 928,30 928,30 932,34 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 741
---------------------------------------------------------
UNION ALL
SELECT '5.743'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''568'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 930,34 928,30 928,30 932,31 932,31 930,34 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 742
---------------------------------------------------------
UNION ALL
SELECT '5.744'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''569'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 934,35 933,32 933,32 930,31 930,31 934,35 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 743
---------------------------------------------------------
UNION ALL
SELECT '5.745'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''569'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 934,35 930,34 930,34 932,31 932,31 934,35 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 744
---------------------------------------------------------
UNION ALL
SELECT '5.746'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''569'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 934,35 930,31 930,31 934,35 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 745
---------------------------------------------------------
UNION ALL
SELECT '5.747'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''570'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 934,51 930,47 930,47 934,51 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 746
---------------------------------------------------------
UNION ALL
SELECT '5.748'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''570'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 934,51 933,48 933,48 930,47 930,47 934,51 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 747
---------------------------------------------------------
UNION ALL
SELECT '5.749'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''570'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 934,51 930,50 930,50 932,47 932,47 934,51 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 748
---------------------------------------------------------
UNION ALL
SELECT '5.750'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''571'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 933,52 929,50 929,50 930,51 930,51 933,52 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 749
---------------------------------------------------------
UNION ALL
SELECT '5.751'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''571'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 933,52 929,48 929,48 933,52 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 750
---------------------------------------------------------
UNION ALL
SELECT '5.752'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''572'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 929,50 928,46 928,46 932,47 932,47 930,48 930,48 929,50 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 751
---------------------------------------------------------
UNION ALL
SELECT '5.753'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''572'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 932,50 928,46 928,46 932,50 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 752
---------------------------------------------------------
UNION ALL
SELECT '5.754'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''572'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 930,50 928,46 928,46 932,47 932,47 930,50 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 753
---------------------------------------------------------
UNION ALL
SELECT '5.755'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''573'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 933,68 929,64 929,64 933,68 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 754
---------------------------------------------------------
UNION ALL
SELECT '5.756'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''573'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 933,68 929,66 929,66 930,67 930,67 933,68 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 755
---------------------------------------------------------
UNION ALL
SELECT '5.757'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''574'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 934,67 930,63 930,63 934,67 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 756
---------------------------------------------------------
UNION ALL
SELECT '5.758'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''574'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 934,67 930,66 930,66 932,63 932,63 934,67 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 757
---------------------------------------------------------
UNION ALL
SELECT '5.759'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''574'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 934,67 933,64 933,64 930,63 930,63 934,67 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 758
---------------------------------------------------------
UNION ALL
SELECT '5.760'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''575'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 929,66 928,62 928,62 932,63 932,63 930,64 930,64 929,66 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 759
---------------------------------------------------------
UNION ALL
SELECT '5.761'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''575'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 932,66 928,62 928,62 932,66 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 760
---------------------------------------------------------
UNION ALL
SELECT '5.762'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''575'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 930,66 928,62 928,62 932,63 932,63 930,66 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 761
---------------------------------------------------------
-- The 6.x test series was generated using
-- SELECT TT_GenerateTestsForTable('test_geohistory_3_results_with_validity', 6);
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''0'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((-14 -1,-14 -2,-18 -2,-18 2,-17 2,-17 0,-16 0,-16 -1,-14 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 0
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''1'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((-13 4,-13 3,-16 3,-16 0,-17 0,-17 4,-13 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 1
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''2'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((-12 3,-12 -1,-16 -1,-16 3,-12 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 2
---------------------------------------------------------
UNION ALL
SELECT '6.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''3'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 -1,2 -2,-2 -2,-2 2,-1 2,-1 0,0 0,0 -1,2 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 3
---------------------------------------------------------
UNION ALL
SELECT '6.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''4'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 3,4 -1,0 -1,0 0,3 0,3 3,4 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 4
---------------------------------------------------------
UNION ALL
SELECT '6.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''5'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 4,3 0,-1 0,-1 4,3 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 5
---------------------------------------------------------
UNION ALL
SELECT '6.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''6'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 4,19 3,16 3,16 2,15 2,15 4,19 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 6
---------------------------------------------------------
UNION ALL
SELECT '6.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''7'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 -1,18 -2,14 -2,14 2,16 2,16 -1,18 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 7
---------------------------------------------------------
UNION ALL
SELECT '6.9'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''8'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 3,20 -1,16 -1,16 3,20 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 8
---------------------------------------------------------
UNION ALL
SELECT '6.10'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''9'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 3,36 -1,32 -1,32 3,36 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 9
---------------------------------------------------------
UNION ALL
SELECT '6.11'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''10'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 -1,34 -2,30 -2,30 2,31 2,31 0,32 0,32 -1,34 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 10
---------------------------------------------------------
UNION ALL
SELECT '6.12'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''11'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 4,35 3,32 3,32 0,31 0,31 4,35 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 11
---------------------------------------------------------
UNION ALL
SELECT '6.13'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''12'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 4,51 3,48 3,48 2,47 2,47 4,51 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 12
---------------------------------------------------------
UNION ALL
SELECT '6.14'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''13'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 3,52 -1,50 -1,50 2,48 2,48 3,52 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 13
---------------------------------------------------------
UNION ALL
SELECT '6.15'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''14'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 2,50 -2,46 -2,46 2,50 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 14
---------------------------------------------------------
UNION ALL
SELECT '6.16'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''15'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 3,68 -1,66 -1,66 0,67 0,67 3,68 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 15
---------------------------------------------------------
UNION ALL
SELECT '6.17'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''16'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 4,67 0,66 0,66 2,63 2,63 4,67 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 16
---------------------------------------------------------
UNION ALL
SELECT '6.18'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''17'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 2,66 -2,62 -2,62 2,66 2))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 17
---------------------------------------------------------
UNION ALL
SELECT '6.19'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''18'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 -1,82 -2,78 -2,78 2,79 2,79 0,80 0,80 -1,82 -1))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 18
---------------------------------------------------------
UNION ALL
SELECT '6.20'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''19'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 4,83 3,80 3,80 0,79 0,79 4,83 4))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 19
---------------------------------------------------------
UNION ALL
SELECT '6.21'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''20'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 3,84 -1,80 -1,80 3,84 3))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 20
---------------------------------------------------------
UNION ALL
SELECT '6.22'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''21'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 29,2 28,-2 28,-2 32,-1 32,-1 30,0 30,0 29,2 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 21
---------------------------------------------------------
UNION ALL
SELECT '6.23'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''22'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 33,4 29,0 29,0 33,4 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 22
---------------------------------------------------------
UNION ALL
SELECT '6.24'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''23'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 34,3 33,0 33,0 30,-1 30,-1 34,3 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 23
---------------------------------------------------------
UNION ALL
SELECT '6.25'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''24'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 34,19 33,16 33,16 32,15 32,15 34,19 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 24
---------------------------------------------------------
UNION ALL
SELECT '6.26'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''25'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 29,18 28,14 28,14 32,16 32,16 29,18 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 25
---------------------------------------------------------
UNION ALL
SELECT '6.27'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''26'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 33,20 29,16 29,16 33,20 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 26
---------------------------------------------------------
UNION ALL
SELECT '6.28'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''27'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 33,36 29,32 29,32 33,36 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 27
---------------------------------------------------------
UNION ALL
SELECT '6.29'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''28'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 29,34 28,30 28,30 32,31 32,31 30,32 30,32 29,34 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 28
---------------------------------------------------------
UNION ALL
SELECT '6.30'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''29'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 34,35 33,32 33,32 30,31 30,31 34,35 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 29
---------------------------------------------------------
UNION ALL
SELECT '6.31'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''30'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 34,51 33,48 33,48 32,47 32,47 34,51 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 30
---------------------------------------------------------
UNION ALL
SELECT '6.32'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''31'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 33,52 29,48 29,48 33,52 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 31
---------------------------------------------------------
UNION ALL
SELECT '6.33'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''32'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 29,50 28,46 28,46 32,48 32,48 29,50 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 32
---------------------------------------------------------
UNION ALL
SELECT '6.34'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''33'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 33,68 29,64 29,64 33,68 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 33
---------------------------------------------------------
UNION ALL
SELECT '6.35'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''34'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 34,67 33,64 33,64 32,63 32,63 34,67 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 34
---------------------------------------------------------
UNION ALL
SELECT '6.36'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''35'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 29,66 28,62 28,62 32,64 32,64 29,66 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 35
---------------------------------------------------------
UNION ALL
SELECT '6.37'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''36'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 29,82 28,78 28,78 32,79 32,79 30,80 30,80 29,82 29))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 36
---------------------------------------------------------
UNION ALL
SELECT '6.38'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''37'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 34,83 30,79 30,79 34,83 34))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 37
---------------------------------------------------------
UNION ALL
SELECT '6.39'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''38'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 33,84 29,80 29,80 30,83 30,83 33,84 33))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 38
---------------------------------------------------------
UNION ALL
SELECT '6.40'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''39'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 59,2 58,-2 58,-2 62,-1 62,-1 60,0 60,0 59,2 59))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 39
---------------------------------------------------------
UNION ALL
SELECT '6.41'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''40'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 63,4 59,0 59,0 60,3 60,3 63,4 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 40
---------------------------------------------------------
UNION ALL
SELECT '6.42'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''41'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 64,3 60,-1 60,-1 64,3 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 41
---------------------------------------------------------
UNION ALL
SELECT '6.43'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''42'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 64,19 60,15 60,15 64,19 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 42
---------------------------------------------------------
UNION ALL
SELECT '6.44'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''43'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 59,18 58,14 58,14 62,15 62,15 60,16 60,16 59,18 59))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 43
---------------------------------------------------------
UNION ALL
SELECT '6.45'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''44'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 63,20 59,16 59,16 60,19 60,19 63,20 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 44
---------------------------------------------------------
UNION ALL
SELECT '6.46'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''45'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 63,36 59,34 59,34 60,35 60,35 63,36 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 45
---------------------------------------------------------
UNION ALL
SELECT '6.47'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''46'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 60,34 58,30 58,30 62,31 62,31 60,34 60))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 46
---------------------------------------------------------
UNION ALL
SELECT '6.48'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''47'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 64,35 60,31 60,31 64,35 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 47
---------------------------------------------------------
UNION ALL
SELECT '6.49'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''48'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 64,51 60,47 60,47 64,51 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 48
---------------------------------------------------------
UNION ALL
SELECT '6.50'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''49'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 63,52 59,50 59,50 60,51 60,51 63,52 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 49
---------------------------------------------------------
UNION ALL
SELECT '6.51'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''50'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 60,50 58,46 58,46 62,47 62,47 60,50 60))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 50
---------------------------------------------------------
UNION ALL
SELECT '6.52'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''51'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 63,68 59,66 59,66 60,67 60,67 63,68 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 51
---------------------------------------------------------
UNION ALL
SELECT '6.53'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''52'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 64,67 60,63 60,63 64,67 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 52
---------------------------------------------------------
UNION ALL
SELECT '6.54'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''53'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 60,66 58,62 58,62 62,63 62,63 60,66 60))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 53
---------------------------------------------------------
UNION ALL
SELECT '6.55'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''54'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 59,82 58,78 58,78 62,79 62,79 60,80 60,80 59,82 59))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 54
---------------------------------------------------------
UNION ALL
SELECT '6.56'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''55'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 64,83 63,80 63,80 60,79 60,79 64,83 64))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 55
---------------------------------------------------------
UNION ALL
SELECT '6.57'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''56'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 63,84 59,80 59,80 63,84 63))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 56
---------------------------------------------------------
UNION ALL
SELECT '6.58'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''57'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 89,2 88,-2 88,-2 92,-1 92,-1 90,0 90,0 89,2 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 57
---------------------------------------------------------
UNION ALL
SELECT '6.59'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''58'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 93,4 89,0 89,0 90,3 90,3 93,4 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 58
---------------------------------------------------------
UNION ALL
SELECT '6.60'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''59'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 94,3 90,-1 90,-1 94,3 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 59
---------------------------------------------------------
UNION ALL
SELECT '6.61'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''60'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 94,19 93,16 93,16 90,15 90,15 94,19 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 60
---------------------------------------------------------
UNION ALL
SELECT '6.62'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''61'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 89,18 88,14 88,14 92,15 92,15 90,16 90,16 89,18 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 61
---------------------------------------------------------
UNION ALL
SELECT '6.63'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''62'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 93,20 89,16 89,16 93,20 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 62
---------------------------------------------------------
UNION ALL
SELECT '6.64'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''63'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 93,36 89,32 89,32 90,35 90,35 93,36 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 63
---------------------------------------------------------
UNION ALL
SELECT '6.65'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''64'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 89,34 88,30 88,30 92,31 92,31 90,32 90,32 89,34 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 64
---------------------------------------------------------
UNION ALL
SELECT '6.66'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''65'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 94,35 90,31 90,31 94,35 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 65
---------------------------------------------------------
UNION ALL
SELECT '6.67'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''66'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 94,51 93,48 93,48 90,47 90,47 94,51 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 66
---------------------------------------------------------
UNION ALL
SELECT '6.68'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''67'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 93,52 89,48 89,48 93,52 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 67
---------------------------------------------------------
UNION ALL
SELECT '6.69'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''68'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 89,50 88,46 88,46 92,47 92,47 90,48 90,48 89,50 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 68
---------------------------------------------------------
UNION ALL
SELECT '6.70'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''69'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 93,68 89,64 89,64 90,67 90,67 93,68 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 69
---------------------------------------------------------
UNION ALL
SELECT '6.71'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''70'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 94,67 90,63 90,63 94,67 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 70
---------------------------------------------------------
UNION ALL
SELECT '6.72'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''71'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 89,66 88,62 88,62 92,63 92,63 90,64 90,64 89,66 89))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 71
---------------------------------------------------------
UNION ALL
SELECT '6.73'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''72'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 92,82 88,78 88,78 92,82 92))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 72
---------------------------------------------------------
UNION ALL
SELECT '6.74'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''73'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 94,83 93,80 93,80 92,79 92,79 94,83 94))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 73
---------------------------------------------------------
UNION ALL
SELECT '6.75'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''74'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 93,84 89,82 89,82 92,80 92,80 93,84 93))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 74
---------------------------------------------------------
UNION ALL
SELECT '6.76'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''75'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 122,2 118,-2 118,-2 122,2 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 75
---------------------------------------------------------
UNION ALL
SELECT '6.77'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''76'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 123,4 119,2 119,2 120,3 120,3 123,4 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 76
---------------------------------------------------------
UNION ALL
SELECT '6.78'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''77'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 124,3 120,2 120,2 122,-1 122,-1 124,3 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 77
---------------------------------------------------------
UNION ALL
SELECT '6.79'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''78'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 124,19 123,16 123,16 122,15 122,15 124,19 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 78
---------------------------------------------------------
UNION ALL
SELECT '6.80'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''79'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 122,18 118,14 118,14 122,18 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 79
---------------------------------------------------------
UNION ALL
SELECT '6.81'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''80'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 123,20 119,18 119,18 122,16 122,16 123,20 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 80
---------------------------------------------------------
UNION ALL
SELECT '6.82'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''81'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 123,36 119,34 119,34 120,35 120,35 123,36 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 81
---------------------------------------------------------
UNION ALL
SELECT '6.83'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''82'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 122,34 118,30 118,30 122,34 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 82
---------------------------------------------------------
UNION ALL
SELECT '6.84'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''83'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 124,35 120,34 120,34 122,31 122,31 124,35 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 83
---------------------------------------------------------
UNION ALL
SELECT '6.85'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''84'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 124,51 123,48 123,48 122,47 122,47 124,51 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 84
---------------------------------------------------------
UNION ALL
SELECT '6.86'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''85'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 123,52 119,50 119,50 122,48 122,48 123,52 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 85
---------------------------------------------------------
UNION ALL
SELECT '6.87'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''86'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 122,50 118,46 118,46 122,50 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 86
---------------------------------------------------------
UNION ALL
SELECT '6.88'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''87'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 123,68 119,66 119,66 120,67 120,67 123,68 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 87
---------------------------------------------------------
UNION ALL
SELECT '6.89'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''88'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 124,67 120,66 120,66 122,63 122,63 124,67 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 88
---------------------------------------------------------
UNION ALL
SELECT '6.90'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''89'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 122,66 118,62 118,62 122,66 122))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 89
---------------------------------------------------------
UNION ALL
SELECT '6.91'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''90'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 119,82 118,78 118,78 122,80 122,80 119,82 119))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 90
---------------------------------------------------------
UNION ALL
SELECT '6.92'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''91'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 124,83 123,80 123,80 122,79 122,79 124,83 124))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 91
---------------------------------------------------------
UNION ALL
SELECT '6.93'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''92'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 123,84 119,80 119,80 123,84 123))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 92
---------------------------------------------------------
UNION ALL
SELECT '6.94'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''93'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 149,2 148,-2 148,-2 152,0 152,0 149,2 149))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 93
---------------------------------------------------------
UNION ALL
SELECT '6.95'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''94'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 153,4 149,0 149,0 153,4 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 94
---------------------------------------------------------
UNION ALL
SELECT '6.96'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''95'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 154,3 153,0 153,0 152,-1 152,-1 154,3 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 95
---------------------------------------------------------
UNION ALL
SELECT '6.97'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''96'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 154,19 153,16 153,16 152,15 152,15 154,19 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 96
---------------------------------------------------------
UNION ALL
SELECT '6.98'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''97'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 149,18 148,14 148,14 152,16 152,16 149,18 149))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 97
---------------------------------------------------------
UNION ALL
SELECT '6.99'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''98'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 153,20 149,16 149,16 153,20 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 98
---------------------------------------------------------
UNION ALL
SELECT '6.100'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''99'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 153,36 149,32 149,32 153,36 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 99
---------------------------------------------------------
UNION ALL
SELECT '6.101'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''100'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 149,34 148,30 148,30 152,32 152,32 149,34 149))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 100
---------------------------------------------------------
UNION ALL
SELECT '6.102'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''101'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 154,35 153,32 153,32 152,31 152,31 154,35 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 101
---------------------------------------------------------
UNION ALL
SELECT '6.103'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''102'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 154,51 153,48 153,48 152,47 152,47 154,51 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 102
---------------------------------------------------------
UNION ALL
SELECT '6.104'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''103'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 153,52 149,50 149,50 152,48 152,48 153,52 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 103
---------------------------------------------------------
UNION ALL
SELECT '6.105'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''104'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 152,50 148,46 148,46 152,50 152))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 104
---------------------------------------------------------
UNION ALL
SELECT '6.106'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''105'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 153,68 149,66 149,66 152,64 152,64 153,68 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 105
---------------------------------------------------------
UNION ALL
SELECT '6.107'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''106'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 154,67 153,64 153,64 152,63 152,63 154,67 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 106
---------------------------------------------------------
UNION ALL
SELECT '6.108'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''107'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 152,66 148,62 148,62 152,66 152))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 107
---------------------------------------------------------
UNION ALL
SELECT '6.109'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''108'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 150,82 148,78 148,78 152,79 152,79 150,82 150))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 108
---------------------------------------------------------
UNION ALL
SELECT '6.110'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''109'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 154,83 150,79 150,79 154,83 154))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 109
---------------------------------------------------------
UNION ALL
SELECT '6.111'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''110'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 153,84 149,82 149,82 150,83 150,83 153,84 153))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 110
---------------------------------------------------------
UNION ALL
SELECT '6.112'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''111'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 180,2 178,-2 178,-2 182,-1 182,-1 180,2 180))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 111
---------------------------------------------------------
UNION ALL
SELECT '6.113'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''112'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 183,4 179,2 179,2 180,3 180,3 183,4 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 112
---------------------------------------------------------
UNION ALL
SELECT '6.114'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''113'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 184,3 180,-1 180,-1 184,3 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 113
---------------------------------------------------------
UNION ALL
SELECT '6.115'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''114'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 184,19 180,18 180,18 182,15 182,15 184,19 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 114
---------------------------------------------------------
UNION ALL
SELECT '6.116'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''115'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 182,18 178,14 178,14 182,18 182))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 115
---------------------------------------------------------
UNION ALL
SELECT '6.117'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''116'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 183,20 179,18 179,18 180,19 180,19 183,20 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 116
---------------------------------------------------------
UNION ALL
SELECT '6.118'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''117'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 183,36 179,34 179,34 180,35 180,35 183,36 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 117
---------------------------------------------------------
UNION ALL
SELECT '6.119'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''118'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 180,34 178,30 178,30 182,31 182,31 180,34 180))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 118
---------------------------------------------------------
UNION ALL
SELECT '6.120'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''119'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 184,35 180,31 180,31 184,35 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 119
---------------------------------------------------------
UNION ALL
SELECT '6.121'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''120'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 184,51 180,50 180,50 182,47 182,47 184,51 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 120
---------------------------------------------------------
UNION ALL
SELECT '6.122'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''121'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 183,52 179,50 179,50 180,51 180,51 183,52 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 121
---------------------------------------------------------
UNION ALL
SELECT '6.123'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''122'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 182,50 178,46 178,46 182,50 182))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 122
---------------------------------------------------------
UNION ALL
SELECT '6.124'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''123'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 183,68 179,66 179,66 180,67 180,67 183,68 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 123
---------------------------------------------------------
UNION ALL
SELECT '6.125'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''124'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 184,67 180,66 180,66 182,63 182,63 184,67 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 124
---------------------------------------------------------
UNION ALL
SELECT '6.126'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''125'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 182,66 178,62 178,62 182,66 182))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 125
---------------------------------------------------------
UNION ALL
SELECT '6.127'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''126'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 179,82 178,78 178,78 182,79 182,79 180,80 180,80 179,82 179))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 126
---------------------------------------------------------
UNION ALL
SELECT '6.128'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''127'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 184,83 183,80 183,80 180,79 180,79 184,83 184))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 127
---------------------------------------------------------
UNION ALL
SELECT '6.129'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''128'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 183,84 179,80 179,80 183,84 183))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 128
---------------------------------------------------------
UNION ALL
SELECT '6.130'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''129'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 209,2 208,-2 208,-2 212,-1 212,-1 210,0 210,0 209,2 209))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 129
---------------------------------------------------------
UNION ALL
SELECT '6.131'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''130'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 213,4 209,0 209,0 210,3 210,3 213,4 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 130
---------------------------------------------------------
UNION ALL
SELECT '6.132'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''131'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 214,3 210,-1 210,-1 214,3 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 131
---------------------------------------------------------
UNION ALL
SELECT '6.133'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''132'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 214,19 213,16 213,16 212,15 212,15 214,19 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 132
---------------------------------------------------------
UNION ALL
SELECT '6.134'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''133'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 209,18 208,14 208,14 212,16 212,16 209,18 209))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 133
---------------------------------------------------------
UNION ALL
SELECT '6.135'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''134'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 213,20 209,16 209,16 213,20 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 134
---------------------------------------------------------
UNION ALL
SELECT '6.136'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''135'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 213,36 209,34 209,34 210,35 210,35 213,36 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 135
---------------------------------------------------------
UNION ALL
SELECT '6.137'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''136'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 210,34 208,30 208,30 212,31 212,31 210,34 210))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 136
---------------------------------------------------------
UNION ALL
SELECT '6.138'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''137'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 214,35 210,31 210,31 214,35 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 137
---------------------------------------------------------
UNION ALL
SELECT '6.139'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''138'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 214,51 213,48 213,48 212,47 212,47 214,51 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 138
---------------------------------------------------------
UNION ALL
SELECT '6.140'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''139'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 213,52 209,50 209,50 212,48 212,48 213,52 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 139
---------------------------------------------------------
UNION ALL
SELECT '6.141'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''140'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 212,50 208,46 208,46 212,50 212))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 140
---------------------------------------------------------
UNION ALL
SELECT '6.142'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''141'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 213,68 209,66 209,66 210,67 210,67 213,68 213))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 141
---------------------------------------------------------
UNION ALL
SELECT '6.143'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''142'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 214,67 210,66 210,66 212,63 212,63 214,67 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 142
---------------------------------------------------------
UNION ALL
SELECT '6.144'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''143'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 212,66 208,62 208,62 212,66 212))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 143
---------------------------------------------------------
UNION ALL
SELECT '6.145'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''144'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 209,82 208,78 208,78 212,79 212,79 210,80 210,80 209,82 209))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 144
---------------------------------------------------------
UNION ALL
SELECT '6.146'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''145'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 214,83 213,80 213,80 210,79 210,79 214,83 214))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 145
---------------------------------------------------------
UNION ALL
SELECT '6.147'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''146'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 213,84 209,80 209,80 213,84 213))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 146
---------------------------------------------------------
UNION ALL
SELECT '6.148'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''147'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 239,2 238,-2 238,-2 242,-1 242,-1 240,0 240,0 239,2 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 147
---------------------------------------------------------
UNION ALL
SELECT '6.149'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''148'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 243,4 239,0 239,0 243,4 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 148
---------------------------------------------------------
UNION ALL
SELECT '6.150'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''149'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 244,3 243,0 243,0 240,-1 240,-1 244,3 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 149
---------------------------------------------------------
UNION ALL
SELECT '6.151'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''150'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 244,19 243,16 243,16 242,15 242,15 244,19 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 150
---------------------------------------------------------
UNION ALL
SELECT '6.152'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''151'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 239,18 238,14 238,14 242,16 242,16 239,18 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 151
---------------------------------------------------------
UNION ALL
SELECT '6.153'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''152'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 243,20 239,16 239,16 243,20 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 152
---------------------------------------------------------
UNION ALL
SELECT '6.154'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''153'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 243,36 239,32 239,32 243,36 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 153
---------------------------------------------------------
UNION ALL
SELECT '6.155'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''154'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 239,34 238,30 238,30 242,31 242,31 240,32 240,32 239,34 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 154
---------------------------------------------------------
UNION ALL
SELECT '6.156'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''155'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 244,35 243,32 243,32 240,31 240,31 244,35 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 155
---------------------------------------------------------
UNION ALL
SELECT '6.157'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''156'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 244,51 243,48 243,48 242,47 242,47 244,51 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 156
---------------------------------------------------------
UNION ALL
SELECT '6.158'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''157'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 243,52 239,48 239,48 243,52 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 157
---------------------------------------------------------
UNION ALL
SELECT '6.159'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''158'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 239,50 238,46 238,46 242,48 242,48 239,50 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 158
---------------------------------------------------------
UNION ALL
SELECT '6.160'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''159'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 243,68 239,64 239,64 243,68 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 159
---------------------------------------------------------
UNION ALL
SELECT '6.161'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''160'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 244,67 243,64 243,64 242,63 242,63 244,67 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 160
---------------------------------------------------------
UNION ALL
SELECT '6.162'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''161'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 239,66 238,62 238,62 242,64 242,64 239,66 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 161
---------------------------------------------------------
UNION ALL
SELECT '6.163'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''162'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 239,82 238,78 238,78 242,79 242,79 240,80 240,80 239,82 239))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 162
---------------------------------------------------------
UNION ALL
SELECT '6.164'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''163'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 244,83 243,80 243,80 240,79 240,79 244,83 244))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 163
---------------------------------------------------------
UNION ALL
SELECT '6.165'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''164'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 243,84 239,80 239,80 243,84 243))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 164
---------------------------------------------------------
UNION ALL
SELECT '6.166'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''165'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 269,2 268,-2 268,-2 272,-1 272,-1 270,0 270,0 269,2 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 165
---------------------------------------------------------
UNION ALL
SELECT '6.167'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''166'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 273,4 269,0 269,0 273,4 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 166
---------------------------------------------------------
UNION ALL
SELECT '6.168'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''167'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 274,3 273,0 273,0 270,-1 270,-1 274,3 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 167
---------------------------------------------------------
UNION ALL
SELECT '6.169'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''168'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 274,19 273,16 273,16 272,15 272,15 274,19 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 168
---------------------------------------------------------
UNION ALL
SELECT '6.170'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''169'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 269,18 268,14 268,14 272,16 272,16 269,18 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 169
---------------------------------------------------------
UNION ALL
SELECT '6.171'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''170'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 273,20 269,16 269,16 273,20 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 170
---------------------------------------------------------
UNION ALL
SELECT '6.172'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''171'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 273,36 269,32 269,32 273,36 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 171
---------------------------------------------------------
UNION ALL
SELECT '6.173'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''172'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 269,34 268,30 268,30 272,31 272,31 270,32 270,32 269,34 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 172
---------------------------------------------------------
UNION ALL
SELECT '6.174'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''173'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 274,35 273,32 273,32 270,31 270,31 274,35 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 173
---------------------------------------------------------
UNION ALL
SELECT '6.175'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''174'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 274,51 273,48 273,48 272,47 272,47 274,51 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 174
---------------------------------------------------------
UNION ALL
SELECT '6.176'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''175'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 273,52 269,48 269,48 273,52 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 175
---------------------------------------------------------
UNION ALL
SELECT '6.177'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''176'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 269,50 268,46 268,46 272,48 272,48 269,50 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 176
---------------------------------------------------------
UNION ALL
SELECT '6.178'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''177'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 273,68 269,64 269,64 273,68 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 177
---------------------------------------------------------
UNION ALL
SELECT '6.179'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''178'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 274,67 273,64 273,64 272,63 272,63 274,67 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 178
---------------------------------------------------------
UNION ALL
SELECT '6.180'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''179'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 269,66 268,62 268,62 272,64 272,64 269,66 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 179
---------------------------------------------------------
UNION ALL
SELECT '6.181'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''180'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 269,82 268,78 268,78 272,79 272,79 270,80 270,80 269,82 269))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 180
---------------------------------------------------------
UNION ALL
SELECT '6.182'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''181'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 274,83 270,79 270,79 274,83 274))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 181
---------------------------------------------------------
UNION ALL
SELECT '6.183'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''182'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 273,84 269,80 269,80 270,83 270,83 273,84 273))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 182
---------------------------------------------------------
UNION ALL
SELECT '6.184'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''183'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 299,2 298,-2 298,-2 302,-1 302,-1 300,0 300,0 299,2 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 183
---------------------------------------------------------
UNION ALL
SELECT '6.185'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''184'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 303,4 299,0 299,0 300,3 300,3 303,4 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 184
---------------------------------------------------------
UNION ALL
SELECT '6.186'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''185'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 304,3 300,-1 300,-1 304,3 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 185
---------------------------------------------------------
UNION ALL
SELECT '6.187'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''186'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 304,19 300,15 300,15 304,19 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 186
---------------------------------------------------------
UNION ALL
SELECT '6.188'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''187'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 299,18 298,14 298,14 302,15 302,15 300,16 300,16 299,18 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 187
---------------------------------------------------------
UNION ALL
SELECT '6.189'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''188'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 303,20 299,16 299,16 300,19 300,19 303,20 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 188
---------------------------------------------------------
UNION ALL
SELECT '6.190'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''189'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 303,36 299,32 299,32 300,35 300,35 303,36 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 189
---------------------------------------------------------
UNION ALL
SELECT '6.191'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''190'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 299,34 298,30 298,30 302,31 302,31 300,32 300,32 299,34 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 190
---------------------------------------------------------
UNION ALL
SELECT '6.192'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''191'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 304,35 300,31 300,31 304,35 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 191
---------------------------------------------------------
UNION ALL
SELECT '6.193'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''192'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 304,51 300,47 300,47 304,51 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 192
---------------------------------------------------------
UNION ALL
SELECT '6.194'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''193'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 303,52 299,48 299,48 300,51 300,51 303,52 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 193
---------------------------------------------------------
UNION ALL
SELECT '6.195'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''194'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 299,50 298,46 298,46 302,47 302,47 300,48 300,48 299,50 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 194
---------------------------------------------------------
UNION ALL
SELECT '6.196'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''195'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 303,68 299,64 299,64 300,67 300,67 303,68 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 195
---------------------------------------------------------
UNION ALL
SELECT '6.197'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''196'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 304,67 300,63 300,63 304,67 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 196
---------------------------------------------------------
UNION ALL
SELECT '6.198'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''197'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 299,66 298,62 298,62 302,63 302,63 300,64 300,64 299,66 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 197
---------------------------------------------------------
UNION ALL
SELECT '6.199'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''198'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 299,82 298,78 298,78 302,79 302,79 300,80 300,80 299,82 299))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 198
---------------------------------------------------------
UNION ALL
SELECT '6.200'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''199'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 199
---------------------------------------------------------
UNION ALL
SELECT '6.201'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''199'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 304,83 300,79 300,79 304,83 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 200
---------------------------------------------------------
UNION ALL
SELECT '6.202'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''199'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 304,83 303,80 303,80 300,79 300,79 304,83 304))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 201
---------------------------------------------------------
UNION ALL
SELECT '6.203'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''200'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 303,84 299,80 299,80 303,84 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 202
---------------------------------------------------------
UNION ALL
SELECT '6.204'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''200'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 303,84 299,80 299,80 300,83 300,83 303,84 303))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 203
---------------------------------------------------------
UNION ALL
SELECT '6.205'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''201'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 329,2 328,-2 328,-2 332,-1 332,-1 330,0 330,0 329,2 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 204
---------------------------------------------------------
UNION ALL
SELECT '6.206'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''202'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 333,4 329,0 329,0 333,4 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 205
---------------------------------------------------------
UNION ALL
SELECT '6.207'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''202'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 333,4 329,0 329,0 330,3 330,3 333,4 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 206
---------------------------------------------------------
UNION ALL
SELECT '6.208'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''203'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 334,3 333,0 333,0 330,-1 330,-1 334,3 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 207
---------------------------------------------------------
UNION ALL
SELECT '6.209'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''203'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 334,3 330,-1 330,-1 334,3 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 208
---------------------------------------------------------
UNION ALL
SELECT '6.210'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''203'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 209
---------------------------------------------------------
UNION ALL
SELECT '6.211'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''204'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 334,19 333,16 333,16 330,15 330,15 334,19 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 210
---------------------------------------------------------
UNION ALL
SELECT '6.212'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''204'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 334,19 330,15 330,15 334,19 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 211
---------------------------------------------------------
UNION ALL
SELECT '6.213'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''204'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 212
---------------------------------------------------------
UNION ALL
SELECT '6.214'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''205'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 329,18 328,14 328,14 332,15 332,15 330,16 330,16 329,18 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 213
---------------------------------------------------------
UNION ALL
SELECT '6.215'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''206'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 333,20 329,16 329,16 330,19 330,19 333,20 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 214
---------------------------------------------------------
UNION ALL
SELECT '6.216'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''206'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 333,20 329,16 329,16 333,20 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 215
---------------------------------------------------------
UNION ALL
SELECT '6.217'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''207'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 333,36 329,32 329,32 330,35 330,35 333,36 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 216
---------------------------------------------------------
UNION ALL
SELECT '6.218'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''207'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 333,36 329,32 329,32 333,36 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 217
---------------------------------------------------------
UNION ALL
SELECT '6.219'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''208'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 329,34 328,30 328,30 332,31 332,31 330,32 330,32 329,34 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 218
---------------------------------------------------------
UNION ALL
SELECT '6.220'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''209'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 219
---------------------------------------------------------
UNION ALL
SELECT '6.221'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''209'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 334,35 333,32 333,32 330,31 330,31 334,35 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 220
---------------------------------------------------------
UNION ALL
SELECT '6.222'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''209'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 334,35 330,31 330,31 334,35 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 221
---------------------------------------------------------
UNION ALL
SELECT '6.223'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''210'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 222
---------------------------------------------------------
UNION ALL
SELECT '6.224'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''210'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 334,51 333,48 333,48 330,47 330,47 334,51 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 223
---------------------------------------------------------
UNION ALL
SELECT '6.225'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''210'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 334,51 330,47 330,47 334,51 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 224
---------------------------------------------------------
UNION ALL
SELECT '6.226'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''211'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 333,52 329,48 329,48 333,52 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 225
---------------------------------------------------------
UNION ALL
SELECT '6.227'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''211'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 333,52 329,48 329,48 330,51 330,51 333,52 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 226
---------------------------------------------------------
UNION ALL
SELECT '6.228'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''212'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 329,50 328,46 328,46 332,47 332,47 330,48 330,48 329,50 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 227
---------------------------------------------------------
UNION ALL
SELECT '6.229'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''213'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 333,68 329,64 329,64 330,67 330,67 333,68 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 228
---------------------------------------------------------
UNION ALL
SELECT '6.230'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''213'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 333,68 329,64 329,64 333,68 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 229
---------------------------------------------------------
UNION ALL
SELECT '6.231'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''214'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 230
---------------------------------------------------------
UNION ALL
SELECT '6.232'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''214'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 334,67 330,63 330,63 334,67 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 231
---------------------------------------------------------
UNION ALL
SELECT '6.233'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''214'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 334,67 333,64 333,64 330,63 330,63 334,67 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 232
---------------------------------------------------------
UNION ALL
SELECT '6.234'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''215'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 329,66 328,62 328,62 332,63 332,63 330,64 330,64 329,66 329))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 233
---------------------------------------------------------
UNION ALL
SELECT '6.235'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''216'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 332,82 328,78 328,78 332,82 332))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 234
---------------------------------------------------------
UNION ALL
SELECT '6.236'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''217'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 334,83 333,80 333,80 332,79 332,79 334,83 334))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 235
---------------------------------------------------------
UNION ALL
SELECT '6.237'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''218'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 333,84 329,82 329,82 332,80 332,80 333,84 333))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 236
---------------------------------------------------------
UNION ALL
SELECT '6.238'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''219'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 362,2 358,-2 358,-2 362,2 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 237
---------------------------------------------------------
UNION ALL
SELECT '6.239'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''220'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 363,4 359,2 359,2 362,0 362,0 363,4 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 238
---------------------------------------------------------
UNION ALL
SELECT '6.240'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''221'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 364,3 363,0 363,0 362,-1 362,-1 364,3 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 239
---------------------------------------------------------
UNION ALL
SELECT '6.241'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''222'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 364,19 363,16 363,16 362,15 362,15 364,19 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 240
---------------------------------------------------------
UNION ALL
SELECT '6.242'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''223'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 362,18 358,14 358,14 362,18 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 241
---------------------------------------------------------
UNION ALL
SELECT '6.243'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''224'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 363,20 359,18 359,18 362,16 362,16 363,20 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 242
---------------------------------------------------------
UNION ALL
SELECT '6.244'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''225'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 363,36 359,34 359,34 362,32 362,32 363,36 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 243
---------------------------------------------------------
UNION ALL
SELECT '6.245'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''226'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 362,34 358,30 358,30 362,34 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 244
---------------------------------------------------------
UNION ALL
SELECT '6.246'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''227'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 364,35 363,32 363,32 362,31 362,31 364,35 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 245
---------------------------------------------------------
UNION ALL
SELECT '6.247'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''228'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 364,51 363,48 363,48 362,47 362,47 364,51 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 246
---------------------------------------------------------
UNION ALL
SELECT '6.248'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''229'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 363,52 359,50 359,50 362,48 362,48 363,52 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 247
---------------------------------------------------------
UNION ALL
SELECT '6.249'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''230'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 362,50 358,46 358,46 362,50 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 248
---------------------------------------------------------
UNION ALL
SELECT '6.250'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''231'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 363,68 359,66 359,66 362,64 362,64 363,68 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 249
---------------------------------------------------------
UNION ALL
SELECT '6.251'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''232'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 364,67 363,64 363,64 362,63 362,63 364,67 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 250
---------------------------------------------------------
UNION ALL
SELECT '6.252'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''233'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 362,66 358,62 358,62 362,66 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 251
---------------------------------------------------------
UNION ALL
SELECT '6.253'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''234'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 362,82 358,78 358,78 362,82 362))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 252
---------------------------------------------------------
UNION ALL
SELECT '6.254'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''234'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 253
---------------------------------------------------------
UNION ALL
SELECT '6.255'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''234'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 359,82 358,78 358,78 362,80 362,80 359,82 359))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 254
---------------------------------------------------------
UNION ALL
SELECT '6.256'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''235'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 364,83 363,80 363,80 362,79 362,79 364,83 364))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 255
---------------------------------------------------------
UNION ALL
SELECT '6.257'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''236'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 363,84 359,80 359,80 363,84 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 256
---------------------------------------------------------
UNION ALL
SELECT '6.258'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''236'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 363,84 359,82 359,82 362,80 362,80 363,84 363))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 257
---------------------------------------------------------
UNION ALL
SELECT '6.259'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''237'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 392,2 388,-2 388,-2 392,2 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 258
---------------------------------------------------------
UNION ALL
SELECT '6.260'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''237'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 259
---------------------------------------------------------
UNION ALL
SELECT '6.261'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''237'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 389,2 388,-2 388,-2 392,0 392,0 389,2 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 260
---------------------------------------------------------
UNION ALL
SELECT '6.262'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''238'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 393,4 389,0 389,0 393,4 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 261
---------------------------------------------------------
UNION ALL
SELECT '6.263'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''238'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 393,4 389,2 389,2 392,0 392,0 393,4 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 262
---------------------------------------------------------
UNION ALL
SELECT '6.264'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''239'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 394,3 393,0 393,0 392,-1 392,-1 394,3 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 263
---------------------------------------------------------
UNION ALL
SELECT '6.265'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''240'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 394,19 393,16 393,16 392,15 392,15 394,19 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 264
---------------------------------------------------------
UNION ALL
SELECT '6.266'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''241'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 265
---------------------------------------------------------
UNION ALL
SELECT '6.267'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''241'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 389,18 388,14 388,14 392,16 392,16 389,18 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 266
---------------------------------------------------------
UNION ALL
SELECT '6.268'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''241'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 392,18 388,14 388,14 392,18 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 267
---------------------------------------------------------
UNION ALL
SELECT '6.269'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''242'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 393,20 389,18 389,18 392,16 392,16 393,20 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 268
---------------------------------------------------------
UNION ALL
SELECT '6.270'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''242'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 393,20 389,16 389,16 393,20 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 269
---------------------------------------------------------
UNION ALL
SELECT '6.271'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''243'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 393,36 389,32 389,32 393,36 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 270
---------------------------------------------------------
UNION ALL
SELECT '6.272'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''243'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 393,36 389,34 389,34 392,32 392,32 393,36 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 271
---------------------------------------------------------
UNION ALL
SELECT '6.273'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''244'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 389,34 388,30 388,30 392,32 392,32 389,34 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 272
---------------------------------------------------------
UNION ALL
SELECT '6.274'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''244'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 273
---------------------------------------------------------
UNION ALL
SELECT '6.275'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''244'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 392,34 388,30 388,30 392,34 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 274
---------------------------------------------------------
UNION ALL
SELECT '6.276'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''245'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 394,35 393,32 393,32 392,31 392,31 394,35 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 275
---------------------------------------------------------
UNION ALL
SELECT '6.277'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''246'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 394,51 393,48 393,48 392,47 392,47 394,51 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 276
---------------------------------------------------------
UNION ALL
SELECT '6.278'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''247'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 393,52 389,48 389,48 393,52 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 277
---------------------------------------------------------
UNION ALL
SELECT '6.279'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''247'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 393,52 389,50 389,50 392,48 392,48 393,52 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 278
---------------------------------------------------------
UNION ALL
SELECT '6.280'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''248'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 389,50 388,46 388,46 392,48 392,48 389,50 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 279
---------------------------------------------------------
UNION ALL
SELECT '6.281'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''248'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 392,50 388,46 388,46 392,50 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 280
---------------------------------------------------------
UNION ALL
SELECT '6.282'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''248'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 281
---------------------------------------------------------
UNION ALL
SELECT '6.283'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''249'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 393,68 389,64 389,64 393,68 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 282
---------------------------------------------------------
UNION ALL
SELECT '6.284'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''249'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 393,68 389,66 389,66 392,64 392,64 393,68 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 283
---------------------------------------------------------
UNION ALL
SELECT '6.285'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''250'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 394,67 393,64 393,64 392,63 392,63 394,67 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 284
---------------------------------------------------------
UNION ALL
SELECT '6.286'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''251'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 392,66 388,62 388,62 392,66 392))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 285
---------------------------------------------------------
UNION ALL
SELECT '6.287'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''251'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 389,66 388,62 388,62 392,64 392,64 389,66 389))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 286
---------------------------------------------------------
UNION ALL
SELECT '6.288'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''251'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 287
---------------------------------------------------------
UNION ALL
SELECT '6.289'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''252'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 390,82 388,78 388,78 392,79 392,79 390,82 390))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 288
---------------------------------------------------------
UNION ALL
SELECT '6.290'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''253'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 394,83 390,79 390,79 394,83 394))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 289
---------------------------------------------------------
UNION ALL
SELECT '6.291'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''254'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 393,84 389,82 389,82 390,83 390,83 393,84 393))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 290
---------------------------------------------------------
UNION ALL
SELECT '6.292'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''255'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 420,2 418,-2 418,-2 422,-1 422,-1 420,2 420))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 291
---------------------------------------------------------
UNION ALL
SELECT '6.293'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''256'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 423,4 419,2 419,2 420,3 420,3 423,4 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 292
---------------------------------------------------------
UNION ALL
SELECT '6.294'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''257'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 424,3 420,-1 420,-1 424,3 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 293
---------------------------------------------------------
UNION ALL
SELECT '6.295'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''258'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 424,19 420,18 420,18 422,15 422,15 424,19 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 294
---------------------------------------------------------
UNION ALL
SELECT '6.296'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''259'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 422,18 418,14 418,14 422,18 422))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 295
---------------------------------------------------------
UNION ALL
SELECT '6.297'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''260'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 423,20 419,18 419,18 420,19 420,19 423,20 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 296
---------------------------------------------------------
UNION ALL
SELECT '6.298'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''261'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 423,36 419,34 419,34 420,35 420,35 423,36 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 297
---------------------------------------------------------
UNION ALL
SELECT '6.299'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''262'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 420,34 418,30 418,30 422,31 422,31 420,34 420))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 298
---------------------------------------------------------
UNION ALL
SELECT '6.300'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''263'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 424,35 420,31 420,31 424,35 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 299
---------------------------------------------------------
UNION ALL
SELECT '6.301'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''264'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 424,51 420,50 420,50 422,47 422,47 424,51 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 300
---------------------------------------------------------
UNION ALL
SELECT '6.302'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''265'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 423,52 419,50 419,50 420,51 420,51 423,52 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 301
---------------------------------------------------------
UNION ALL
SELECT '6.303'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''266'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 422,50 418,46 418,46 422,50 422))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 302
---------------------------------------------------------
UNION ALL
SELECT '6.304'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''267'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 423,68 419,66 419,66 420,67 420,67 423,68 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 303
---------------------------------------------------------
UNION ALL
SELECT '6.305'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''268'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 424,67 420,66 420,66 422,63 422,63 424,67 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 304
---------------------------------------------------------
UNION ALL
SELECT '6.306'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''269'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 422,66 418,62 418,62 422,66 422))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 305
---------------------------------------------------------
UNION ALL
SELECT '6.307'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''270'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 420,82 418,78 418,78 422,79 422,79 420,82 420))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 306
---------------------------------------------------------
UNION ALL
SELECT '6.308'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''270'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 419,82 418,78 418,78 422,79 422,79 420,80 420,80 419,82 419))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 307
---------------------------------------------------------
UNION ALL
SELECT '6.309'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''270'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 308
---------------------------------------------------------
UNION ALL
SELECT '6.310'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''271'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 424,83 423,80 423,80 420,79 420,79 424,83 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 309
---------------------------------------------------------
UNION ALL
SELECT '6.311'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''271'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 424,83 420,79 420,79 424,83 424))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 310
---------------------------------------------------------
UNION ALL
SELECT '6.312'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''271'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 311
---------------------------------------------------------
UNION ALL
SELECT '6.313'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''272'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 423,84 419,82 419,82 420,83 420,83 423,84 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 312
---------------------------------------------------------
UNION ALL
SELECT '6.314'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''272'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 423,84 419,80 419,80 423,84 423))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 313
---------------------------------------------------------
UNION ALL
SELECT '6.315'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''273'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 449,2 448,-2 448,-2 452,-1 452,-1 450,0 450,0 449,2 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 314
---------------------------------------------------------
UNION ALL
SELECT '6.316'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''273'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 315
---------------------------------------------------------
UNION ALL
SELECT '6.317'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''273'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 450,2 448,-2 448,-2 452,-1 452,-1 450,2 450))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 316
---------------------------------------------------------
UNION ALL
SELECT '6.318'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''274'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 453,4 449,0 449,0 453,4 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 317
---------------------------------------------------------
UNION ALL
SELECT '6.319'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''274'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 453,4 449,2 449,2 450,3 450,3 453,4 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 318
---------------------------------------------------------
UNION ALL
SELECT '6.320'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''275'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 454,3 453,0 453,0 450,-1 450,-1 454,3 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 319
---------------------------------------------------------
UNION ALL
SELECT '6.321'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''275'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 454,3 450,-1 450,-1 454,3 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 320
---------------------------------------------------------
UNION ALL
SELECT '6.322'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''275'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 321
---------------------------------------------------------
UNION ALL
SELECT '6.323'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''276'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 322
---------------------------------------------------------
UNION ALL
SELECT '6.324'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''276'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 454,19 453,16 453,16 452,15 452,15 454,19 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 323
---------------------------------------------------------
UNION ALL
SELECT '6.325'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''276'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 454,19 450,18 450,18 452,15 452,15 454,19 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 324
---------------------------------------------------------
UNION ALL
SELECT '6.326'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''277'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 449,18 448,14 448,14 452,16 452,16 449,18 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 325
---------------------------------------------------------
UNION ALL
SELECT '6.327'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''277'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 326
---------------------------------------------------------
UNION ALL
SELECT '6.328'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''277'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 452,18 448,14 448,14 452,18 452))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 327
---------------------------------------------------------
UNION ALL
SELECT '6.329'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''278'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 453,20 449,16 449,16 453,20 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 328
---------------------------------------------------------
UNION ALL
SELECT '6.330'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''278'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 453,20 449,18 449,18 450,19 450,19 453,20 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 329
---------------------------------------------------------
UNION ALL
SELECT '6.331'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''279'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 453,36 449,34 449,34 450,35 450,35 453,36 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 330
---------------------------------------------------------
UNION ALL
SELECT '6.332'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''279'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 453,36 449,32 449,32 453,36 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 331
---------------------------------------------------------
UNION ALL
SELECT '6.333'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''280'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 449,34 448,30 448,30 452,31 452,31 450,32 450,32 449,34 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 332
---------------------------------------------------------
UNION ALL
SELECT '6.334'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''280'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 333
---------------------------------------------------------
UNION ALL
SELECT '6.335'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''280'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 450,34 448,30 448,30 452,31 452,31 450,34 450))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 334
---------------------------------------------------------
UNION ALL
SELECT '6.336'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''281'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 335
---------------------------------------------------------
UNION ALL
SELECT '6.337'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''281'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 454,35 450,31 450,31 454,35 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 336
---------------------------------------------------------
UNION ALL
SELECT '6.338'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''281'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 454,35 453,32 453,32 450,31 450,31 454,35 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 337
---------------------------------------------------------
UNION ALL
SELECT '6.339'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''282'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 454,51 453,48 453,48 452,47 452,47 454,51 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 338
---------------------------------------------------------
UNION ALL
SELECT '6.340'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''282'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 339
---------------------------------------------------------
UNION ALL
SELECT '6.341'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''282'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 454,51 450,50 450,50 452,47 452,47 454,51 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 340
---------------------------------------------------------
UNION ALL
SELECT '6.342'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''283'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 453,52 449,50 449,50 450,51 450,51 453,52 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 341
---------------------------------------------------------
UNION ALL
SELECT '6.343'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''283'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 453,52 449,48 449,48 453,52 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 342
---------------------------------------------------------
UNION ALL
SELECT '6.344'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''284'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 343
---------------------------------------------------------
UNION ALL
SELECT '6.345'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''284'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 449,50 448,46 448,46 452,48 452,48 449,50 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 344
---------------------------------------------------------
UNION ALL
SELECT '6.346'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''284'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 452,50 448,46 448,46 452,50 452))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 345
---------------------------------------------------------
UNION ALL
SELECT '6.347'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''285'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 453,68 449,66 449,66 450,67 450,67 453,68 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 346
---------------------------------------------------------
UNION ALL
SELECT '6.348'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''285'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 453,68 449,64 449,64 453,68 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 347
---------------------------------------------------------
UNION ALL
SELECT '6.349'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''286'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 454,67 453,64 453,64 452,63 452,63 454,67 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 348
---------------------------------------------------------
UNION ALL
SELECT '6.350'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''286'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 454,67 450,66 450,66 452,63 452,63 454,67 454))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 349
---------------------------------------------------------
UNION ALL
SELECT '6.351'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''286'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 350
---------------------------------------------------------
UNION ALL
SELECT '6.352'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''287'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 449,66 448,62 448,62 452,64 452,64 449,66 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 351
---------------------------------------------------------
UNION ALL
SELECT '6.353'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''287'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 452,66 448,62 448,62 452,66 452))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 352
---------------------------------------------------------
UNION ALL
SELECT '6.354'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''287'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 353
---------------------------------------------------------
UNION ALL
SELECT '6.355'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''288'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 449,82 448,78 448,78 452,79 452,79 450,80 450,80 449,82 449))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 354
---------------------------------------------------------
UNION ALL
SELECT '6.356'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''289'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 454,83 453,80 453,80 450,79 450,79 454,83 454))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 355
---------------------------------------------------------
UNION ALL
SELECT '6.357'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''290'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 453,84 449,80 449,80 453,84 453))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 356
---------------------------------------------------------
UNION ALL
SELECT '6.358'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''291'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 479,2 478,-2 478,-2 482,-1 482,-1 480,0 480,0 479,2 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 357
---------------------------------------------------------
UNION ALL
SELECT '6.359'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''292'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 483,4 479,0 479,0 480,3 480,3 483,4 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 358
---------------------------------------------------------
UNION ALL
SELECT '6.360'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''293'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 484,3 480,-1 480,-1 484,3 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 359
---------------------------------------------------------
UNION ALL
SELECT '6.361'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''294'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 484,19 483,16 483,16 480,15 480,15 484,19 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 360
---------------------------------------------------------
UNION ALL
SELECT '6.362'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''295'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 479,18 478,14 478,14 482,15 482,15 480,16 480,16 479,18 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 361
---------------------------------------------------------
UNION ALL
SELECT '6.363'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''296'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 483,20 479,16 479,16 483,20 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 362
---------------------------------------------------------
UNION ALL
SELECT '6.364'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''297'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 483,36 479,32 479,32 480,35 480,35 483,36 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 363
---------------------------------------------------------
UNION ALL
SELECT '6.365'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''298'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 479,34 478,30 478,30 482,31 482,31 480,32 480,32 479,34 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 364
---------------------------------------------------------
UNION ALL
SELECT '6.366'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''299'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 484,35 480,31 480,31 484,35 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 365
---------------------------------------------------------
UNION ALL
SELECT '6.367'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''300'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 484,51 483,48 483,48 480,47 480,47 484,51 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 366
---------------------------------------------------------
UNION ALL
SELECT '6.368'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''301'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 483,52 479,48 479,48 483,52 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 367
---------------------------------------------------------
UNION ALL
SELECT '6.369'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''302'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 479,50 478,46 478,46 482,47 482,47 480,48 480,48 479,50 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 368
---------------------------------------------------------
UNION ALL
SELECT '6.370'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''303'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 483,68 479,64 479,64 480,67 480,67 483,68 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 369
---------------------------------------------------------
UNION ALL
SELECT '6.371'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''304'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 484,67 480,63 480,63 484,67 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 370
---------------------------------------------------------
UNION ALL
SELECT '6.372'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''305'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 479,66 478,62 478,62 482,63 482,63 480,64 480,64 479,66 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 371
---------------------------------------------------------
UNION ALL
SELECT '6.373'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''306'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 479,82 478,78 478,78 482,79 482,79 480,80 480,80 479,82 479))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 372
---------------------------------------------------------
UNION ALL
SELECT '6.374'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''307'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 484,83 483,80 483,80 480,79 480,79 484,83 484))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 373
---------------------------------------------------------
UNION ALL
SELECT '6.375'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''308'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 483,84 479,80 479,80 483,84 483))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 374
---------------------------------------------------------
UNION ALL
SELECT '6.376'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''309'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 509,2 508,-2 508,-2 512,-1 512,-1 510,0 510,0 509,2 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 375
---------------------------------------------------------
UNION ALL
SELECT '6.377'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''310'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 513,4 509,0 509,0 513,4 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 376
---------------------------------------------------------
UNION ALL
SELECT '6.378'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''311'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 514,3 513,0 513,0 510,-1 510,-1 514,3 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 377
---------------------------------------------------------
UNION ALL
SELECT '6.379'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''312'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 514,19 513,16 513,16 510,15 510,15 514,19 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 378
---------------------------------------------------------
UNION ALL
SELECT '6.380'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''313'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 509,18 508,14 508,14 512,15 512,15 510,16 510,16 509,18 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 379
---------------------------------------------------------
UNION ALL
SELECT '6.381'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''314'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 513,20 509,16 509,16 513,20 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 380
---------------------------------------------------------
UNION ALL
SELECT '6.382'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''315'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 513,36 509,32 509,32 513,36 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 381
---------------------------------------------------------
UNION ALL
SELECT '6.383'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''316'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 509,34 508,30 508,30 512,31 512,31 510,32 510,32 509,34 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 382
---------------------------------------------------------
UNION ALL
SELECT '6.384'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''317'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 514,35 513,32 513,32 510,31 510,31 514,35 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 383
---------------------------------------------------------
UNION ALL
SELECT '6.385'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''318'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 514,51 513,48 513,48 510,47 510,47 514,51 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 384
---------------------------------------------------------
UNION ALL
SELECT '6.386'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''319'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 513,52 509,48 509,48 513,52 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 385
---------------------------------------------------------
UNION ALL
SELECT '6.387'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''320'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 509,50 508,46 508,46 512,47 512,47 510,48 510,48 509,50 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 386
---------------------------------------------------------
UNION ALL
SELECT '6.388'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''321'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 513,68 509,64 509,64 513,68 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 387
---------------------------------------------------------
UNION ALL
SELECT '6.389'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''322'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 514,67 513,64 513,64 510,63 510,63 514,67 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 388
---------------------------------------------------------
UNION ALL
SELECT '6.390'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''323'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 509,66 508,62 508,62 512,63 512,63 510,64 510,64 509,66 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 389
---------------------------------------------------------
UNION ALL
SELECT '6.391'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''324'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 509,82 508,78 508,78 512,79 512,79 510,80 510,80 509,82 509))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 390
---------------------------------------------------------
UNION ALL
SELECT '6.392'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''325'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 514,83 510,79 510,79 514,83 514))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 391
---------------------------------------------------------
UNION ALL
SELECT '6.393'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''326'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 513,84 509,80 509,80 510,83 510,83 513,84 513))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 392
---------------------------------------------------------
UNION ALL
SELECT '6.394'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''327'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 539,2 538,-2 538,-2 542,-1 542,-1 540,0 540,0 539,2 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 393
---------------------------------------------------------
UNION ALL
SELECT '6.395'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''328'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 543,4 539,0 539,0 540,3 540,3 543,4 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 394
---------------------------------------------------------
UNION ALL
SELECT '6.396'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''329'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 544,3 540,-1 540,-1 544,3 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 395
---------------------------------------------------------
UNION ALL
SELECT '6.397'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''330'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 544,19 540,15 540,15 544,19 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 396
---------------------------------------------------------
UNION ALL
SELECT '6.398'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''331'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 539,18 538,14 538,14 542,15 542,15 540,16 540,16 539,18 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 397
---------------------------------------------------------
UNION ALL
SELECT '6.399'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''332'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 543,20 539,16 539,16 540,19 540,19 543,20 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 398
---------------------------------------------------------
UNION ALL
SELECT '6.400'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''333'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 543,36 539,32 539,32 540,35 540,35 543,36 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 399
---------------------------------------------------------
UNION ALL
SELECT '6.401'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''334'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 539,34 538,30 538,30 542,31 542,31 540,32 540,32 539,34 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 400
---------------------------------------------------------
UNION ALL
SELECT '6.402'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''335'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 544,35 540,31 540,31 544,35 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 401
---------------------------------------------------------
UNION ALL
SELECT '6.403'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''336'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 544,51 540,47 540,47 544,51 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 402
---------------------------------------------------------
UNION ALL
SELECT '6.404'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''337'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 543,52 539,48 539,48 540,51 540,51 543,52 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 403
---------------------------------------------------------
UNION ALL
SELECT '6.405'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''338'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 539,50 538,46 538,46 542,47 542,47 540,48 540,48 539,50 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 404
---------------------------------------------------------
UNION ALL
SELECT '6.406'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''339'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 543,68 539,64 539,64 540,67 540,67 543,68 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 405
---------------------------------------------------------
UNION ALL
SELECT '6.407'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''340'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 544,67 540,63 540,63 544,67 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 406
---------------------------------------------------------
UNION ALL
SELECT '6.408'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''341'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 539,66 538,62 538,62 542,63 542,63 540,64 540,64 539,66 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 407
---------------------------------------------------------
UNION ALL
SELECT '6.409'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''342'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 539,82 538,78 538,78 542,79 542,79 540,80 540,80 539,82 539))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 408
---------------------------------------------------------
UNION ALL
SELECT '6.410'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''343'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 544,83 543,80 543,80 540,79 540,79 544,83 544))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 409
---------------------------------------------------------
UNION ALL
SELECT '6.411'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''344'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 543,84 539,80 539,80 543,84 543))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 410
---------------------------------------------------------
UNION ALL
SELECT '6.412'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''345'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 569,2 568,-2 568,-2 572,-1 572,-1 570,0 570,0 569,2 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 411
---------------------------------------------------------
UNION ALL
SELECT '6.413'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''346'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 573,4 569,0 569,0 570,3 570,3 573,4 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 412
---------------------------------------------------------
UNION ALL
SELECT '6.414'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''347'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 574,3 570,-1 570,-1 574,3 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 413
---------------------------------------------------------
UNION ALL
SELECT '6.415'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''348'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 574,19 573,16 573,16 570,15 570,15 574,19 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 414
---------------------------------------------------------
UNION ALL
SELECT '6.416'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''349'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 569,18 568,14 568,14 572,15 572,15 570,16 570,16 569,18 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 415
---------------------------------------------------------
UNION ALL
SELECT '6.417'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''350'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 573,20 569,16 569,16 573,20 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 416
---------------------------------------------------------
UNION ALL
SELECT '6.418'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''351'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 573,36 569,32 569,32 570,35 570,35 573,36 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 417
---------------------------------------------------------
UNION ALL
SELECT '6.419'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''352'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 569,34 568,30 568,30 572,31 572,31 570,32 570,32 569,34 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 418
---------------------------------------------------------
UNION ALL
SELECT '6.420'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''353'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 574,35 570,31 570,31 574,35 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 419
---------------------------------------------------------
UNION ALL
SELECT '6.421'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''354'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 574,51 573,48 573,48 570,47 570,47 574,51 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 420
---------------------------------------------------------
UNION ALL
SELECT '6.422'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''355'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 573,52 569,48 569,48 573,52 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 421
---------------------------------------------------------
UNION ALL
SELECT '6.423'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''356'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 569,50 568,46 568,46 572,47 572,47 570,48 570,48 569,50 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 422
---------------------------------------------------------
UNION ALL
SELECT '6.424'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''357'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 573,68 569,64 569,64 570,67 570,67 573,68 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 423
---------------------------------------------------------
UNION ALL
SELECT '6.425'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''358'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 574,67 570,63 570,63 574,67 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 424
---------------------------------------------------------
UNION ALL
SELECT '6.426'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''359'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 569,66 568,62 568,62 572,63 572,63 570,64 570,64 569,66 569))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 425
---------------------------------------------------------
UNION ALL
SELECT '6.427'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''360'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 572,82 568,78 568,78 572,82 572))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 426
---------------------------------------------------------
UNION ALL
SELECT '6.428'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''361'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 574,83 573,80 573,80 572,79 572,79 574,83 574))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 427
---------------------------------------------------------
UNION ALL
SELECT '6.429'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''362'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 573,84 569,82 569,82 572,80 572,80 573,84 573))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 428
---------------------------------------------------------
UNION ALL
SELECT '6.430'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''363'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 602,2 598,-2 598,-2 602,2 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 429
---------------------------------------------------------
UNION ALL
SELECT '6.431'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''364'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 603,4 599,2 599,2 600,3 600,3 603,4 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 430
---------------------------------------------------------
UNION ALL
SELECT '6.432'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''365'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 604,3 600,2 600,2 602,-1 602,-1 604,3 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 431
---------------------------------------------------------
UNION ALL
SELECT '6.433'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''366'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 604,19 603,16 603,16 602,15 602,15 604,19 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 432
---------------------------------------------------------
UNION ALL
SELECT '6.434'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''367'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 602,18 598,14 598,14 602,18 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 433
---------------------------------------------------------
UNION ALL
SELECT '6.435'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''368'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 603,20 599,18 599,18 602,16 602,16 603,20 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 434
---------------------------------------------------------
UNION ALL
SELECT '6.436'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''369'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 603,36 599,34 599,34 600,35 600,35 603,36 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 435
---------------------------------------------------------
UNION ALL
SELECT '6.437'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''370'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 602,34 598,30 598,30 602,34 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 436
---------------------------------------------------------
UNION ALL
SELECT '6.438'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''371'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 604,35 600,34 600,34 602,31 602,31 604,35 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 437
---------------------------------------------------------
UNION ALL
SELECT '6.439'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''372'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 604,51 603,48 603,48 602,47 602,47 604,51 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 438
---------------------------------------------------------
UNION ALL
SELECT '6.440'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''373'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 603,52 599,50 599,50 602,48 602,48 603,52 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 439
---------------------------------------------------------
UNION ALL
SELECT '6.441'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''374'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 602,50 598,46 598,46 602,50 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 440
---------------------------------------------------------
UNION ALL
SELECT '6.442'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''375'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 603,68 599,66 599,66 600,67 600,67 603,68 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 441
---------------------------------------------------------
UNION ALL
SELECT '6.443'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''376'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 604,67 600,66 600,66 602,63 602,63 604,67 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 442
---------------------------------------------------------
UNION ALL
SELECT '6.444'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''377'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 602,66 598,62 598,62 602,66 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 443
---------------------------------------------------------
UNION ALL
SELECT '6.445'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''378'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 599,82 598,78 598,78 602,80 602,80 599,82 599))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 444
---------------------------------------------------------
UNION ALL
SELECT '6.446'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''378'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 602,82 598,78 598,78 602,82 602))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 445
---------------------------------------------------------
UNION ALL
SELECT '6.447'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''379'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 604,83 603,80 603,80 602,79 602,79 604,83 604))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 446
---------------------------------------------------------
UNION ALL
SELECT '6.448'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''380'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 603,84 599,80 599,80 603,84 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 447
---------------------------------------------------------
UNION ALL
SELECT '6.449'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''380'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 603,84 599,82 599,82 602,80 602,80 603,84 603))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 448
---------------------------------------------------------
UNION ALL
SELECT '6.450'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''381'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 632,2 628,-2 628,-2 632,2 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 449
---------------------------------------------------------
UNION ALL
SELECT '6.451'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''381'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 629,2 628,-2 628,-2 632,0 632,0 629,2 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 450
---------------------------------------------------------
UNION ALL
SELECT '6.452'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''382'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 633,4 629,0 629,0 633,4 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 451
---------------------------------------------------------
UNION ALL
SELECT '6.453'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''382'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 633,4 629,2 629,2 632,0 632,0 633,4 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 452
---------------------------------------------------------
UNION ALL
SELECT '6.454'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''383'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 634,3 633,0 633,0 632,-1 632,-1 634,3 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 453
---------------------------------------------------------
UNION ALL
SELECT '6.455'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''384'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 634,19 633,16 633,16 632,15 632,15 634,19 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 454
---------------------------------------------------------
UNION ALL
SELECT '6.456'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''385'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 632,18 628,14 628,14 632,18 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 455
---------------------------------------------------------
UNION ALL
SELECT '6.457'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''385'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 629,18 628,14 628,14 632,16 632,16 629,18 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 456
---------------------------------------------------------
UNION ALL
SELECT '6.458'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''386'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 633,20 629,16 629,16 633,20 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 457
---------------------------------------------------------
UNION ALL
SELECT '6.459'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''386'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 633,20 629,18 629,18 632,16 632,16 633,20 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 458
---------------------------------------------------------
UNION ALL
SELECT '6.460'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''387'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 633,36 629,32 629,32 633,36 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 459
---------------------------------------------------------
UNION ALL
SELECT '6.461'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''387'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 633,36 629,34 629,34 632,32 632,32 633,36 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 460
---------------------------------------------------------
UNION ALL
SELECT '6.462'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''388'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 632,34 628,30 628,30 632,34 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 461
---------------------------------------------------------
UNION ALL
SELECT '6.463'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''388'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 629,34 628,30 628,30 632,32 632,32 629,34 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 462
---------------------------------------------------------
UNION ALL
SELECT '6.464'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''389'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 634,35 633,32 633,32 632,31 632,31 634,35 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 463
---------------------------------------------------------
UNION ALL
SELECT '6.465'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''390'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 634,51 633,48 633,48 632,47 632,47 634,51 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 464
---------------------------------------------------------
UNION ALL
SELECT '6.466'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''391'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 633,52 629,50 629,50 632,48 632,48 633,52 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 465
---------------------------------------------------------
UNION ALL
SELECT '6.467'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''391'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 633,52 629,48 629,48 633,52 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 466
---------------------------------------------------------
UNION ALL
SELECT '6.468'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''392'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 629,50 628,46 628,46 632,48 632,48 629,50 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 467
---------------------------------------------------------
UNION ALL
SELECT '6.469'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''392'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 632,50 628,46 628,46 632,50 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 468
---------------------------------------------------------
UNION ALL
SELECT '6.470'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''393'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 633,68 629,66 629,66 632,64 632,64 633,68 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 469
---------------------------------------------------------
UNION ALL
SELECT '6.471'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''393'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 633,68 629,64 629,64 633,68 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 470
---------------------------------------------------------
UNION ALL
SELECT '6.472'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''394'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 634,67 633,64 633,64 632,63 632,63 634,67 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 471
---------------------------------------------------------
UNION ALL
SELECT '6.473'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''395'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 632,66 628,62 628,62 632,66 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 472
---------------------------------------------------------
UNION ALL
SELECT '6.474'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''395'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 629,66 628,62 628,62 632,64 632,64 629,66 629))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 473
---------------------------------------------------------
UNION ALL
SELECT '6.475'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''396'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 630,82 628,78 628,78 632,79 632,79 630,82 630))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 474
---------------------------------------------------------
UNION ALL
SELECT '6.476'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''396'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 632,82 628,78 628,78 632,82 632))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 475
---------------------------------------------------------
UNION ALL
SELECT '6.477'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''397'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 634,83 630,82 630,82 632,79 632,79 634,83 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 476
---------------------------------------------------------
UNION ALL
SELECT '6.478'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''397'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 634,83 630,79 630,79 634,83 634))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 477
---------------------------------------------------------
UNION ALL
SELECT '6.479'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''398'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 633,84 629,82 629,82 630,83 630,83 633,84 633))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 478
---------------------------------------------------------
UNION ALL
SELECT '6.480'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''399'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 660,2 658,-2 658,-2 662,-1 662,-1 660,2 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 479
---------------------------------------------------------
UNION ALL
SELECT '6.481'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''399'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 662,2 658,-2 658,-2 662,2 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 480
---------------------------------------------------------
UNION ALL
SELECT '6.482'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''400'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 663,4 659,2 659,2 660,3 660,3 663,4 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 481
---------------------------------------------------------
UNION ALL
SELECT '6.483'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''401'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 664,3 660,2 660,2 662,-1 662,-1 664,3 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 482
---------------------------------------------------------
UNION ALL
SELECT '6.484'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''401'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 664,3 660,-1 660,-1 664,3 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 483
---------------------------------------------------------
UNION ALL
SELECT '6.485'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''402'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 664,19 660,15 660,15 664,19 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 484
---------------------------------------------------------
UNION ALL
SELECT '6.486'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''402'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 664,19 660,18 660,18 662,15 662,15 664,19 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 485
---------------------------------------------------------
UNION ALL
SELECT '6.487'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''403'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 660,18 658,14 658,14 662,15 662,15 660,18 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 486
---------------------------------------------------------
UNION ALL
SELECT '6.488'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''403'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 662,18 658,14 658,14 662,18 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 487
---------------------------------------------------------
UNION ALL
SELECT '6.489'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''404'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 663,20 659,18 659,18 660,19 660,19 663,20 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 488
---------------------------------------------------------
UNION ALL
SELECT '6.490'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''405'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 663,36 659,34 659,34 660,35 660,35 663,36 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 489
---------------------------------------------------------
UNION ALL
SELECT '6.491'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''406'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 660,34 658,30 658,30 662,31 662,31 660,34 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 490
---------------------------------------------------------
UNION ALL
SELECT '6.492'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''406'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 662,34 658,30 658,30 662,34 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 491
---------------------------------------------------------
UNION ALL
SELECT '6.493'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''407'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 664,35 660,34 660,34 662,31 662,31 664,35 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 492
---------------------------------------------------------
UNION ALL
SELECT '6.494'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''407'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 664,35 660,31 660,31 664,35 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 493
---------------------------------------------------------
UNION ALL
SELECT '6.495'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''408'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 664,51 660,50 660,50 662,47 662,47 664,51 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 494
---------------------------------------------------------
UNION ALL
SELECT '6.496'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''408'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 664,51 660,47 660,47 664,51 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 495
---------------------------------------------------------
UNION ALL
SELECT '6.497'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''409'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 663,52 659,50 659,50 660,51 660,51 663,52 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 496
---------------------------------------------------------
UNION ALL
SELECT '6.498'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''410'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 660,50 658,46 658,46 662,47 662,47 660,50 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 497
---------------------------------------------------------
UNION ALL
SELECT '6.499'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''410'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 662,50 658,46 658,46 662,50 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 498
---------------------------------------------------------
UNION ALL
SELECT '6.500'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''411'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 663,68 659,66 659,66 660,67 660,67 663,68 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 499
---------------------------------------------------------
UNION ALL
SELECT '6.501'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''412'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 664,67 660,63 660,63 664,67 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 500
---------------------------------------------------------
UNION ALL
SELECT '6.502'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''412'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 664,67 660,66 660,66 662,63 662,63 664,67 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 501
---------------------------------------------------------
UNION ALL
SELECT '6.503'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''413'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 662,66 658,62 658,62 662,66 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 502
---------------------------------------------------------
UNION ALL
SELECT '6.504'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''413'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 660,66 658,62 658,62 662,63 662,63 660,66 660))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 503
---------------------------------------------------------
UNION ALL
SELECT '6.505'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''414'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 659,82 658,78 658,78 662,79 662,79 660,80 660,80 659,82 659))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 504
---------------------------------------------------------
UNION ALL
SELECT '6.506'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''414'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 662,82 658,78 658,78 662,82 662))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 505
---------------------------------------------------------
UNION ALL
SELECT '6.507'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''415'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 664,83 663,80 663,80 660,79 660,79 664,83 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 506
---------------------------------------------------------
UNION ALL
SELECT '6.508'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''415'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 664,83 663,80 663,80 662,79 662,79 664,83 664))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 507
---------------------------------------------------------
UNION ALL
SELECT '6.509'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''416'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 663,84 659,80 659,80 663,84 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 508
---------------------------------------------------------
UNION ALL
SELECT '6.510'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''416'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 663,84 659,82 659,82 662,80 662,80 663,84 663))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 509
---------------------------------------------------------
UNION ALL
SELECT '6.511'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''417'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 689,2 688,-2 688,-2 692,-1 692,-1 690,0 690,0 689,2 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 510
---------------------------------------------------------
UNION ALL
SELECT '6.512'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''417'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 692,2 688,-2 688,-2 692,2 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 511
---------------------------------------------------------
UNION ALL
SELECT '6.513'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''418'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 693,4 689,2 689,2 690,3 690,3 693,4 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 512
---------------------------------------------------------
UNION ALL
SELECT '6.514'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''418'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 693,4 689,0 689,0 690,3 690,3 693,4 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 513
---------------------------------------------------------
UNION ALL
SELECT '6.515'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''419'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 694,3 690,-1 690,-1 694,3 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 514
---------------------------------------------------------
UNION ALL
SELECT '6.516'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''419'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 694,3 690,2 690,2 692,-1 692,-1 694,3 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 515
---------------------------------------------------------
UNION ALL
SELECT '6.517'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''420'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 694,19 693,16 693,16 690,15 690,15 694,19 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 516
---------------------------------------------------------
UNION ALL
SELECT '6.518'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''420'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 694,19 693,16 693,16 692,15 692,15 694,19 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 517
---------------------------------------------------------
UNION ALL
SELECT '6.519'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''421'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 692,18 688,14 688,14 692,18 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 518
---------------------------------------------------------
UNION ALL
SELECT '6.520'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''421'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 689,18 688,14 688,14 692,15 692,15 690,16 690,16 689,18 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 519
---------------------------------------------------------
UNION ALL
SELECT '6.521'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''422'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 693,20 689,16 689,16 693,20 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 520
---------------------------------------------------------
UNION ALL
SELECT '6.522'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''422'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 693,20 689,18 689,18 692,16 692,16 693,20 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 521
---------------------------------------------------------
UNION ALL
SELECT '6.523'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''423'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 693,36 689,34 689,34 690,35 690,35 693,36 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 522
---------------------------------------------------------
UNION ALL
SELECT '6.524'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''423'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 693,36 689,32 689,32 690,35 690,35 693,36 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 523
---------------------------------------------------------
UNION ALL
SELECT '6.525'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''424'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 689,34 688,30 688,30 692,31 692,31 690,32 690,32 689,34 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 524
---------------------------------------------------------
UNION ALL
SELECT '6.526'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''424'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 692,34 688,30 688,30 692,34 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 525
---------------------------------------------------------
UNION ALL
SELECT '6.527'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''425'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 694,35 690,34 690,34 692,31 692,31 694,35 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 526
---------------------------------------------------------
UNION ALL
SELECT '6.528'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''425'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 694,35 690,31 690,31 694,35 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 527
---------------------------------------------------------
UNION ALL
SELECT '6.529'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''426'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 694,51 693,48 693,48 690,47 690,47 694,51 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 528
---------------------------------------------------------
UNION ALL
SELECT '6.530'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''426'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 694,51 693,48 693,48 692,47 692,47 694,51 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 529
---------------------------------------------------------
UNION ALL
SELECT '6.531'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''427'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 693,52 689,48 689,48 693,52 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 530
---------------------------------------------------------
UNION ALL
SELECT '6.532'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''427'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 693,52 689,50 689,50 692,48 692,48 693,52 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 531
---------------------------------------------------------
UNION ALL
SELECT '6.533'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''428'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 692,50 688,46 688,46 692,50 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 532
---------------------------------------------------------
UNION ALL
SELECT '6.534'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''428'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 689,50 688,46 688,46 692,47 692,47 690,48 690,48 689,50 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 533
---------------------------------------------------------
UNION ALL
SELECT '6.535'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''429'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 693,68 689,66 689,66 690,67 690,67 693,68 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 534
---------------------------------------------------------
UNION ALL
SELECT '6.536'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''429'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 693,68 689,64 689,64 690,67 690,67 693,68 693))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 535
---------------------------------------------------------
UNION ALL
SELECT '6.537'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''430'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 694,67 690,63 690,63 694,67 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 536
---------------------------------------------------------
UNION ALL
SELECT '6.538'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''430'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 694,67 690,66 690,66 692,63 692,63 694,67 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 537
---------------------------------------------------------
UNION ALL
SELECT '6.539'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''431'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 692,66 688,62 688,62 692,66 692))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 538
---------------------------------------------------------
UNION ALL
SELECT '6.540'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''431'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 689,66 688,62 688,62 692,63 692,63 690,64 690,64 689,66 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 539
---------------------------------------------------------
UNION ALL
SELECT '6.541'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''432'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 689,82 688,78 688,78 692,79 692,79 690,80 690,80 689,82 689))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 540
---------------------------------------------------------
UNION ALL
SELECT '6.542'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''433'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 694,83 693,80 693,80 690,79 690,79 694,83 694))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 541
---------------------------------------------------------
UNION ALL
SELECT '6.543'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''434'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 693,84 689,80 689,80 693,84 693))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 542
---------------------------------------------------------
UNION ALL
SELECT '6.544'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''435'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 719,2 718,-2 718,-2 722,-1 722,-1 720,0 720,0 719,2 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 543
---------------------------------------------------------
UNION ALL
SELECT '6.545'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''436'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 723,4 719,0 719,0 723,4 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 544
---------------------------------------------------------
UNION ALL
SELECT '6.546'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''437'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 724,3 723,0 723,0 720,-1 720,-1 724,3 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 545
---------------------------------------------------------
UNION ALL
SELECT '6.547'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''438'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 724,19 723,16 723,16 720,15 720,15 724,19 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 546
---------------------------------------------------------
UNION ALL
SELECT '6.548'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''439'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 719,18 718,14 718,14 722,15 722,15 720,16 720,16 719,18 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 547
---------------------------------------------------------
UNION ALL
SELECT '6.549'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''440'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 723,20 719,16 719,16 723,20 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 548
---------------------------------------------------------
UNION ALL
SELECT '6.550'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''441'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 723,36 719,32 719,32 723,36 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 549
---------------------------------------------------------
UNION ALL
SELECT '6.551'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''442'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 719,34 718,30 718,30 722,31 722,31 720,32 720,32 719,34 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 550
---------------------------------------------------------
UNION ALL
SELECT '6.552'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''443'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 724,35 723,32 723,32 720,31 720,31 724,35 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 551
---------------------------------------------------------
UNION ALL
SELECT '6.553'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''444'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 724,51 723,48 723,48 720,47 720,47 724,51 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 552
---------------------------------------------------------
UNION ALL
SELECT '6.554'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''445'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 723,52 719,48 719,48 723,52 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 553
---------------------------------------------------------
UNION ALL
SELECT '6.555'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''446'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 719,50 718,46 718,46 722,47 722,47 720,48 720,48 719,50 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 554
---------------------------------------------------------
UNION ALL
SELECT '6.556'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''447'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 723,68 719,64 719,64 723,68 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 555
---------------------------------------------------------
UNION ALL
SELECT '6.557'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''448'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 724,67 723,64 723,64 720,63 720,63 724,67 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 556
---------------------------------------------------------
UNION ALL
SELECT '6.558'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''449'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 719,66 718,62 718,62 722,63 722,63 720,64 720,64 719,66 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 557
---------------------------------------------------------
UNION ALL
SELECT '6.559'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''450'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 719,82 718,78 718,78 722,79 722,79 720,80 720,80 719,82 719))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 558
---------------------------------------------------------
UNION ALL
SELECT '6.560'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''451'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 724,83 723,80 723,80 720,79 720,79 724,83 724))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 559
---------------------------------------------------------
UNION ALL
SELECT '6.561'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''452'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 723,84 719,80 719,80 723,84 723))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 560
---------------------------------------------------------
UNION ALL
SELECT '6.562'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''453'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 749,2 748,-2 748,-2 752,-1 752,-1 750,0 750,0 749,2 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 561
---------------------------------------------------------
UNION ALL
SELECT '6.563'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''454'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 753,4 749,0 749,0 753,4 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 562
---------------------------------------------------------
UNION ALL
SELECT '6.564'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''455'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 754,3 753,0 753,0 750,-1 750,-1 754,3 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 563
---------------------------------------------------------
UNION ALL
SELECT '6.565'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''456'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 754,19 753,16 753,16 750,15 750,15 754,19 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 564
---------------------------------------------------------
UNION ALL
SELECT '6.566'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''457'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 749,18 748,14 748,14 752,15 752,15 750,16 750,16 749,18 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 565
---------------------------------------------------------
UNION ALL
SELECT '6.567'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''458'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 753,20 749,16 749,16 753,20 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 566
---------------------------------------------------------
UNION ALL
SELECT '6.568'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''459'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 753,36 749,32 749,32 753,36 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 567
---------------------------------------------------------
UNION ALL
SELECT '6.569'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''460'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 749,34 748,30 748,30 752,31 752,31 750,32 750,32 749,34 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 568
---------------------------------------------------------
UNION ALL
SELECT '6.570'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''461'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 754,35 753,32 753,32 750,31 750,31 754,35 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 569
---------------------------------------------------------
UNION ALL
SELECT '6.571'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''462'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 754,51 753,48 753,48 750,47 750,47 754,51 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 570
---------------------------------------------------------
UNION ALL
SELECT '6.572'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''463'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 753,52 749,48 749,48 753,52 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 571
---------------------------------------------------------
UNION ALL
SELECT '6.573'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''464'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 749,50 748,46 748,46 752,47 752,47 750,48 750,48 749,50 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 572
---------------------------------------------------------
UNION ALL
SELECT '6.574'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''465'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 753,68 749,64 749,64 753,68 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 573
---------------------------------------------------------
UNION ALL
SELECT '6.575'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''466'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 754,67 753,64 753,64 750,63 750,63 754,67 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 574
---------------------------------------------------------
UNION ALL
SELECT '6.576'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''467'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 749,66 748,62 748,62 752,63 752,63 750,64 750,64 749,66 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 575
---------------------------------------------------------
UNION ALL
SELECT '6.577'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''468'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 749,82 748,78 748,78 752,79 752,79 750,80 750,80 749,82 749))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 576
---------------------------------------------------------
UNION ALL
SELECT '6.578'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''469'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 754,83 750,79 750,79 754,83 754))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 577
---------------------------------------------------------
UNION ALL
SELECT '6.579'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''470'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 753,84 749,80 749,80 750,83 750,83 753,84 753))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 578
---------------------------------------------------------
UNION ALL
SELECT '6.580'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''471'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 779,2 778,-2 778,-2 782,-1 782,-1 780,0 780,0 779,2 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 579
---------------------------------------------------------
UNION ALL
SELECT '6.581'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''472'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 783,4 779,0 779,0 780,3 780,3 783,4 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 580
---------------------------------------------------------
UNION ALL
SELECT '6.582'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''473'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 784,3 780,-1 780,-1 784,3 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 581
---------------------------------------------------------
UNION ALL
SELECT '6.583'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''474'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 784,19 780,15 780,15 784,19 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 582
---------------------------------------------------------
UNION ALL
SELECT '6.584'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''475'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 779,18 778,14 778,14 782,15 782,15 780,16 780,16 779,18 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 583
---------------------------------------------------------
UNION ALL
SELECT '6.585'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''476'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 783,20 779,16 779,16 780,19 780,19 783,20 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 584
---------------------------------------------------------
UNION ALL
SELECT '6.586'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''477'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 783,36 779,32 779,32 780,35 780,35 783,36 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 585
---------------------------------------------------------
UNION ALL
SELECT '6.587'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''478'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 779,34 778,30 778,30 782,31 782,31 780,32 780,32 779,34 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 586
---------------------------------------------------------
UNION ALL
SELECT '6.588'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''479'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 784,35 780,31 780,31 784,35 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 587
---------------------------------------------------------
UNION ALL
SELECT '6.589'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''480'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 784,51 780,47 780,47 784,51 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 588
---------------------------------------------------------
UNION ALL
SELECT '6.590'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''481'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 783,52 779,48 779,48 780,51 780,51 783,52 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 589
---------------------------------------------------------
UNION ALL
SELECT '6.591'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''482'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 779,50 778,46 778,46 782,47 782,47 780,48 780,48 779,50 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 590
---------------------------------------------------------
UNION ALL
SELECT '6.592'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''483'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 783,68 779,64 779,64 780,67 780,67 783,68 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 591
---------------------------------------------------------
UNION ALL
SELECT '6.593'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''484'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 784,67 780,63 780,63 784,67 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 592
---------------------------------------------------------
UNION ALL
SELECT '6.594'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''485'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 779,66 778,62 778,62 782,63 782,63 780,64 780,64 779,66 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 593
---------------------------------------------------------
UNION ALL
SELECT '6.595'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''486'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 779,82 778,78 778,78 782,79 782,79 780,80 780,80 779,82 779))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 594
---------------------------------------------------------
UNION ALL
SELECT '6.596'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''487'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 784,83 783,80 783,80 780,79 780,79 784,83 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 595
---------------------------------------------------------
UNION ALL
SELECT '6.597'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''487'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 596
---------------------------------------------------------
UNION ALL
SELECT '6.598'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''487'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 784,83 780,79 780,79 784,83 784))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 597
---------------------------------------------------------
UNION ALL
SELECT '6.599'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''488'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 783,84 779,80 779,80 783,84 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 598
---------------------------------------------------------
UNION ALL
SELECT '6.600'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''488'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 783,84 779,80 779,80 780,83 780,83 783,84 783))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 599
---------------------------------------------------------
UNION ALL
SELECT '6.601'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''489'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 809,2 808,-2 808,-2 812,-1 812,-1 810,0 810,0 809,2 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 600
---------------------------------------------------------
UNION ALL
SELECT '6.602'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''490'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 813,4 809,0 809,0 813,4 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 601
---------------------------------------------------------
UNION ALL
SELECT '6.603'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''490'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 813,4 809,0 809,0 810,3 810,3 813,4 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 602
---------------------------------------------------------
UNION ALL
SELECT '6.604'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''491'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 814,3 810,-1 810,-1 814,3 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 603
---------------------------------------------------------
UNION ALL
SELECT '6.605'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''491'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 814,3 813,0 813,0 810,-1 810,-1 814,3 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 604
---------------------------------------------------------
UNION ALL
SELECT '6.606'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''491'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 605
---------------------------------------------------------
UNION ALL
SELECT '6.607'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''492'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 814,19 813,16 813,16 810,15 810,15 814,19 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 606
---------------------------------------------------------
UNION ALL
SELECT '6.608'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''492'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 814,19 810,15 810,15 814,19 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 607
---------------------------------------------------------
UNION ALL
SELECT '6.609'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''492'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 608
---------------------------------------------------------
UNION ALL
SELECT '6.610'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''493'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 809,18 808,14 808,14 812,15 812,15 810,16 810,16 809,18 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 609
---------------------------------------------------------
UNION ALL
SELECT '6.611'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''494'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 813,20 809,16 809,16 813,20 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 610
---------------------------------------------------------
UNION ALL
SELECT '6.612'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''494'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 813,20 809,16 809,16 810,19 810,19 813,20 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 611
---------------------------------------------------------
UNION ALL
SELECT '6.613'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''495'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 813,36 809,32 809,32 813,36 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 612
---------------------------------------------------------
UNION ALL
SELECT '6.614'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''495'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 813,36 809,32 809,32 810,35 810,35 813,36 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 613
---------------------------------------------------------
UNION ALL
SELECT '6.615'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''496'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 809,34 808,30 808,30 812,31 812,31 810,32 810,32 809,34 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 614
---------------------------------------------------------
UNION ALL
SELECT '6.616'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''497'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 814,35 813,32 813,32 810,31 810,31 814,35 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 615
---------------------------------------------------------
UNION ALL
SELECT '6.617'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''497'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 616
---------------------------------------------------------
UNION ALL
SELECT '6.618'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''497'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 814,35 810,31 810,31 814,35 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 617
---------------------------------------------------------
UNION ALL
SELECT '6.619'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''498'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 814,51 813,48 813,48 810,47 810,47 814,51 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 618
---------------------------------------------------------
UNION ALL
SELECT '6.620'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''498'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 619
---------------------------------------------------------
UNION ALL
SELECT '6.621'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''498'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 814,51 810,47 810,47 814,51 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 620
---------------------------------------------------------
UNION ALL
SELECT '6.622'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''499'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 813,52 809,48 809,48 813,52 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 621
---------------------------------------------------------
UNION ALL
SELECT '6.623'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''499'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 813,52 809,48 809,48 810,51 810,51 813,52 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 622
---------------------------------------------------------
UNION ALL
SELECT '6.624'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''500'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 809,50 808,46 808,46 812,47 812,47 810,48 810,48 809,50 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 623
---------------------------------------------------------
UNION ALL
SELECT '6.625'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''501'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 813,68 809,64 809,64 813,68 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 624
---------------------------------------------------------
UNION ALL
SELECT '6.626'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''501'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 813,68 809,64 809,64 810,67 810,67 813,68 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 625
---------------------------------------------------------
UNION ALL
SELECT '6.627'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''502'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 626
---------------------------------------------------------
UNION ALL
SELECT '6.628'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''502'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 814,67 810,63 810,63 814,67 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 627
---------------------------------------------------------
UNION ALL
SELECT '6.629'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''502'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 814,67 813,64 813,64 810,63 810,63 814,67 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 628
---------------------------------------------------------
UNION ALL
SELECT '6.630'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''503'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 809,66 808,62 808,62 812,63 812,63 810,64 810,64 809,66 809))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 629
---------------------------------------------------------
UNION ALL
SELECT '6.631'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''504'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 812,82 808,78 808,78 812,82 812))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 630
---------------------------------------------------------
UNION ALL
SELECT '6.632'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''505'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 814,83 813,80 813,80 812,79 812,79 814,83 814))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 631
---------------------------------------------------------
UNION ALL
SELECT '6.633'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''506'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 813,84 809,82 809,82 812,80 812,80 813,84 813))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 632
---------------------------------------------------------
UNION ALL
SELECT '6.634'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''507'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 842,2 838,-2 838,-2 842,2 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 633
---------------------------------------------------------
UNION ALL
SELECT '6.635'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''508'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 843,4 839,2 839,2 842,0 842,0 843,4 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 634
---------------------------------------------------------
UNION ALL
SELECT '6.636'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''509'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 844,3 843,0 843,0 842,-1 842,-1 844,3 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 635
---------------------------------------------------------
UNION ALL
SELECT '6.637'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''510'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 844,19 843,16 843,16 842,15 842,15 844,19 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 636
---------------------------------------------------------
UNION ALL
SELECT '6.638'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''511'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 842,18 838,14 838,14 842,18 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 637
---------------------------------------------------------
UNION ALL
SELECT '6.639'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''512'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 843,20 839,18 839,18 842,16 842,16 843,20 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 638
---------------------------------------------------------
UNION ALL
SELECT '6.640'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''513'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 843,36 839,34 839,34 842,32 842,32 843,36 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 639
---------------------------------------------------------
UNION ALL
SELECT '6.641'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''514'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 842,34 838,30 838,30 842,34 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 640
---------------------------------------------------------
UNION ALL
SELECT '6.642'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''515'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 844,35 843,32 843,32 842,31 842,31 844,35 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 641
---------------------------------------------------------
UNION ALL
SELECT '6.643'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''516'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 844,51 843,48 843,48 842,47 842,47 844,51 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 642
---------------------------------------------------------
UNION ALL
SELECT '6.644'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''517'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 843,52 839,50 839,50 842,48 842,48 843,52 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 643
---------------------------------------------------------
UNION ALL
SELECT '6.645'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''518'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 842,50 838,46 838,46 842,50 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 644
---------------------------------------------------------
UNION ALL
SELECT '6.646'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''519'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 843,68 839,66 839,66 842,64 842,64 843,68 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 645
---------------------------------------------------------
UNION ALL
SELECT '6.647'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''520'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 844,67 843,64 843,64 842,63 842,63 844,67 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 646
---------------------------------------------------------
UNION ALL
SELECT '6.648'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''521'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 842,66 838,62 838,62 842,66 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 647
---------------------------------------------------------
UNION ALL
SELECT '6.649'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''522'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 839,82 838,78 838,78 842,80 842,80 839,82 839))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 648
---------------------------------------------------------
UNION ALL
SELECT '6.650'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''522'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 649
---------------------------------------------------------
UNION ALL
SELECT '6.651'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''522'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 842,82 838,78 838,78 842,82 842))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 650
---------------------------------------------------------
UNION ALL
SELECT '6.652'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''523'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 844,83 843,80 843,80 842,79 842,79 844,83 844))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 651
---------------------------------------------------------
UNION ALL
SELECT '6.653'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''524'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 843,84 839,82 839,82 842,80 842,80 843,84 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 652
---------------------------------------------------------
UNION ALL
SELECT '6.654'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''524'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 843,84 839,80 839,80 843,84 843))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 653
---------------------------------------------------------
UNION ALL
SELECT '6.655'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''525'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 872,2 868,-2 868,-2 872,2 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 654
---------------------------------------------------------
UNION ALL
SELECT '6.656'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''525'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 869,2 868,-2 868,-2 872,0 872,0 869,2 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 655
---------------------------------------------------------
UNION ALL
SELECT '6.657'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''525'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 656
---------------------------------------------------------
UNION ALL
SELECT '6.658'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''526'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 873,4 869,2 869,2 872,0 872,0 873,4 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 657
---------------------------------------------------------
UNION ALL
SELECT '6.659'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''526'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 873,4 869,0 869,0 873,4 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 658
---------------------------------------------------------
UNION ALL
SELECT '6.660'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''527'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 874,3 873,0 873,0 872,-1 872,-1 874,3 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 659
---------------------------------------------------------
UNION ALL
SELECT '6.661'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''528'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 874,19 873,16 873,16 872,15 872,15 874,19 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 660
---------------------------------------------------------
UNION ALL
SELECT '6.662'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''529'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 872,18 868,14 868,14 872,18 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 661
---------------------------------------------------------
UNION ALL
SELECT '6.663'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''529'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 662
---------------------------------------------------------
UNION ALL
SELECT '6.664'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''529'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 869,18 868,14 868,14 872,16 872,16 869,18 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 663
---------------------------------------------------------
UNION ALL
SELECT '6.665'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''530'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 873,20 869,18 869,18 872,16 872,16 873,20 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 664
---------------------------------------------------------
UNION ALL
SELECT '6.666'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''530'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 873,20 869,16 869,16 873,20 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 665
---------------------------------------------------------
UNION ALL
SELECT '6.667'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''531'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 873,36 869,32 869,32 873,36 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 666
---------------------------------------------------------
UNION ALL
SELECT '6.668'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''531'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 873,36 869,34 869,34 872,32 872,32 873,36 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 667
---------------------------------------------------------
UNION ALL
SELECT '6.669'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''532'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 872,34 868,30 868,30 872,34 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 668
---------------------------------------------------------
UNION ALL
SELECT '6.670'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''532'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 869,34 868,30 868,30 872,32 872,32 869,34 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 669
---------------------------------------------------------
UNION ALL
SELECT '6.671'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''532'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 670
---------------------------------------------------------
UNION ALL
SELECT '6.672'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''533'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 874,35 873,32 873,32 872,31 872,31 874,35 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 671
---------------------------------------------------------
UNION ALL
SELECT '6.673'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''534'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 874,51 873,48 873,48 872,47 872,47 874,51 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 672
---------------------------------------------------------
UNION ALL
SELECT '6.674'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''535'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 873,52 869,50 869,50 872,48 872,48 873,52 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 673
---------------------------------------------------------
UNION ALL
SELECT '6.675'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''535'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 873,52 869,48 869,48 873,52 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 674
---------------------------------------------------------
UNION ALL
SELECT '6.676'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''536'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 869,50 868,46 868,46 872,48 872,48 869,50 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 675
---------------------------------------------------------
UNION ALL
SELECT '6.677'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''536'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 872,50 868,46 868,46 872,50 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 676
---------------------------------------------------------
UNION ALL
SELECT '6.678'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''536'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 677
---------------------------------------------------------
UNION ALL
SELECT '6.679'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''537'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 873,68 869,64 869,64 873,68 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 678
---------------------------------------------------------
UNION ALL
SELECT '6.680'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''537'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 873,68 869,66 869,66 872,64 872,64 873,68 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 679
---------------------------------------------------------
UNION ALL
SELECT '6.681'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''538'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 874,67 873,64 873,64 872,63 872,63 874,67 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 680
---------------------------------------------------------
UNION ALL
SELECT '6.682'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''539'' '::text description,
        ST_AsText(wkb_geometry) IS NULL AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2000' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 681
---------------------------------------------------------
UNION ALL
SELECT '6.683'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''539'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 869,66 868,62 868,62 872,64 872,64 869,66 869))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 682
---------------------------------------------------------
UNION ALL
SELECT '6.684'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''539'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 872,66 868,62 868,62 872,66 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 683
---------------------------------------------------------
UNION ALL
SELECT '6.685'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''540'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 872,82 868,78 868,78 872,82 872))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 684
---------------------------------------------------------
UNION ALL
SELECT '6.686'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''540'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 870,82 868,78 868,78 872,79 872,79 870,82 870))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 685
---------------------------------------------------------
UNION ALL
SELECT '6.687'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''541'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 874,83 870,79 870,79 874,83 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 686
---------------------------------------------------------
UNION ALL
SELECT '6.688'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''541'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 874,83 870,82 870,82 872,79 872,79 874,83 874))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 687
---------------------------------------------------------
UNION ALL
SELECT '6.689'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''542'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 873,84 869,82 869,82 870,83 870,83 873,84 873))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 688
---------------------------------------------------------
UNION ALL
SELECT '6.690'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''543'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 900,2 898,-2 898,-2 902,-1 902,-1 900,2 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 689
---------------------------------------------------------
UNION ALL
SELECT '6.691'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''543'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 902,2 898,-2 898,-2 902,2 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 690
---------------------------------------------------------
UNION ALL
SELECT '6.692'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''544'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 903,4 899,2 899,2 900,3 900,3 903,4 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 691
---------------------------------------------------------
UNION ALL
SELECT '6.693'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''545'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 904,3 900,-1 900,-1 904,3 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 692
---------------------------------------------------------
UNION ALL
SELECT '6.694'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''545'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 904,3 900,2 900,2 902,-1 902,-1 904,3 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 693
---------------------------------------------------------
UNION ALL
SELECT '6.695'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''546'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 904,19 900,18 900,18 902,15 902,15 904,19 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 694
---------------------------------------------------------
UNION ALL
SELECT '6.696'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''546'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 904,19 900,15 900,15 904,19 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 695
---------------------------------------------------------
UNION ALL
SELECT '6.697'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''547'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 900,18 898,14 898,14 902,15 902,15 900,18 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 696
---------------------------------------------------------
UNION ALL
SELECT '6.698'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''547'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 902,18 898,14 898,14 902,18 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 697
---------------------------------------------------------
UNION ALL
SELECT '6.699'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''548'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 903,20 899,18 899,18 900,19 900,19 903,20 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 698
---------------------------------------------------------
UNION ALL
SELECT '6.700'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''549'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 903,36 899,34 899,34 900,35 900,35 903,36 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 699
---------------------------------------------------------
UNION ALL
SELECT '6.701'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''550'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 900,34 898,30 898,30 902,31 902,31 900,34 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 700
---------------------------------------------------------
UNION ALL
SELECT '6.702'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''550'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 902,34 898,30 898,30 902,34 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 701
---------------------------------------------------------
UNION ALL
SELECT '6.703'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''551'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 904,35 900,31 900,31 904,35 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 702
---------------------------------------------------------
UNION ALL
SELECT '6.704'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''551'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 904,35 900,34 900,34 902,31 902,31 904,35 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 703
---------------------------------------------------------
UNION ALL
SELECT '6.705'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''552'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 904,51 900,50 900,50 902,47 902,47 904,51 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 704
---------------------------------------------------------
UNION ALL
SELECT '6.706'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''552'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 904,51 900,47 900,47 904,51 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 705
---------------------------------------------------------
UNION ALL
SELECT '6.707'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''553'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 903,52 899,50 899,50 900,51 900,51 903,52 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 706
---------------------------------------------------------
UNION ALL
SELECT '6.708'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''554'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 900,50 898,46 898,46 902,47 902,47 900,50 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 707
---------------------------------------------------------
UNION ALL
SELECT '6.709'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''554'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 902,50 898,46 898,46 902,50 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 708
---------------------------------------------------------
UNION ALL
SELECT '6.710'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''555'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 903,68 899,66 899,66 900,67 900,67 903,68 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 709
---------------------------------------------------------
UNION ALL
SELECT '6.711'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''556'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 904,67 900,63 900,63 904,67 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 710
---------------------------------------------------------
UNION ALL
SELECT '6.712'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''556'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 904,67 900,66 900,66 902,63 902,63 904,67 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 711
---------------------------------------------------------
UNION ALL
SELECT '6.713'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''557'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 902,66 898,62 898,62 902,66 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2009' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 712
---------------------------------------------------------
UNION ALL
SELECT '6.714'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''557'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 900,66 898,62 898,62 902,63 902,63 900,66 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 713
---------------------------------------------------------
UNION ALL
SELECT '6.715'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''558'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 899,82 898,78 898,78 902,79 902,79 900,80 900,80 899,82 899))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 714
---------------------------------------------------------
UNION ALL
SELECT '6.716'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''558'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 902,82 898,78 898,78 902,82 902))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 715
---------------------------------------------------------
UNION ALL
SELECT '6.717'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''558'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((82 900,82 898,78 898,78 902,79 902,79 900,82 900))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 716
---------------------------------------------------------
UNION ALL
SELECT '6.718'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''559'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 904,83 903,80 903,80 900,79 900,79 904,83 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 717
---------------------------------------------------------
UNION ALL
SELECT '6.719'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''559'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 904,83 900,82 900,82 902,79 902,79 904,83 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 718
---------------------------------------------------------
UNION ALL
SELECT '6.720'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''559'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((83 904,83 900,79 900,79 904,83 904))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 719
---------------------------------------------------------
UNION ALL
SELECT '6.721'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''560'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 903,84 899,80 899,80 903,84 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 720
---------------------------------------------------------
UNION ALL
SELECT '6.722'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''560'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((84 903,84 899,82 899,82 900,83 900,83 903,84 903))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 721
---------------------------------------------------------
UNION ALL
SELECT '6.723'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''561'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 929,2 928,-2 928,-2 932,-1 932,-1 930,0 930,0 929,2 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 722
---------------------------------------------------------
UNION ALL
SELECT '6.724'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''561'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 932,2 928,-2 928,-2 932,2 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 723
---------------------------------------------------------
UNION ALL
SELECT '6.725'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''561'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((2 930,2 928,-2 928,-2 932,-1 932,-1 930,2 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 724
---------------------------------------------------------
UNION ALL
SELECT '6.726'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''562'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 933,4 929,2 929,2 930,3 930,3 933,4 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 725
---------------------------------------------------------
UNION ALL
SELECT '6.727'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''562'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((4 933,4 929,0 929,0 933,4 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 726
---------------------------------------------------------
UNION ALL
SELECT '6.728'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''563'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 934,3 933,0 933,0 930,-1 930,-1 934,3 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 727
---------------------------------------------------------
UNION ALL
SELECT '6.729'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''563'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 934,3 930,2 930,2 932,-1 932,-1 934,3 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 728
---------------------------------------------------------
UNION ALL
SELECT '6.730'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''563'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((3 934,3 930,-1 930,-1 934,3 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 729
---------------------------------------------------------
UNION ALL
SELECT '6.731'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''564'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 934,19 930,18 930,18 932,15 932,15 934,19 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 730
---------------------------------------------------------
UNION ALL
SELECT '6.732'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''564'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 934,19 930,15 930,15 934,19 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 731
---------------------------------------------------------
UNION ALL
SELECT '6.733'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''564'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((19 934,19 933,16 933,16 930,15 930,15 934,19 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 732
---------------------------------------------------------
UNION ALL
SELECT '6.734'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''565'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 929,18 928,14 928,14 932,15 932,15 930,16 930,16 929,18 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 733
---------------------------------------------------------
UNION ALL
SELECT '6.735'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''565'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 932,18 928,14 928,14 932,18 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 734
---------------------------------------------------------
UNION ALL
SELECT '6.736'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''565'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((18 930,18 928,14 928,14 932,15 932,15 930,18 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 735
---------------------------------------------------------
UNION ALL
SELECT '6.737'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''566'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 933,20 929,16 929,16 933,20 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 736
---------------------------------------------------------
UNION ALL
SELECT '6.738'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''566'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((20 933,20 929,18 929,18 930,19 930,19 933,20 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 737
---------------------------------------------------------
UNION ALL
SELECT '6.739'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''567'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 933,36 929,32 929,32 933,36 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 738
---------------------------------------------------------
UNION ALL
SELECT '6.740'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''567'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((36 933,36 929,34 929,34 930,35 930,35 933,36 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 739
---------------------------------------------------------
UNION ALL
SELECT '6.741'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''568'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 929,34 928,30 928,30 932,31 932,31 930,32 930,32 929,34 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 740
---------------------------------------------------------
UNION ALL
SELECT '6.742'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''568'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 932,34 928,30 928,30 932,34 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 741
---------------------------------------------------------
UNION ALL
SELECT '6.743'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''568'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((34 930,34 928,30 928,30 932,31 932,31 930,34 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 742
---------------------------------------------------------
UNION ALL
SELECT '6.744'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''569'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 934,35 933,32 933,32 930,31 930,31 934,35 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 743
---------------------------------------------------------
UNION ALL
SELECT '6.745'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''569'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 934,35 930,34 930,34 932,31 932,31 934,35 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 744
---------------------------------------------------------
UNION ALL
SELECT '6.746'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''569'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((35 934,35 930,31 930,31 934,35 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 745
---------------------------------------------------------
UNION ALL
SELECT '6.747'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''570'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 934,51 930,47 930,47 934,51 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 746
---------------------------------------------------------
UNION ALL
SELECT '6.748'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''570'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 934,51 933,48 933,48 930,47 930,47 934,51 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 747
---------------------------------------------------------
UNION ALL
SELECT '6.749'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''570'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((51 934,51 930,50 930,50 932,47 932,47 934,51 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 748
---------------------------------------------------------
UNION ALL
SELECT '6.750'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''571'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 933,52 929,50 929,50 930,51 930,51 933,52 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 749
---------------------------------------------------------
UNION ALL
SELECT '6.751'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''571'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((52 933,52 929,48 929,48 933,52 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 750
---------------------------------------------------------
UNION ALL
SELECT '6.752'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''572'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 929,50 928,46 928,46 932,47 932,47 930,48 930,48 929,50 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 751
---------------------------------------------------------
UNION ALL
SELECT '6.753'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''572'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 932,50 928,46 928,46 932,50 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 752
---------------------------------------------------------
UNION ALL
SELECT '6.754'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''572'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((50 930,50 928,46 928,46 932,47 932,47 930,50 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 753
---------------------------------------------------------
UNION ALL
SELECT '6.755'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''573'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 933,68 929,64 929,64 933,68 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 754
---------------------------------------------------------
UNION ALL
SELECT '6.756'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''573'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((68 933,68 929,66 929,66 930,67 930,67 933,68 933))' AND
        ref_year::text = '2020' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 755
---------------------------------------------------------
UNION ALL
SELECT '6.757'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''574'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 934,67 930,63 930,63 934,67 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 756
---------------------------------------------------------
UNION ALL
SELECT '6.758'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''574'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 934,67 930,66 930,66 932,63 932,63 934,67 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 757
---------------------------------------------------------
UNION ALL
SELECT '6.759'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''574'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((67 934,67 933,64 933,64 930,63 930,63 934,67 934))' AND
        ref_year::text = '2010' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 758
---------------------------------------------------------
UNION ALL
SELECT '6.760'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''575'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 929,66 928,62 928,62 932,63 932,63 930,64 930,64 929,66 929))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2020' AND 
        valid_year_end::text = '3000' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 759
---------------------------------------------------------
UNION ALL
SELECT '6.761'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''575'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 932,66 928,62 928,62 932,66 932))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 760
---------------------------------------------------------
UNION ALL
SELECT '6.762'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test TT_GeoHistory() on polygon ID ''575'' '::text description,
        ST_AsText(wkb_geometry)  = 'POLYGON((66 930,66 928,62 928,62 932,63 932,63 930,66 930))' AND
        ref_year::text = '2000' AND
        valid_year_begin::text = '2010' AND 
        valid_year_end::text = '2019' passed
FROM public.test_geohistory_3_results_with_validity
WHERE rownum = 761
---------------------------------------------------------
) foo WHERE NOT passed;