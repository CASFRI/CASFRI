CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_panp01_lyr', '_pc_panp_lyr_test', 'ab_avi01_lyr', FALSE);
SELECT TT_Prepare('translation', 'pc_wbnp01_lyr', '_pc_wbnp_lyr_test', 'ab_avi01_lyr', FALSE);
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
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, 300, NULL, 'lyr'); -- Generates 210 LYR rows
CREATE TABLE casfri50_test.lyr_pc_new AS
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l1_to_pc_panp_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1, 600, NULL, 'lyr'); -- Generates 106 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l2_to_pc_panp_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1, NULL, NULL, 'lyr'); -- Generates 137 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_panp_lyr_test('rawfri', 'pc01_l3_to_pc_panp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 40, NULL, 'lyr'); -- Generates 20 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_40_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 70, NULL, 'lyr'); -- Generates 36 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_70_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 100, NULL, 'lyr'); -- Generates 52 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 120, NULL, 'lyr'); -- Generates 17 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, 800, NULL, 'lyr'); -- Generates 45 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates 2 LYR rows
INSERT INTO casfri50_test.lyr_pc_new
SELECT * FROM TT_Translate_pc_wbnp_lyr_test('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, NULL, 'lyr'); -- Generates 7 LYR rows
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
-- SELECT  *
FROM TT_CheckNumberOfTests('lyr', 'pc', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/