CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_01_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'yt_yvi02_nfl', '_yt_02_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_yt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 2, 'yt', 1, 600, NULL, 'nfl'); -- Generates about 200 (213) NFL rows
CREATE TABLE casfri50_test.nfl_yt_new AS
SELECT * FROM TT_Translate_yt_01_nfl_test('rawfri', 'yt01_l2_to_yt_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 2, 'yt', 1, 645, NULL, 'nfl'); -- Generates about 200 (221) NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_01_nfl_test('rawfri', 'yt02_l2_to_yt_l1_map_645_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 3, 'yt_yvi02', 1, 150, NULL, 'nfl'); -- Generates 15 NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_02_nfl_test('rawfri', 'yt03_l3_to_yt_yvi02_l1_map_150_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 4, 'yt_yvi02', 1, 150, NULL, 'nfl'); -- Generates 14 NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_02_nfl_test('rawfri', 'yt03_l4_to_yt_yvi02_l1_map_150_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 5, 'yt_yvi02', 1, 150, NULL, 'nfl'); -- Generates 0 NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_02_nfl_test('rawfri', 'yt03_l5_to_yt_yvi02_l1_map_150_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 6, 'yt_yvi02', 1, 150, NULL, 'nfl'); -- Generates 2 NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_02_nfl_test('rawfri', 'yt03_l6_to_yt_yvi02_l1_map_150_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 7, 'yt_yvi02', 1, 150, NULL, 'nfl'); -- Generates 102 NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_02_nfl_test('rawfri', 'yt03_l7_to_yt_yvi02_l1_map_150_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 8, 'yt_yvi02', 1, 200, NULL, 'nfl'); -- Generates 100 NFL rows
INSERT INTO casfri50_test.nfl_yt_new 
SELECT * FROM TT_Translate_yt_02_nfl_test('rawfri', 'yt03_l8_to_yt_yvi02_l1_map_200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt04', 2, 'yt', 1, 2500, NULL, 'nfl'); -- Generates 202 NFL rows
INSERT INTO casfri50_test.nfl_yt_new
SELECT * FROM TT_Translate_yt_01_nfl_test('rawfri', 'yt04_l2_to_yt_l1_map_2500_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_yt_new_ordered AS
SELECT * FROM casfri50_test.nfl_yt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'yt', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;