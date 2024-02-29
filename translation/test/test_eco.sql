------------------------------------------------------------------------------
-- CASFRI - ECO table translation test script for CASFRI v5
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
-- Usage
--
-- 1) Load the test tables from a command window with load_test_tables.sh.
-- 2) Execute "test_translation.sql" in PostgreSQL (this file)
-- 3) If undesirable changes show up in a file diff, fix your translation tables.
--    If desirable changes occurs, dump them as new test tables with 
--    dump_test_tables.sh and commit.
--
-- Whole test takes about 30 minutes. You can execute only part of it depending 
-- on which translation tables were modified.
--
-- You can get a detailed summary of the differences between new translated tables
-- and test tables by copying and executing the content of the "check_query" column
-- (it's a query!) from the final result table. A better, faster way is to dump the 
-- tables with the dump_test_tables.sh and make a diff with the archived tables.
--
-- Approximate number of rows to test depending on the number of translated rows:
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
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab_eco_test');
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_utm_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk_sfv_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_01_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi02_eco', '_yt_02_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'ns_nsi01_eco', '_ns_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pe_pei01_eco', '_pe_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fri01_eco', '_mb_fri_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fri02_eco', '_mb_fri02_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fli01_eco', '_mb_fli_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nl_nli01_eco', '_nl_nli_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'qc_ini03_eco', '_qc_ini03_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'qc_ini04_eco', '_qc_ini04_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'qc_ipf05_eco', '_qc_ipf05_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pc_panp01_eco', '_pc_panp_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pc_wbnp01_eco', '_pc_wbnp_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi02_eco', '_yt_yvi02_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab', 3200, NULL, 'eco'); -- Generates about 200 (223) ECO rows
CREATE TABLE casfri50_test.eco_all_new AS 
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab03_l1_to_ab_l1_map_3200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 2200, NULL, 'eco'); -- Generates about 200 (234) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab06_l1_to_ab_l1_map_2200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 'ab', 3300, NULL, 'eco'); -- Generates about 200 (211) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab07_l1_to_ab_l1_map_3300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 'ab', 7000, NULL, 'eco'); -- Generates about 200 (207) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab08_l1_to_ab_l1_map_7000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab', 1700, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab10_l1_to_ab_l1_map_1700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab', 3500, NULL, 'eco'); -- Generates about 200 (231) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab11_l1_to_ab_l1_map_3500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 5000, NULL, 'eco'); -- Generates about 200 (236) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab16_l1_to_ab_l1_map_5000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 'ab', 1600, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab21_l1_to_ab_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 'ab', 2700, NULL, 'eco'); -- Generates about 200 (210) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab24_l1_to_ab_l1_map_2700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab', 2300, NULL, 'eco'); -- Generates about 200 (212) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab25_l1_to_ab_l1_map_2300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 'ab', 3400, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab27_l1_to_ab_l1_map_3400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab', 2050, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab29_l1_to_ab_l1_map_2050_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 'ab', 2200, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab31_l1_to_ab_l1_map_2200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 'ab', 2200, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab32_l1_to_ab_l1_map_2200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 2650, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb01_l1_to_nb_l1_map_2650_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 3100, NULL, 'eco'); -- Generates about 300 (303) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb02_l1_to_nb_l1_map_3100_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 'bc', 14000, NULL, 'eco'); -- Generates about 200 (200) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc04_l1_to_bc_l1_map_14000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 14000, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc08_l1_to_bc_l1_map_14000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 15000, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc10_l1_to_bc_l1_map_15000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 'bc', 14500, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc11_l1_to_bc_l1_map_14500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 'bc', 15000, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc12_l1_to_bc_l1_map_15000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 'bc', 30000, NULL, 'eco'); -- Generates about 200 (211) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc13_l1_to_bc_l1_map_30000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 1300, NULL, 'eco'); -- Generates about 200 (345) ECO rows
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt01_l1_to_nt_l1_map_1300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 'nt', 950, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt03_l1_to_nt_l1_map_950_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 'on', 1000, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_on_eco_test('rawfri', 'on01_l1_to_on_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 1000, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_on_eco_test('rawfri', 'on02_l1_to_on_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 1600, NULL, 'eco'); -- Generates about 500 (504) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_utm_eco_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', 6000, NULL, 'eco'); -- Generates about 200 (217) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_6000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', 4500, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_4500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 1750, NULL, 'eco'); -- Generates about 300 (300) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_1750_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 1100, NULL, 'eco'); -- Generates about 200 (222) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_1100_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', 1600, NULL, 'eco'); -- Generates about 200 (213) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 'yt', 4400, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_yt_01_eco_test('rawfri', 'yt01_l1_to_yt_l1_map_4400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 4650, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_yt_01_eco_test('rawfri', 'yt02_l1_to_yt_l1_map_4650_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt_yvi02', 1300, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_yt_02_eco_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_1300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 'ns_nsi', 3400, NULL, 'eco'); -- Generates about 300 (328) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_3400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 'ns_nsi', 3400, NULL, 'eco'); -- Generates about 300 (329) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_3400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 2500, NULL, 'eco'); -- Generates about 300 (314) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_2500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', 16000, NULL, 'eco'); -- Generates about 200 (229) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pe_eco_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_16000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 'mb_fri2', 1000, NULL, 'eco'); -- Generates about 200 (200) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fri02_eco_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli', 820, NULL, 'eco'); -- Generates about 200 (218) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_820_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 'mb_fli', 700, NULL, 'eco'); -- Generates about 200 (207) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', 3000, NULL, 'eco'); -- Generates about 300 (312) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fri_eco_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_3000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', 800, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_800_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 'mb_fli', 600, NULL, 'eco'); -- Generates about 200 (212) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 3150, NULL, 'eco'); -- Generates about 400 (406) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_nl_nli_eco_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_3150_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 'qc_ini03', 6000, NULL, 'eco'); -- Generates about 600 (620) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_6000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 'qc_ini03', 3750, NULL, 'eco'); -- Generates about 500 (513) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_3750_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 'qc_ini03', 1600, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 'qc_ini04', 4050, NULL, 'eco'); -- Generates about 400 (409) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ini04_eco_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_4050_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 'qc_ipf', 5500, NULL, 'eco'); -- Generates about 700 (714) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ipf05_eco_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_5500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 'qc_ini04', 5000, NULL, 'eco'); -- Generates about 500 (501) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ini04_eco_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_5000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 'qc_ipf', 3000, NULL, 'eco'); -- Generates about 200 (210) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_qc_ipf05_eco_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_3000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 1100, NULL, 'eco'); -- Generates about 200 (216) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_panp_eco_test('rawfri', 'pc01_l4_to_pc_panp_l1_map_1100_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, NULL, NULL, 'eco'); -- Generates about 200 (233) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_panp_eco_test('rawfri', 'pc01_l5_to_pc_panp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, NULL, NULL, 'eco'); -- Generates about 200 (6) ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_panp_eco_test('rawfri', 'pc01_l6_to_pc_panp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 43 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 600, NULL, 'eco'); -- Generates 61 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 900, NULL, 'eco'); -- Generates 214 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_900_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 104 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 19 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 600, NULL, 'eco'); -- Generates 210 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 400, NULL, 'eco'); -- Generates 204 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 900, NULL, 'eco'); -- Generates 202 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_900_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 186 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 70 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 20 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_all_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_eco');
------------------------

