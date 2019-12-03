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
SELECT * FROM rawfri.nt01 LIMIT 10;

-- Create a 200 rows test view on the inventory table
SELECT TT_CreateMappingView('rawfri', 'nt01', 200);

-- Display
SELECT * FROM rawfri.nt01_min_200;

-- Refine the view to test with one row if necessary
DROP VIEW IF EXISTS rawfri.nt01_min_200_test;
CREATE VIEW rawfri.nt01_min_200_test AS
SELECT * FROM rawfri.nt01_min_200
WHERE ogc_fid = 114;

-- Display
SELECT * FROM rawfri.nt01_min_200_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.fvi01_cas; 
SELECT * FROM translation.fvi01_dst; 
SELECT * FROM translation.fvi01_eco; 
SELECT * FROM translation.fvi01_lyr; 
SELECT * FROM translation.fvi01_nfl;
SELECT * FROM translation.fvi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nt01_fvi01_cas_test;
CREATE TABLE translation_test.nt01_fvi01_cas_test AS
SELECT * FROM translation.fvi01_cas
--WHERE rule_id::int < 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.nt01_fvi01_dst_test;
CREATE TABLE translation_test.nt01_fvi01_dst_test AS
SELECT * FROM translation.fvi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.nt01_fvi01_eco_test;
CREATE TABLE translation_test.nt01_fvi01_eco_test AS
SELECT * FROM translation.fvi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.nt01_fvi01_lyr_test;
CREATE TABLE translation_test.nt01_fvi01_lyr_test AS
SELECT * FROM translation.fvi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.nt01_fvi01_nfl_test;
CREATE TABLE translation_test.nt01_fvi01_nfl_test AS
SELECT * FROM translation.fvi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.nt01_fvi01_geo_test;
CREATE TABLE translation_test.nt01_fvi01_geo_test AS
SELECT * FROM translation.fvi01_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_test.nt01_fvi01_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate the NT species dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_species_validation', '_nt_species_val');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_fvi01_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_test', 'nt01_fvi01_cas_test', '_nt01_cas_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_dst_test', '_nt01_dst_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_eco_test', '_nt01_eco_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_lyr_test', '_nt01_lyr_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_nfl_test', '_nt01_nfl_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_geo_test', '_nt01_geo_test');

-- Create VIEW 'nt01_l2_to_nt01_l1_map_200' mapping the NT01 layer 2 
-- attributes to the NT01 layer 1 attributes
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 200);

-- Translate the samples
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt01_min_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_cas_test');

SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt01_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_dst_test');

SELECT * FROM TT_Translate_nt01_eco_test('rawfri', 'nt01_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_eco_test');

SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt01_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt01_l2_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt01_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt01_l2_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

SELECT * FROM TT_Translate_nt01_geo_test('rawfri', 'nt01_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_geo_test');

--------------------------------------------------------------------------
--SELECT TT_DeleteAllLogs('translation_test');
