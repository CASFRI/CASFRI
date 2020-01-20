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
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create a 200 random rows views on the source inventory
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Have a look at the source inventory table
SELECT * FROM rawfri.qc03 LIMIT 10;

-- Create a 200 rows test view on the inventory table
SELECT TT_CreateMappingView('rawfri', 'qc03', 200);

-- Display
SELECT * FROM rawfri.qc03_min_200;

-- Refine the view to test with one row if necessary
DROP VIEW IF EXISTS rawfri.qc03_min_200_test;
CREATE VIEW rawfri.qc03_min_200_test AS
SELECT * FROM rawfri.qc03_min_200
WHERE ogc_fid = 114;

-- Display
SELECT * FROM rawfri.qc03_min_200_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.tie03_cas; 
SELECT * FROM translation.tie03_dst; 
SELECT * FROM translation.tie03_eco; 
SELECT * FROM translation.tie03_lyr; 
SELECT * FROM translation.tie03_nfl;
SELECT * FROM translation.tie03_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.qc03_tie03_cas_test;
CREATE TABLE translation_test.qc03_tie03_cas_test AS
SELECT * FROM translation.tie03_cas
--WHERE rule_id::int < 1
;
-- display
SELECT * FROM translation_test.qc03_tie03_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.qc03_tie03_dst_test;
CREATE TABLE translation_test.qc03_tie03_dst_test AS
SELECT * FROM translation.tie03_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.qc03_tie03_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.qc03_tie03_eco_test;
CREATE TABLE translation_test.qc03_tie03_eco_test AS
SELECT * FROM translation.tie03_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.qc03_tie03_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.qc03_tie03_lyr_test;
CREATE TABLE translation_test.qc03_tie03_lyr_test AS
SELECT * FROM translation.tie03_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.qc03_tie03_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.qc03_tie03_nfl_test;
CREATE TABLE translation_test.qc03_tie03_nfl_test AS
SELECT * FROM translation.tie03_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.qc03_tie03_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.qc03_tie03_geo_test;
CREATE TABLE translation_test.qc03_tie03_geo_test AS
SELECT * FROM translation.tie03_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_test.qc03_tie03_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate the NT species dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'nt_tie03_species_validation', '_nt_species_val');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_tie03_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_test', 'qc03_tie03_cas_test', '_qc03_cas_test');
SELECT TT_Prepare('translation_test', 'qc03_tie03_dst_test', '_qc03_dst_test');
SELECT TT_Prepare('translation_test', 'qc03_tie03_eco_test', '_qc03_eco_test');
SELECT TT_Prepare('translation_test', 'qc03_tie03_lyr_test', '_qc03_lyr_test');
SELECT TT_Prepare('translation_test', 'qc03_tie03_nfl_test', '_qc03_nfl_test');
SELECT TT_Prepare('translation_test', 'qc03_tie03_geo_test', '_qc03_geo_test');

-- Create VIEW 'qc03_l2_to_qc03_l1_map_200' mapping the NT01 layer 2 
-- attributes to the QC03 layer 1 attributes
--SELECT TT_CreateMappingView('rawfri', 'qc03', 2, 'nt', 1, 200);

-- Translate the samples
SELECT * FROM TT_Translate_qc03_cas_test('rawfri', 'qc03_min_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_cas_test');

SELECT * FROM TT_Translate_qc03_dst_test('rawfri', 'qc03_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_dst_test');

SELECT * FROM TT_Translate_qc03_eco_test('rawfri', 'qc03_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_eco_test');

SELECT * FROM TT_Translate_qc03_lyr_test('rawfri', 'qc03_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_lyr_test');

SELECT * FROM TT_Translate_qc03_lyr_test('rawfri', 'qc03_l2_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_lyr_test');

SELECT * FROM TT_Translate_qc03_nfl_test('rawfri', 'qc03_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_nfl_test');

SELECT * FROM TT_Translate_qc03_nfl_test('rawfri', 'qc03_l2_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_nfl_test');

SELECT * FROM TT_Translate_qc03_geo_test('rawfri', 'qc03_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'qc03_tie03_geo_test');

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
