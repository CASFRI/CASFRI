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
SELECT * FROM translation.nt_fvi01_cas; 
SELECT * FROM translation.nt_fvi01_dst; 
SELECT * FROM translation.nt_fvi01_eco; 
SELECT * FROM translation.nt_fvi01_lyr; 
SELECT * FROM translation.nt_fvi01_nfl;
SELECT * FROM translation.nt_fvi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.nt01_fvi01_cas_devel;
CREATE TABLE translation_devel.nt01_fvi01_cas_devel AS
SELECT * FROM translation.nt_fvi01_cas
--WHERE rule_id::int < 1
;
-- display
SELECT * FROM translation_devel.nt01_fvi01_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.nt01_fvi01_dst_devel;
CREATE TABLE translation_devel.nt01_fvi01_dst_devel AS
SELECT * FROM translation.nt_fvi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt01_fvi01_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.nt01_fvi01_eco_devel;
CREATE TABLE translation_devel.nt01_fvi01_eco_devel AS
SELECT * FROM translation.nt_fvi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt01_fvi01_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.nt01_fvi01_lyr_devel;
CREATE TABLE translation_devel.nt01_fvi01_lyr_devel AS
SELECT * FROM translation.nt_fvi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt01_fvi01_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.nt01_fvi01_nfl_devel;
CREATE TABLE translation_devel.nt01_fvi01_nfl_devel AS
SELECT * FROM translation.nt_fvi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt01_fvi01_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.nt01_fvi01_geo_devel;
CREATE TABLE translation_devel.nt01_fvi01_geo_devel AS
SELECT * FROM translation.nt_fvi01_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_devel.nt01_fvi01_geo_devel;

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
SELECT TT_Prepare('translation_devel', 'nt01_fvi01_cas_devel', '_nt01_cas_devel');
SELECT TT_Prepare('translation_devel', 'nt01_fvi01_dst_devel', '_nt01_dst_devel');
SELECT TT_Prepare('translation_devel', 'nt01_fvi01_eco_devel', '_nt01_eco_devel');
SELECT TT_Prepare('translation_devel', 'nt01_fvi01_lyr_devel', '_nt01_lyr_devel');
SELECT TT_Prepare('translation_devel', 'nt01_fvi01_nfl_devel', '_nt01_nfl_devel');
SELECT TT_Prepare('translation_devel', 'nt01_fvi01_geo_devel', '_nt01_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_cas_devel('rawfri', 'nt01_l1_to_nt_l1_map_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_cas_devel');

SELECT * FROM TT_Translate_nt01_dst_devel('rawfri', 'nt01_l1_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_dst_devel');

SELECT * FROM TT_Translate_nt01_eco_devel('rawfri', 'nt01_l1_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_eco_devel');

SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt01_l1_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt01_l2_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt01_l3_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_nfl_devel');

SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt01_l4_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_nfl_devel');

SELECT * FROM TT_Translate_nt01_geo_devel('rawfri', 'nt01_l1_to_nt_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_geo_devel');

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