-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_all_new_ordered AS
SELECT * FROM casfri50_test.eco_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site;
------------------------
SELECT count(*) FROM casfri50_test.eco_all_new; -- 14937, 2m30
-------------------------------------------------------
---------------------------------------------------------
-- Check if the number of test is ok. 
-- This can be run only after a first translation
-- For layered inventories, the number of tested row might
-- differ from what is expected because the resulting layer 
-- number might be different from the tested layer. e.g.
-- translation of layer 1 might reusult in the stand being 
-- assigned layer 2. The sum of all test for all layers of 
-- an inventory should however be similar to the sum of 
-- expected tests for this inventory.
---------------------------------------------------------
/*
WITH tested AS (
 SELECT 
  left(cas_id, 4) inv, 
  layer,
  count(*) cnt
 FROM casfri50_test.eco_all_new
 GROUP BY left(cas_id, 4), layer
 ORDER BY left(cas_id, 4), layer
), translated AS (
 SELECT 
  left(cas_id, 4) inv, 
  layer,
  count(*) cnt 
 FROM casfri50.eco_all
 GROUP BY left(cas_id, 4), layer
 ORDER BY left(cas_id, 4), layer
), suggested_nb AS (
  SELECT * 
  FROM (VALUES 
      (1, 100000, 200), 
      (100000, 200000, 300), 
      (200000, 400000, 400), 
      (400000, 600000, 500), 
      (600000, 800000, 600), 
      (800000, 1000000, 700), 
      (1000000, 1500000, 800), 
      (1500000, 2000000, 900), 
      (2000000, 100000000, 1000)
     ) AS t (min, max, s_nb)
)
SELECT 
  a.inv, 
  a.layer,
  a.cnt, 
  s.s_nb suggested_nbr, 
  b.cnt tested_nb,
  b.cnt = a.cnt OR b.cnt >= s.s_nb sufficient,
  CASE WHEN b.cnt = a.cnt THEN 0
       ELSE b.cnt - s.s_nb
  END diff,
  CASE WHEN b.cnt = a.cnt THEN 0
       ELSE trunc(((b.cnt - s.s_nb)::float/s.s_nb*100)::numeric, 1)
  END diff_per
FROM translated a 
LEFT OUTER JOIN suggested_nb s ON (s.min <= a.cnt AND a.cnt < s.max) 
LEFT OUTER JOIN tested b USING (inv, layer);
*/