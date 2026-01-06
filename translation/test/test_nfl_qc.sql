CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'qc_ini03_nfl', '_qc_ini03_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'qc_ini04_nfl', '_qc_ini04_nfl_test', 'ab_avi01_nfl', FALSE);
SELECT TT_Prepare('translation', 'qc_ipf05_nfl', '_qc_ipf05_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_qc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 3, 'qc_ini03', 1, 4000, NULL, 'nfl'); -- Generates about 800 (827) NFL rows
CREATE TABLE casfri50_test.nfl_qc_new AS
SELECT * FROM TT_Translate_qc_ini03_nfl_test('rawfri', 'qc01_l3_to_qc_ini03_l1_map_4000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 3, 'qc_ini03', 1, 2550, NULL, 'nfl'); -- Generates about 600 (637) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ini03_nfl_test('rawfri', 'qc02_l3_to_qc_ini03_l1_map_2550_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 3, 'qc_ini03', 1, 650, NULL, 'nfl'); -- Generates about 300 (330) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ini03_nfl_test('rawfri', 'qc03_l3_to_qc_ini03_l1_map_650_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 3, 'qc_ini04', 1, 3500, NULL, 'nfl'); -- Generates about 400 (444) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ini04_nfl_test('rawfri', 'qc04_l3_to_qc_ini04_l1_map_3500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 3, 'qc_ipf', 1, 5500, NULL, 'nfl'); -- Generates about 800 (840) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_nfl_test('rawfri', 'qc05_l3_to_qc_ipf_l1_map_5500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 3, 'qc_ini04', 1, 4500, NULL, 'nfl'); -- Generates about 600 (607) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ini04_nfl_test('rawfri', 'qc06_l3_to_qc_ini04_l1_map_4500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 3, 'qc_ipf', 1, 1450, NULL, 'nfl'); -- Generates about 200 (232) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_nfl_test('rawfri', 'qc07_l3_to_qc_ipf_l1_map_1450_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc08', 3, 'qc_ini03', 1, 600, NULL, 'nfl'); -- Generates about 300 (300) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ini03_nfl_test('rawfri', 'qc08_l3_to_qc_ini03_l1_map_600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc09', 3, 'qc_ini04', 1, 1350, NULL, 'nfl'); -- Generates about 200 (221) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ini04_nfl_test('rawfri', 'qc09_l3_to_qc_ini04_l1_map_1350_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc10', 3, 'qc_ipf', 1, 6000, NULL, 'nfl'); -- Generates about 800 (875) NFL rows
INSERT INTO casfri50_test.nfl_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_nfl_test('rawfri', 'qc10_l3_to_qc_ipf_l1_map_6000_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_qc_new_ordered AS
SELECT * FROM casfri50_test.nfl_qc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT * 
-- FROM TT_CheckNumberOfTests('nfl', 'qc', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;
