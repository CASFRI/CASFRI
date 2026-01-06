CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'mb_fri01_eco', '_mb_fri_eco_test', 'ab_avi01_eco', FALSE);
SELECT TT_Prepare('translation', 'mb_fri02_eco', '_mb_fri02_eco_test', 'ab_avi01_eco', FALSE);
SELECT TT_Prepare('translation', 'mb_fli01_eco', '_mb_fli_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_mb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 'mb_fri2', 1000, NULL, 'eco'); -- Generates about 200 (200) ECO rows
CREATE TABLE casfri50_test.eco_mb_new AS
SELECT * FROM TT_Translate_mb_fri02_eco_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_1000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli', 820, NULL, 'eco'); -- Generates about 200 (218) ECO rows
INSERT INTO casfri50_test.eco_mb_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_820_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 'mb_fli', 700, NULL, 'eco'); -- Generates about 200 (207) ECO rows
INSERT INTO casfri50_test.eco_mb_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_700_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', 3000, NULL, 'eco'); -- Generates about 300 (312) ECO rows
INSERT INTO casfri50_test.eco_mb_new 
SELECT * FROM TT_Translate_mb_fri_eco_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_3000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', 800, NULL, 'eco'); -- Generates about 200 (202) ECO rows
INSERT INTO casfri50_test.eco_mb_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_800_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 'mb_fli', 600, NULL, 'eco'); -- Generates about 200 (212) ECO rows
INSERT INTO casfri50_test.eco_mb_new 
SELECT * FROM TT_Translate_mb_fli_eco_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_600_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_mb_new_ordered AS
SELECT * FROM casfri50_test.eco_mb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('eco', 'mb', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;