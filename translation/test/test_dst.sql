------------------------------------------------------------------------------
-- CASFRI - DST table test script for CASFRI v5
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
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab_dst_test');
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_utm01_dst', '_sk_utm_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk_sfv_dst_test', 'ab_avi01_dst'); 
SELECT TT_Prepare('translation', 'yt_yvi01_dst', '_yt_01_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'yt_yvi02_dst', '_yt_02_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'ns_nsi01_dst', '_ns_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'pe_pei01_dst', '_pe_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fri01_dst', '_mb_fri_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fli01_dst', '_mb_fli_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nl_nli01_dst', '_nl_nli_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'qc_ini03_dst', '_qc_ini03_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'qc_ini04_dst', '_qc_ini04_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'qc_ipf05_dst', '_qc_ipf05_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'pc_wbnp01_dst', '_pc_wbnp01_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'yt_yvi02_dst', '_yt_yvi02_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'ds_cfs01_dst', '_ds_cfs_dst_test', 'ab_avi01_dst');

------------------------
DROP TABLE IF EXISTS casfri50_test.dst_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1, 2000, NULL, 'dst'); -- Generates about 200 (179) DST rows
CREATE TABLE casfri50_test.dst_all_new AS
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab03_l1_to_ab_l1_map_2000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 1250, NULL, 'dst'); -- Generates about 200 (197) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab06_l1_to_ab_l1_map_1250_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 1, 'ab', 1, 3600, NULL, 'dst'); -- Generates about 200 (209) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab07_l1_to_ab_l1_map_3600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 1, 'ab', 1, 1200, NULL, 'dst'); -- Generates about 200 (200) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab08_l1_to_ab_l1_map_1200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1, 1350, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab10_l1_to_ab_l1_map_1350_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1, 1500, NULL, 'dst'); -- Generates about 200 (201) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab11_l1_to_ab_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 3000, NULL, 'dst'); -- Generates about 200 (219) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab16_l1_to_ab_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 1, 'ab', 1, 3000, NULL, 'dst'); -- Generates about 200 (213) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab21_l1_to_ab_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 1, 'ab', 1, 1550, NULL, 'dst'); -- Generates about 200 (211) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab24_l1_to_ab_l1_map_1550_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1, 4200, NULL, 'dst'); -- Generates about 200 (205) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab25_l1_to_ab_l1_map_4200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1, 1200, NULL, 'dst'); -- Generates about 200 (219) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab27_l1_to_ab_l1_map_1200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1, 2700, NULL, 'dst'); -- Generates about 200 (216) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab29_l1_to_ab_l1_map_2700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab30', 1, 'ab', 1, 200, NULL, 'dst'); -- Generates about 200 (200) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab30_l1_to_ab_l1_map_200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 1, 'ab', 1, 2200, NULL, 'dst'); -- Generates about 200 (210) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab31_l1_to_ab_l1_map_2200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 1, 'ab', 1, 2200, NULL, 'dst'); -- Generates about 300 (327) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab32_l1_to_ab_l1_map_2200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 1500, NULL, 'dst'); -- Generates about 400 (417) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb01_l1_to_nb_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 90000, NULL, 'dst'); -- Generates about 200 (217) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb01_l2_to_nb_l1_map_90000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 1500, NULL, 'dst'); -- Generates about 400 (444) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb02_l1_to_nb_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 1, 'bc', 1, 3600, NULL, 'dst'); -- Generates about 800 (813) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc04_l1_to_bc_l1_map_3600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 3300, NULL, 'dst'); -- Generates about 800 (820) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc08_l1_to_bc_l1_map_3300_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 3000, NULL, 'dst'); -- Generates about 800 (852) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc10_l1_to_bc_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 1, 'bc', 1, 3200, NULL, 'dst'); -- Generates about 800 (824) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc11_l1_to_bc_l1_map_3200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1, 3400, NULL, 'dst'); -- Generates about 800 (828) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc12_l1_to_bc_l1_map_3400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 800, NULL, 'dst'); -- Generates about 200 (211) DST rows
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt01_l1_to_nt_l1_map_800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1, 800, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt03_l1_to_nt_l1_map_800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1, 6000, NULL, 'dst'); -- Generates about 400 (442) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_on_dst_test('rawfri', 'on01_l1_to_on_l1_map_6000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 7100, NULL, 'dst'); -- Generates about 300 (309) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_on_dst_test('rawfri', 'on02_l1_to_on_l1_map_7100_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 5000, NULL, 'dst'); -- Generates about 200 (201) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_utm_dst_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_5000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 650, NULL, 'dst'); -- Generates about 200 (198) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_650_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 7800, NULL, 'dst'); -- Generates about 200 (206) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_7800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 1500, NULL, 'dst'); -- Generates about 200 (222) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 1500, NULL, 'dst'); -- Generates about 200 (230) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 1000, NULL, 'dst'); -- Generates about 200 (208) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 1, 'yt', 1, 2500, NULL, 'dst'); -- Generates about 200 (218) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_yt_01_dst_test('rawfri', 'yt01_l1_to_yt_l1_map_2500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 2400, NULL, 'dst'); -- Generates about 200 (202) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_yt_01_dst_test('rawfri', 'yt02_l1_to_yt_l1_map_2400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1, 750, NULL, 'dst'); -- Generates about 200 (204) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_yt_02_dst_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_750_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1, 10000, NULL, 'dst'); -- Generates about 200 (208) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_yt_yvi02_dst_test('rawfri', 'yt03_l2_to_yt_yvi02_l1_map_10000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 1, 'ns_nsi', 1, 2800, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_2800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 1, 'ns_nsi', 1, 3000, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 3000, NULL, 'dst'); -- Generates about 200 (217) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 700, NULL, 'dst'); -- Generates about 200 (233) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_pe_dst_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1, 1600, NULL, 'dst'); -- Generates about 200 (211) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_1600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 1, 'mb_fli', 1, 510, NULL, 'dst'); -- Generates about 200 (211) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_510_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 1000, NULL, 'dst'); -- Generates 0 DST rows. No DST info to translate
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fri_dst_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 820, NULL, 'dst'); -- Generates about 200 (214) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_820_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 1, 'mb_fli', 1, 700, NULL, 'dst'); -- Generates about 300 (316) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 5010, NULL, 'dst'); -- Generates about 300 (330) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_nl_nli_dst_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_5010_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1, 2500, NULL, 'dst'); -- Generates about 1000 (1054) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_2500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 1, 'qc_ini03', 1, 1800, NULL, 'dst'); -- Generates about 800 (843) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, 1200, NULL, 'dst'); -- Generates about 200 (233) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_1200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, 1500, NULL, 'dst'); -- Generates about 900 (880) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ini04_dst_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, 2000, NULL, 'dst'); -- Generates about 1000 (1082) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ipf05_dst_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_2000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, 1800, NULL, 'dst'); -- Generates about 1000 (1041) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ini04_dst_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1, 400, NULL, 'dst'); -- Generates about 200 (218) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_qc_ipf05_dst_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 500, NULL, 'dst'); -- Generates about 200 (235) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_pc_wbnp01_dst_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds01', 'ds', 200, NULL, 'dst'); -- Generates 200 DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds01_l1_to_ds_l1_map_200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds02', 'ds', 1050, NULL, 'dst'); -- Generates about 1000 (1021) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds02_l1_to_ds_l1_map_1050_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds03', 'ds', 1000, NULL, 'dst'); -- Generates 1000 DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds03_l1_to_ds_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds04', 'ds', 500, NULL, 'dst'); -- Generates about 200 (201) DST rows
INSERT INTO casfri50_test.dst_all_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds04_l1_to_ds_l1_map_500_dst'); -- return only about 400 rows because there is a ROW_TRANSATION_RULE for Cutblock
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
SELECT count(*) FROM casfri50_test.dst_all_new; -- 29525, 3m33
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
 FROM casfri50_test.dst_all_new
 GROUP BY left(cas_id, 4), layer
 ORDER BY left(cas_id, 4), layer
), translated AS (
 SELECT 
  left(cas_id, 4) inv, 
  layer,
  count(*) cnt 
 FROM casfri50.dst_all
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
