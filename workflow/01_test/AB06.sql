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
-- AB06
-------------------------------------------------------
-- Display one of the source inventory table
SELECT * FROM rawfri.ab06 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.ab06;

-- Create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.ab06_test_200;
CREATE OR REPLACE VIEW rawfri.ab06_test_200 AS
SELECT src_filename, inventory_id, ogc_fid, wkb_geometry, shape_area, area, perimeter, poly_num, 
       trm, moist_reg, density, height, 
       sp1, sp1_per, sp2, sp2_per, sp3, sp3_per, sp4, sp4_per, sp5, sp5_per, 
       struc, struc_val, origin, tpr, nfl, nfl_per, nat_non, anth_veg, anth_non, 
       mod1, mod1_ext, mod1_yr, mod2, mod2_ext, mod2_yr, trm_1
FROM rawfri.ab06 TABLESAMPLE SYSTEM (300.0*100/11484) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- Display
SELECT * FROM rawfri.ab06_test_200;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.ab06_avi01_cas; 
SELECT * FROM translation.ab06_avi01_dst; 
SELECT * FROM translation.ab06_avi01_eco; 
SELECT * FROM translation.ab06_avi01_lyr; 
SELECT * FROM translation.ab06_avi01_nfl;
SELECT * FROM translation.ab06_avi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab06_avi01_cas_test;
CREATE TABLE translation_test.ab06_avi01_cas_test AS
SELECT * FROM translation.ab06_avi01_cas
--WHERE rule_id::int = 10
;
-- Display
SELECT * FROM translation_test.ab06_avi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.ab06_avi01_dst_test;
CREATE TABLE translation_test.ab06_avi01_dst_test AS
SELECT * FROM translation.ab06_avi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab06_avi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.ab06_avi01_eco_test;
CREATE TABLE translation_test.ab06_avi01_eco_test AS
SELECT * FROM translation.ab06_avi01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab06_avi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.ab06_avi01_lyr_test;
CREATE TABLE translation_test.ab06_avi01_lyr_test AS
SELECT * FROM translation.ab06_avi01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab06_avi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.ab06_avi01_nfl_test;
CREATE TABLE translation_test.ab06_avi01_nfl_test AS
SELECT * FROM translation.ab06_avi01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab06_avi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.ab06_avi01_geo_test;
CREATE TABLE translation_test.ab06_avi01_geo_test AS
SELECT * FROM translation.ab06_avi01_geo
--WHERE rule_id::int = 2
;
-- Display
SELECT * FROM translation_test.ab06_avi01_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_species_validation', '_ab_species_val');
SELECT * FROM TT_Translate_ab_species_val('translation', 'ab_avi01_species');

-------------------------------------------------------
-- AB photo year
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_photoyear_validation', '_ab_photo_val');
SELECT * FROM TT_Translate_ab_photo_val('rawfri', 'ab_photoyear'); -- 5s

-- make table valid and subset by rows with valid photo years
DROP TABLE IF EXISTS rawfri.new_photo_year;
CREATE TABLE rawfri.new_photo_year AS
SELECT TT_GeoMakeValid(wkb_geometry) as wkb_geometry, photo_yr
FROM rawfri.ab_photoyear
WHERE TT_IsInt(photo_yr);

CREATE INDEX IF NOT EXISTS ab_photoyear_idx 
 ON rawfri.new_photo_year
 USING GIST(wkb_geometry);

DROP TABLE rawfri.ab_photoyear;
ALTER TABLE rawfri.new_photo_year RENAME TO ab_photoyear;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_test', 'ab06_avi01_cas_test', '_ab06_cas_test');
SELECT TT_Prepare('translation_test', 'ab06_avi01_dst_test', '_ab06_dst_test');
SELECT TT_Prepare('translation_test', 'ab06_avi01_eco_test', '_ab06_eco_test');
SELECT TT_Prepare('translation_test', 'ab06_avi01_lyr_test', '_ab06_lyr_test');
SELECT TT_Prepare('translation_test', 'ab06_avi01_nfl_test', '_ab06_nfl_test');
SELECT TT_Prepare('translation_test', 'ab06_avi01_geo_test', '_ab06_geo_test');

-- translate the samples (5 sec.)
SELECT * FROM TT_Translate_ab06_cas_test('rawfri', 'ab06_test_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_cas_test');

SELECT * FROM TT_Translate_ab06_dst_test('rawfri', 'ab06_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_dst_test');

SELECT * FROM TT_Translate_ab06_eco_test('rawfri', 'ab06_test_200', 'ogc_fid'); -- 1 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_eco_test');

SELECT * FROM TT_Translate_ab06_lyr_test('rawfri', 'ab06_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_lyr_test');

SELECT * FROM TT_Translate_ab06_nfl_test('rawfri', 'ab06_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_nfl_test');

SELECT * FROM TT_Translate_ab06_geo_test('rawfri', 'ab06_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_geo_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, trm_1, poly_num, cas_id, 
       density, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_per, species_per_1
FROM TT_Translate_ab06_lyr_test('rawfri', 'ab06_test_200'), rawfri.ab06_test_200
WHERE poly_num = substr(cas_id, 33, 10)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
