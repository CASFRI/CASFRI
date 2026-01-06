CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pc_wbnp01_dst', '_pc_wbnp01_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_pc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 120, NULL, 'dst'); -- Generates about 50 (56) DST rows
CREATE TABLE casfri50_test.dst_pc_new AS
SELECT * FROM TT_Translate_pc_wbnp01_dst_test('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_120_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_pc_new_ordered AS
SELECT * FROM casfri50_test.dst_pc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('dst', 'yt', FALSE)
-- WHERE NOT sufficient OR diff_pct >= 20;