CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pe_pei01_eco', '_pe_eco_test', 'ab_avi01_eco', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_pe_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', 8000, NULL, 'eco'); -- Generates about 100 (117) ECO rows
CREATE TABLE casfri50_test.eco_pe_new AS
SELECT * FROM TT_Translate_pe_eco_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_8000_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe02', 'pe_pei', 4500, NULL, 'eco'); -- Generates about 200 (201) ECO rows
INSERT INTO casfri50_test.eco_pe_new 
SELECT * FROM TT_Translate_pe_eco_test('rawfri', 'pe02_l1_to_pe_pei_l1_map_4500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe03', 'pe_pei', 5500, NULL, 'eco'); -- Generates about 200 (233) ECO rows
INSERT INTO casfri50_test.eco_pe_new 
SELECT * FROM TT_Translate_pe_eco_test('rawfri', 'pe03_l1_to_pe_pei_l1_map_5500_eco');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe04', 'pe_pei', 4000, NULL, 'eco'); -- Generates about 200 (227) ECO rows
INSERT INTO casfri50_test.eco_pe_new 
SELECT * FROM TT_Translate_pe_eco_test('rawfri', 'pe04_l1_to_pe_pei_l1_map_4000_eco');
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_pe_new_ordered AS
SELECT * FROM casfri50_test.eco_pe_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('eco', 'pe', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;