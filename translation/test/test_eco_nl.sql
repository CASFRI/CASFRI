CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nl_nli01_eco', '_nl_nli01_eco_test', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nl_nli02_eco', '_nl_nli02_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_nl_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli1', 2500, NULL, 'eco'); -- Generates about 300 (329) ECO rows
CREATE TABLE casfri50_test.eco_nl_new AS
SELECT * FROM TT_Translate_nl_nli01_eco_test('rawfri', 'nl01_l1_to_nl_nli1_l1_map_2500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl02', 'nl_nli2', 2900, NULL, 'eco'); -- Generates about 300 (311) ECO rows
INSERT INTO casfri50_test.eco_nl_new 
SELECT * FROM TT_Translate_nl_nli02_eco_test('rawfri', 'nl02_l1_to_nl_nli2_l1_map_2900_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_nl_new_ordered AS
SELECT * FROM casfri50_test.eco_nl_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT (TT_CheckTestNumber('eco', 'nl')).*