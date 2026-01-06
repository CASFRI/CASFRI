CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_nb_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 1500, NULL, 'dst'); -- Generates about 400 (417) DST rows
CREATE TABLE casfri50_test.dst_nb_new AS
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb01_l1_to_nb_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 40000, NULL, 'dst'); -- Generates about 100 (103) DST rows
INSERT INTO casfri50_test.dst_nb_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb01_l2_to_nb_l1_map_40000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 1500, NULL, 'dst'); -- Generates about 400 (444) DST rows
INSERT INTO casfri50_test.dst_nb_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb02_l1_to_nb_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb03', 1, 'nb', 1, 1600, NULL, 'dst'); -- Generates about 500 (529) DST rows
INSERT INTO casfri50_test.dst_nb_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb03_l1_to_nb_l1_map_1600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nb06', 1, 'nb', 1, 1700, NULL, 'dst'); -- Generates about 600 (525) DST rows
INSERT INTO casfri50_test.dst_nb_new
SELECT * FROM TT_Translate_nb_dst_test('rawfri', 'nb06_l1_to_nb_l1_map_1700_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_nb_new_ordered AS
SELECT * FROM casfri50_test.dst_nb_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('dst', 'nb', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;