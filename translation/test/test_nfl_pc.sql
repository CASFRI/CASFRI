CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_panp01_nfl', '_pc_panp_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'pc_wbnp01_nfl', '_pc_wbnp_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_pc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 200, NULL, 'nfl'); -- Generates 84 LYR rows
CREATE TABLE casfri50_test.nfl_pc_new AS
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l4_to_pc_panp_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 200, NULL, 'nfl'); -- Generates 9 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l5_to_pc_panp_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, NULL, NULL, 'nfl'); -- Generates 14 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l6_to_pc_panp_l1_map_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 50, NULL, 'nfl'); -- Generates 18 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_50_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 50, NULL, 'nfl'); -- Generates 25 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_50_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 100, NULL, 'nfl'); -- Generates 20 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, 100, NULL, 'nfl'); -- Generates 19 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, 100, NULL, 'nfl'); -- Generates 10 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, 100, NULL, 'nfl'); -- Generates 2 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, 100, NULL, 'nfl'); -- Generates 0 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 15, 'pc_wbnp', 1, 100, NULL, 'nfl'); -- Generates 16 LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l15_to_pc_wbnp_l1_map_100_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_pc_new_ordered AS
SELECT * FROM casfri50_test.nfl_pc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('nfl', 'pc', FALSE)
WHERE NOT sufficient OR diff_pct >= 20;
*/