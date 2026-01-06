CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_01_eco_test', 'ab_avi01_eco', FALSE);
SELECT TT_Prepare('translation', 'yt_yvi02_eco', '_yt_02_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_yt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 'yt', 4400, NULL, 'eco'); -- Generates about 200 (203) ECO rows
CREATE TABLE casfri50_test.eco_yt_new AS
SELECT * FROM TT_Translate_yt_01_eco_test('rawfri', 'yt01_l1_to_yt_l1_map_4400_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 4650, NULL, 'eco'); -- Generates about 200 (215) ECO rows
INSERT INTO casfri50_test.eco_yt_new 
SELECT * FROM TT_Translate_yt_01_eco_test('rawfri', 'yt02_l1_to_yt_l1_map_4650_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt_yvi02', 1300, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_yt_new 
SELECT * FROM TT_Translate_yt_02_eco_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_1300_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt04', 'yt', 4400, NULL, 'eco'); -- Generates about 200 (203) ECO rows
INSERT INTO casfri50_test.eco_yt_new
SELECT * FROM TT_Translate_yt_01_eco_test('rawfri', 'yt04_l1_to_yt_l1_map_4400_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_yt_new_ordered AS
SELECT * FROM casfri50_test.eco_yt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('eco', 'yt', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;