CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab_dst_test', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_ab_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1, 2000, NULL, 'dst'); -- Generates about 200 (179) DST rows
CREATE TABLE casfri50_test.dst_ab_new AS
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab03_l1_to_ab_l1_map_2000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 600, NULL, 'dst'); -- Generates about 100 (108) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab06_l1_to_ab_l1_map_600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab07', 1, 'ab', 1, 1800, NULL, 'dst'); -- Generates about 100 (111) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab07_l1_to_ab_l1_map_1800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab08', 1, 'ab', 1, 1200, NULL, 'dst'); -- Generates about 200 (200) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab08_l1_to_ab_l1_map_1200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1, 1350, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab10_l1_to_ab_l1_map_1350_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1, 1500, NULL, 'dst'); -- Generates about 200 (201) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab11_l1_to_ab_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 3000, NULL, 'dst'); -- Generates about 200 (219) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab16_l1_to_ab_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab21', 1, 'ab', 1, 3000, NULL, 'dst'); -- Generates about 200 (213) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab21_l1_to_ab_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab24', 1, 'ab', 1, 1550, NULL, 'dst'); -- Generates about 200 (211) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab24_l1_to_ab_l1_map_1550_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1, 4200, NULL, 'dst'); -- Generates about 200 (205) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab25_l1_to_ab_l1_map_4200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1, 1200, NULL, 'dst'); -- Generates about 200 (219) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab27_l1_to_ab_l1_map_1200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1, 2700, NULL, 'dst'); -- Generates about 200 (216) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab29_l1_to_ab_l1_map_2700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab30', 1, 'ab', 1, 100, NULL, 'dst'); -- Generates about 100 (100) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab30_l1_to_ab_l1_map_100_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab31', 1, 'ab', 1, 2200, NULL, 'dst'); -- Generates about 200 (210) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab31_l1_to_ab_l1_map_2200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab32', 1, 'ab', 1, 2200, NULL, 'dst'); -- Generates about 300 (327) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab32_l1_to_ab_l1_map_2200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ab34', 1, 'ab', 1, 100, NULL, 'dst'); -- Generates about 100 (100) DST rows
INSERT INTO casfri50_test.dst_ab_new
SELECT * FROM TT_Translate_ab_dst_test('rawfri', 'ab34_l1_to_ab_l1_map_100_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_ab_new_ordered AS
SELECT * FROM casfri50_test.dst_ab_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('dst', 'ab', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;