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
-- Usage
--
-- 1) Load the test tables from a command window with load_test_tables.bat.
-- 2) Execute "test_translation.sql" in PostgreSQL (this file).
-- 2) Execute "test_translation.sql" in PostgreSQL (this file)
-- 3) If undesirable changes show up, fix your translation tables.
--    If desirable changes occurs, dump them as new test tables with 
--    dump_test_tables.bat and commit.
--
-- Whole test takes about 3 minutes. You can execute only part of it depending 
-- on which translation tables were modified.
--
-- You can get a detailed summary of the differences between new translated tables
-- and test tables by copying and executing the "check_query" query for a specific table.
-------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_test;
------------------------------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab_cas_test');
SELECT TT_Prepare('translation', 'nb_nbi01_cas', '_nb_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'on_fim02_cas', '_on_cas_test', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'sk_utm01_cas', '_sk_cas_test', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'yt_yvi01_cas', '_yt_cas_test', 'ab_avi01_cas'); 
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_all_new CASCADE;;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 200);
CREATE TABLE casfri50_test.cas_all_new AS 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab06_l1_to_ab_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 400);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab16_l1_to_ab_l1_map_400');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb01_l1_to_nb_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb02_l1_to_nb_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc08_l1_to_bc_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 1000);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc10_l1_to_bc_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt01_l1_to_nt_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt02_l1_to_nt_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 1000);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_on_cas_test('rawfri', 'on02_l1_to_on_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 700);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_cas_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_700');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 600);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_yt_cas_test('rawfri', 'yt02_l1_to_yt_l1_map_600');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_all_new_ordered AS
SELECT * FROM casfri50_test.cas_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
SELECT count(*) FROM casfri50_test.cas_all_new; -- 7100
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab_dst_test');
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_utm01_dst', '_sk_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'yt_yvi01_dst', '_yt_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 1250); -- Generates about 200 (197) DST rows

