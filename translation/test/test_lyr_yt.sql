CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_01_lyr_test', 'ab_avi01_lyr', FALSE); 
SELECT TT_Prepare('translation', 'yt_yvi02_lyr', '_yt_02_lyr_test', 'ab_avi01_lyr', FALSE); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_yt_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_yt_species_codes_idx
ON translation.species_code_mapping (yt_species_codes)
WHERE TT_NotEmpty(yt_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 1, 'yt', 1, 680, NULL, 'lyr'); -- Generates about 300 (314) LYR rows
CREATE TABLE casfri50_test.lyr_yt_new AS
SELECT * FROM TT_Translate_yt_01_lyr_test('rawfri', 'yt01_l1_to_yt_l1_map_680_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 750, NULL, 'lyr'); -- Generates about 300 (336) LYR rows
INSERT INTO casfri50_test.lyr_yt_new
SELECT * FROM TT_Translate_yt_01_lyr_test('rawfri', 'yt02_l1_to_yt_l1_map_750_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1, 300, NULL, 'lyr'); -- Generates about 200 (232) LYR rows
INSERT INTO casfri50_test.lyr_yt_new
SELECT * FROM TT_Translate_yt_02_lyr_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1, 2000, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_yt_new
SELECT * FROM TT_Translate_yt_02_lyr_test('rawfri', 'yt03_l2_to_yt_yvi02_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt04', 1, 'yt', 1, 680, NULL, 'lyr'); -- Generates about 300 (314) LYR rows
INSERT INTO casfri50_test.lyr_yt_new
SELECT * FROM TT_Translate_yt_01_lyr_test('rawfri', 'yt04_l1_to_yt_l1_map_680_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_yt_new_ordered AS
SELECT * FROM casfri50_test.lyr_yt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('lyr', 'yt', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/