CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'mb_fri01_lyr', '_mb_fri_lyr_test', 'ab_avi01_lyr', FALSE); 
SELECT TT_Prepare('translation', 'mb_fri02_lyr', '_mb_fri02_lyr_test', 'ab_avi01_lyr', FALSE); 
SELECT TT_Prepare('translation', 'mb_fli01_lyr', '_mb_fli_lyr_test', 'ab_avi01_lyr', FALSE); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_mb_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_mb_species_codes_idx
ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 1, 'mb_fri2', 1, 400, NULL, 'lyr'); -- Generates about 300 (345) LYR rows
CREATE TABLE casfri50_test.lyr_mb_new AS
SELECT * FROM TT_Translate_mb_fri02_lyr_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_400_lyr'); 
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1, 250, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 2, 'mb_fli', 1, 400, NULL, 'lyr'); -- Generates about 200 (213) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l2_to_mb_fli_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 3, 'mb_fli', 1, 2350, NULL, 'lyr'); -- Generates about 200 (211) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l3_to_mb_fli_l1_map_2350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (80) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (2) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb02_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 1, 'mb_fli', 1, 250, NULL, 'lyr'); -- Generates about 200 (221) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 2, 'mb_fli', 1, 480, NULL, 'lyr'); -- Generates about 200 (218) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l2_to_mb_fli_l1_map_480_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 3, 'mb_fli', 1, 1800, NULL, 'lyr'); -- Generates about 100 (111) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l3_to_mb_fli_l1_map_1800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (25) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb04_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 1200, NULL, 'lyr'); -- Generates about 800 (834) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fri_lyr_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_1200_lyr'); -- Generates about 500 (508) LYR rows
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 350, NULL, 'lyr'); -- Generates about 300 (321) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb_fli', 1, 600, NULL, 'lyr'); -- Generates about 200 (203) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l2_to_mb_fli_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 3, 'mb_fli', 1, 4000, NULL, 'lyr'); -- Generates about 200 (219) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l3_to_mb_fli_l1_map_4000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (108) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb06_l5_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 1, 'mb_fli', 1, 500, NULL, 'lyr'); -- Generates about 300 (354) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 2, 'mb_fli', 1, 15000, NULL, 'lyr'); -- Generates about 100 (111) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l2_to_mb_fli_l1_map_15000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 3, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates about 200 (3) LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l3_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 4, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l4_to_mb_fli_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 5, 'mb_fli', 1, NULL, NULL, 'lyr'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.lyr_mb_new
SELECT * FROM TT_Translate_mb_fli_lyr_test('rawfri', 'mb07_l5_to_mb_fli_l1_map_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_mb_new_ordered AS
SELECT * FROM casfri50_test.lyr_mb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'mb', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;