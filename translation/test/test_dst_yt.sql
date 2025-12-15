CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'yt_yvi01_dst', '_yt_01_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'yt_yvi02_dst', '_yt_02_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_yt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt01', 1, 'yt', 1, 2500, NULL, 'dst'); -- Generates about 200 (218) DST rows
CREATE TABLE casfri50_test.dst_yt_new AS
SELECT * FROM TT_Translate_yt_01_dst_test('rawfri', 'yt01_l1_to_yt_l1_map_2500_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, 2400, NULL, 'dst'); -- Generates about 200 (202) DST rows
INSERT INTO casfri50_test.dst_yt_new 
SELECT * FROM TT_Translate_yt_01_dst_test('rawfri', 'yt02_l1_to_yt_l1_map_2400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1, 750, NULL, 'dst'); -- Generates about 200 (204) DST rows
INSERT INTO casfri50_test.dst_yt_new 
SELECT * FROM TT_Translate_yt_02_dst_test('rawfri', 'yt03_l1_to_yt_yvi02_l1_map_750_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1, 10000, NULL, 'dst'); -- Generates about 200 (208) DST rows
INSERT INTO casfri50_test.dst_yt_new 
SELECT * FROM TT_Translate_yt_02_dst_test('rawfri', 'yt03_l2_to_yt_yvi02_l1_map_10000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'yt04', 1, 'yt', 1, 2500, NULL, 'dst'); -- Generates about 200 (218) DST rows
INSERT INTO casfri50_test.dst_yt_new
SELECT * FROM TT_Translate_yt_01_dst_test('rawfri', 'yt04_l1_to_yt_l1_map_2500_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_yt_new_ordered AS
SELECT * FROM casfri50_test.dst_yt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT (TT_CheckTestNumber('dst', 'yt')).*