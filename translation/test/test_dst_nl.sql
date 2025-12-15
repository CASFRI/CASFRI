CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nl_nli01_dst', '_nl_nli01_dst_test', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nl_nli02_dst', '_nl_nli02_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_nl_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli1', 1, 5010, NULL, 'dst'); -- Generates about 300 (330) DST rows
CREATE TABLE casfri50_test.dst_nl_new AS
SELECT * FROM TT_Translate_nl_nli01_dst_test('rawfri', 'nl01_l1_to_nl_nli1_l1_map_5010_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1, 18000, NULL, 'dst'); -- Generates about 200 (201) DST rows
INSERT INTO casfri50_test.dst_nl_new 
SELECT * FROM TT_Translate_nl_nli02_dst_test('rawfri', 'nl02_l1_to_nl_nli2_l1_map_18000_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_nl_new_ordered AS
SELECT * FROM casfri50_test.dst_nl_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT (TT_CheckTestNumber('dst', 'nl')).*