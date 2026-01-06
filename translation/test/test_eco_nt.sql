CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_nt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 1210, NULL, 'eco'); -- Generates about 200 (224) ECO rows
CREATE TABLE casfri50_test.eco_nt_new AS
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt01_l1_to_nt_l1_map_1210_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 'nt', 950, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_nt_new 
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt03_l1_to_nt_l1_map_950_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt04', 'nt', 350, NULL, 'eco'); -- Generates about 200 (222) ECO rows
INSERT INTO casfri50_test.eco_nt_new 
SELECT * FROM TT_Translate_nt_eco_test('rawfri', 'nt04_l1_to_nt_l1_map_350_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_nt_new_ordered AS
SELECT * FROM casfri50_test.eco_nt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('eco', 'nt', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/