------------------------------------------------------------------------------
-- CASFRI - PC02 translation development script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
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
SELECT * FROM TT_Translate_pc02_cas_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200');

-- DST ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_dst;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_dst_devel;
CREATE TABLE translation_devel.pc02_wbnp01_dst_devel AS
SELECT * FROM translation.pc_wbnp01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc02_wbnp01_dst_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_dst_devel', '_pc02_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_dst_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map'); -- 4 s.

SELECT a.cas_id, b.dist_type_1, a.dist_type_1, a.dist_type_2 
FROM TT_Translate_pc02_dst_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200') a, rawfri.pc02_l1_to_pc_wbnp_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

-- LYR ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_lyr;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_lyr_devel;
CREATE TABLE translation_devel.pc02_wbnp01_lyr_devel AS
SELECT * FROM translation.pc_wbnp01_lyr;
--WHERE rule_id::int < 21;
SELECT * FROM translation_devel.pc02_wbnp01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_lyr_devel', '_pc02_lyr_devel');
--Layer 1
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map');
--Layer 2
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l2_to_pc_wbnp_l1_map');
--Layer 3
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l3_to_pc_wbnp_l1_map');
--Layer 4
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_200');
--Layer 5
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_200');
--Layer 6
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_200');
--Layer 7 (Empty)
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_lyr_devel('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_200');

-- NFL ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_nfl;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_nfl_devel;
CREATE TABLE translation_devel.pc02_wbnp01_nfl_devel AS
SELECT * FROM translation.pc_wbnp01_nfl; --WHERE rule_id::int != 4; --IN (0,1,2,3);
SELECT * FROM translation_devel.pc02_wbnp01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_nfl_devel', '_pc02_nfl_devel');
-- Layer 8
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 1000);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_1000');
-- Layer 9
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_200');
--Layer 10
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_200');
--Layer 11
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_200');
-- Layer 12
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_200');
--Layer 13
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_200');
--Layer 14
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_200');
--Layer 15
SELECT TT_CreateMappingView('rawfri', 'pc02', 15, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_nfl_devel('rawfri', 'pc02_l15_to_pc_wbnp_l1_map');


-- ECO ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_eco;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_eco_devel;
CREATE TABLE translation_devel.pc02_wbnp01_eco_devel AS
SELECT * FROM translation.pc_wbnp01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc02_wbnp01_eco_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_eco_devel', '_pc02_eco_devel');

-- layer 1 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map'); -- 4 s.
--layer 2 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l2_to_pc_wbnp_l1_map'); -- 4 s.
--layer 3 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l3_to_pc_wbnp_l1_map'); -- 4 s.
--layer 4 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l4_to_pc_wbnp_l1_map'); -- 4 s.
--layer 5 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l5_to_pc_wbnp_l1_map'); -- 4 s.
--layer 6 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l6_to_pc_wbnp_l1_map'); -- 4 s.
--layer 7 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l7_to_pc_wbnp_l1_map'); -- 4 s.
--layer 8 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l8_to_pc_wbnp_l1_map'); -- 4 s.
--layer 9 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l9_to_pc_wbnp_l1_map'); -- 4 s.
--layer 10 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l10_to_pc_wbnp_l1_map'); -- 4 s.
--layer 11 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l11_to_pc_wbnp_l1_map'); -- 4 s.
--layer 12 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l12_to_pc_wbnp_l1_map'); -- 4 s.
--layer 13 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l13_to_pc_wbnp_l1_map'); -- 4 s.
--layer 14 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1);
SELECT * FROM TT_Translate_pc02_eco_devel('rawfri', 'pc02_l14_to_pc_wbnp_l1_map'); -- 4 s.


-- GEO ATTRIBUTES
SELECT * FROM translation.pc_wbnp01_geo;
DROP TABLE IF EXISTS translation_devel.pc02_wbnp01_geo_devel;
CREATE TABLE translation_devel.pc02_wbnp01_geo_devel AS
SELECT * FROM translation.pc_wbnp01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc02_wbnp01_geo_devel;
SELECT TT_Prepare('translation_devel', 'pc02_wbnp01_geo_devel', '_pc02_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 200);
SELECT * FROM TT_Translate_pc02_geo_devel('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200'); -- 4 s.


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
