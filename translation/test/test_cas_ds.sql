CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ds_cfs01_cas', '_ds_cfs_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'ds_bea01_cas', '_ds_bea_cas_test', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_ds_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds01', 'ds', 200, NULL, 'cas');
CREATE TABLE casfri50_test.cas_ds_new AS 
SELECT * FROM TT_Translate_ds_cfs_cas_test('rawfri', 'ds01_l1_to_ds_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds02', 'ds', 1100, NULL, 'cas'); -- Generate about 900 rows
INSERT INTO casfri50_test.cas_ds_new 
SELECT * FROM TT_Translate_ds_cfs_cas_test('rawfri', 'ds02_l1_to_ds_l1_map_1100_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds03', 'ds', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_ds_new 
SELECT * FROM TT_Translate_ds_cfs_cas_test('rawfri', 'ds03_l1_to_ds_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds04', 'ds', 400, NULL, 'cas');
INSERT INTO casfri50_test.cas_ds_new 
SELECT * FROM TT_Translate_ds_bea_cas_test('rawfri', 'ds04_l1_to_ds_l1_map_400_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_ds_new_ordered AS
SELECT * FROM casfri50_test.cas_ds_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT (TT_CheckNumberOfTests('cas', 'ds')).*