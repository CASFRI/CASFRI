------------------------------------------------------------------------------
-- CASFRI Sample workflow file for CASFRI v4 beta
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
SELECT * FROM translation.qc_ini04_cas; 
SELECT * FROM translation.qc_ini04_dst; 
SELECT * FROM translation.qc_ini04_eco; 
SELECT * FROM translation.qc_ini04_lyr; 
SELECT * FROM translation.qc_ini04_nfl;
SELECT * FROM translation.qc_ini04_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.qc06_ini04_cas_devel;
CREATE TABLE translation_devel.qc06_ini04_cas_devel AS
SELECT * FROM translation.qc_ini04_cas
--WHERE rule_id::int < 1
;
-- display
SELECT * FROM translation_devel.qc06_ini04_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.qc06_ini04_dst_devel;
CREATE TABLE translation_devel.qc06_ini04_dst_devel AS
SELECT * FROM translation.qc_ini04_dst
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_devel.qc04_ini04_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.qc06_ini04_eco_devel;
CREATE TABLE translation_devel.qc06_ini04_eco_devel AS
SELECT * FROM translation.qc_ini04_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.qc06_ini04_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.qc06_ini04_lyr_devel;
CREATE TABLE translation_devel.qc06_ini04_lyr_devel AS
SELECT * FROM translation.qc_ini04_lyr
--WHERE rule_id::int >12 AND rule_id::int <19
;
-- display
SELECT * FROM translation_devel.qc04_ini04_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.qc06_ini04_nfl_devel;
CREATE TABLE translation_devel.qc06_ini04_nfl_devel AS
SELECT * FROM translation.qc_ini04_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.qc06_ini04_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.qc06_ini04_geo_devel;
CREATE TABLE translation_devel.qc06_ini04_geo_devel AS
SELECT * FROM translation.qc_ini04_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_devel.qc06_ini04_geo_devel;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Check the uniqueness of QC species codes
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_devel', 'qc06_ini04_cas_devel', '_qc06_cas_devel');
SELECT TT_Prepare('translation_devel', 'qc06_ini04_dst_devel', '_qc06_dst_devel');
SELECT TT_Prepare('translation_devel', 'qc06_ini04_eco_devel', '_qc06_eco_devel');
SELECT TT_Prepare('translation_devel', 'qc06_ini04_lyr_devel', '_qc06_lyr_devel');
SELECT TT_Prepare('translation_devel', 'qc06_ini04_nfl_devel', '_qc06_nfl_devel');
SELECT TT_Prepare('translation_devel', 'qc06_ini04_geo_devel', '_qc06_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, 200);
SELECT * FROM TT_Translate_qc06_cas_devel('rawfri', 'qc06_l1_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_cas_devel', 'qc06_l1_to_qc_ini04_l1_map_200');

SELECT * FROM TT_Translate_qc06_dst_devel('rawfri', 'qc06_l1_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_dst_devel', 'qc06_l1_to_qc_ini04_l1_map_200');

SELECT * FROM TT_Translate_qc06_eco_devel('rawfri', 'qc06_l1_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_eco_devel', 'qc06_l1_to_qc_ini04_l1_map_200');
--Layer 1
SELECT * FROM TT_Translate_qc06_lyr_devel('rawfri', 'qc06_l1_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_lyr_devel', 'qc06_l1_to_qc_ini04_l1_map_200');
--Layer 2
SELECT TT_CreateMappingView('rawfri', 'qc06', 2, 'qc_ini04', 1, 200);
SELECT * FROM TT_Translate_qc06_lyr_devel('rawfri', 'qc06_l2_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_lyr_devel', 'qc06_l2_to_qc_ini04_l1_map_200');

-- LYR layer 2 doesn't exist in QC04
SELECT TT_CreateMappingView('rawfri', 'qc06', 2, 'qc_ini04', 1, 20000);
SELECT * FROM TT_Translate_qc06_lyr_devel('rawfri', 'qc06_l2_to_qc_ini04_l1_map_20000', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_lyr_devel', 'qc06_l2_to_qc_ini04_l1_map_20000');

SELECT TT_CreateMappingView('rawfri', 'qc06', 3, 'qc_ini04', 1, 200);
SELECT * FROM TT_Translate_qc06_nfl_devel('rawfri', 'qc06_l3_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_nfl_devel', 'qc06_l3_to_qc_ini04_l1_map_200');

SELECT * FROM TT_Translate_qc06_geo_devel('rawfri', 'qc06_l1_to_qc_ini04_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc06_ini04_geo_devel', 'qc06_l1_to_qc_ini04_l1_map_200');

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
