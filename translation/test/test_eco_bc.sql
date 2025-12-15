CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_bc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 'bc', 14000, NULL, 'eco'); -- Generates about 200 (200) ECO rows
CREATE TABLE casfri50_test.eco_bc_new AS
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc04_l1_to_bc_l1_map_14000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 14000, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc08_l1_to_bc_l1_map_14000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 15000, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc10_l1_to_bc_l1_map_15000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 'bc', 14500, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc11_l1_to_bc_l1_map_14500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 'bc', 15000, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc12_l1_to_bc_l1_map_15000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 'bc', 30000, NULL, 'eco'); -- Generates about 200 (211) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc13_l1_to_bc_l1_map_30000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 'bc', 22000, NULL, 'eco'); -- Generates about 200 (219) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc14_l1_to_bc_l1_map_22000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 'bc', 22000, NULL, 'eco'); -- Generates about 200 (220) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc15_l1_to_bc_l1_map_22000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 'bc', 21000, NULL, 'eco'); -- Generates about 200 (227) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc16_l1_to_bc_l1_map_21000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 'bc', 22000, NULL, 'eco'); -- Generates about 200 (221) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc17_l1_to_bc_l1_map_22000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 'bc', 16000, NULL, 'eco'); -- Generates about 200 (214) ECO rows
INSERT INTO casfri50_test.eco_bc_new
SELECT * FROM TT_Translate_bc_eco_test('rawfri', 'bc18_l1_to_bc_l1_map_16000_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_bc_new_ordered AS
SELECT * FROM casfri50_test.eco_bc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT (TT_CheckTestNumber('eco', 'bc')).*