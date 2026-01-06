CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_nt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1, 1350, NULL, 'nfl'); -- Generates about 200 (207) NFL rows
CREATE TABLE casfri50_test.nfl_nt_new AS
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l3_to_nt_l1_map_1350_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1, 2500, NULL, 'nfl'); -- Generates about 200 (207) NFL rows
INSERT INTO casfri50_test.nfl_nt_new
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt01_l4_to_nt_l1_map_2500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 3, 'nt', 1, 1300, NULL, 'nfl'); -- Generates about 200 (223) NFL rows
INSERT INTO casfri50_test.nfl_nt_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt03_l3_to_nt_l1_map_1300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 4, 'nt', 1, 920, NULL, 'nfl'); -- Generates about 200 (217) NFL rows
INSERT INTO casfri50_test.nfl_nt_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt03_l4_to_nt_l1_map_920_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt04', 3, 'nt', 1, 350, NULL, 'nfl'); -- Generates about 200 (228) NFL rows
INSERT INTO casfri50_test.nfl_nt_new 
SELECT * FROM TT_Translate_nt_nfl_test('rawfri', 'nt04_l3_to_nt_l1_map_350_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_nt_new_ordered AS
SELECT * FROM casfri50_test.nfl_nt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('nfl', 'nt', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/