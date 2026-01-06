CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr_test', 'ab_avi01_lyr', FALSE);
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_nb_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nb_species_codes_idx
ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 730, NULL, 'lyr'); -- Generates 601 LYR rows
CREATE TABLE casfri50_test.lyr_nb_new AS
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l1_to_nb_l1_map_730_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 1800, NULL, 'lyr'); -- Generates 326 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb01_l2_to_nb_l1_map_1800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 700, NULL, 'lyr'); -- Generates 464 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l1_to_nb_l1_map_700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 1850, NULL, 'lyr'); -- Generates 550 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb02_l2_to_nb_l1_map_1850_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb03', 1, 'nb', 1, 800, NULL, 'lyr'); -- Generates 478 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb03_l1_to_nb_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb03', 2, 'nb', 1, 2500, NULL, 'lyr'); -- Generates 820 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb03_l2_to_nb_l1_map_2500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb06', 1, 'nb', 1, 800, NULL, 'lyr'); -- Generates 506 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb06_l1_to_nb_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb06', 2, 'nb', 1, 2500, NULL, 'lyr'); -- Generates 810 LYR rows
INSERT INTO casfri50_test.lyr_nb_new
SELECT * FROM TT_Translate_nb_lyr_test('rawfri', 'nb06_l2_to_nb_l1_map_2500_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_nb_new_ordered AS
SELECT * FROM casfri50_test.lyr_nb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'nb', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;