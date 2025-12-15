CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_utm_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk_sfv_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_sk_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, 2000, NULL, 'nfl'); -- Generates about 400 (420) NFL rows
CREATE TABLE casfri50_test.nfl_sk_new AS
SELECT * FROM TT_Translate_sk_utm_nfl_test('rawfri', 'sk01_l3_to_sk_utm_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 4, 'sk_sfv', 1, 540, NULL, 'nfl'); -- Generates about 200 (235) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l4_to_sk_sfv_l1_map_540_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 5, 'sk_sfv', 1, 860, NULL, 'nfl'); -- Generates about 200 (209) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l5_to_sk_sfv_l1_map_860_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1, 9200, NULL, 'nfl'); -- Generates about 200 (203) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l6_to_sk_sfv_l1_map_9200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1, 450, NULL, 'nfl'); -- Generates about 200 (200) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l4_to_sk_sfv_l1_map_450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates about 200 (222) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l5_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1, 2800, NULL, 'nfl'); -- Generates about 200 (219) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l6_to_sk_sfv_l1_map_2800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 4, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates about 200 (233) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l4_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 5, 'sk_sfv', 1, 2300, NULL, 'nfl'); -- Generates about 300 (303) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l5_to_sk_sfv_l1_map_2300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 6, 'sk_sfv', 1, 3000, NULL, 'nfl'); -- Generates about 200 (238) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l6_to_sk_sfv_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates about 200 (228) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l4_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, 3000, NULL, 'nfl'); -- Generates about 300 (371) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l5_to_sk_sfv_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, 5000, NULL, 'nfl'); -- Generates about 200 (241) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l6_to_sk_sfv_l1_map_5000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 4, 'sk_sfv', 1, 850, NULL, 'nfl'); -- Generates about 200 (2231) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l4_to_sk_sfv_l1_map_850_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 5, 'sk_sfv', 1, 2200, NULL, 'nfl'); -- Generates about 200 (228) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l5_to_sk_sfv_l1_map_2200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 6, 'sk_sfv', 1, 7500, NULL, 'nfl'); -- Generates about 200 (234) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l6_to_sk_sfv_l1_map_7500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 3, 'sk_utm', 1, 3130, NULL, 'nfl'); -- Generates about 700 (724) NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_utm_nfl_test('rawfri', 'sk07_l3_to_sk_utm_l1_map_3130_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_sk_new_ordered AS
SELECT * FROM casfri50_test.nfl_sk_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT (TT_CheckTestNumber('nfl', 'sk')).*