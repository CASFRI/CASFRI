CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_panp01_lyr', '_pc_panp_lyr_test', 'ab_avi01_lyr');
SELECT TT_Prepare('translation', 'pc_wbnp01_lyr', '_pc_wbnp_lyr_test', 'ab_avi01_lyr');
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_pc_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc01_species_codes_idx
ON translation.species_code_mapping (pc01_species_codes)
WHERE TT_NotEmpty(pc01_species_codes);

CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc02_species_codes_idx
ON translation.species_code_mapping (pc02_species_codes)
WHERE TT_NotEmpty(pc02_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, 300, NULL, 'lyr'); -- Generates about 200 (210) LYR rows
CREATE TABLE casfri50_test.lyr_pc_new AS
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l1_to_pc_panp_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1, 1100, NULL, 'lyr'); -- Generates about 200 (226) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l2_to_pc_panp_l1_map_1100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (137) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l3_to_pc_panp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 400, NULL, 'lyr'); -- Generates about 200 (209) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 450, NULL, 'lyr'); -- Generates about 200 (209) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 450, NULL, 'lyr'); -- Generates about 200 (224) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (192) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (59) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (2) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates about 200 (7) LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_pc_new_ordered AS
SELECT * FROM casfri50_test.lyr_pc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT (TT_CheckTestNumber('lyr', 'pc')).*