CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ns_nsi01_dst', '_ns_dst_test', 'ab_avi01_dst', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_ns_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 1, 'ns_nsi', 1, 2800, NULL, 'dst'); -- Generates about 200 (228) DST rows
CREATE TABLE casfri50_test.dst_ns_new AS
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_2800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 1, 'ns_nsi', 1, 3000, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_ns_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 3000, NULL, 'dst'); -- Generates about 200 (217) DST rows
INSERT INTO casfri50_test.dst_ns_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns04', 1, 'ns_nsi', 1, 3000, NULL, 'dst'); -- Generates about 200 (219) DST rows
INSERT INTO casfri50_test.dst_ns_new 
SELECT * FROM TT_Translate_ns_dst_test('rawfri', 'ns04_l1_to_ns_nsi_l1_map_3000_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_ns_new_ordered AS
SELECT * FROM casfri50_test.dst_ns_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('dst', 'ns', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/