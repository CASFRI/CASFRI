CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc_cas_test', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_bc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 'bc', 1000, NULL, 'cas');
CREATE TABLE casfri50_test.cas_bc_new AS
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc04_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc08_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc10_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc11_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc12_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc13_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc14_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc15_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc16_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc17_l1_to_bc_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 'bc', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_bc_new 
SELECT * FROM TT_Translate_bc_cas_test('rawfri', 'bc18_l1_to_bc_l1_map_1000_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_bc_new_ordered AS
SELECT * FROM casfri50_test.cas_bc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'bc', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;