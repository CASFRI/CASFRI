CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'yt_yvi01_cas', '_yt_01_cas_test', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'yt_yvi02_cas', '_yt_02_cas_test', 'ab_avi01_cas'); 
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_yt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 'yt', 400, NULL, 'cas');
CREATE TABLE casfri50_test.cas_yt_new AS 
SELECT * FROM TT_Translate_yt_01_cas_test('rawfri', 'yt01_l1_to_yt_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_yt_new 
SELECT * FROM TT_Translate_yt_01_cas_test('rawfri', 'yt02_l1_to_yt_l1_map_400_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt_yvi02', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_yt_new 
SELECT * FROM TT_Translate_yt_02_cas_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt04', 'yt', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_yt_new
SELECT * FROM TT_Translate_yt_01_cas_test('rawfri', 'yt04_l1_to_yt_l1_map_400_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_yt_new_ordered AS
SELECT * FROM casfri50_test.cas_yt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT (TT_CheckTestNumber('cas', 'yt')).*