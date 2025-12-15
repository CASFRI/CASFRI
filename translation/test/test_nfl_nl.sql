CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nl_nli01_nfl', '_nl_nli01_nfl_test', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'nl_nli02_nfl', '_nl_nli02_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_nl_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli1', 1, 1800, NULL, 'nfl'); -- Generates about 600 (618) NFL rows
CREATE TABLE casfri50_test.nfl_nl_new AS
SELECT * FROM TT_Translate_nl_nli01_nfl_test('rawfri', 'nl01_l1_to_nl_nli1_l1_map_1800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1, 2800, NULL, 'nfl'); -- Generates about 500 (532) NFL rows
INSERT INTO casfri50_test.nfl_nl_new 
SELECT * FROM TT_Translate_nl_nli02_nfl_test('rawfri', 'nl02_l1_to_nl_nli2_l1_map_2800_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_nl_new_ordered AS
SELECT * FROM casfri50_test.nfl_nl_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT (TT_CheckTestNumber('nfl', 'nl')).*