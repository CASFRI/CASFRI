CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr_test', 'ab_avi01_lyr'); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_on_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_on_species_codes_idx
ON translation.species_code_mapping (on_species_codes)
WHERE TT_NotEmpty(on_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1, 1400, NULL, 'lyr'); -- Generates about 1000 (1011) LYR rows
CREATE TABLE casfri50_test.lyr_on_new AS
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on01_l1_to_on_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 2, 'on', 1, 500000, NULL, 'lyr'); -- Generates about 50 (51) LYR rows
INSERT INTO casfri50_test.lyr_on_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on01_l2_to_on_l1_map_500000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 1600, NULL, 'lyr'); -- Generates about 1000 (1020) LYR rows
INSERT INTO casfri50_test.lyr_on_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l1_to_on_l1_map_1600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 6200, NULL, 'lyr'); -- Generates about 300 (322) LYR rows
INSERT INTO casfri50_test.lyr_on_new
SELECT * FROM TT_Translate_on_lyr_test('rawfri', 'on02_l2_to_on_l1_map_6200_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_on_new_ordered AS
SELECT * FROM casfri50_test.lyr_on_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'on', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;