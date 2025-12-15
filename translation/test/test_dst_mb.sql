CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'mb_fri01_dst', '_mb_fri_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fli01_dst', '_mb_fli_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_mb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1, 1600, NULL, 'dst'); -- Generates about 200 (211) DST rows
CREATE TABLE casfri50_test.dst_mb_new AS
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb02_l1_to_mb_fli_l1_map_1600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb04', 1, 'mb_fli', 1, 510, NULL, 'dst'); -- Generates about 200 (211) DST rows
INSERT INTO casfri50_test.dst_mb_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb04_l1_to_mb_fli_l1_map_510_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 1000, NULL, 'dst'); -- Generates 0 DST rows. No DST info to translate
INSERT INTO casfri50_test.dst_mb_new 
SELECT * FROM TT_Translate_mb_fri_dst_test('rawfri', 'mb05_l1_to_mb_fri_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 820, NULL, 'dst'); -- Generates about 200 (214) DST rows
INSERT INTO casfri50_test.dst_mb_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb06_l1_to_mb_fli_l1_map_820_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'mb07', 1, 'mb_fli', 1, 700, NULL, 'dst'); -- Generates about 300 (316) DST rows
INSERT INTO casfri50_test.dst_mb_new 
SELECT * FROM TT_Translate_mb_fli_dst_test('rawfri', 'mb07_l1_to_mb_fli_l1_map_700_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_mb_new_ordered AS
SELECT * FROM casfri50_test.dst_mb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT (TT_CheckTestNumber('dst', 'mb')).*