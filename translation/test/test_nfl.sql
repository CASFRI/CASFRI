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
SELECT TT_Prepare('translation', 'qc_ini03_nfl', '_qc_ini03_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ini04_nfl', '_qc_ini04_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ipf05_nfl', '_qc_ipf05_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pc_panp01_nfl', '_pc_panp_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 3, 'ab', 1, 1120, NULL, 'nfl'); -- Generates about 200 (198) NFL rows
CREATE TABLE casfri50_test.nfl_all_new AS 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab03_l3_to_ab_l1_map_1120_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 4, 'ab', 1, 1700, NULL, 'nfl'); -- Generates about 200 (205) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab03_l4_to_ab_l1_map_1700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 3, 'ab', 1, 1120, NULL, 'nfl'); -- Generates about 200 (203) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l3_to_ab_l1_map_1120_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 4, 'ab', 1, 1700, NULL, 'nfl'); -- Generates about 200 (206) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l4_to_ab_l1_map_1700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 3, 'ab', 1, 1120, NULL, 'nfl'); -- Generates about 200 (194) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab07_l3_to_ab_l1_map_1120_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 4, 'ab', 1, 3000, NULL, 'nfl'); -- Generates about 200 (157) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab07_l4_to_ab_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 3, 'ab', 1, 2000, NULL, 'nfl'); -- Generates about 200 (217) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab08_l3_to_ab_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 4, 'ab', 1, 1800, NULL, 'nfl'); -- Generates about 200 (194) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab08_l4_to_ab_l1_map_1800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 3, 'ab', 1, 1000, NULL, 'nfl'); -- Generates about 200 (225) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab10_l3_to_ab_l1_map_1000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 4, 'ab', 1, 1800, NULL, 'nfl'); -- Generates about 200 (173) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab10_l4_to_ab_l1_map_1800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 3, 'ab', 1, 2000, NULL, 'nfl'); -- Generates about 200 (199) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab11_l3_to_ab_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 4, 'ab', 1, 1800, NULL, 'nfl'); -- Generates about 200 (169) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab11_l4_to_ab_l1_map_1800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 3, 'ab', 1, 3200, NULL, 'nfl'); -- Generates about 400 (399) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l3_to_ab_l1_map_3200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 4, 'ab', 1, 4100, NULL, 'nfl'); -- Generates about 400 (407) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l4_to_ab_l1_map_4100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 3, 'ab', 1, 700, NULL, 'nfl'); -- Generates about 200 (191) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab25_l3_to_ab_l1_map_700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 4, 'ab', 1, 1200, NULL, 'nfl'); -- Generates about 200 (206) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab25_l4_to_ab_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 3, 'ab', 1, 700, NULL, 'nfl'); -- Generates about 200 (191) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab29_l3_to_ab_l1_map_700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 4, 'ab', 1, 1200, NULL, 'nfl'); -- Generates about 200 (206) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab29_l4_to_ab_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1, 7280, NULL, 'nfl'); -- Generates about 600 (604) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb01_l3_to_nb_l1_map_7280_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 3, 'nb', 1, 4750, NULL, 'nfl'); -- Generates about 600 (602) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb02_l3_to_nb_l1_map_4750_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, 4800, NULL, 'nfl'); -- Generates about 1000 (1031) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l3_to_bc_l1_map_4800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, 16000, NULL, 'nfl'); -- Generates about 1000 (1039) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l4_to_bc_l1_map_16000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 5, 'bc', 1, 6200, NULL, 'nfl'); -- Generates about 1000 (1042) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l5_to_bc_l1_map_6200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1, 4800, NULL, 'nfl'); -- Generates about 1000 (1031) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l3_to_bc_l1_map_4800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1, 16000, NULL, 'nfl'); -- Generates about 1000 (1039) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l4_to_bc_l1_map_16000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1, 6200, NULL, 'nfl'); -- Generates about 1000 (1042) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l5_to_bc_l1_map_6200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1, 3350, NULL, 'nfl'); -- Generates about 500 (509) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l3_to_nt_l1_map_3350_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1, 6220, NULL, 'nfl'); -- Generates about 500 (503) NFL rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l4_to_nt_l1_map_6220_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 3, 'nt', 1, 3020, NULL, 'nfl'); -- Generates about 500 (513) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt02_l3_to_nt_l1_map_3020_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt02', 4, 'nt', 1, 2100, NULL, 'nfl'); -- Generates about 500 (523) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt02_l4_to_nt_l1_map_2100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 3, 'on', 1, 2450, NULL, 'nfl'); -- Generates about 1000 (1005) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_on_nfl_test('rawfri', 'on02_l3_to_on_l1_map_2450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, 3130, NULL, 'nfl'); -- Generates about 700 (724) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_utm_nfl_test('rawfri', 'sk01_l3_to_sk_utm_l1_map_3130_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 4, 'sk_sfv', 1, 540, NULL, 'nfl'); -- Generates about 200 (205) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l4_to_sk_sfv_l1_map_540_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 5, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates about 200 (192) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l5_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1, 9000, NULL, 'nfl'); -- Generates about 200 (211) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l6_to_sk_sfv_l1_map_9000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1, 450, NULL, 'nfl'); -- Generates about 200 (196) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l4_to_sk_sfv_l1_map_450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l5_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1, 2800, NULL, 'nfl'); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l6_to_sk_sfv_l1_map_2800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 4, 'sk_sfv', 1, 1800, NULL, 'nfl'); -- Generates about 500 (508) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l4_to_sk_sfv_l1_map_1800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 5, 'sk_sfv', 1, 3500, NULL, 'nfl'); -- Generates about 500 (501) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l5_to_sk_sfv_l1_map_3500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 6, 'sk_sfv', 1, 7900, NULL, 'nfl'); -- Generates about 500 (491) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l6_to_sk_sfv_l1_map_7900_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, 1800, NULL, 'nfl'); -- Generates about 500 (492) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l4_to_sk_sfv_l1_map_1800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, 4000, NULL, 'nfl'); -- Generates about 500 (491) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l5_to_sk_sfv_l1_map_4000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, 14000, NULL, 'nfl'); -- Generates about 500 (505) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l6_to_sk_sfv_l1_map_14000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 4, 'sk_sfv', 1, 1150, NULL, 'nfl'); -- Generates about 300 (306) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l4_to_sk_sfv_l1_map_1150_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 5, 'sk_sfv', 1, 3120, NULL, 'nfl'); -- Generates about 300 (293) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l5_to_sk_sfv_l1_map_3120_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 6, 'sk_sfv', 1, 35000, NULL, 'nfl'); -- Generates about 300 (312) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l6_to_sk_sfv_l1_map_35000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 2, 'yt', 1, 1850, NULL, 'nfl'); -- Generates about 600 (613) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_yt_nfl_test('rawfri', 'yt02_l2_to_yt_l1_map_1850_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 3, 'ns_nsi', 1, 3800, NULL, 'nfl'); -- Generates about 800 (797) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_ns_nfl_test('rawfri', 'ns03_l3_to_ns_nsi_l1_map_3800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 2, 'pe_pei', 1, 1420, NULL, 'nfl'); -- Generates about 300 (309) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_pe_nfl_test('rawfri', 'pe01_l2_to_pe_pei_l1_map_1420_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 2, 'mb_fri', 1, 1250, NULL, 'nfl'); -- Generates about 500 (479) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_mb_fri_nfl_test('rawfri', 'mb05_l2_to_mb_fri_l1_map_1250_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 6, 'mb_fli', 1, 5000, NULL, 'nfl'); -- Generates about 300 (298) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_mb_fli_nfl_test('rawfri', 'mb06_l6_to_mb_fli_l1_map_5000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 2450, NULL, 'nfl'); -- Generates about 900 (881) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_nl_nli_nfl_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_2450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 3, 'qc_ini03', 1, 800, NULL, 'nfl'); -- Generates about 400 (387) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_qc_ini03_nfl_test('rawfri', 'qc03_l3_to_qc_ini03_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 3, 'qc_ini04', 1, 7000, NULL, 'nfl'); -- Generates about 900 (890) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_qc_ini04_nfl_test('rawfri', 'qc04_l3_to_qc_ini04_l1_map_7000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 3, 'qc_ipf', 1, 6000, NULL, 'nfl'); -- Generates about 900 (916) NFL rows
INSERT INTO casfri50_test.nfl_all_new 
SELECT * FROM TT_Translate_qc_ipf05_nfl_test('rawfri', 'qc05_l3_to_qc_ipf_l1_map_6000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 450, NULL, 'nfl'); -- Generates 200 (189) LYR rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l4_to_pc_panp_l1_map_450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 6000, NULL, 'nfl'); -- Generates 200 (215) LYR rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l5_to_pc_panp_l1_map_6000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, NULL, NULL, 'nfl'); -- Generates 200 (14) LYR rows
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l6_to_pc_panp_l1_map_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_all_new_ordered AS
SELECT * FROM casfri50_test.nfl_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
SELECT count(*) FROM casfri50_test.nfl_all_new; -- 25725, 38m
---------------------------------------------------------
