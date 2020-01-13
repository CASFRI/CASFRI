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
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_devel;
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
DROP TABLE IF EXISTS translation_devel.ab06_avi01_cas_devel;
CREATE TABLE translation_devel.ab06_avi01_cas_devel AS
SELECT * FROM translation.avi01_a_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab06_avi01_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.ab06_avi01_dst_devel;
CREATE TABLE translation_devel.ab06_avi01_dst_devel AS
SELECT * FROM translation.avi01_a_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab06_avi01_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.ab06_avi01_eco_devel;
CREATE TABLE translation_devel.ab06_avi01_eco_devel AS
SELECT * FROM translation.avi01_a_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab06_avi01_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.ab06_avi01_lyr_devel;
CREATE TABLE translation_devel.ab06_avi01_lyr_devel AS
SELECT * FROM translation.avi01_a_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab06_avi01_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.ab06_avi01_nfl_devel;
CREATE TABLE translation_devel.ab06_avi01_nfl_devel AS
SELECT * FROM translation.avi01_a_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab06_avi01_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.ab06_avi01_geo_devel;
CREATE TABLE translation_devel.ab06_avi01_geo_devel AS
SELECT * FROM translation.avi01_a_geo
--WHERE rule_id::int = 2
;
-- Display
SELECT * FROM translation_devel.ab06_avi01_geo_devel;

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
SELECT TT_Prepare('translation_devel', 'ab06_avi01_cas_devel', '_ab06_cas_devel');
SELECT TT_Prepare('translation_devel', 'ab06_avi01_dst_devel', '_ab06_dst_devel');
SELECT TT_Prepare('translation_devel', 'ab06_avi01_eco_devel', '_ab06_eco_devel');
SELECT TT_Prepare('translation_devel', 'ab06_avi01_lyr_devel', '_ab06_lyr_devel');
SELECT TT_Prepare('translation_devel', 'ab06_avi01_nfl_devel', '_ab06_nfl_devel');
SELECT TT_Prepare('translation_devel', 'ab06_avi01_geo_devel', '_ab06_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200);
SELECT * FROM TT_Translate_ab06_cas_devel('rawfri', 'ab06_l1_to_ab_a_l1_map_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_cas_devel');

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'DST'); -- Only rows with a dst
SELECT * FROM TT_Translate_ab06_dst_devel('rawfri', 'ab06_l1_to_ab_a_l1_map_200_dst', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_dst_devel');

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'ECO'); -- Only rows with eco (none in this case)
SELECT * FROM TT_Translate_ab06_eco_devel('rawfri', 'ab06_l1_to_ab_a_l1_map_200_eco', 'ogc_fid'); -- 1 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_eco_devel');

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'LYR');
SELECT * FROM TT_Translate_ab06_lyr_devel('rawfri', 'ab06_l1_to_ab_a_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab_a', 1, 200, 'LYR');
SELECT * FROM TT_Translate_ab06_lyr_devel('rawfri', 'ab06_l2_to_ab_a_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab_a', 200, 'NFL');
SELECT * FROM TT_Translate_ab06_nfl_devel('rawfri', 'ab06_l1_to_ab_a_l1_map_200_nfl', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_nfl_devel');

SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab_a', 1, 200, 'NFL');
SELECT * FROM TT_Translate_ab06_nfl_devel('rawfri', 'ab06_l2_to_ab_a_l1_map_200_nfl', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_nfl_devel');

SELECT * FROM TT_Translate_ab06_geo_devel('rawfri', 'ab06_l1_to_ab_a_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab06_avi01_geo_devel');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.trm_1, b.poly_num, a.cas_id, 
       b.density, a.crown_closure_lower, a.crown_closure_upper, 
       b.height, a.height_upper, a.height_lower,
       b.sp1, a.species_1,
       b.sp1_per, a.species_per_1
FROM TT_Translate_ab06_lyr_devel('rawfri', 'ab06_min_200') a, rawfri.ab06_min_200 b
WHERE b.poly_num = substr(a.cas_id, 33, 10)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
