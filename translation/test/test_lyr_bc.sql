CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr_test', 'ab_avi01_lyr');
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_bc_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_bc_species_codes_idx
ON translation.species_code_mapping (bc_species_codes)
WHERE TT_NotEmpty(bc_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1044) LYR rows
CREATE TABLE casfri50_test.lyr_bc_new AS
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc04_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1055) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, 10000, NULL, 'lyr'); -- Generates about 300 (354) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc08_l2_to_bc_l1_map_10000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 1120, NULL, 'lyr'); -- Generates about 1000 (1004) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l1_to_bc_l1_map_1120_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 9000, NULL, 'lyr'); -- Generates about 300 (315) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc10_l2_to_bc_l1_map_9000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1074) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc11_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 2, 'bc', 1, 9300, NULL, 'lyr'); -- Generates about 300 (317) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc11_l2_to_bc_l1_map_9300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1077) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc12_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 2, 'bc', 1, 10000, NULL, 'lyr'); -- Generates about 300 (332) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc12_l2_to_bc_l1_map_10000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 1, 'bc', 1, 1200, NULL, 'lyr'); -- Generates about 1000 (1018) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc13_l1_to_bc_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 1, 'bc', 1, 1100, NULL, 'lyr'); -- Generates about 1000 (1085) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc14_l1_to_bc_l1_map_1100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 2, 'bc', 1, 11000, NULL, 'lyr'); -- Generates about 400 (461) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc14_l2_to_bc_l1_map_11000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 1, 'bc', 1, 1050, NULL, 'lyr'); -- Generates about 1000 (1039) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc15_l1_to_bc_l1_map_1050_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 2, 'bc', 1, 11100, NULL, 'lyr'); -- Generates about 400 (415) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc15_l2_to_bc_l1_map_11100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 1, 'bc', 1, 1050, NULL, 'lyr'); -- Generates about 1000 (1044) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc16_l1_to_bc_l1_map_1050_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 2, 'bc', 1, 11100, NULL, 'lyr'); -- Generates about 400 (404) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc16_l2_to_bc_l1_map_11100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 1, 'bc', 1, 1050, NULL, 'lyr'); -- Generates about 1000 (1033) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc17_l1_to_bc_l1_map_1050_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 2, 'bc', 1, 8300, NULL, 'lyr'); -- Generates about 300 (304) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc17_l2_to_bc_l1_map_8300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 1, 'bc', 1, 1050, NULL, 'lyr'); -- Generates about 1000 (1042) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc18_l1_to_bc_l1_map_1050_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 2, 'bc', 1, 11000, NULL, 'lyr'); -- Generates about 400 (311) LYR rows
INSERT INTO casfri50_test.lyr_bc_new
SELECT * FROM TT_Translate_bc_lyr_test('rawfri', 'bc18_l2_to_bc_l1_map_11000_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_bc_new_ordered AS
SELECT * FROM casfri50_test.lyr_bc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'bc', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;