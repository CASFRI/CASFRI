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
SELECT TT_Prepare('translation', 'mb_fri02_cas', '_mb_fri2_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'mb_fli01_cas', '_mb_fli_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'nl_nli01_cas', '_nl_nli_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'qc_ini03_cas', '_qc_ini03_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'qc_ini04_cas', '_qc_ini04_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'qc_ipf05_cas', '_qc_ipf05_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'pc_panp01_cas', '_pc_panp_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'pc_wbnp01_cas', '_pc_wbnp_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'yt_yvi02_cas', '_yt_yvi02_cas_test', 'ab_avi01_cas'); 
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_all_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab', 200, NULL, 'cas');
CREATE TABLE casfri50_test.cas_all_new AS 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab03_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab06_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab07_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab08_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab10_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab11_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab16_l1_to_ab_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab25_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab29_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab30', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab30_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 600, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb01_l1_to_nb_l1_map_600_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 600, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb02_l1_to_nb_l1_map_600_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc08_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc10_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt01_l1_to_nt_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 'nt', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt03_l1_to_nt_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 'on', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_on_cas_test('rawfri', 'on01_l1_to_on_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_on_cas_test('rawfri', 'on02_l1_to_on_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 700, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_utm_cas_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_700_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 'yt', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_yt_cas_test('rawfri', 'yt01_l1_to_yt_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 600, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_yt_cas_test('rawfri', 'yt02_l1_to_yt_l1_map_600_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt_yvi02', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_yt_yvi02_cas_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 'ns_nsi', 800, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_800_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 'ns_nsi', 800, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_800_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 800, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_800_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_pe_cas_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 'mb_fri2', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fri2_cas_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fri_cas_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 'mb_fli', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 'mb_fli', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 900, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nl_nli_cas_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_900_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 'qc_ini03', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 'qc_ini03', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 'qc_ini03', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 'qc_ini04', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ini04_cas_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 'qc_ini04', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ini04_cas_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 'qc_ipf', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ipf05_cas_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 'qc_ipf', 700, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_qc_ipf05_cas_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_700_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 'pc_panp', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_pc_panp_cas_test('rawfri', 'pc01_l1_to_pc_panp_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 'pc_wbnp', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_pc_wbnp_cas_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_all_new_ordered AS
SELECT * FROM casfri50_test.cas_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
SELECT count(*) FROM casfri50_test.cas_all_new; -- 23639, 2m58
---------------------------------------------------------