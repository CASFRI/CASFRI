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
-------------------------------------------------------
-- Create a 200 random rows views on the source inventory
--------------------------------------------------------------------------
-------------------------------------------------------
-- Have a look at the source inventory table
SELECT * FROM rawfri.bc09 LIMIT 10;

-- Create a 200 rows test view on the inventory table
SELECT TT_CreateMappingView('rawfri', 'bc09', 200);

-- Display
SELECT * FROM rawfri.bc09_min_200;

-- Refine the view to test with one row if necessary
DROP VIEW IF EXISTS rawfri.bc09_min_200_test;
CREATE VIEW rawfri.bc09_min_200_test AS
SELECT * FROM rawfri.bc09_min_200
WHERE ogc_fid = 1879;

-- Display
SELECT * FROM rawfri.bc09_min_200_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.bc09_vri01_cas; 
SELECT * FROM translation.bc09_vri01_dst; 
SELECT * FROM translation.bc09_vri01_eco; 
SELECT * FROM translation.bc09_vri01_lyr; 
SELECT * FROM translation.bc09_vri01_nfl;
SELECT * FROM translation.bc09_vri01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.bc09_vri01_cas_test;
CREATE TABLE translation_test.bc09_vri01_cas_test AS
SELECT * FROM translation.bc09_vri01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.bc09_vri01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.bc09_vri01_dst_test;
CREATE TABLE translation_test.bc09_vri01_dst_test AS
SELECT * FROM translation.bc09_vri01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.bc09_vri01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.bc09_vri01_eco_test;
CREATE TABLE translation_test.bc09_vri01_eco_test AS
SELECT * FROM translation.bc09_vri01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.bc09_vri01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.bc09_vri01_lyr_test;
CREATE TABLE translation_test.bc09_vri01_lyr_test AS
SELECT * FROM translation.bc09_vri01_lyr
--WHERE rule_id::int = 34
;
-- Display
SELECT * FROM translation_test.bc09_vri01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.bc09_vri01_nfl_test;
CREATE TABLE translation_test.bc09_vri01_nfl_test AS
SELECT * FROM translation.bc09_vri01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.bc09_vri01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.bc09_vri01_geo_test;
CREATE TABLE translation_test.bc09_vri01_geo_test AS
SELECT * FROM translation.bc09_vri01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.bc09_vri01_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate the BC species dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'bc_vri01_species_validation', '_bc_species_val');
SELECT * FROM TT_Translate_bc_species_val('translation', 'bc_vri01_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_test', 'bc09_vri01_cas_test', '_bc09_cas_test');
SELECT TT_Prepare('translation_test', 'bc09_vri01_dst_test', '_bc09_dst_test');
SELECT TT_Prepare('translation_test', 'bc09_vri01_eco_test', '_bc09_eco_test');
SELECT TT_Prepare('translation_test', 'bc09_vri01_lyr_test', '_bc09_lyr_test');
SELECT TT_Prepare('translation_test', 'bc09_vri01_nfl_test', '_bc09_nfl_test');
SELECT TT_Prepare('translation_test', 'bc09_vri01_geo_test', '_bc09_geo_test');

-- Translate the samples
SELECT * FROM TT_Translate_bc09_cas_test('rawfri', 'bc09_min_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_cas_test');

SELECT * FROM TT_Translate_bc09_dst_test('rawfri', 'bc09_min_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_dst_test');

SELECT * FROM TT_Translate_bc09_eco_test('rawfri', 'bc09_min_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_eco_test');

SELECT * FROM TT_Translate_bc09_lyr_test('rawfri', 'bc09_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_lyr_test');

SELECT * FROM TT_Translate_bc09_nfl_test('rawfri', 'bc09_min_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_nfl_test');

SELECT * FROM TT_Translate_bc09_geo_test('rawfri', 'bc09_min_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_geo_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.map_id, b.ogc_fid, a.cas_id, 
       b.crown_closure, a.crown_closure_lower, a.crown_closure_upper, 
       b.proj_height_1, a.height_upper, a.height_lower,
       b.species_cd_1, a.species_1,
       b.species_pct_1, a.species_per_1
FROM TT_Translate_bc09_lyr_test('rawfri', 'bc09_min_200') a, rawfri.bc09_min_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
