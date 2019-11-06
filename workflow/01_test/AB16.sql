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
SELECT * FROM rawfri.ab16 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.ab16;

-- Create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.ab16_test_200;
CREATE OR REPLACE VIEW rawfri.ab16_test_200 AS
SELECT ogc_fid, wkb_geometry, area, perimeter,
       stand_age, age_class, cc_update, moisture, crownclose, height, 
       sp1, sp1_percnt, sp2, sp2_percnt, sp3, sp3_percnt, sp4, sp4_percnt, sp5, sp5_percnt, 
       std_struct, origin, tpr, modcon1, modext1, modyear1, modcon2, modext2, modyear2, 
       nonfor_veg, nonforvecl, anthro_veg, anth_noveg, nat_nonveg, 
       us_moist, us_crown, us_height, 
       us_sp1, us_sp1perc, us_sp2, us_sp2perc, us_sp3, us_sp3perc, us_sp4, us_sp4perc, us_sp5, us_sp5perc, 
       us_struc, us_origin, us_tpr, us_int_trp, 
       modcon1us, modext1us, modyr1us, modcon2us, modext2us, modyr2us, 
       nonforvegu, nforvegclu, us_anthveg, us_annoveg, us_natnveg, 
       src_filename, inventory_id, forest_id_2
FROM rawfri.ab16 TABLESAMPLE SYSTEM (300.0*100/120476) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- Display
SELECT * FROM rawfri.ab16_test_200;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.ab16_avi01_cas; 
SELECT * FROM translation.ab16_avi01_dst; 
SELECT * FROM translation.ab16_avi01_eco; 
SELECT * FROM translation.ab16_avi01_lyr; 
SELECT * FROM translation.ab16_avi01_nfl;
SELECT * FROM translation.ab16_avi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab16_avi01_cas_test;
CREATE TABLE translation_test.ab16_avi01_cas_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab16_avi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.ab16_avi01_dst_test;
CREATE TABLE translation_test.ab16_avi01_dst_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab16_avi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.ab16_avi01_eco_test;
CREATE TABLE translation_test.ab16_avi01_eco_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab16_avi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.ab16_avi01_lyr_test;
CREATE TABLE translation_test.ab16_avi01_lyr_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab16_avi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.ab16_avi01_nfl_test;
CREATE TABLE translation_test.ab16_avi01_nfl_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab16_avi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.ab16_avi01_geo_test;
CREATE TABLE translation_test.ab16_avi01_geo_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.ab16_avi01_geo_test;

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
SELECT TT_Prepare('translation_test', 'ab16_avi01_cas_test', '_ab16_cas_test');
SELECT TT_Prepare('translation_test', 'ab16_avi01_dst_test', '_ab16_dst_test');
SELECT TT_Prepare('translation_test', 'ab16_avi01_eco_test', '_ab16_eco_test');
SELECT TT_Prepare('translation_test', 'ab16_avi01_lyr_test', '_ab16_lyr_test');
SELECT TT_Prepare('translation_test', 'ab16_avi01_nfl_test', '_ab16_nfl_test');
SELECT TT_Prepare('translation_test', 'ab16_avi01_geo_test', '_ab16_geo_test');

-- translate the samples
SELECT * FROM TT_Translate_ab16_cas_test('rawfri', 'ab16_test_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_cas_test');

SELECT * FROM TT_Translate_ab16_dst_test('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_dst_test');

SELECT * FROM TT_Translate_ab16_eco_test('rawfri', 'ab16_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_eco_test');

SELECT * FROM TT_Translate_ab16_lyr_test('rawfri', 'ab16_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_lyr_test');

SELECT * FROM TT_Translate_ab16_nfl_test('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_nfl_test');

SELECT * FROM TT_Translate_ab16_geo_test('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_geo_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, inventory_id, ogc_fid, cas_id, 
       crownclose, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_percnt, species_per_1
FROM TT_Translate_ab16_lyr_test('rawfri', 'ab16_test_200'), rawfri.ab16_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
