CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ns_nsi01_cas', '_ns_cas_test', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_ns_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 'ns_nsi', 800, NULL, 'cas');
CREATE TABLE casfri50_test.cas_ns_new AS 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_800_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 'ns_nsi', 800, NULL, 'cas');
INSERT INTO casfri50_test.cas_ns_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_800_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 700, NULL, 'cas');
INSERT INTO casfri50_test.cas_ns_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_700_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns04', 'ns_nsi', 800, NULL, 'cas');
INSERT INTO casfri50_test.cas_ns_new 
SELECT * FROM TT_Translate_ns_cas_test('rawfri', 'ns04_l1_to_ns_nsi_l1_map_800_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_ns_new_ordered AS
SELECT * FROM casfri50_test.cas_ns_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT (TT_CheckTestNumber('cas', 'ns')).*