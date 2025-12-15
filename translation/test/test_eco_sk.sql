CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_utm_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk_sfv_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_sk_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 1600, NULL, 'eco'); -- Generates about 500 (504) ECO rows
CREATE TABLE casfri50_test.eco_sk_new AS
SELECT * FROM TT_Translate_sk_utm_eco_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', 6000, NULL, 'eco'); -- Generates about 200 (217) ECO rows
INSERT INTO casfri50_test.eco_sk_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_6000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', 4500, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_sk_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_4500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 1750, NULL, 'eco'); -- Generates about 300 (300) ECO rows
INSERT INTO casfri50_test.eco_sk_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_1750_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 1100, NULL, 'eco'); -- Generates about 200 (222) ECO rows
INSERT INTO casfri50_test.eco_sk_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_1100_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', 1600, NULL, 'eco'); -- Generates about 200 (213) ECO rows
INSERT INTO casfri50_test.eco_sk_new 
SELECT * FROM TT_Translate_sk_sfv_eco_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_1600_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 'sk_utm', 700, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_sk_new 
SELECT * FROM TT_Translate_sk_utm_eco_test('rawfri', 'sk07_l1_to_sk_utm_l1_map_700_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_sk_new_ordered AS
SELECT * FROM casfri50_test.eco_sk_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT (TT_CheckTestNumber('eco', 'sk')).*