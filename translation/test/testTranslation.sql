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
-- 2) Execute "test_translation.sql" in PostgreSQL (this file)
-- 3) If undesirable changes show up in a file diff, fix your translation tables.
--    If desirable changes occurs, dump them as new test tables with 
--    dump_test_tables.bat and commit.
--
-- Whole test takes about 30 minutes. You can execute only part of it depending 
-- on which translation tables were modified.
--
-- You can get a detailed summary of the differences between new translated tables
-- and test tables by copying and executing the content of the "check_query" column
-- (it's a query!) from the final result table. A better, faster way is to dump the 
-- tables with the dump_test_tables.bat and make a diff with the archived tables.
--
-- Some rules of thumb for the number of rows to test for DST, LYR and NFL
-- depending on the number of total source rows:
--
--       1-100000  sources rows -->  200 test rows
--  100000-200000  sources rows -->  300 test rows
--  200000-400000  sources rows -->  400 test rows
--  400000-600000  sources rows -->  500 test rows
--  600000-800000  sources rows -->  600 test rows
--  800000-1000000 sources rows -->  700 test rows
-- 1000000-1500000 sources rows -->  800 test rows
-- 1500000-2000000 sources rows -->  900 test rows
-- 2000000-more    sources rows --> 1000 test rows

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
SELECT TT_Prepare('translation', 'sk_utm01_cas', '_sk_utm_cas_test', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'sk_sfv01_cas', '_sk_sfv_cas_test', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'yt_yvi01_cas', '_yt_cas_test', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'ns_nsi01_cas', '_ns_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'pe_pei01_cas', '_pe_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'mb_fri01_cas', '_mb_fri_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'mb_fli01_cas', '_mb_fli_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'nl_nli01_cas', '_nl_nli_cas_test', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_all_new CASCADE;
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
SELECT * FROM TT_Translate_sk_utm_cas_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_700');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', 200);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', 200);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', 300);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 600);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_yt_cas_test('rawfri', 'yt02_l1_to_yt_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 800);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', 300);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_pe_cas_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', 500);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fri_cas_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', 300);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 900);
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nl_nli_cas_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_900');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_all_new_ordered AS
SELECT * FROM casfri50_test.cas_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
SELECT count(*) FROM casfri50_test.cas_all_new; -- 11600, 26m
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab_dst_test');
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_utm01_dst', '_sk_utm_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk_sfv_dst_test', 'ab_avi01_dst'); 
SELECT TT_Prepare('translation', 'yt_yvi01_dst', '_yt_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'ns_nsi01_dst', '_ns_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'pe_pei01_dst', '_pe_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fri01_dst', '_mb_fri_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fli01_dst', '_mb_fli_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nl_nli01_dst', '_nl_nli_dst_test', 'ab_avi01_dst');
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
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 3600); -- Generates about 1000 (1016) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc08_l1_to_bc_l1_map_3600');
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
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1800); -- Generates about 1000 (985) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_on_dst_test('rawfri', 'on02_l1_to_on_l1_map_1800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 16500); -- Generates about 700 (703) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_utm_dst_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_16500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 650); -- Generates about 200 (198) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_650');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 7800); -- Generates about 200 (206) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_7800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 3400); -- Generates about 500 (505) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_3400');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 3600); -- Generates about 500 (517) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_3600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 1500); -- Generates about 300 (302) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_1500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 7230); -- Generates about 600 (611) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_yt_dst_test('rawfri', 'yt02_l1_to_yt_l1_map_7230');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 7230); -- Generates about 600 (611) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_7230');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 7230); -- Generates about 600 (611) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_pe_dst_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_7230');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 1000); -- Generates 0 DST rows. No DST info to translate
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fri_dst_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_1000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 1200); -- Generates about 300 (301) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_1200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 20000); -- Generates about 900 (955) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_nl_nli_dst_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_20000');
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
SELECT count(*) FROM casfri50_test.dst_all_new; -- 13116, 23m
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab_eco_test');
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_utm_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk_sfv_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'ns_nsi01_eco', '_ns_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pe_pei01_eco', '_pe_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fri01_eco', '_mb_fri_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fli01_eco', '_mb_fli_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nl_nli01_eco', '_nl_nli_eco_test', 'ab_avi01_eco');
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
SELECT * FROM TT_Translate_sk_utm_eco_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_700');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', 200); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', 200); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 500); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 500); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', 300); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 600); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_yt_eco_test('rawfri', 'yt02_l1_to_yt_l1_map_600');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 800); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', 300); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pe_eco_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', 300); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fri_eco_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', 300); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 900); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_nl_nli_eco_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_900');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_all_new_ordered AS
SELECT * FROM casfri50_test.eco_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site;
------------------------
SELECT count(*) FROM casfri50_test.eco_all_new; -- 1467, 2m
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr_test');
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_utm_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk_sfv_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'ns_nsi01_lyr', '_ns_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'pe_pei01_lyr', '_pe_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'mb_fri01_lyr', '_mb_fri_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'mb_fli01_lyr', '_mb_fli_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'nl_nli01_lyr', '_nl_nli_lyr_test', 'ab_avi01_lyr'); 
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
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 1120); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l1_to_bc_l1_map_1120');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, 30000); -- Generates about 1000 (1001) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l2_to_bc_l1_map_30000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 1120); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l1_to_bc_l1_map_1120');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 30000); -- Generates about 1000 (1001) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l2_to_bc_l1_map_30000');
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
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1750); -- Generates about 1000 (1007) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l1_to_on_l1_map_1750');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 22200); -- Generates about 1000 (1038) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l2_to_on_l1_map_22200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 1280); -- Generates about 700 (741) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_1280');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, 80000); -- Generates about 700 (727) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l2_to_sk_utm_l1_map_80000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 230); -- Generates about 200 (210) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_230');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1, 1200); -- Generates about 200 (218) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l2_to_sk_sfv_l1_map_1200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1, 27000); -- Generates about 200 (165) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l3_to_sk_sfv_l1_map_27000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 240); -- Generates about 200 (198) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_240');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1, 500); -- Generates about 200 (192) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l2_to_sk_sfv_l1_map_500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1, 8900); -- Generates about 200 (14) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l3_to_sk_sfv_l1_map_8900');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 580); -- Generates about 500 (517) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_580');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, 2050); -- Generates about 500 (498) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l2_to_sk_sfv_l1_map_2050');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, 90000); -- Generates about 500 (512) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l3_to_sk_sfv_l1_map_90000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 570); -- Generates about 500 (526) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_570');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, 2000); -- Generates about 500 (509) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l2_to_sk_sfv_l1_map_2000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, 134500); -- Generates about 500 (507) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l3_to_sk_sfv_l1_map_134500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 350); -- Generates about 300 (296) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_350');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 2, 'sk_sfv', 1, 650); -- Generates about 300 (314) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l2_to_sk_sfv_l1_map_650');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 3, 'sk_sfv', 1, 6000); -- Generates about 300 (301) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l3_to_sk_sfv_l1_map_6000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 1300); -- Generates about 600 (598) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_lyr_test('rawfri', 'yt02_l1_to_yt_l1_map_1300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 1070); -- Generates about 800 (780) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_1070');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, 3300); -- Generates about 800 (805) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l2_to_ns_nsi_l1_map_3300');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 400); -- Generates about 300 (300) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_400');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 1100); -- Generates about 300 (300) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fri_lyr_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_1100'); -- Generates about 500 (508) LYR rows
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 350); -- Generates about 300 (316) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_350');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb_fli', 1, 800); -- Generates about 300 (296) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l2_to_mb_fli_l1_map_800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 3, 'mb_fli', 1, 5000); -- Generates about 300 (255) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l3_to_mb_fli_l1_map_5000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 4, 'mb_fli', 1); -- Generates 107 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l4_to_mb_fli_l1_map');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 5, 'mb_fli', 1); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l5_to_mb_fli_l1_map');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 2000); -- Generates 900 (901) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nl_nli_lyr_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_2000');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_all_new_ordered AS
SELECT * FROM casfri50_test.lyr_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
SELECT count(*) FROM casfri50_test.lyr_all_new; -- 23135, 2h26
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab_nfl_test');
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_utm_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk_sfv_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'ns_nsi01_nfl', '_ns_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pe_pei01_nfl', '_pe_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'mb_fri01_nfl', '_mb_fri_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'mb_fli01_nfl', '_mb_fli_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'nl_nli01_nfl', '_nl_nli_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 3, 'ab', 1, 1120); -- Generates about 200 (203) NFL rows
CREATE TABLE casfri50_test.nfl_all_new AS 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l3_to_ab_l1_map_1120');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 4, 'ab', 1, 1700); -- Generates about 200 (206) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l4_to_ab_l1_map_1700');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 3, 'ab', 1, 3200); -- Generates about 400 (399) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l3_to_ab_l1_map_3200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 4, 'ab', 1, 4100); -- Generates about 400 (407) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l4_to_ab_l1_map_4100');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1, 7280); -- Generates about 600 (604) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb01_l3_to_nb_l1_map_7280');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 3, 'nb', 1, 4750); -- Generates about 600 (602) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb02_l3_to_nb_l1_map_4750');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, 4800); -- Generates about 1000 (1031) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l3_to_bc_l1_map_4800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, 16000); -- Generates about 1000 (1039) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l4_to_bc_l1_map_16000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 5, 'bc', 1, 6200); -- Generates about 1000 (1042) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l5_to_bc_l1_map_6200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1, 4800); -- Generates about 1000 (1031) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l3_to_bc_l1_map_4800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1, 16000); -- Generates about 1000 (1039) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l4_to_bc_l1_map_16000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1, 6200); -- Generates about 1000 (1042) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l5_to_bc_l1_map_6200');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1, 3350); -- Generates about 500 (509) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l3_to_nt_l1_map_3350');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1, 6220); -- Generates about 500 (503) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l4_to_nt_l1_map_6220');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 3, 'nt', 1, 3020); -- Generates about 500 (513) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt02_l3_to_nt_l1_map_3020');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 4, 'nt', 1, 2100); -- Generates about 500 (523) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt02_l4_to_nt_l1_map_2100');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 3, 'on', 1, 2450); -- Generates about 1000 (1005) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_on_nfl_test('rawfri', 'on02_l3_to_on_l1_map_2450');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, 3130); -- Generates about 700 (724) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_utm_nfl_test('rawfri', 'sk01_l3_to_sk_utm_l1_map_3130');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 4, 'sk_sfv', 1, 540); -- Generates about 200 (205) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l4_to_sk_sfv_l1_map_540');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 5, 'sk_sfv', 1, 800); -- Generates about 200 (192) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l5_to_sk_sfv_l1_map_800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1, 9000); -- Generates about 200 (211) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l6_to_sk_sfv_l1_map_9000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1, 450); -- Generates about 200 (196) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l4_to_sk_sfv_l1_map_450');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1, 800); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l5_to_sk_sfv_l1_map_800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1, 2800); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l6_to_sk_sfv_l1_map_2800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 4, 'sk_sfv', 1, 1800); -- Generates about 500 (508) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l4_to_sk_sfv_l1_map_1800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 5, 'sk_sfv', 1, 3500); -- Generates about 500 (501) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l5_to_sk_sfv_l1_map_3500');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 6, 'sk_sfv', 1, 7900); -- Generates about 500 (491) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l6_to_sk_sfv_l1_map_7900');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, 1800); -- Generates about 500 (492) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l4_to_sk_sfv_l1_map_1800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, 4000); -- Generates about 500 (491) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l5_to_sk_sfv_l1_map_4000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, 14000); -- Generates about 500 (505) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l6_to_sk_sfv_l1_map_14000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 4, 'sk_sfv', 1, 1150); -- Generates about 300 (306) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l4_to_sk_sfv_l1_map_1150');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 5, 'sk_sfv', 1, 3120); -- Generates about 300 (293) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l5_to_sk_sfv_l1_map_3120');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 6, 'sk_sfv', 1, 35000); -- Generates about 300 (312) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l6_to_sk_sfv_l1_map_35000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 2, 'yt', 1, 1850); -- Generates about 600 (613) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_yt_nfl_test('rawfri', 'yt02_l2_to_yt_l1_map_1850');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 3, 'ns_nsi', 1, 3800); -- Generates about 800 (797) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ns_nfl_test('rawfri', 'ns03_l3_to_ns_nsi_l1_map_3800');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 2, 'pe_pei', 1, 1420); -- Generates about 300 (309) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_pe_nfl_test('rawfri', 'pe01_l2_to_pe_pei_l1_map_1420');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 2, 'mb_fri', 1, 1250); -- Generates about 500 (479) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_mb_fri_nfl_test('rawfri', 'mb05_l2_to_mb_fri_l1_map_1250');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 6, 'mb_fli', 1, 5000); -- Generates about 300 (298) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_mb_fli_nfl_test('rawfri', 'mb06_l6_to_mb_fli_l1_map_5000');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 2450); -- Generates about 900 (881) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nl_nli_nfl_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_2450');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_all_new_ordered AS
SELECT * FROM casfri50_test.nfl_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
SELECT count(*) FROM casfri50_test.nfl_all_new; -- 20374, 38m
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