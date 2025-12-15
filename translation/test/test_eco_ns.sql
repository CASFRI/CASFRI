CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ns_nsi01_eco', '_ns_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_ns_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 'ns_nsi', 3400, NULL, 'eco'); -- Generates about 300 (328) ECO rows
CREATE TABLE casfri50_test.eco_ns_new AS
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_3400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 'ns_nsi', 3400, NULL, 'eco'); -- Generates about 300 (329) ECO rows
INSERT INTO casfri50_test.eco_ns_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_3400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 2500, NULL, 'eco'); -- Generates about 300 (314) ECO rows
INSERT INTO casfri50_test.eco_ns_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_2500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns04', 'ns_nsi', 2500, NULL, 'eco'); -- Generates about 300 (317) ECO rows
INSERT INTO casfri50_test.eco_ns_new 
SELECT * FROM TT_Translate_ns_eco_test('rawfri', 'ns04_l1_to_ns_nsi_l1_map_2500_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_ns_new_ordered AS
SELECT * FROM casfri50_test.eco_ns_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT (TT_CheckTestNumber('eco', 'ns')).*