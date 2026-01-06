CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_nb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1, 2200, NULL, 'nfl'); -- Generates about 200 (208) NFL rows
CREATE TABLE casfri50_test.nfl_nb_new AS
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb01_l3_to_nb_l1_map_2200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 3, 'nb', 1, 2600, NULL, 'nfl'); -- Generates about 300 (316) NFL rows
INSERT INTO casfri50_test.nfl_nb_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb02_l3_to_nb_l1_map_2600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb03', 3, 'nb', 1, 2600, NULL, 'nfl'); -- Generates about 300 (316) NFL rows
INSERT INTO casfri50_test.nfl_nb_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb03_l3_to_nb_l1_map_2600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb06', 3, 'nb', 1, 3500, NULL, 'nfl'); -- Generates about 400 (415) NFL rows
INSERT INTO casfri50_test.nfl_nb_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb06_l3_to_nb_l1_map_3500_nfl');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.nfl_nb_new_ordered AS
SELECT * FROM casfri50_test.nfl_nb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'nb', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;