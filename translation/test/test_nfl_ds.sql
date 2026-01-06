CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ds_bea01_nfl', '_ds_bea01_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_ds_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds04', 1, 'ds', 1, 510, NULL, 'nfl'); -- Generates 300 (320) LYR rows
CREATE TABLE casfri50_test.nfl_ds_new AS
SELECT * FROM TT_Translate_ds_bea01_nfl_test('rawfri', 'ds04_l1_to_ds_l1_map_510_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_ds_new_ordered AS
SELECT * FROM casfri50_test.nfl_ds_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT (TT_CheckNumberOfTests('nfl', 'ds')).*