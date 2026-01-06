CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_utm_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk_sfv_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_sk_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, 2000, NULL, 'nfl'); -- Generates 420 NFL rows
CREATE TABLE casfri50_test.nfl_sk_new AS
SELECT * FROM TT_Translate_sk_utm_nfl_test('rawfri', 'sk01_l3_to_sk_utm_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 4, 'sk_sfv', 1, 300, NULL, 'nfl'); -- Generates 113 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l4_to_sk_sfv_l1_map_300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 5, 'sk_sfv', 1, 300, NULL, 'nfl'); -- Generates 65 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l5_to_sk_sfv_l1_map_300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1, 2000, NULL, 'nfl'); -- Generates 45 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk02_l6_to_sk_sfv_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1, 200, NULL, 'nfl'); -- Generates 96 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l4_to_sk_sfv_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1, 200, NULL, 'nfl'); -- Generates 55 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l5_to_sk_sfv_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1, 1000, NULL, 'nfl'); -- Generates 71 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk03_l6_to_sk_sfv_l1_map_1000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 4, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates 233 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l4_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 5, 'sk_sfv', 1, 800, NULL, 'nfl'); -- Generates 89 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l5_to_sk_sfv_l1_map_800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 6, 'sk_sfv', 1, 1200, NULL, 'nfl'); -- Generates 103 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk04_l6_to_sk_sfv_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, 600, NULL, 'nfl'); -- Generates 179 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l4_to_sk_sfv_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, 600, NULL, 'nfl'); -- Generates 66 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l5_to_sk_sfv_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, 1200, NULL, 'nfl'); -- Generates 62 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk05_l6_to_sk_sfv_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 4, 'sk_sfv', 1, 500, NULL, 'nfl'); -- Generates 135 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l4_to_sk_sfv_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 5, 'sk_sfv', 1, 600, NULL, 'nfl'); -- Generates 49 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l5_to_sk_sfv_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 6, 'sk_sfv', 1, 1200, NULL, 'nfl'); -- Generates 35 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_sfv_nfl_test('rawfri', 'sk06_l6_to_sk_sfv_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 3, 'sk_utm', 1, 2000, NULL, 'nfl'); -- Generates 431 NFL rows
INSERT INTO casfri50_test.nfl_sk_new 
SELECT * FROM TT_Translate_sk_utm_nfl_test('rawfri', 'sk07_l3_to_sk_utm_l1_map_2000_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_sk_new_ordered AS
SELECT * FROM casfri50_test.nfl_sk_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'sk', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;