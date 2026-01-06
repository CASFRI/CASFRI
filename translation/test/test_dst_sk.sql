CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'sk_utm01_dst', '_sk_utm_dst_test', 'ab_avi01_dst', FALSE);
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk_sfv_dst_test', 'ab_avi01_dst', FALSE); 
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_sk_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 5000, NULL, 'dst'); -- Generates about 200 (201) DST rows
CREATE TABLE casfri50_test.dst_sk_new AS
SELECT * FROM TT_Translate_sk_utm_dst_test('rawfri', 'sk01_l1_to_sk_utm_l1_map_5000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, 650, NULL, 'dst'); -- Generates about 200 (198) DST rows
INSERT INTO casfri50_test.dst_sk_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk02_l1_to_sk_sfv_l1_map_650_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 1700, NULL, 'dst'); -- Generates about 50 (50) DST rows
INSERT INTO casfri50_test.dst_sk_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk03_l1_to_sk_sfv_l1_map_1700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, 1500, NULL, 'dst'); -- Generates about 200 (222) DST rows
INSERT INTO casfri50_test.dst_sk_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk04_l1_to_sk_sfv_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, 1500, NULL, 'dst'); -- Generates about 200 (230) DST rows
INSERT INTO casfri50_test.dst_sk_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk05_l1_to_sk_sfv_l1_map_1500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, 1000, NULL, 'dst'); -- Generates about 200 (208) DST rows
INSERT INTO casfri50_test.dst_sk_new 
SELECT * FROM TT_Translate_sk_sfv_dst_test('rawfri', 'sk06_l1_to_sk_sfv_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'sk07', 1, 'sk_utm', 1, 5000, NULL, 'dst'); -- Generates about 200 (227) DST rows
INSERT INTO casfri50_test.dst_sk_new 
SELECT * FROM TT_Translate_sk_utm_dst_test('rawfri', 'sk07_l1_to_sk_utm_l1_map_5000_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_sk_new_ordered AS
SELECT * FROM casfri50_test.dst_sk_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('dst', 'sk', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;