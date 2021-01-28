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
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Check the uniqueness of PE species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (pc02_species_codes)
WHERE TT_NotEmpty(pc02_species_codes);

--SELECT TT_DeleteAllViews('rawfri');

-- CAS ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_cas;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_cas_devel;
CREATE TABLE translation_devel.pc02_wbnp01_cas_devel AS
SELECT * FROM translation.pc_wbnp01_cas;
--WHERE rule_id::int < 2;

SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_cas_devel', '_pc02_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 'pc_wbnp', 200);
SELECT * FROM translation_devel.pc02_wbnp01_cas_devel;
SELECT * FROM TT_Translate_pc02_cas_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc_wbnp01_cas_devel');

-- DST ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_dst;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_dst_devel;
CREATE TABLE translation_devel.pc02_wbnp01_dst_devel AS
SELECT * FROM translation.pc_wbnp01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc02_wbnp01_dst_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_dst_devel', '_pc02_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_dst_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc_wbnp01_dst_devel');

SELECT a.cas_id, b.dist_type_1, a.dist_type_1, a.dist_type_2 
FROM TT_Translate_pc02_dst_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200') a, rawfri.pc02_l1_to_pc_wbnp_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

-- LYR1 ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_lyr;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_lyr_devel;
CREATE TABLE translation_devel.pc02_wbnp01_lyr_devel AS
SELECT * FROM translation.pc_wbnp01_lyr;
--WHERE rule_id::int < 21;
SELECT * FROM translation_devel.pc02_wbnp01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_lyr_devel', '_pc02_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');
--Layer 2
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');
--Layer 3
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');
--Layer 4
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');
--Layer 5
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');
--Layer 6
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');
--Layer 7 (Empty)
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_lyr_devel');

-- NFL ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_nfl;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_nfl_devel;
CREATE TABLE translation_devel.pc02_wbnp01_nfl_devel AS
SELECT * FROM translation.pc_wbnp01_nfl; --WHERE rule_id::int != 4; --IN (0,1,2,3);
SELECT * FROM translation_devel.pc02_wbnp01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_nfl_devel', '_pc02_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 1000);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_1000', 'ogc_fid');
-- Layer 9
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_200', 'ogc_fid');
--Layer 10
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_200', 'ogc_fid');
--Layer 11
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_200', 'ogc_fid');
-- Layer 12
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_200', 'ogc_fid');
--Layer 13
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_200', 'ogc_fid');
--Layer 14
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_200', 'ogc_fid');
--Layer 15
SELECT TT_CreateMappingView('rawfri', 'pc02', 15, 'pc_wbnp', 1, 1053);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l15_to_pc_wbnp_l1_map_1053', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_nfl_devel');

-- ECO ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_eco;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_eco_devel;
CREATE TABLE translation_devel.pc02_wbnp01_eco_devel AS
SELECT * FROM translation.pc_wbnp01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc02_wbnp01_eco_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_eco_devel', '_pc02_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');
--layer 2
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');
--layer 3
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');
--layer 4
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');
--layer 5
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');
--layer 6
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');
--layer 7
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_eco_devel');

-- GEO ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_geo;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_geo_devel;
CREATE TABLE translation_devel.pc02_wbnp01_geo_devel AS
SELECT * FROM translation.pc_wbnp01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc02_wbnp01_geo_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_geo_devel', '_pc02_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_geo_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'pc02_wbnp01_geo_devel');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_pe01_lyr_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200') a, rawfri.pc02_l1_to_pc_wbnp_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
