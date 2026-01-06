CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr_test', 'ab_avi01_lyr', FALSE);
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_nt_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nt_species_codes_idx
ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 500, NULL, 'lyr'); -- Generates about 400 (438) LYR rows
CREATE TABLE casfri50_test.lyr_nt_new AS
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l1_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 7000, NULL, 'lyr'); -- Generates about 200 (208) LYR rows
INSERT INTO casfri50_test.lyr_nt_new
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt01_l2_to_nt_l1_map_7000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1, 500, NULL, 'lyr'); -- Generates about 400 (402) LYR rows
INSERT INTO casfri50_test.lyr_nt_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt03_l1_to_nt_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 2, 'nt', 1, 850, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_nt_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt03_l2_to_nt_l1_map_850_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt04', 1, 'nt', 1, 750, NULL, 'lyr'); -- Generates about 200 (229) LYR rows
INSERT INTO casfri50_test.lyr_nt_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt04_l1_to_nt_l1_map_750_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt04', 2, 'nt', 1, 5000, NULL, 'lyr'); -- Generates 51 LYR rows
INSERT INTO casfri50_test.lyr_nt_new 
SELECT * FROM TT_Translate_nt_lyr_test('rawfri', 'nt04_l2_to_nt_l1_map_5000_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_nt_new_ordered AS
SELECT * FROM casfri50_test.lyr_nt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'nt', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;