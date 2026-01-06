CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt_cas_test', 'ab_avi01_cas', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_nt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 400, NULL, 'cas');
CREATE TABLE casfri50_test.cas_nt_new AS 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt01_l1_to_nt_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 'nt', 410, NULL, 'cas');
INSERT INTO casfri50_test.cas_nt_new 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt03_l1_to_nt_l1_map_410_cas'); -- 408 rows
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt04', 'nt', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_nt_new 
SELECT * FROM TT_Translate_nt_cas_test('rawfri', 'nt04_l1_to_nt_l1_map_200_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_nt_new_ordered AS
SELECT * FROM casfri50_test.cas_nt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'nt', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;