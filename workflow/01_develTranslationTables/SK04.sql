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


-- Validate species dependency tables
SELECT TT_Prepare('translation', 'sk_sfv01_species_validation', '_sk_species_val');
SELECT * FROM TT_Translate_sk_species_val('translation', 'sk_sfv01_species');


-- CAS ATTRIBUTES
SELECT * FROM translation.sk_sfv01_cas;
DROP TABLE IF EXISTS translation_devel.sk04_sfv01_cas_devel;
CREATE TABLE translation_devel.sk04_sfv01_cas_devel AS
SELECT * FROM translation.sk_sfv01_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk04_sfv01_cas_devel;
SELECT TT_Prepare('translation_devel', 'sk04_sfv01_cas_devel', '_sk04_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 200);
SELECT * FROM TT_Translate_sk04_cas_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_cas_devel');

-- LYR1 ATTRIBUTES
SELECT * FROM translation.sk_sfv01_lyr;
DROP TABLE IF EXISTS translation_devel.sk04_sfv01_lyr_devel;
CREATE TABLE translation_devel.sk04_sfv01_lyr_devel AS
SELECT * FROM translation.sk_sfv01_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk04_sfv01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'sk04_sfv01_lyr_devel', '_sk04_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 200, 'lyr');
SELECT * FROM TT_Translate_sk04_lyr_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_lyr_devel');

-- LYR2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, 200, 'lyr');
SELECT * FROM TT_Translate_sk04_lyr_devel('rawfri', 'sk04_l2_to_sk_sfv_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_lyr_devel');

-- LYR3 ATTRIBUTES
-- ERROR: ERROR TT_RandomInt(): nb (200) must be smaller or equal to the range of values (165)...
-- FIXED: BY REDUCING SAMPLE FROM 200 TO 100
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, 100, 'lyr');
SELECT * FROM TT_Translate_sk04_lyr_devel('rawfri', 'sk04_l3_to_sk_sfv_l1_map_100_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_lyr_devel');

-- DST ATTRIBUTES
SELECT * FROM translation.sk_sfv01_dst;
DROP TABLE IF EXISTS translation_devel.sk04_sfv01_dst_devel;
CREATE TABLE translation_devel.sk04_sfv01_dst_devel AS
SELECT * FROM translation.sk_sfv01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk04_sfv01_dst_devel;
SELECT TT_Prepare('translation_devel', 'sk04_sfv01_dst_devel', '_sk04_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 200, 'dst');
SELECT * FROM TT_Translate_sk04_dst_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200_dst', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_dst_devel');

-- NFL ATTRIBUTES
SELECT * FROM translation.sk_sfv01_nfl;
DROP TABLE IF EXISTS translation_devel.sk04_sfv01_nfl_devel;
CREATE TABLE translation_devel.sk04_sfv01_nfl_devel AS
SELECT * FROM translation.sk_sfv01_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk04_sfv01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'sk04_sfv01_nfl_devel', '_sk04_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 200, 'nfl');
SELECT * FROM rawfri.sk04_l1_to_sk_sfv_l1_map_200_nfl; -- view source table
SELECT * FROM TT_Translate_sk04_nfl_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200_nfl', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_nfl_devel');

SELECT count(*), nvsl, aquatic_class, CONCAT(nvsl,aquatic_class) FROM rawfri.sk04 GROUP BY nvsl, aquatic_class;

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT a.cas_id, b.nvsl, b.aquatic_class, b.luc, b.transp_class, b.shrub1, b.herb1, a.nat_non_veg, a.non_for_anth, a.non_for_veg
FROM TT_Translate_sk02_nfl_devel('rawfri', 'sk02_l1_to_sk_sfv_l1_map_200_nfl') a, rawfri.sk02_l1_to_sk_sfv_l1_map_200_nfl b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

-- ECO ATTRIBUTES
SELECT * FROM translation.sk_sfv01_eco;
DROP TABLE IF EXISTS translation_devel.sk04_sfv01_eco_devel;
CREATE TABLE translation_devel.sk04_sfv01_eco_devel AS
SELECT * FROM translation.sk_sfv01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk04_sfv01_eco_devel;
SELECT TT_Prepare('translation_devel', 'sk04_sfv01_eco_devel', '_sk04_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 200, 'eco');
SELECT * FROM TT_Translate_sk04_eco_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200_eco', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_eco_devel');


-- GEO ATTRIBUTES
SELECT * FROM translation.sk_sfv01_geo;
DROP TABLE IF EXISTS translation_devel.sk04_sfv01_geo_devel;
CREATE TABLE translation_devel.sk04_sfv01_geo_devel AS
SELECT * FROM translation.sk_sfv01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk04_sfv01_geo_devel;
SELECT TT_Prepare('translation_devel', 'sk04_sfv01_geo_devel', '_sk04_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 200); --, 'geo');
SELECT * FROM TT_Translate_sk04_geo_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk04_sfv01_geo_devel');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1_crown_closure, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1_height, a.height_upper, a.height_lower, 
       b.l1_sp1, a.species_1,
       b.l1_sp1_cover, a.species_per_1
FROM TT_Translate_sk04_lyr_devel('rawfri', 'sk04_l1_to_sk_sfv_l1_map_200') a, rawfri.sk04_l1_to_sk_sfv_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');