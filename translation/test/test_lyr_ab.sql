CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr_test');
------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_ab_new CASCADE;
------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (252) LYR rows
CREATE TABLE casfri50_test.lyr_ab_new AS 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab03_l1_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (225) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab03_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (241) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l1_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 480, NULL, 'lyr'); -- Generates about 200 (218) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab06_l2_to_ab_l1_map_480_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab07_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 2, 'ab', 1, 300, NULL, 'lyr'); -- Generates about 200 (202) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab07_l2_to_ab_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (228) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab08_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (222) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab08_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 300 (306) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab10_l1_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (230) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab10_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 300 (349) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab11_l1_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 2, 'ab', 1, 3400, NULL, 'lyr'); -- Generates about 200 (203) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab11_l2_to_ab_l1_map_3400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 360, NULL, 'lyr'); -- Generates about 300 (329) LYR rows
INSERT INTO casfri50_test.lyr_ab_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l1_to_ab_l1_map_360_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 200 (231) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab16_l2_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 1, 'ab', 1, 500, NULL, 'lyr'); -- Generates about 400 (428) LYR rows
INSERT INTO casfri50_test.lyr_ab_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab21_l1_to_ab_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 2, 'ab', 1, 850, NULL, 'lyr'); -- Generates about 300 (310) LYR rows
INSERT INTO casfri50_test.lyr_ab_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab21_l2_to_ab_l1_map_850_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 1, 'ab', 1, 400, NULL, 'lyr'); -- Generates about 300 (316) LYR rows
INSERT INTO casfri50_test.lyr_ab_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab24_l1_to_ab_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 2, 'ab', 1, 550, NULL, 'lyr'); -- Generates about 200 (202) LYR rows
INSERT INTO casfri50_test.lyr_ab_new
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab24_l2_to_ab_l1_map_550_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1, 600, NULL, 'lyr'); -- Generates about 400 (426) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab25_l1_to_ab_l1_map_600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 2, 'ab', 1, 1200, NULL, 'lyr'); -- Generates about 300 (335) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab25_l2_to_ab_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1, 250, NULL, 'lyr'); -- Generates about 200 (228) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab27_l1_to_ab_l1_map_250_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 2, 'ab', 1, 900, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab27_l2_to_ab_l1_map_900_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1, 700, NULL, 'lyr'); -- Generates about 500 (515) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab29_l1_to_ab_l1_map_700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 2, 'ab', 1, 1200, NULL, 'lyr'); -- Generates about 300 (330) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab29_l2_to_ab_l1_map_1200_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 1, 'ab', 1, 710, NULL, 'lyr'); -- Generates about 600 (614) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab31_l1_to_ab_l1_map_710_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 2, 'ab', 1, 2000, NULL, 'lyr'); -- Generates about 300 (312) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab31_l2_to_ab_l1_map_2000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 1, 'ab', 1, 750, NULL, 'lyr'); -- Generates about 600 (648) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab32_l1_to_ab_l1_map_750_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 2, 'ab', 1, 2000, NULL, 'lyr'); -- Generates about 300 (352) LYR rows
INSERT INTO casfri50_test.lyr_ab_new 
SELECT * FROM TT_Translate_ab_lyr_test('rawfri', 'ab32_l2_to_ab_l1_map_2000_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_ab_new_ordered AS
SELECT * FROM casfri50_test.lyr_ab_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT (TT_CheckTestNumber('lyr', 'ab')).*
