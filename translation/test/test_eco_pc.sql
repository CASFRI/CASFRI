CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_panp01_eco', '_pc_panp_eco_test', 'ab_avi01_eco', FALSE);
SELECT TT_Prepare('translation', 'pc_wbnp01_eco', '_pc_wbnp_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_pc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 300, NULL, 'eco'); -- Generates 64 ECO rows
CREATE TABLE casfri50_test.eco_pc_new AS
SELECT * FROM TT_Translate_pc_panp_eco_test('rawfri', 'pc01_l4_to_pc_panp_l1_map_300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 1000, NULL, 'eco'); -- Generates 39 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_panp_eco_test('rawfri', 'pc01_l5_to_pc_panp_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, NULL, NULL, 'eco'); -- Generates 6 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_panp_eco_test('rawfri', 'pc01_l6_to_pc_panp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 400, NULL, 'eco'); -- Generates 12 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 100, NULL, 'eco'); -- Generates 12 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_100_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 50, NULL, 'eco'); -- Generates 5 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_50_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 50, NULL, 'eco'); -- Generates 7 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_50_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, 200, NULL, 'eco'); -- Generates 7 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 20, NULL, 'eco'); -- Generates 6 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_20_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 20, NULL, 'eco'); -- Generates 9 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_20_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 50, NULL, 'eco'); -- Generates 15 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_50_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, 50, NULL, 'eco'); -- Generates 9 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_50_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, 200, NULL, 'eco'); -- Generates 13 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_200_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, 300, NULL, 'eco'); -- Generates 7 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, NULL, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_eco_test('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_pc_new_ordered AS
SELECT * FROM casfri50_test.eco_pc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('eco', 'pc', FALSE)
WHERE NOT sufficient OR diff_pct >= 20;
*/