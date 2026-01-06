CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'mb_fri01_nfl', '_mb_fri_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'mb_fri02_nfl', '_mb_fri02_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'mb_fli01_nfl', '_mb_fli_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_mb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 2, 'mb_fri2', 1, 2200, NULL, 'nfl'); -- Generates about 200 (227) NFL rows
CREATE TABLE casfri50_test.nfl_mb_new AS
SELECT * FROM TT_Translate_mb_fri02_nfl_test('rawfri', 'mb01_l2_to_mb_fri2_l1_map_2200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 6, 'mb_fli', 1, 1300, NULL, 'nfl'); -- Generates about 100 (118) NFL rows
INSERT INTO casfri50_test.nfl_mb_new 
SELECT * FROM TT_Translate_mb_fli_nfl_test('rawfri', 'mb02_l6_to_mb_fli_l1_map_1300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 6, 'mb_fli', 1, 1300, NULL, 'nfl'); -- Generates about 100 (115) NFL rows
INSERT INTO casfri50_test.nfl_mb_new 
SELECT * FROM TT_Translate_mb_fli_nfl_test('rawfri', 'mb04_l6_to_mb_fli_l1_map_1300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 2, 'mb_fri', 1, 2000, NULL, 'nfl'); -- Generates about 400 (411) NFL rows
INSERT INTO casfri50_test.nfl_mb_new 
SELECT * FROM TT_Translate_mb_fri_nfl_test('rawfri', 'mb05_l2_to_mb_fri_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 6, 'mb_fli', 1, 3400, NULL, 'nfl'); -- Generates about 200 (210) NFL rows
INSERT INTO casfri50_test.nfl_mb_new 
SELECT * FROM TT_Translate_mb_fli_nfl_test('rawfri', 'mb06_l6_to_mb_fli_l1_map_3400_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 6, 'mb_fli', 1, 2000, NULL, 'nfl'); -- Generates about 200 (228) NFL rows
INSERT INTO casfri50_test.nfl_mb_new 
SELECT * FROM TT_Translate_mb_fli_nfl_test('rawfri', 'mb07_l6_to_mb_fli_l1_map_2000_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_mb_new_ordered AS
SELECT * FROM casfri50_test.nfl_mb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'mb', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;