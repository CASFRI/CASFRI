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
-- 1) Load the test tables from a command window:
--    >load_test_tables.bat 
-- 2) Execute "test_translation.sql" in PostgreSQL (this file)
-- 3) If undesirable changes show up, fix your translation tables.
--    If desirable changes occurs, dump them as new test tables and commit:
--    >dump_test_tables.bat
--
-- Whole test takes about 3 minutes. You can execute only part of it depending 
-- on what translation file was modified.
--
-- You can get a detailled summary of the different between new translated tables
-- and test tables by copying and executing the "check_query" query for a specific table.
-------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_test;
-------------------------------------------------------------------------------
-- Create random views on the target tables
CREATE OR REPLACE VIEW casfri50_test.ab06_test AS
SELECT r.*
FROM TT_RandomInt(200, 1, 11484, 1.0) rd, rawfri.ab06 r
WHERE rd.id = r.ogc_fid;

CREATE OR REPLACE VIEW casfri50_test.ab16_test AS
SELECT r.*
FROM TT_RandomInt(400, 1, 120476, 1.0) rd, rawfri.ab16 r
WHERE rd.id = r.ogc_fid;

CREATE OR REPLACE VIEW casfri50_test.nb01_test AS
SELECT r.*
FROM TT_RandomInt(600, 1, 927177, 1.0) rd, rawfri.nb01 r
WHERE rd.id = r.ogc_fid;

CREATE OR REPLACE VIEW casfri50_test.nb02_test AS
SELECT r.*
FROM TT_RandomInt(600, 1, 1123893, 1.0) rd, rawfri.nb02 r
WHERE rd.id = r.ogc_fid;

CREATE OR REPLACE VIEW casfri50_test.bc08_test AS
SELECT r.*
FROM TT_RandomInt(1000, 1, 4677411, 1.0) rd, rawfri.bc08 r
WHERE rd.id = r.ogc_fid;

CREATE OR REPLACE VIEW casfri50_test.bc09_test AS
SELECT r.*
FROM TT_RandomInt(1000, 1, 5151772, 1.0) rd, rawfri.bc09 r
WHERE rd.id = r.ogc_fid;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_cas', '_ab06_cas_test');
SELECT TT_Prepare('translation', 'ab16_avi01_cas', '_ab16_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nb01_nbi01_cas', '_nb01_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc08_vri01_cas', '_bc08_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc09_vri01_cas', '_bc09_cas_test', 'ab06_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_all_new;
CREATE TABLE casfri50_test.cas_all_new AS 
SELECT * FROM TT_Translate_ab06_cas_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab16_cas_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb01_cas_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc08_cas_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc09_cas_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.cas_all_new; -- 3200
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_dst', '_ab06_dst_test');
SELECT TT_Prepare('translation', 'ab16_avi01_dst', '_ab16_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst', '_nb01_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc08_vri01_dst', '_bc08_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc09_vri01_dst', '_bc09_dst_test', 'ab06_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_all_new;
CREATE TABLE casfri50_test.dst_all_new AS
SELECT * FROM TT_Translate_ab06_dst_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab16_dst_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb01_dst_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc08_dst_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc09_dst_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.dst_all_new; -- 3200
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_eco', '_ab06_eco_test');
SELECT TT_Prepare('translation', 'ab16_avi01_eco', '_ab16_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'nb01_nbi01_eco', '_nb01_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'bc08_vri01_eco', '_bc08_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'bc09_vri01_eco', '_bc09_eco_test', 'ab06_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_all_new;
CREATE TABLE casfri50_test.eco_all_new AS 
SELECT * FROM TT_Translate_ab06_eco_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab16_eco_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb01_eco_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc08_eco_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc09_eco_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.eco_all_new; -- 3200
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr_test');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb01_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc09_vri01_lyr', '_bc09_lyr_test', 'ab06_avi01_lyr');
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_all_new;
CREATE TABLE casfri50_test.lyr_all_new AS 
SELECT * FROM TT_Translate_ab06_lyr_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab16_lyr_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb01_lyr_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc08_lyr_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc09_lyr_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.lyr_all_new; 
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_nfl', '_ab06_nfl_test');
SELECT TT_Prepare('translation', 'ab16_avi01_nfl', '_ab16_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nb01_nbi01_nfl', '_nb01_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc08_vri01_nfl', '_bc08_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc09_vri01_nfl', '_bc09_nfl_test', 'ab06_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new;
CREATE TABLE casfri50_test.nfl_all_new AS 
SELECT * FROM TT_Translate_ab06_nfl_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab16_nfl_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb01_nfl_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc08_nfl_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc09_nfl_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.nfl_all_new;
-------------------------------------------------------

---------------------------------------------------------
SELECT '1.0' number, 
       'Compare "cas_all_new" and "cas_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''cas_all_new'', ''casfri50_test'' , ''cas_all_test'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.cas_all_new a 
      FULL OUTER JOIN casfri50_test.cas_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.0' number, 
       'Compare "dst_all_new" and "dst_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''dst_all_test'', ''casfri50_test'' , ''dst_all_new'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.dst_all_new a 
      FULL OUTER JOIN casfri50_test.dst_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.0' number, 
       'Compare "eco_all_new" and "eco_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''eco_all_test'', ''casfri50_test'' , ''eco_all_new'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.eco_all_new a 
      FULL OUTER JOIN casfri50_test.eco_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.0' number, 
       'Compare "lyr_all_new" and "lyr_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''lyr_all_test'', ''casfri50_test'' , ''lyr_all_new'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.lyr_all_new a 
      FULL OUTER JOIN casfri50_test.lyr_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.0' number, 
       'Compare "nfl_all_new" and "nfl_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''nfl_all_test'', ''casfri50_test'' , ''nfl_all_new'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.nfl_all_new a 
      FULL OUTER JOIN casfri50_test.nfl_all_test b USING (cas_id)) foo
---------------------------------------------------------




