CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_nb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 2650, NULL, 'eco'); -- Generates about 200 (215) ECO rows
CREATE TABLE casfri50_test.eco_nb_new AS
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb01_l1_to_nb_l1_map_2650_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 3100, NULL, 'eco'); -- Generates about 300 (303) ECO rows
INSERT INTO casfri50_test.eco_nb_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb02_l1_to_nb_l1_map_3100_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb03', 'nb', 4000, NULL, 'eco'); -- Generates about 300 (334) ECO rows
INSERT INTO casfri50_test.eco_nb_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb03_l1_to_nb_l1_map_4000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb06', 'nb', 3500, NULL, 'eco'); -- Generates about 300 (333) ECO rows
INSERT INTO casfri50_test.eco_nb_new
SELECT * FROM TT_Translate_nb_eco_test('rawfri', 'nb06_l1_to_nb_l1_map_3500_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_nb_new_ordered AS
SELECT * FROM casfri50_test.eco_nb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('eco', 'nb', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/