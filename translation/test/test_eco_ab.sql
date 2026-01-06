CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab_eco_test', FALSE);
DROP TABLE IF EXISTS casfri50_test.eco_ab_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab', 1600, NULL, 'eco'); -- Generates about 100 (103) ECO rows
CREATE TABLE casfri50_test.eco_ab_new AS 
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab03_l1_to_ab_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 1050, NULL, 'eco'); -- Generates about 100 (100) ECO rows
INSERT INTO casfri50_test.eco_ab_new 
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab06_l1_to_ab_l1_map_1050_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 'ab', 1500, NULL, 'eco'); -- Generates about 100 (104) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab07_l1_to_ab_l1_map_1500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 'ab', 3600, NULL, 'eco'); -- Generates about 100 (103) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab08_l1_to_ab_l1_map_3600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab', 1700, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab10_l1_to_ab_l1_map_1700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab', 3500, NULL, 'eco'); -- Generates about 200 (231) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab11_l1_to_ab_l1_map_3500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 5000, NULL, 'eco'); -- Generates about 200 (236) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab16_l1_to_ab_l1_map_5000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 'ab', 1600, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab21_l1_to_ab_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 'ab', 2700, NULL, 'eco'); -- Generates about 200 (210) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab24_l1_to_ab_l1_map_2700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab', 2300, NULL, 'eco'); -- Generates about 200 (212) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab25_l1_to_ab_l1_map_2300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 'ab', 1700, NULL, 'eco'); -- Generates about 100 (118) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab27_l1_to_ab_l1_map_1700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab', 2050, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab29_l1_to_ab_l1_map_2050_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 'ab', 2200, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab31_l1_to_ab_l1_map_2200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 'ab', 2200, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_ab_new
SELECT * FROM TT_Translate_ab_eco_test('rawfri', 'ab32_l1_to_ab_l1_map_2200_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_ab_new_ordered AS
SELECT * FROM casfri50_test.eco_ab_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('eco', 'ab', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;