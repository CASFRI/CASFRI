CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nb_nbi01_cas', '_nb_cas_test', 'ab_avi01_cas', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_nb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 700, NULL, 'cas');
CREATE TABLE casfri50_test.cas_nb_new AS 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb01_l1_to_nb_l1_map_700_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 800, NULL, 'cas');
INSERT INTO casfri50_test.cas_nb_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb02_l1_to_nb_l1_map_800_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb03', 'nb', 900, NULL, 'cas');
INSERT INTO casfri50_test.cas_nb_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb03_l1_to_nb_l1_map_900_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb06', 'nb', 900, NULL, 'cas');
INSERT INTO casfri50_test.cas_nb_new 
SELECT * FROM TT_Translate_nb_cas_test('rawfri', 'nb06_l1_to_nb_l1_map_900_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_nb_new_ordered AS
SELECT * FROM casfri50_test.cas_nb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'nb', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;