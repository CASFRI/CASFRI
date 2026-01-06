CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt_dst_test', 'ab_avi01_dst', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_nt_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, 800, NULL, 'dst'); -- Generates about 200 (211) DST rows
CREATE TABLE casfri50_test.dst_nt_new AS
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt01_l1_to_nt_l1_map_800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1, 800, NULL, 'dst'); -- Generates about 200 (228) DST rows
INSERT INTO casfri50_test.dst_nt_new 
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt03_l1_to_nt_l1_map_800_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nt04', 1, 'nt', 1, 600, NULL, 'dst'); -- Generates about 200 (212) DST rows
INSERT INTO casfri50_test.dst_nt_new 
SELECT * FROM TT_Translate_nt_dst_test('rawfri', 'nt04_l1_to_nt_l1_map_600_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_nt_new_ordered AS
SELECT * FROM casfri50_test.dst_nt_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('dst', 'nt', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/