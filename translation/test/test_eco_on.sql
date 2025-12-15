CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on_eco_test', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_on_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 'on', 1000, NULL, 'eco'); -- Generates 0 ECO rows
CREATE TABLE casfri50_test.eco_on_new AS
SELECT * FROM TT_Translate_on_eco_test('rawfri', 'on01_l1_to_on_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 1000, NULL, 'eco'); -- Generates 0 ECO rows
INSERT INTO casfri50_test.eco_on_new 
SELECT * FROM TT_Translate_on_eco_test('rawfri', 'on02_l1_to_on_l1_map_1000_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_on_new_ordered AS
SELECT * FROM casfri50_test.eco_on_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT (TT_CheckTestNumber('eco', 'on')).*