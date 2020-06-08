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
SELECT * FROM translation.bc_vri01_cas; 
SELECT * FROM translation.bc_vri01_dst; 
SELECT * FROM translation.bc_vri01_eco; 
SELECT * FROM translation.bc_vri01_lyr; 
SELECT * FROM translation.bc_vri01_nfl;
SELECT * FROM translation.bc_vri01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.bc10_vri01_cas_devel;
CREATE TABLE translation_devel.bc10_vri01_cas_devel AS
SELECT * FROM translation.bc_vri01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc10_vri01_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.bc10_vri01_dst_devel;
CREATE TABLE translation_devel.bc10_vri01_dst_devel AS
SELECT * FROM translation.bc_vri01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc10_vri01_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.bc10_vri01_eco_devel;
CREATE TABLE translation_devel.bc10_vri01_eco_devel AS
SELECT * FROM translation.bc_vri01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc10_vri01_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.bc10_vri01_lyr_devel;
CREATE TABLE translation_devel.bc10_vri01_lyr_devel AS
SELECT * FROM translation.bc_vri01_lyr
--WHERE rule_id::int = 34
;
-- Display
SELECT * FROM translation_devel.bc10_vri01_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.bc10_vri01_nfl_devel;
CREATE TABLE translation_devel.bc10_vri01_nfl_devel AS
SELECT * FROM translation.bc_vri01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc10_vri01_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.bc10_vri01_geo_devel;
CREATE TABLE translation_devel.bc10_vri01_geo_devel AS
SELECT * FROM translation.bc_vri01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc10_vri01_geo_devel;

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
SELECT TT_Prepare('translation_devel', 'bc10_vri01_cas_devel', '_bc10_cas_devel');
SELECT TT_Prepare('translation_devel', 'bc10_vri01_dst_devel', '_bc10_dst_devel');
SELECT TT_Prepare('translation_devel', 'bc10_vri01_eco_devel', '_bc10_eco_devel');
SELECT TT_Prepare('translation_devel', 'bc10_vri01_lyr_devel', '_bc10_lyr_devel');
SELECT TT_Prepare('translation_devel', 'bc10_vri01_nfl_devel', '_bc10_nfl_devel');
SELECT TT_Prepare('translation_devel', 'bc10_vri01_geo_devel', '_bc10_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 200);
SELECT * FROM TT_Translate_bc10_cas_devel('rawfri', 'bc10_l1_to_bc_l1_map_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_cas_devel');

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 200);
SELECT * FROM TT_Translate_bc10_dst_devel('rawfri', 'bc10_l1_to_bc_l1_map_200_dst', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_dst_devel');

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 200);
SELECT * FROM TT_Translate_bc10_eco_devel('rawfri', 'bc10_l1_to_bc_l1_map_200_eco', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_eco_devel');

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 200);
SELECT * FROM TT_Translate_bc10_lyr_devel('rawfri', 'bc10_l1_to_bc_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 200);
SELECT * FROM TT_Translate_bc10_lyr_devel('rawfri', 'bc10_l2_to_bc_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 200);
SELECT * FROM TT_Translate_bc10_nfl_devel('rawfri', 'bc10_l1_to_bc_l1_map_200_nfl', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_nfl_devel');

SELECT * FROM TT_Translate_bc10_geo_devel('rawfri', 'bc10_l1_to_bc_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc10_vri01_geo_devel');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.map_id, b.ogc_fid, a.cas_id, 
       b.crown_closure, a.crown_closure_lower, a.crown_closure_upper, 
       b.proj_height_1, a.height_upper, a.height_lower,
       b.species_cd_1, a.species_1,
       b.species_pct_1, a.species_per_1
FROM TT_Translate_bc10_lyr_devel('rawfri', 'bc10_l1_to_bc_l1_map_200') a, rawfri.bc10_l1_to_bc_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
