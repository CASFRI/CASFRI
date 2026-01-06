CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'sk_utm01_cas', '_sk_utm_cas_test', 'ab_avi01_cas', FALSE); 
SELECT TT_Prepare('translation', 'sk_sfv01_cas', '_sk_sfv_cas_test', 'ab_avi01_cas', FALSE); 
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_sk_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 900, NULL, 'cas');
CREATE TABLE casfri50_test.cas_sk_new AS 
SELECT * FROM TT_Translate_sk_utm_cas_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_900_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_sk_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_sk_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', 600, NULL, 'cas');
INSERT INTO casfri50_test.cas_sk_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_600_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_sk_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_sk_new 
SELECT * FROM TT_Translate_sk_sfv_cas_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 'sk_utm', 900, NULL, 'cas');
INSERT INTO casfri50_test.cas_sk_new 
SELECT * FROM TT_Translate_sk_utm_cas_test('rawfri', 'sk07_l1_to_sk_utm_l1_map_900_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_sk_new_ordered AS
SELECT * FROM casfri50_test.cas_sk_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('cas', 'sk', FALSE)
WHERE NOT sufficient OR diff_pct >= 20;
*/