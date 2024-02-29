------------------------------------------------------------------------------
-- CASFRI - LYR table test script for CASFRI v5
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
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr_test');
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_utm_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk_sfv_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_01_lyr_test', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'yt_yvi02_lyr', '_yt_02_lyr_test', 'ab_avi01_lyr'); 
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
SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (252) LYR rows
CREATE TABLE casfri50_test.lyr_all_new AS 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab03_l1_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (225) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab03_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (241) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l1_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 480, NULL, 'lyr'); -- Generates about 200 (218) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l2_to_ab_l1_map_480_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab07_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 2, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (202) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab07_l2_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (228) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab08_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (222) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab08_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 300 (306) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab10_l1_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (230) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab10_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 300 (349) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab11_l1_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 2, 'ab', 1, 3400, NULL, 'lyr'); -- Generates about 200 (203) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab11_l2_to_ab_l1_map_3400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 360, NULL, 'lyr'); -- Generates about 300 (329) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l1_to_ab_l1_map_360_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (231) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 1, 'ab', 1, 500, NULL, 'lyr'); -- Generates about 400 (428) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab21_l1_to_ab_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 2, 'ab', 1, 850, NULL, 'lyr'); -- Generates about 300 (310) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab21_l2_to_ab_l1_map_850_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 1, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 300 (316) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab24_l1_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 2, 'ab', 1, 550, NULL, 'lyr'); -- Generates about 200 (202) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab24_l2_to_ab_l1_map_550_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 400 (426) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab25_l1_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 2, 'ab', 1, 1200, NULL, 'lyr'); -- Generates about 300 (335) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab25_l2_to_ab_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (228) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab27_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 2, 'ab', 1, 900, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab27_l2_to_ab_l1_map_900_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1, 700, NULL, 'lyr'); -- Generates about 500 (515) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab29_l1_to_ab_l1_map_700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 2, 'ab', 1, 1200, NULL, 'lyr'); -- Generates about 300 (330) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab29_l2_to_ab_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 1, 'ab', 1, 710, NULL, 'lyr'); -- Generates about 600 (614) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab31_l1_to_ab_l1_map_710_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 2, 'ab', 1, 2000, NULL, 'lyr'); -- Generates about 300 (312) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab31_l2_to_ab_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 1, 'ab', 1, 750, NULL, 'lyr'); -- Generates about 600 (648) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab32_l1_to_ab_l1_map_750_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 2, 'ab', 1, 2000, NULL, 'lyr'); -- Generates about 300 (352) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab32_l2_to_ab_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 730, NULL, 'lyr'); -- Generates about 600 (601) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l1_to_nb_l1_map_730_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 1800, NULL, 'lyr'); -- Generates about 300 (326) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l2_to_nb_l1_map_1800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 1100, NULL, 'lyr'); -- Generates about 700 (731) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l1_to_nb_l1_map_1100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 1100, NULL, 'lyr'); -- Generates about 300 (301) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l2_to_nb_l1_map_1100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1044) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc04_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1055) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, 10000, NULL, 'lyr'); -- Generates about 300 (354) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l2_to_bc_l1_map_10000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 1120, NULL, 'lyr'); -- Generates about 1000 (1004) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l1_to_bc_l1_map_1120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 9000, NULL, 'lyr'); -- Generates about 300 (315) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l2_to_bc_l1_map_9000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1074) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc11_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 2, 'bc', 1, 9300, NULL, 'lyr'); -- Generates about 300 (317) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc11_l2_to_bc_l1_map_9300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1077) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc12_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 2, 'bc', 1, 10000, NULL, 'lyr'); -- Generates about 300 (332) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc12_l2_to_bc_l1_map_10000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1018) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc13_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 500, NULL, 'lyr'); -- Generates about 400 (438) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l1_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 7000, NULL, 'lyr'); -- Generates about 200 (208) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l2_to_nt_l1_map_7000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1, 500, NULL, 'lyr'); -- Generates about 400 (402) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt03_l1_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 2, 'nt', 1, 850, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_all_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt03_l2_to_nt_l1_map_850_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1, 1400, NULL, 'lyr'); -- Generates about 1000 (1011) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on01_l1_to_on_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 2, 'on', 1, 100000, NULL, 'lyr'); -- Generates about 200 (10) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on01_l2_to_on_l1_map_100000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1600, NULL, 'lyr'); -- Generates about 1000 (1020) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l1_to_on_l1_map_1600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 7000, NULL, 'lyr'); -- Generates about 300 (344) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l2_to_on_l1_map_7000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 1200, NULL, 'lyr'); -- Generates about 800 (851) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, 25000, NULL, 'lyr'); -- Generates about 200 (201) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l2_to_sk_utm_l1_map_25000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 230, NULL, 'lyr'); -- Generates about 200 (200) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_230_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1, 1200, NULL, 'lyr'); -- Generates about 200 (210) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l2_to_sk_sfv_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1, NULL, NULL, 'lyr'); -- Generates about 200 (165) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l3_to_sk_sfv_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 280, NULL, 'lyr'); -- Generates about 200 (228) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_280_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1, 600, NULL, 'lyr'); -- Generates about 200 (216) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l2_to_sk_sfv_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1, NULL, NULL, 'lyr'); -- Generates about 200 (14) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l3_to_sk_sfv_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 580, NULL, 'lyr'); -- Generates about 500 (515) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_580_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, 1300, NULL, 'lyr'); -- Generates about 300 (310) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l2_to_sk_sfv_l1_map_1300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, 40000, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l3_to_sk_sfv_l1_map_40000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 450, NULL, 'lyr'); -- Generates about 400 (417) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, 1300, NULL, 'lyr'); -- Generates about 300 (331) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l2_to_sk_sfv_l1_map_1300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, 70000, NULL, 'lyr'); -- Generates about 200 (273) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l3_to_sk_sfv_l1_map_70000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 360, NULL, 'lyr'); -- Generates about 300 (317) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_360_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 2, 'sk_sfv', 1, 650, NULL, 'lyr'); -- Generates about 300 (318) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l2_to_sk_sfv_l1_map_650_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 3, 'sk_sfv', 1, 4200, NULL, 'lyr'); -- Generates about 200 (206) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l3_to_sk_sfv_l1_map_4200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 1, 'yt', 1, 680, NULL, 'lyr'); -- Generates about 300 (314) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_01_lyr_test('rawfri', 'yt01_l1_to_yt_l1_map_680_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 750, NULL, 'lyr'); -- Generates about 300 (336) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_01_lyr_test('rawfri', 'yt02_l1_to_yt_l1_map_750_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1, 300, NULL, 'lyr'); -- Generates about 200 (232) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_02_lyr_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1, 2000, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_yt_yvi02_lyr_test('rawfri', 'yt03_l2_to_yt_yvi02_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 1, 'ns_nsi', 1, 1000, NULL, 'lyr'); -- Generates about 700 (779) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_1000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 2, 'ns_nsi', 1, 2100, NULL, 'lyr'); -- Generates about 300 (328) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns01_l2_to_ns_nsi_l1_map_2100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 1, 'ns_nsi', 1, 1000, NULL, 'lyr'); -- Generates about 700 (776) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_1000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 2, 'ns_nsi', 1, 2100, NULL, 'lyr'); -- Generates about 300 (348) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns02_l2_to_ns_nsi_l1_map_2100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 800, NULL, 'lyr'); -- Generates about 600 (609) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, 1700, NULL, 'lyr'); -- Generates about 400 (429) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l2_to_ns_nsi_l1_map_1700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 300, NULL, 'lyr'); -- Generates about 200 (227) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 1, 'mb_fri2', 1, 400, NULL, 'lyr'); -- Generates about 300 (345) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fri02_lyr_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_400_lyr'); 
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1, 250, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 2, 'mb_fli', 1, 400, NULL, 'lyr'); -- Generates about 200 (213) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l2_to_mb_fli_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 3, 'mb_fli', 1, 2350, NULL, 'lyr'); -- Generates about 200 (211) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l3_to_mb_fli_l1_map_2350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (80) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (2) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 1, 'mb_fli', 1, 250, NULL, 'lyr'); -- Generates about 200 (221) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 2, 'mb_fli', 1, 480, NULL, 'lyr'); -- Generates about 200 (218) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l2_to_mb_fli_l1_map_480_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 3, 'mb_fli', 1, 3550, NULL, 'lyr'); -- Generates about 200 (222) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l3_to_mb_fli_l1_map_3550_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (25) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 1200, NULL, 'lyr'); -- Generates about 800 (834) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fri_lyr_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_1200_lyr'); -- Generates about 500 (508) LYR rows
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 350, NULL, 'lyr'); -- Generates about 300 (321) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb_fli', 1, 600, NULL, 'lyr'); -- Generates about 200 (203) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l2_to_mb_fli_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 3, 'mb_fli', 1, 4000, NULL, 'lyr'); -- Generates about 200 (219) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l3_to_mb_fli_l1_map_4000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (108) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 1, 'mb_fli', 1, 500, NULL, 'lyr'); -- Generates about 300 (354) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 2, 'mb_fli', 1, 34000, NULL, 'lyr'); -- Generates about 200 (214) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l2_to_mb_fli_l1_map_34000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 3, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (3) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l3_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 1350, NULL, 'lyr'); -- Generates about 800 (861) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nl_nli_lyr_test('rawfri', 'nl01_l1_to_nl_nli_l1_map_1350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1, 1700, NULL, 'lyr'); -- Generates about 1000 (1072) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_1700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 2, 'qc_ini03', 1, 20000, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc01_l2_to_qc_ini03_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 1, 'qc_ini03', 1, 1600, NULL, 'lyr'); -- Generates about 800 (819) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 2, 'qc_ini03', 1, 50000, NULL, 'lyr'); -- Generates about 200 (227) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc02_l2_to_qc_ini03_l1_map_50000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, 800, NULL, 'lyr'); -- Generates about 300 (321) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 2, 'qc_ini03', 1, 340000, NULL, 'lyr'); -- Generates about 200 (213) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc03_l2_to_qc_ini03_l1_map_340000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, 1400, NULL, 'lyr'); -- Generates about 900 (942) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 2, 'qc_ini04', 1, 20000, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc04_l2_to_qc_ini04_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, 1400, NULL, 'lyr'); -- Generates about 1000 (1021) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 2, 'qc_ipf', 1, 20000, NULL, 'lyr'); -- Generates about 200 (201) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc05_l2_to_qc_ipf_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, 1500, NULL, 'lyr'); -- Generates about 1000 (1051) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 2, 'qc_ini04', 1, 15000, NULL, 'lyr'); -- Generates about 200 (216) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc06_l2_to_qc_ini04_l1_map_15000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1, 300, NULL, 'lyr'); -- Generates about 200 (220) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 2, 'qc_ipf', 1, 12000, NULL, 'lyr'); -- Generates about 200 (225) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc07_l2_to_qc_ipf_l1_map_12000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, 300, NULL, 'lyr'); -- Generates about 200 (210) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l1_to_pc_panp_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1, 1100, NULL, 'lyr'); -- Generates about 200 (226) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l2_to_pc_panp_l1_map_1100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (137) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l3_to_pc_panp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 400, NULL, 'lyr'); -- Generates about 200 (209) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 450, NULL, 'lyr'); -- Generates about 200 (209) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 450, NULL, 'lyr'); -- Generates about 200 (224) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (192) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (59) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (2) LYR rows
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (7) LYR rows
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
SELECT count(*) FROM casfri50_test.lyr_all_new; -- 44827 rows, new engine 13m46
---------------------------------------------------------
---------------------------------------------------------
-- Check if the number of test is ok. 
-- This can be run only after a first translation,
-- For layered inventories, the number of tested row might
-- differ from what is expected because the resulting layer 
-- number might be different from the tested layer. e.g.
-- translation of layer 1 might result in the stand being 
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
 FROM casfri50_test.lyr_all_new
 GROUP BY left(cas_id, 4), layer
 ORDER BY left(cas_id, 4), layer
), translated AS (
 SELECT 
  left(cas_id, 4) inv, 
  layer,
  count(*) cnt 
 FROM casfri50.lyr_all
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