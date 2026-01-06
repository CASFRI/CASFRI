CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_on_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 3, 'on', 1, 3100, NULL, 'nfl'); -- Generates about 800 (808) NFL rows
CREATE TABLE casfri50_test.nfl_on_new AS
SELECT * FROM TT_Translate_on_nfl_test('rawfri', 'on01_l3_to_on_l1_map_3100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 3, 'on', 1, 2200, NULL, 'nfl'); -- Generates about 800 (803) NFL rows
INSERT INTO casfri50_test.nfl_on_new 
SELECT * FROM TT_Translate_on_nfl_test('rawfri', 'on02_l3_to_on_l1_map_2200_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_on_new_ordered AS
SELECT * FROM casfri50_test.nfl_on_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'on', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;