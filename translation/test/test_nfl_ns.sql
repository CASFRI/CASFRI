CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ns_nsi01_nfl', '_ns_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_ns_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 3, 'ns_nsi', 1, 2000, NULL, 'nfl'); -- Generates about 300 (349) NFL rows
CREATE TABLE casfri50_test.nfl_ns_new AS
SELECT * FROM TT_Translate_ns_nfl_test('rawfri', 'ns01_l3_to_ns_nsi_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 3, 'ns_nsi', 1, 2000, NULL, 'nfl'); -- Generates about 300 (335) NFL rows
INSERT INTO casfri50_test.nfl_ns_new 
SELECT * FROM TT_Translate_ns_nfl_test('rawfri', 'ns02_l3_to_ns_nsi_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 3, 'ns_nsi', 1, 1700, NULL, 'nfl'); -- Generates about 300 (317) NFL rows
INSERT INTO casfri50_test.nfl_ns_new 
SELECT * FROM TT_Translate_ns_nfl_test('rawfri', 'ns03_l3_to_ns_nsi_l1_map_1700_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns04', 3, 'ns_nsi', 1, 1700, NULL, 'nfl'); -- Generates about 300 (337) NFL rows
INSERT INTO casfri50_test.nfl_ns_new 
SELECT * FROM TT_Translate_ns_nfl_test('rawfri', 'ns04_l3_to_ns_nsi_l1_map_1700_nfl');
-------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_ns_new_ordered AS
SELECT * FROM casfri50_test.nfl_ns_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('nfl', 'ns', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;