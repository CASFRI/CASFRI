CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'on_fim02_cas', '_on_cas_test', 'ab_avi01_cas', FALSE); 
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_on_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 'on', 1000, NULL, 'cas');
CREATE TABLE casfri50_test.cas_on_new AS 
SELECT * FROM TT_Translate_on_cas_test('rawfri', 'on01_l1_to_on_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_on_new 
SELECT * FROM TT_Translate_on_cas_test('rawfri', 'on02_l1_to_on_l1_map_1000_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_on_new_ordered AS
SELECT * FROM casfri50_test.cas_on_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'on', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;