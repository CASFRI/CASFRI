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
SELECT TT_DeleteAllViews('rawfri');

-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- CAS ATTRIBUTES
SELECT * FROM translation.sk_sfv01_cas;
DROP TABLE IF EXISTS translation_devel.sk05_sfv01_cas_devel;
CREATE TABLE translation_devel.sk05_sfv01_cas_devel AS
SELECT * FROM translation.sk_sfv01_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk05_sfv01_cas_devel;
SELECT TT_Prepare('translation_devel', 'sk05_sfv01_cas_devel', '_sk05_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 200);
SELECT * FROM TT_Translate_sk05_cas_devel('rawfri', 'sk05_l1_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_cas_devel');

-- LYR1 ATTRIBUTES
SELECT * FROM translation.sk_sfv01_lyr;
DROP TABLE IF EXISTS translation_devel.sk05_sfv01_lyr_devel;
CREATE TABLE translation_devel.sk05_sfv01_lyr_devel AS
SELECT * FROM translation.sk_sfv01_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk05_sfv01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'sk05_sfv01_lyr_devel', '_sk05_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_lyr_devel('rawfri', 'sk05_l1_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_lyr_devel');

-- LYR2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_lyr_devel('rawfri', 'sk05_l2_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_lyr_devel');

-- LYR3 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_lyr_devel('rawfri', 'sk05_l3_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_lyr_devel');

-- NFL1 ATTRIBUTES
SELECT * FROM translation.sk_sfv01_nfl;
DROP TABLE IF EXISTS translation_devel.sk05_sfv01_nfl_devel;
CREATE TABLE translation_devel.sk05_sfv01_nfl_devel AS
SELECT * FROM translation.sk_sfv01_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk05_sfv01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'sk05_sfv01_nfl_devel', '_sk05_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_nfl_devel('rawfri', 'sk05_l4_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_nfl_devel');

-- NFL2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_nfl_devel('rawfri', 'sk05_l5_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_lyr_devel');

-- NFL3 ATTRIBUTES - layer 6 can either be nat_non_veg or non_for_anth, not both.
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_nfl_devel('rawfri', 'sk05_l6_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_lyr_devel');

-- DST ATTRIBUTES
SELECT * FROM translation.sk_sfv01_dst;
DROP TABLE IF EXISTS translation_devel.sk05_sfv01_dst_devel;
CREATE TABLE translation_devel.sk05_sfv01_dst_devel AS
SELECT * FROM translation.sk_sfv01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk05_sfv01_dst_devel;
SELECT TT_Prepare('translation_devel', 'sk05_sfv01_dst_devel', '_sk05_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk05_dst_devel('rawfri', 'sk05_l1_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_dst_devel');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT a.cas_id, b.nvsl, b.aquatic_class, b.luc, b.transp_class, b.shrub1, b.herb1, a.nat_non_veg, a.non_for_anth, a.non_for_veg
FROM TT_Translate_sk02_nfl_devel('rawfri', 'sk02_l1_to_sk_sfv_l1_map_200') a, rawfri.sk02_l1_to_sk_sfv_l1_map_200_nfl b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

-- ECO ATTRIBUTES
SELECT * FROM translation.sk_sfv01_eco;
DROP TABLE IF EXISTS translation_devel.sk05_sfv01_eco_devel;
CREATE TABLE translation_devel.sk05_sfv01_eco_devel AS
SELECT * FROM translation.sk_sfv01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk05_sfv01_eco_devel;
SELECT TT_Prepare('translation_devel', 'sk05_sfv01_eco_devel', '_sk05_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 200);
SELECT * FROM TT_Translate_sk05_eco_devel('rawfri', 'sk05_l1_to_sk_sfv_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_eco_devel');


-- GEO ATTRIBUTES
SELECT * FROM translation.sk_sfv01_geo;
DROP TABLE IF EXISTS translation_devel.sk05_sfv01_geo_devel;
CREATE TABLE translation_devel.sk05_sfv01_geo_devel AS
SELECT * FROM translation.sk_sfv01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk05_sfv01_geo_devel;
SELECT TT_Prepare('translation_devel', 'sk05_sfv01_geo_devel', '_sk05_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 200);
SELECT * FROM TT_Translate_sk05_geo_devel('rawfri', 'sk05_l1_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk05_sfv01_geo_devel');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1_crown_closure, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1_height, a.height_upper, a.height_lower, 
       b.l1_sp1, a.species_1,
       b.l1_sp1_cover, a.species_per_1
FROM TT_Translate_sk05_lyr_devel('rawfri', 'sk05_l1_to_sk_sfv_l1_map_200') a, rawfri.sk05_l1_to_sk_sfv_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
