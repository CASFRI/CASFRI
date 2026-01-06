CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pe_pei01_nfl', '_pe_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_pe_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 2, 'pe_pei', 1, 1000, NULL, 'nfl'); -- Generates about 200 (229) NFL rows
CREATE TABLE casfri50_test.nfl_pe_new AS
SELECT * FROM TT_Translate_pe_nfl_test('rawfri', 'pe01_l2_to_pe_pei_l1_map_1000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe02', 2, 'pe_pei', 1, 500, NULL, 'nfl'); -- Generates about 200 (227) NFL rows
INSERT INTO casfri50_test.nfl_pe_new 
SELECT * FROM TT_Translate_pe_nfl_test('rawfri', 'pe02_l2_to_pe_pei_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe03', 2, 'pe_pei', 1, 500, NULL, 'nfl'); -- Generates about 200 (208) NFL rows
INSERT INTO casfri50_test.nfl_pe_new 
SELECT * FROM TT_Translate_pe_nfl_test('rawfri', 'pe03_l2_to_pe_pei_l1_map_500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe04', 2, 'pe_pei', 1, 500, NULL, 'nfl'); -- Generates about 200 (228) NFL rows
INSERT INTO casfri50_test.nfl_pe_new 
SELECT * FROM TT_Translate_pe_nfl_test('rawfri', 'pe04_l2_to_pe_pei_l1_map_500_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_pe_new_ordered AS
SELECT * FROM casfri50_test.nfl_pe_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'pe', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;