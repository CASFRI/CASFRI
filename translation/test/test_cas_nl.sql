CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nl_nli01_cas', '_nl_nli01_cas_test', 'ab_avi01_cas', FALSE);
SELECT TT_Prepare('translation', 'nl_nli02_cas', '_nl_nli02_cas_test', 'ab_avi01_cas', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_nl_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli1', 900, NULL, 'cas');
CREATE TABLE casfri50_test.cas_nl_new AS 
SELECT * FROM TT_Translate_nl_nli01_cas_test('rawfri', 'nl01_l1_to_nl_nli1_l1_map_900_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl02', 'nl_nli2', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_nl_new 
SELECT * FROM TT_Translate_nl_nli02_cas_test('rawfri', 'nl02_l1_to_nl_nli2_l1_map_1000_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_nl_new_ordered AS
SELECT * FROM casfri50_test.cas_nl_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'nl', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;