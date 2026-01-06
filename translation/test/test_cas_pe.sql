CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pe_pei01_cas', '_pe_cas_test', 'ab_avi01_cas', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_pe_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', 300, NULL, 'cas');
CREATE TABLE casfri50_test.cas_pe_new AS 
SELECT * FROM TT_Translate_pe_cas_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe02', 'pe_pei', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_pe_new 
SELECT * FROM TT_Translate_pe_cas_test('rawfri', 'pe02_l1_to_pe_pei_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe03', 'pe_pei', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_pe_new 
SELECT * FROM TT_Translate_pe_cas_test('rawfri', 'pe03_l1_to_pe_pei_l1_map_300_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe04', 'pe_pei', 300, NULL, 'cas');
INSERT INTO casfri50_test.cas_pe_new 
SELECT * FROM TT_Translate_pe_cas_test('rawfri', 'pe04_l1_to_pe_pei_l1_map_300_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_pe_new_ordered AS
SELECT * FROM casfri50_test.cas_pe_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'pe', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;