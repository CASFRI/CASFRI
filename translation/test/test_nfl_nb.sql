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
SELECT TT_CreateMappingView('rawfri', 'nb06', 3, 'nb', 1, 2600, NULL, 'nfl'); -- Generates about 300 (316) NFL rows
INSERT INTO casfri50_test.nfl_nb_new
SELECT * FROM TT_Translate_nb_nfl_test('rawfri', 'nb06_l3_to_nb_l1_map_2600_nfl');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.nfl_nb_new_ordered AS
SELECT * FROM casfri50_test.nfl_nb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT (TT_CheckTestNumber('nfl', 'nb')).*