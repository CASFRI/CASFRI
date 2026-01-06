CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'qc_ini03_cas', '_qc_ini03_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'qc_ini04_cas', '_qc_ini04_cas_test', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'qc_ipf05_cas', '_qc_ipf05_cas_test', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_qc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 'qc_ini03', 1100, NULL, 'cas');
CREATE TABLE casfri50_test.cas_qc_new AS 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_1100_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 'qc_ini03', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 'qc_ini03', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 'qc_ini04', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ini04_cas_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 'qc_ipf', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_cas_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 'qc_ini04', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ini04_cas_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1000_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 'qc_ipf', 200, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_cas_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_200_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc08', 'qc_ini03', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ini03_cas_test('rawfri', 'qc08_l1_to_qc_ini03_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc09', 'qc_ini04', 500, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ini04_cas_test('rawfri', 'qc09_l1_to_qc_ini04_l1_map_500_cas');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc10', 'qc_ipf', 1000, NULL, 'cas');
INSERT INTO casfri50_test.cas_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_cas_test('rawfri', 'qc10_l1_to_qc_ipf_l1_map_1000_cas');
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_qc_new_ordered AS
SELECT * FROM casfri50_test.cas_qc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('cas', 'qc', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;