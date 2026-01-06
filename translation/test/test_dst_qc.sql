CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'qc_ini03_dst', '_qc_ini03_dst_test', 'ab_avi01_dst', FALSE);
SELECT TT_Prepare('translation', 'qc_ini04_dst', '_qc_ini04_dst_test', 'ab_avi01_dst', FALSE);
SELECT TT_Prepare('translation', 'qc_ipf05_dst', '_qc_ipf05_dst_test', 'ab_avi01_dst', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_qc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1, 2500, NULL, 'dst'); -- Generates about 1000 (1054) DST rows
CREATE TABLE casfri50_test.dst_qc_new AS
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_2500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 1, 'qc_ini03', 1, 1800, NULL, 'dst'); -- Generates about 800 (843) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, 1200, NULL, 'dst'); -- Generates about 200 (233) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_1200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, 1500, NULL, 'dst'); -- Generates about 900 (880) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ini04_dst_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, 2000, NULL, 'dst'); -- Generates about 1000 (1082) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_dst_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_2000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, 1800, NULL, 'dst'); -- Generates about 1000 (1041) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ini04_dst_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1, 400, NULL, 'dst'); -- Generates about 200 (218) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_dst_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc08', 1, 'qc_ini03', 1, 1000, NULL, 'dst'); -- Generates about 200 (224) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ini03_dst_test('rawfri', 'qc08_l1_to_qc_ini03_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc09', 1, 'qc_ini04', 1, 700, NULL, 'dst'); -- Generates about 400 (428) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ini04_dst_test('rawfri', 'qc09_l1_to_qc_ini04_l1_map_700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc10', 1, 'qc_ipf', 1, 2000, NULL, 'dst'); -- Generates about 1000 (1030) DST rows
INSERT INTO casfri50_test.dst_qc_new 
SELECT * FROM TT_Translate_qc_ipf05_dst_test('rawfri', 'qc10_l1_to_qc_ipf_l1_map_2000_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_qc_new_ordered AS
SELECT * FROM casfri50_test.dst_qc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('dst', 'qc', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/