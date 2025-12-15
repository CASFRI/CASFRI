CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab_nfl_test');
DROP TABLE IF EXISTS casfri50_test.nfl_ab_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 3, 'ab', 1, 1120, NULL, 'nfl'); -- Generates about 200 (204) NFL rows
CREATE TABLE casfri50_test.nfl_ab_new AS 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab03_l3_to_ab_l1_map_1120_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 4, 'ab', 1, 1700, NULL, 'nfl'); -- Generates about 200 (214) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab03_l4_to_ab_l1_map_1700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 3, 'ab', 1, 1120, NULL, 'nfl'); -- Generates about 200 (203) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l3_to_ab_l1_map_1120_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 4, 'ab', 1, 1700, NULL, 'nfl'); -- Generates about 200 (210) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab06_l4_to_ab_l1_map_1700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 3, 'ab', 1, 1400, NULL, 'nfl'); -- Generates about 200 (220) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab07_l3_to_ab_l1_map_1400_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 4, 'ab', 1, 4000, NULL, 'nfl'); -- Generates about 200 (208) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab07_l4_to_ab_l1_map_4000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 3, 'ab', 1, 2000, NULL, 'nfl'); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab08_l3_to_ab_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 4, 'ab', 1, 2000, NULL, 'nfl'); -- Generates about 200 (210) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab08_l4_to_ab_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 3, 'ab', 1, 1000, NULL, 'nfl'); -- Generates about 200 (201) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab10_l3_to_ab_l1_map_1000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 4, 'ab', 1, 1850, NULL, 'nfl'); -- Generates about 200 (222) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab10_l4_to_ab_l1_map_1850_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 3, 'ab', 1, 2000, NULL, 'nfl'); -- Generates about 200 (209) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab11_l3_to_ab_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 4, 'ab', 1, 2300, NULL, 'nfl'); -- Generates about 200 (217) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab11_l4_to_ab_l1_map_2300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 3, 'ab', 1, 1600, NULL, 'nfl'); -- Generates about 200 (207) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l3_to_ab_l1_map_1600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 4, 'ab', 1, 2100, NULL, 'nfl'); -- Generates about 200 (215) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab16_l4_to_ab_l1_map_2100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 3, 'ab', 1, 1200, NULL, 'nfl'); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab21_l3_to_ab_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 4, 'ab', 1, 2600, NULL, 'nfl'); -- Generates about 200 (218) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab21_l4_to_ab_l1_map_2600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 3, 'ab', 1, 1050, NULL, 'nfl'); -- Generates about 200 (201) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab24_l3_to_ab_l1_map_1050_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 4, 'ab', 1, 1200, NULL, 'nfl'); -- Generates about 200 (206) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab24_l4_to_ab_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 3, 'ab', 1, 1200, NULL, 'nfl'); -- Generates about 300 (322) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab25_l3_to_ab_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 4, 'ab', 1, 1300, NULL, 'nfl'); -- Generates about 200 (236) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab25_l4_to_ab_l1_map_1300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 3, 'ab', 1, 3000, NULL, 'nfl'); -- Generates about 200 (223) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab27_l3_to_ab_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 4, 'ab', 1, 1250, NULL, 'nfl'); -- Generates about 200 (214) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab27_l4_to_ab_l1_map_1250_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 3, 'ab', 1, 1300, NULL, 'nfl'); -- Generates about 300 (343) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab29_l3_to_ab_l1_map_1300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 4, 'ab', 1, 1650, NULL, 'nfl'); -- Generates about 300 (303) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab29_l4_to_ab_l1_map_1650_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 3, 'ab', 1, 2500, NULL, 'nfl'); -- Generates about 300 (315) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab31_l3_to_ab_l1_map_2500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 4, 'ab', 1, 2300, NULL, 'nfl'); -- Generates about 300 (322) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab31_l4_to_ab_l1_map_2300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 3, 'ab', 1, 2050, NULL, 'nfl'); -- Generates about 300 (334) NFL rows
INSERT INTO casfri50_test.nfl_ab_new
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab32_l3_to_ab_l1_map_2050_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 4, 'ab', 1, 2050, NULL, 'nfl'); -- Generates about 300 (318) NFL rows
INSERT INTO casfri50_test.nfl_ab_new 
SELECT * FROM TT_Translate_ab_nfl_test('rawfri', 'ab32_l4_to_ab_l1_map_2050_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_ab_new_ordered AS
SELECT * FROM casfri50_test.nfl_ab_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT (TT_CheckTestNumber('nfl', 'ab')).*