CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_panp01_cas', '_pc_panp_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'pc_wbnp01_cas', '_pc_wbnp_cas_test', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_pc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc01', 'pc_panp', 200, NULL, 'cas');
CREATE TABLE casfri50_test.cas_pc_new AS 
SELECT * FROM TT_Translate_pc_panp_cas_test('rawfri', 'pc01_l1_to_pc_panp_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 'pc_wbnp', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_pc_new 
SELECT * FROM TT_Translate_pc_wbnp_cas_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_200_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_pc_new_ordered AS
SELECT * FROM casfri50_test.cas_pc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT (TT_CheckTestNumber('cas', 'pc')).*