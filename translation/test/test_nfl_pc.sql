CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_panp01_nfl', '_pc_panp_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pc_wbnp01_nfl', '_pc_wbnp_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_pc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 500, NULL, 'nfl'); -- Generates 200 (214) LYR rows
CREATE TABLE casfri50_test.nfl_pc_new AS
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l4_to_pc_panp_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 6000, NULL, 'nfl'); -- Generates 200 (200) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l5_to_pc_panp_l1_map_6000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, NULL, NULL, 'nfl'); -- Generates 200 (14) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_panp_nfl_test('rawfri', 'pc01_l6_to_pc_panp_l1_map_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 600, NULL, 'nfl'); -- Generates 200 (215) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 450, NULL, 'nfl'); -- Generates 200 (237) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 1000, NULL, 'nfl'); -- Generates 200 (227) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_1000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, NULL, NULL, 'nfl'); -- Generates 200 (186) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, NULL, NULL, 'nfl'); -- Generates 200 (70) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, NULL, NULL, 'nfl'); -- Generates 200 (23) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, NULL, NULL, 'nfl'); -- Generates 200 (0) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 15, 'pc_wbnp', 1, NULL, NULL, 'nfl'); -- Generates 200 (164) LYR rows
INSERT INTO casfri50_test.nfl_pc_new
SELECT * FROM TT_Translate_pc_wbnp_nfl_test('rawfri', 'pc02_l15_to_pc_wbnp_l1_map_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_pc_new_ordered AS
SELECT * FROM casfri50_test.nfl_pc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT (TT_CheckTestNumber('nfl', 'pc')).*