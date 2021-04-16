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
SELECT TT_Prepare('translation', 'mb_fri02_lyr', '_mb_fri02_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'mb_fli01_lyr', '_mb_fli_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'nl_nli01_lyr', '_nl_nli_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'qc_ini03_lyr', '_qc_ini03_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'qc_ini04_lyr', '_qc_ini04_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'qc_ipf05_lyr', '_qc_ipf05_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'pc_panp01_lyr', '_pc_panp_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'pc_wbnp01_lyr', '_pc_wbnp_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'yt_yvi02_lyr', '_yt_yvi02_lyr_test', 'ab_avi01_lyr'); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_all_new CASCADE;
-------------------------
-- Create indexes on species_code_mapping
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_bc_species_codes_idx
ON translation.species_code_mapping (bc_species_codes)
WHERE TT_NotEmpty(bc_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nb_species_codes_idx
ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nt_species_codes_idx
ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_on_species_codes_idx
ON translation.species_code_mapping (on_species_codes)
WHERE TT_NotEmpty(on_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_sk_species_codes_idx
ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_yt_species_codes_idx
ON translation.species_code_mapping (yt_species_codes)
WHERE TT_NotEmpty(yt_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ns_species_codes_idx
ON translation.species_code_mapping (ns_species_codes)
WHERE TT_NotEmpty(ns_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pe_species_codes_idx
ON translation.species_code_mapping (pe_species_codes)
WHERE TT_NotEmpty(pe_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_mb_species_codes_idx
ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nl_species_codes_idx
ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc01_species_codes_idx
ON translation.species_code_mapping (pc01_species_codes)
WHERE TT_NotEmpty(pc01_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc02_species_codes_idx
ON translation.species_code_mapping (pc02_species_codes)
WHERE TT_NotEmpty(pc02_species_codes);

------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (204) LYR rows
CREATE TABLE casfri50_test.lyr_all_new AS 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab03_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1, 550, NULL, 'lyr'); -- Generates about 200 (209) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab03_l2_to_ab_l1_map_550_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (208) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 480, NULL, 'lyr'); -- Generates about 200 (200) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l2_to_ab_l1_map_480_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (211) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab07_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 2, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (185) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab07_l2_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (217) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab08_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 2, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 200 (172) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab08_l2_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (203) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab10_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 2, 'ab', 1, 500, NULL, 'lyr'); -- Generates about 200 (175) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab10_l2_to_ab_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1, 200, NULL, 'lyr'); -- Generates about 200 (182) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab11_l1_to_ab_l1_map_200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 2, 'ab', 1, 3000, NULL, 'lyr'); -- Generates about 200 (176) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab11_l2_to_ab_l1_map_3000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 460, NULL, 'lyr'); -- Generates about 400 (414) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l1_to_ab_l1_map_460_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 1070, NULL, 'lyr'); -- Generates about 400 (421) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l2_to_ab_l1_map_1070_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (184) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab25_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (158) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab25_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (184) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab29_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (158) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab29_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 730, NULL, 'lyr'); -- Generates about 600 (607) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l1_to_nb_l1_map_730_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 3520, NULL, 'lyr'); -- Generates about 600 (618) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l2_to_nb_l1_map_3520_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 900, NULL, 'lyr'); -- Generates about 600 (598) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l1_to_nb_l1_map_900_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 2200, NULL, 'lyr'); -- Generates about 600 (627) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l2_to_nb_l1_map_2200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 1120, NULL, 'lyr'); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l1_to_bc_l1_map_1120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, 30000, NULL, 'lyr'); -- Generates about 1000 (1001) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l2_to_bc_l1_map_30000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 1120, NULL, 'lyr'); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l1_to_bc_l1_map_1120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 30000, NULL, 'lyr'); -- Generates about 1000 (1001) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l2_to_bc_l1_map_30000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 1, 'bc', 1, 1120, NULL, 'lyr'); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc11_l1_to_bc_l1_map_1120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 2, 'bc', 1, 30000, NULL, 'lyr'); -- Generates about 1000 (1001) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc11_l2_to_bc_l1_map_30000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1, 1120, NULL, 'lyr'); -- Generates about 1000 (999) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc12_l1_to_bc_l1_map_1120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 2, 'bc', 1, 30000, NULL, 'lyr'); -- Generates about 1000 (1001) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc12_l2_to_bc_l1_map_30000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 600, NULL, 'lyr'); -- Generates about 500 (522) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l1_to_nt_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 15500, NULL, 'lyr'); -- Generates about 500 (511) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l2_to_nt_l1_map_15500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1, 600, NULL, 'lyr'); -- Generates about 500 (497) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt03_l1_to_nt_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 2, 'nt', 1, 2000, NULL, 'lyr'); -- Generates about 500 (504) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt03_l2_to_nt_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1, 1300, NULL, 'lyr'); -- Generates about 1000 (951) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on01_l1_to_on_l1_map_1300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 2, 'on', 1, 1000000, NULL, 'lyr'); -- Generates about 1000 (100) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on01_l2_to_on_l1_map_1000000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1600, NULL, 'lyr'); -- Generates about 1000 (1000) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l1_to_on_l1_map_1600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 22200, NULL, 'lyr'); -- Generates about 1000 (1038) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l2_to_on_l1_map_22200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 900, NULL, 'lyr'); -- Generates about 700 (659) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_900_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, 80000, NULL, 'lyr'); -- Generates about 700 (727) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l2_to_sk_utm_l1_map_80000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 230, NULL, 'lyr'); -- Generates about 200 (200) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_230_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1, 1200, NULL, 'lyr'); -- Generates about 200 (208) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l2_to_sk_sfv_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1, 27000, NULL, 'lyr'); -- Generates about 200 (164) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l3_to_sk_sfv_l1_map_27000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 240, NULL, 'lyr'); -- Generates about 200 (204) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_240_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1, 500, NULL, 'lyr'); -- Generates about 200 (192) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l2_to_sk_sfv_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1, 8900, NULL, 'lyr'); -- Generates about 200 (14) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l3_to_sk_sfv_l1_map_8900_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 580, NULL, 'lyr'); -- Generates about 500 (524) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_580_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, 2050, NULL, 'lyr'); -- Generates about 500 (498) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l2_to_sk_sfv_l1_map_2050_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, 90000, NULL, 'lyr'); -- Generates about 500 (512) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l3_to_sk_sfv_l1_map_90000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 570, NULL, 'lyr'); -- Generates about 500 (538) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_570_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, 2000, NULL, 'lyr'); -- Generates about 500 (509) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l2_to_sk_sfv_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, 134500, NULL, 'lyr'); -- Generates about 500 (507) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l3_to_sk_sfv_l1_map_134500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 350, NULL, 'lyr'); -- Generates about 300 (296) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 2, 'sk_sfv', 1, 650, NULL, 'lyr'); -- Generates about 300 (314) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l2_to_sk_sfv_l1_map_650_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 3, 'sk_sfv', 1, 6000, NULL, 'lyr'); -- Generates about 300 (301) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l3_to_sk_sfv_l1_map_6000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 1, 'yt', 1, 850, NULL, 'lyr'); -- Generates about 400 (380) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_lyr_test('rawfri', 'yt01_l1_to_yt_l1_map_850_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 1300, NULL, 'lyr'); -- Generates about 600 (598) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_lyr_test('rawfri', 'yt02_l1_to_yt_l1_map_1300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1, 300, NULL, 'lyr'); -- Generates about 200 (250) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_yvi02_lyr_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1, 2000, NULL, 'lyr'); -- Generates about 200 (238) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_yvi02_lyr_test('rawfri', 'yt03_l2_to_yt_yvi02_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 1, 'ns_nsi', 1, 1070, NULL, 'lyr'); -- Generates about 800 (833) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_1070_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 2, 'ns_nsi', 1, 5000, NULL, 'lyr'); -- Generates about 800 (737) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns01_l2_to_ns_nsi_l1_map_5000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 1, 'ns_nsi', 1, 1070, NULL, 'lyr'); -- Generates about 800 (825) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_1070_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 2, 'ns_nsi', 1, 4500, NULL, 'lyr'); -- Generates about 800 (768) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns02_l2_to_ns_nsi_l1_map_4500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 1070, NULL, 'lyr'); -- Generates about 800 (780) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_1070_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, 3300, NULL, 'lyr'); -- Generates about 800 (805) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l2_to_ns_nsi_l1_map_3300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 400, NULL, 'lyr'); -- Generates about 300 (300) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 1, 'mb_fri2', 1, 350, NULL, 'lyr'); -- Generates about 300 (301) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fri02_lyr_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_350_lyr'); 
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 400, NULL, 'lyr'); -- Generates about 300 (272) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fri_lyr_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_400_lyr'); -- Generates about 500 (508) LYR rows
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1, 300, NULL, 'lyr'); -- Generates about 200 (256) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 2, 'mb_fli', 1, 300, NULL, 'lyr'); -- Generates about 200 (179) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l2_to_mb_fli_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 3, 'mb_fli', 1, 3000, NULL, 'lyr'); -- Generates about 200 (265) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l3_to_mb_fli_l1_map_3000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (80) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (2) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 1, 'mb_fli', 1, 300, NULL, 'lyr'); -- Generates about 200 (253) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 2, 'mb_fli', 1, 500, NULL, 'lyr'); -- Generates about 200 (214) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l2_to_mb_fli_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 3, 'mb_fli', 1, 3500, NULL, 'lyr'); -- Generates about 200 (201) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l3_to_mb_fli_l1_map_3500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (25) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 350, NULL, 'lyr'); -- Generates about 300 (316) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb_fli', 1, 800, NULL, 'lyr'); -- Generates about 300 (296) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l2_to_mb_fli_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 3, 'mb_fli', 1, 5000, NULL, 'lyr'); -- Generates about 300 (255) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l3_to_mb_fli_l1_map_5000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 107 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 1, 'mb_fli', 1, 600, NULL, 'lyr'); -- Generates about 400 (426) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 2, 'mb_fli', 1, 65000, NULL, 'lyr'); -- Generates about 400 (411) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l2_to_mb_fli_l1_map_65000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 3, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 400 (3) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l3_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 400 (0) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 400 (0) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 1500, NULL, 'lyr'); -- Generates 900 (964) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nl_nli_lyr_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_1500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1, 1700, NULL, 'lyr'); -- Generates 1000 (1084) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_1700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 2, 'qc_ini03', 1, 100000, NULL, 'lyr'); -- Generates 1000 (1062) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc01_l2_to_qc_ini03_l1_map_100000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 1, 'qc_ini03', 1, 1800, NULL, 'lyr'); -- Generates 1000 (938) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 2, 'qc_ini03', 1, 100000, NULL, 'lyr'); -- Generates 1000 (411) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc02_l2_to_qc_ini03_l1_map_100000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, 800, NULL, 'lyr'); -- Generates 400 (331) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 2, 'qc_ini03', 1, 20000, NULL, 'lyr'); -- Generates 400 (241) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc03_l2_to_qc_ini03_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, 1400, NULL, 'lyr'); -- Generates 900 (930) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 2, 'qc_ini04', 1, 80000, NULL, 'lyr'); -- Generates 900 (873) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc04_l2_to_qc_ini04_l1_map_80000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, 1400, NULL, 'lyr'); -- Generates 900 (989) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 2, 'qc_ini04', 1, 70000, NULL, 'lyr'); -- Generates 1000 (1058) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc06_l2_to_qc_ini04_l1_map_70000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, 1200, NULL, 'lyr'); -- Generates 900 (894) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 2, 'qc_ipf', 1, 80000, NULL, 'lyr'); -- Generates 900 (858) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc05_l2_to_qc_ipf_l1_map_80000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1, 1000, NULL, 'lyr'); -- Generates 700 (739) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_1000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 2, 'qc_ipf', 1, 40000, NULL, 'lyr'); -- Generates 700 (741) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc07_l2_to_qc_ipf_l1_map_40000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, 350, NULL, 'lyr'); -- Generates 200 (236) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l1_to_pc_panp_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1, 1000, NULL, 'lyr'); -- Generates 200 (185) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l2_to_pc_panp_l1_map_1000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1, NULL, NULL, 'lyr'); -- Generates 200 (137) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l3_to_pc_panp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 350, NULL, 'lyr'); -- Generates 200 (172) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 350, NULL, 'lyr'); -- Generates 200 (162) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 350, NULL, 'lyr'); -- Generates 200 (171) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 1000, NULL, 'lyr'); -- Generates 200 (185) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_1000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates 200 (59) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates 200 (2) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates 200 (7) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_lyr');
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
SELECT count(*) FROM casfri50_test.lyr_all_new; -- 45581 rows, 2h26, new engine 13m46
---------------------------------------------------------