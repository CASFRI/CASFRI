CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_utm_lyr_test', 'ab_avi01_lyr', FALSE); 
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk_sfv_lyr_test', 'ab_avi01_lyr', FALSE); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_sk_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_sk_species_codes_idx
ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 1200, NULL, 'lyr'); -- Generates about 800 (851) LYR rows
CREATE TABLE casfri50_test.lyr_sk_new AS
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, 25000, NULL, 'lyr'); -- Generates about 200 (201) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk01_l2_to_sk_utm_l1_map_25000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 230, NULL, 'lyr'); -- Generates about 200 (200) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_230_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1, 550, NULL, 'lyr'); -- Generates about 100 (113) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l2_to_sk_sfv_l1_map_550_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1, NULL, NULL, 'lyr'); -- Generates about 200 (165) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk02_l3_to_sk_sfv_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 280, NULL, 'lyr'); -- Generates about 200 (228) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_280_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1, 250, NULL, 'lyr'); -- Generates about 100 (101) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l2_to_sk_sfv_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1, NULL, NULL, 'lyr'); -- Generates about 200 (14) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk03_l3_to_sk_sfv_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 580, NULL, 'lyr'); -- Generates about 500 (515) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_580_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 2, 'sk_sfv', 1, 1300, NULL, 'lyr'); -- Generates about 300 (310) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l2_to_sk_sfv_l1_map_1300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 3, 'sk_sfv', 1, 20000, NULL, 'lyr'); -- Generates about 100 (108) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk04_l3_to_sk_sfv_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 450, NULL, 'lyr'); -- Generates about 400 (417) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1, 1300, NULL, 'lyr'); -- Generates about 300 (331) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l2_to_sk_sfv_l1_map_1300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1, 30000, NULL, 'lyr'); -- Generates about 100 (114) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk05_l3_to_sk_sfv_l1_map_30000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 360, NULL, 'lyr'); -- Generates about 300 (317) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_360_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 2, 'sk_sfv', 1, 650, NULL, 'lyr'); -- Generates about 300 (318) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l2_to_sk_sfv_l1_map_650_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 3, 'sk_sfv', 1, 4200, NULL, 'lyr'); -- Generates about 200 (206) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_sfv_lyr_test('rawfri', 'sk06_l3_to_sk_sfv_l1_map_4200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 1, 'sk_utm', 1, 1200, NULL, 'lyr'); -- Generates about 800 (853) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk07_l1_to_sk_utm_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 2, 'sk_utm', 1, 22000, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_sk_new
SELECT * FROM TT_Translate_sk_utm_lyr_test('rawfri', 'sk07_l2_to_sk_utm_l1_map_22000_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_sk_new_ordered AS
SELECT * FROM casfri50_test.lyr_sk_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('lyr', 'sk', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/