CREATE TABLE casfri50_test.dst_all_new AS
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab06_l1_to_ab_l1_map_1250');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 5400); -- Generates about 400 (403) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab16_l1_to_ab_l1_map_5400');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 2230); -- Generates about 600 (610) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb01_l1_to_nb_l1_map_2230');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 256000); -- Generates about 600 (607) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb01_l2_to_nb_l1_map_256000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 2010); -- Generates about 600 (610) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb02_l1_to_nb_l1_map_2010');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 4050); -- Generates about 1000 (1031) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc08_l1_to_bc_l1_map_4050');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 3600); -- Generates about 1000 (1016) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc10_l1_to_bc_l1_map_3600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 1870); -- Generates about 500 (536) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt01_l1_to_nt_l1_map_1870');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, 1300); -- Generates about 500 (521) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt02_l1_to_nt_l1_map_1300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1030); -- Generates about 1000 (1015) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_on_dst_test('rawfri', 'on02_l1_to_on_l1_map_1030');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 16500); -- Generates about 700 (703) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_dst_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_16500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 7230); -- Generates about 600 (611) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_yt_dst_test('rawfri', 'yt02_l1_to_yt_l1_map_7230');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_all_new_ordered AS
SELECT * FROM casfri50_test.dst_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
SELECT count(*) FROM casfri50_test.dst_all_new; -- 7860
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab_eco_test');
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 200); -- Generates 0 ECO rows
CREATE TABLE casfri50_test.eco_all_new AS 
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab06_l1_to_ab_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 400); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab16_l1_to_ab_l1_map_400');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 7600); -- Generates about 600 (597) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb01_l1_to_nb_l1_map_7600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 6140); -- Generates about 600 (606) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb02_l1_to_nb_l1_map_6140');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc08_l1_to_bc_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 1000); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc10_l1_to_bc_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt01_l1_to_nt_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 500); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt02_l1_to_nt_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 1000); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_on_eco_test('rawfri', 'on02_l1_to_on_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 700); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_eco_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_700');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 600); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_yt_eco_test('rawfri', 'yt02_l1_to_yt_l1_map_600');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_all_new_ordered AS
SELECT * FROM casfri50_test.eco_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site;
------------------------
SELECT count(*) FROM casfri50_test.eco_all_new; -- 1203
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr_test');
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_lyr_test', 'ab_avi01_lyr'); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 250); -- Generates about 200 (208) LYR rows
CREATE TABLE casfri50_test.lyr_all_new AS 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l1_to_ab_l1_map_250');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 480); -- Generates about 200 (200) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l2_to_ab_l1_map_480');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 460); -- Generates about 400 (414) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l1_to_ab_l1_map_460');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 1070); -- Generates about 400 (421) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l2_to_ab_l1_map_1070');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 730); -- Generates about 600 (607) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l1_to_nb_l1_map_730');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 3520); -- Generates about 600 (618) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l2_to_nb_l1_map_3520');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 900); -- Generates about 600 (598) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l1_to_nb_l1_map_900');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 2200); -- Generates about 600 (627) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l2_to_nb_l1_map_2200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 1170); -- Generates about 1000 (1014) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l1_to_bc_l1_map_1170');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 1120); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l1_to_bc_l1_map_1120');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 1200); -- Issue #362 Generates about 1000 (1061) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l2_to_bc_l1_map_1200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 600); -- Generates about 500 (522) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l1_to_nt_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 15500); -- Generates about 500 (511) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l2_to_nt_l1_map_15500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, 600); -- Generates about 500 (497) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt02_l1_to_nt_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 2000); -- Generates about 500 (504) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt02_l2_to_nt_l1_map_2000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1750); -- Generates about 1000 (1013) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l1_to_on_l1_map_1750');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 1800); -- Issue #362 Generates about 1000 (1032) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l2_to_on_l1_map_1800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 1280); -- Generates about 700 (741) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_lyr_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_1280');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, 80000); -- Issue #362 Generates about 700 (727) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_lyr_test('rawfri', 'sk01_l2_to_sk_utm_l1_map_80000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 1300); -- Generates about 600 (598) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_lyr_test('rawfri', 'yt02_l1_to_yt_l1_map_1300');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_all_new_ordered AS
SELECT * FROM casfri50_test.lyr_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productive_for, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
SELECT count(*) FROM casfri50_test.lyr_all_new; -- 12912
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab_nfl_test');
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 1120); -- Generates about 200 (203) NFL rows
CREATE TABLE casfri50_test.nfl_all_new AS 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l1_to_ab_l1_map_1120');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 1640); -- Generates about 200 (214) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l2_to_ab_l1_map_1640');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 3050); -- Generates about 400 (403) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l1_to_ab_l1_map_3050');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 4200); -- Generates about 400 (406) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l2_to_ab_l1_map_4200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 6250); -- Generates about 600 (620) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb01_l1_to_nb_l1_map_6250');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 4750); -- Generates about 600 (611) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb02_l1_to_nb_l1_map_4750');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 2810); -- Generates about 1000 (995) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l1_to_bc_l1_map_2810');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 2750); -- Generates about 1000 (1004) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l1_to_bc_l1_map_2750');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 3350); -- Generates about 500 (509) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l1_to_nt_l1_map_3350');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 6220); -- Generates about 500 (503) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l2_to_nt_l1_map_6220');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, 3020); -- Generates about 500 (513) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt02_l1_to_nt_l1_map_3020');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 2100); -- Generates about 500 (523) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt02_l2_to_nt_l1_map_2100');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 2450); -- Generates about 1000 (1008) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_on_nfl_test('rawfri', 'on02_l1_to_on_l1_map_2450');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 3130); -- Generates about 700 (724) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_nfl_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_3130');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 1850); -- Generates about 600 (613) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_yt_nfl_test('rawfri', 'yt02_l1_to_yt_l1_map_1850');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_all_new_ordered AS
SELECT * FROM casfri50_test.nfl_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
SELECT count(*) FROM casfri50_test.nfl_all_new; -- 8777
---------------------------------------------------------

---------------------------------------------------------
-- Compare new with old tables
---------------------------------------------------------
SELECT '1.0' number, 
       'Compare "cas_all_new_ordered" and "cas_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''cas_all_test'', ''casfri50_test'' , ''cas_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.cas_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.cas_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.0' number, 
       'Compare "dst_all_new_ordered" and "dst_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''dst_all_test'', ''casfri50_test'' , ''dst_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.dst_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.dst_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.0' number, 
       'Compare "eco_all_new_ordered" and "eco_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''eco_all_test'', ''casfri50_test'' , ''eco_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.eco_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.eco_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.0' number, 
       'Compare "lyr_all_new_ordered" and "lyr_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''lyr_all_test'', ''casfri50_test'' , ''lyr_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.lyr_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.lyr_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.0' number, 
       'Compare "nfl_all_new_ordered" and "nfl_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''nfl_all_test'', ''casfri50_test'' , ''nfl_all_new_ordered'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.nfl_all_new_ordered a 
      FULL OUTER JOIN casfri50_test.nfl_all_test b USING (cas_id, layer)) foo
---------------------------------------------------------