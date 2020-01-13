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
-- Usage
--
-- 1) Load the test tables from a command window with load_test_tables.bat.
-- 2) Execute "test_translation.sql" in PostgreSQL (this file).
-- 2) Execute "test_translation.sql" in PostgreSQL (this file)
-- 3) If undesirable changes show up, fix your translation tables.
--    If desirable changes occurs, dump them as new test tables with 
--    dump_test_tables.bat and commit.
--
-- Whole test takes about 3 minutes. You can execute only part of it depending 
-- on which translation tables were modified.
--
-- You can get a detailed summary of the differences between new translated tables
-- and test tables by copying and executing the "check_query" query for a specific table.
-------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_test;
------------------------------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'avi01_a_cas', '_ab06_cas_test');
SELECT TT_Prepare('translation', 'avi01_b_cas', '_ab16_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nbi01_cas', '_nb01_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'vri01_cas', '_bc08_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'fvi01_cas', '_nt01_cas_test', 'ab06_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_all_new CASCADE;;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200);
CREATE TABLE casfri50_test.cas_all_new AS 
SELECT * FROM TT_Translate_ab06_cas_test('rawfri', 'ab06_l1_to_ab_a_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab_b', 400);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab16_cas_test('rawfri', 'ab16_l1_to_ab_b_l1_map_400');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb01_cas_test('rawfri', 'nb01_l1_to_nb_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb01_cas_test('rawfri', 'nb02_l1_to_nb_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc08_cas_test('rawfri', 'bc08_l1_to_bc_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt01_l1_to_nt_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt02_l1_to_nt_l1_map_500');
------------------------
SELECT count(*) FROM casfri50_test.cas_all_new; -- 3800
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'avi01_a_dst', '_ab06_dst_test');
SELECT TT_Prepare('translation', 'avi01_b_dst', '_ab16_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nbi01_dst', '_nb01_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'vri01_dst', '_bc08_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'fvi01_dst', '_nt01_dst_test', 'ab06_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'DST');
CREATE TABLE casfri50_test.dst_all_new AS
SELECT * FROM TT_Translate_ab06_dst_test('rawfri', 'ab06_l1_to_ab_a_l1_map_200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab_b', 400, 'DST');
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab16_dst_test('rawfri', 'ab16_l1_to_ab_b_l1_map_400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600, 'DST');
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb01_l1_to_nb_l1_map_600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 600, 'DST');
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb02_l2_to_nb_l1_map_600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600, 'DST');
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb02_l1_to_nb_l1_map_600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000, 'DST');
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc08_dst_test('rawfri', 'bc08_l1_to_bc_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500, 'DST');
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt01_l1_to_nt_l1_map_500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500, 'DST');
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt02_l1_to_nt_l1_map_500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 500, 'DST');
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt02_l2_to_nt_l1_map_500_dst');
------------------------
SELECT count(*) FROM casfri50_test.dst_all_new; -- 4900
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'avi01_a_eco', '_ab06_eco_test');
SELECT TT_Prepare('translation', 'avi01_b_eco', '_ab16_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'nbi01_eco', '_nb01_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'vri01_eco', '_bc08_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'fvi01_eco', '_nt01_eco_test', 'ab06_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'ECO');
CREATE TABLE casfri50_test.eco_all_new AS 
SELECT * FROM TT_Translate_ab06_eco_test('rawfri', 'ab06_l1_to_ab_a_l1_map_200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab_b', 400, 'ECO');
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab16_eco_test('rawfri', 'ab16_l1_to_ab_b_l1_map_400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600, 'ECO');
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb01_eco_test('rawfri', 'nb01_l1_to_nb_l1_map_600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600, 'ECO');
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb01_eco_test('rawfri', 'nb02_l1_to_nb_l1_map_600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08','bc', 1000, 'ECO');
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc08_eco_test('rawfri', 'bc08_l1_to_bc_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500, 'ECO');
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nt01_eco_test('rawfri', 'nt01_l1_to_nt_l1_map_500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500, 'ECO');
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_nt01_eco_test('rawfri', 'nt02_l1_to_nt_l1_map_500_eco');
------------------------
SELECT count(*) FROM casfri50_test.eco_all_new; -- 1200
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'avi01_a_lyr', '_ab06_lyr_test');
SELECT TT_Prepare('translation', 'avi01_b_lyr', '_ab16_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nbi01_lyr', '_nb01_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'vri01_lyr', '_bc08_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'fvi01_lyr', '_nt01_lyr_test', 'ab06_avi01_lyr');
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'LYR');
CREATE TABLE casfri50_test.lyr_all_new AS 
SELECT * FROM TT_Translate_ab06_lyr_test('rawfri', 'ab06_l1_to_ab_a_l1_map_200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab_a', 1, 200, 'LYR');
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab06_lyr_test('rawfri', 'ab06_l2_to_ab_a_l1_map_200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab_b', 400, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab16_lyr_test('rawfri', 'ab16_l1_to_ab_b_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab_b', 1, 400, 'LYR');
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab16_lyr_test('rawfri', 'ab16_l2_to_ab_b_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_l1_to_nb_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 600, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_l2_to_nb_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb02_l1_to_nb_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 600, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb02_l2_to_nb_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc08_lyr_test('rawfri', 'bc08_l1_to_bc_l1_map_1000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt01_l1_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 500, 'LYR');
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt01_l2_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500, 'LYR');
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt02_l1_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 500, 'LYR');
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt02_l2_to_nt_l1_map_500_lyr');
------------------------
SELECT count(*) FROM casfri50_test.lyr_all_new; -- 6600
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'avi01_a_nfl', '_ab06_nfl_test');
SELECT TT_Prepare('translation', 'avi01_b_nfl', '_ab16_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nbi01_nfl', '_nb01_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'vri01_nfl', '_bc08_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'fvi01_nfl', '_nt01_nfl_test', 'ab06_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'NFL');
CREATE TABLE casfri50_test.nfl_all_new AS 
SELECT * FROM TT_Translate_ab06_nfl_test('rawfri', 'ab06_l1_to_ab_a_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab_a', 1, 200, 'NFL');
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab06_nfl_test('rawfri', 'ab06_l2_to_ab_a_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab_b', 400, 'NFL');
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab16_nfl_test('rawfri', 'ab16_l1_to_ab_b_l1_map_400_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab_b', 1, 400, 'NFL');
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab16_nfl_test('rawfri', 'ab16_l2_to_ab_b_l1_map_400_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600, 'NFL');
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb01_nfl_test('rawfri', 'nb01_l1_to_nb_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600, 'NFL');
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb01_nfl_test('rawfri', 'nb02_l1_to_nb_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000, 'NFL');
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc08_nfl_test('rawfri', 'bc08_l1_to_bc_l1_map_1000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500, 'NFL');
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt01_l1_to_nt_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 500, 'NFL');
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt01_l2_to_nt_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500, 'NFL');
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt02_l1_to_nt_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 500, 'NFL');
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt02_l2_to_nt_l1_map_500_nfl');
------------------------
SELECT count(*) FROM casfri50_test.nfl_all_new; -- 4200
---------------------------------------------------------
-- Create ordered VIEWs
CREATE OR REPLACE VIEW casfri50_test.cas_all_new_ordered AS
SELECT * FROM casfri50_test.cas_all_new
ORDER BY cas_id;

CREATE OR REPLACE VIEW casfri50_test.dst_all_new_ordered AS
SELECT * FROM casfri50_test.dst_all_new
ORDER BY cas_id, layer;

CREATE OR REPLACE VIEW casfri50_test.eco_all_new_ordered AS
SELECT * FROM casfri50_test.eco_all_new
ORDER BY cas_id;

CREATE OR REPLACE VIEW casfri50_test.lyr_all_new_ordered AS
SELECT * FROM casfri50_test.lyr_all_new
ORDER BY cas_id, layer;

CREATE OR REPLACE VIEW casfri50_test.nfl_all_new_ordered AS
SELECT * FROM casfri50_test.nfl_all_new
ORDER BY cas_id, layer;
---------------------------------------------------------
-- Compare new with old tables
---------------------------------------------------------
SELECT '1.0' number, 
       'Compare "cas_all_new_ordered" and "cas_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''cas_all_test'', ''casfri50_test'' , ''cas_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.cas_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.cas_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.0' number, 
       'Compare "dst_all_new_ordered" and "dst_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''dst_all_test'', ''casfri50_test'' , ''dst_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.dst_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.dst_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.0' number, 
       'Compare "eco_all_new_ordered" and "eco_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''eco_all_test'', ''casfri50_test'' , ''eco_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.eco_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.eco_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.0' number, 
       'Compare "lyr_all_new_ordered" and "lyr_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''lyr_all_test'', ''casfri50_test'' , ''lyr_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.lyr_all_new a 
      FULL OUTER JOIN casfri50_test.lyr_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.0' number, 
       'Compare "nfl_all_new_ordered" and "nfl_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''nfl_all_test'', ''casfri50_test'' , ''nfl_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.nfl_all_new a 
      FULL OUTER JOIN casfri50_test.nfl_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------




