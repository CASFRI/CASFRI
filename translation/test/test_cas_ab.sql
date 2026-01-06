CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab_cas_test', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_ab_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab', 200, NULL, 'cas');
CREATE TABLE casfri50_test.cas_ab_new AS 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab03_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab06_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab07_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab08_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab10_l1_to_ab_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab11_l1_to_ab_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab16_l1_to_ab_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 'ab', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab21_l1_to_ab_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 'ab', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab24_l1_to_ab_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab25_l1_to_ab_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 'ab', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab27_l1_to_ab_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab', 600, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab29_l1_to_ab_l1_map_600_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab30', 'ab', 100, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab30_l1_to_ab_l1_map_100_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 'ab', 700, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab31_l1_to_ab_l1_map_700_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 'ab', 700, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab32_l1_to_ab_l1_map_700_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab34', 'ab', 100, NULL, 'cas');
INSERT INTO casfri50_test.cas_ab_new 
SELECT * FROM TT_Translate_ab_cas_test('rawfri', 'ab34_l1_to_ab_l1_map_100_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_ab_new_ordered AS
SELECT * FROM casfri50_test.cas_ab_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'ab', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;