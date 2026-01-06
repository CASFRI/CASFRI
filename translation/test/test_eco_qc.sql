CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'qc_ini03_eco', '_qc_ini03_eco_test', 'ab_avi01_eco', FALSE);
SELECT TT_Prepare('translation', 'qc_ini04_eco', '_qc_ini04_eco_test', 'ab_avi01_eco', FALSE);
SELECT TT_Prepare('translation', 'qc_ipf05_eco', '_qc_ipf05_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_qc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 'qc_ini03', 6000, NULL, 'eco'); -- Generates about 600 (620) ECO rows
CREATE TABLE casfri50_test.eco_qc_new AS
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_6000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 'qc_ini03', 3750, NULL, 'eco'); -- Generates about 500 (513) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_3750_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 'qc_ini03', 1700, NULL, 'eco'); -- Generates about 200 (209) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_1700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 'qc_ini04', 4050, NULL, 'eco'); -- Generates about 400 (409) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ini04_eco_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_4050_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 'qc_ipf', 5500, NULL, 'eco'); -- Generates about 700 (714) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_eco_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_5500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 'qc_ini04', 5000, NULL, 'eco'); -- Generates about 500 (501) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ini04_eco_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_5000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 'qc_ipf', 3000, NULL, 'eco'); -- Generates about 200 (210) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_eco_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_3000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc08', 'qc_ini03', 1800, NULL, 'eco'); -- Generates about 200 (216) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ini03_eco_test('rawfri', 'qc08_l1_to_qc_ini03_l1_map_1800_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc09', 'qc_ini04', 1600, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ini04_eco_test('rawfri', 'qc09_l1_to_qc_ini04_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc10', 'qc_ipf', 7000, NULL, 'eco'); -- Generates about 800 (865) ECO rows
INSERT INTO casfri50_test.eco_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_eco_test('rawfri', 'qc10_l1_to_qc_ipf_l1_map_7000_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_qc_new_ordered AS
SELECT * FROM casfri50_test.eco_qc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('eco', 'qc', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/