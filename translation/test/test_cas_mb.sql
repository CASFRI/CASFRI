CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'mb_fri01_cas', '_mb_fri_cas_test', 'ab_avi01_cas', FALSE);
SELECT TT_Prepare('translation', 'mb_fri02_cas', '_mb_fri2_cas_test', 'ab_avi01_cas', FALSE);
SELECT TT_Prepare('translation', 'mb_fli01_cas', '_mb_fli_cas_test', 'ab_avi01_cas', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_mb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb01', 'mb_fri2', 300, NULL, 'cas');
CREATE TABLE casfri50_test.cas_mb_new AS 
SELECT * FROM TT_Translate_mb_fri2_cas_test('rawfri', 'mb01_l1_to_mb_fri2_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_mb_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 'mb_fli', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_mb_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', 900, NULL, 'cas');
INSERT INTO casfri50_test.cas_mb_new 
SELECT * FROM TT_Translate_mb_fri_cas_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_900_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_mb_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 'mb_fli', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_mb_new 
SELECT * FROM TT_Translate_mb_fli_cas_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_400_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_mb_new_ordered AS
SELECT * FROM casfri50_test.cas_mb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'mb', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;