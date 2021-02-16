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
-- Create devel translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_devel;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.ab_avi01_cas; 
SELECT * FROM translation.ab_avi01_dst; 
SELECT * FROM translation.ab_avi01_eco; 
SELECT * FROM translation.ab_avi01_lyr; 
SELECT * FROM translation.ab_avi01_nfl;
SELECT * FROM translation.ab_avi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.ab16_avi01_cas_devel;
CREATE TABLE translation_devel.ab16_avi01_cas_devel AS
SELECT * FROM translation.ab_avi01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab16_avi01_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.ab16_avi01_dst_devel;
CREATE TABLE translation_devel.ab16_avi01_dst_devel AS
SELECT * FROM translation.ab_avi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab16_avi01_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.ab16_avi01_eco_devel;
CREATE TABLE translation_devel.ab16_avi01_eco_devel AS
SELECT * FROM translation.ab_avi01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab16_avi01_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.ab16_avi01_lyr_devel;
CREATE TABLE translation_devel.ab16_avi01_lyr_devel AS
SELECT * FROM translation.ab_avi01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab16_avi01_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.ab16_avi01_nfl_devel;
CREATE TABLE translation_devel.ab16_avi01_nfl_devel AS
SELECT * FROM translation.ab_avi01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab16_avi01_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.ab16_avi01_geo_devel;
CREATE TABLE translation_devel.ab16_avi01_geo_devel AS
SELECT * FROM translation.ab_avi01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab16_avi01_geo_devel;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Check the uniqueness of AB species codes
-------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_devel', 'ab16_avi01_cas_devel', '_ab16_cas_devel');
SELECT TT_Prepare('translation_devel', 'ab16_avi01_dst_devel', '_ab16_dst_devel');
SELECT TT_Prepare('translation_devel', 'ab16_avi01_eco_devel', '_ab16_eco_devel');
SELECT TT_Prepare('translation_devel', 'ab16_avi01_lyr_devel', '_ab16_lyr_devel');
SELECT TT_Prepare('translation_devel', 'ab16_avi01_nfl_devel', '_ab16_nfl_devel');
SELECT TT_Prepare('translation_devel', 'ab16_avi01_geo_devel', '_ab16_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 200);
SELECT * FROM TT_Translate_ab16_cas_devel('rawfri', 'ab16_l1_to_ab_l1_map_200'); -- 6 s.

SELECT * FROM TT_Translate_ab16_dst_devel('rawfri', 'ab16_l1_to_ab_l1_map_200'); -- 5 s.

SELECT * FROM TT_Translate_ab16_eco_devel('rawfri', 'ab16_l1_to_ab_l1_map_200'); -- 3 s.

SELECT * FROM TT_Translate_ab16_lyr_devel('rawfri', 'ab16_l1_to_ab_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 200);
SELECT * FROM TT_Translate_ab16_lyr_devel('rawfri', 'ab16_l2_to_ab_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'ab16', 3, 'ab', 1, 200);
SELECT * FROM TT_Translate_ab16_nfl_devel('rawfri', 'ab16_l3_to_ab_l1_map_200'); -- 5 s.

SELECT TT_CreateMappingView('rawfri', 'ab16', 4, 'ab', 1, 200);
SELECT * FROM TT_Translate_ab16_nfl_devel('rawfri', 'ab16_l4_to_ab_l1_map_200'); -- 5 s.

SELECT * FROM TT_Translate_ab16_geo_devel('rawfri', 'ab16_l1_to_ab_l1_map_200'); -- 5 s.

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.ogc_fid, a.cas_id, 
       b.density, a.crown_closure_lower, a.crown_closure_upper, 
       b.height, a.height_upper, a.height_lower,
       b.sp1, a.species_1,
       b.sp1_per, a.species_per_1
FROM TT_Translate_ab16_lyr_devel('rawfri', 'ab16_l2_to_ab_l1_map_200') a, rawfri.ab16_l2_to_ab_l1_map_200_lyr b
WHERE ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
