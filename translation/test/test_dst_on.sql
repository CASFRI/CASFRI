CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_on_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1, 6000, NULL, 'dst'); -- Generates about 400 (442) DST rows
CREATE TABLE casfri50_test.dst_on_new AS
SELECT * FROM TT_Translate_on_dst_test('rawfri', 'on01_l1_to_on_l1_map_6000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, 7100, NULL, 'dst'); -- Generates about 300 (309) DST rows
INSERT INTO casfri50_test.dst_on_new 
SELECT * FROM TT_Translate_on_dst_test('rawfri', 'on02_l1_to_on_l1_map_7100_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_on_new_ordered AS
SELECT * FROM casfri50_test.dst_on_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT (TT_CheckTestNumber('dst', 'on')).*