CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pe_pei01_dst', '_pe_dst_test', 'ab_avi01_dst', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_pe_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 700, NULL, 'dst'); -- Generates about 200 (233) DST rows
CREATE TABLE casfri50_test.dst_pe_new AS
SELECT * FROM TT_Translate_pe_dst_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_700_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe02', 1, 'pe_pei', 1, 1000, NULL, 'dst'); -- Generates about 200 (207) DST rows
INSERT INTO casfri50_test.dst_pe_new 
SELECT * FROM TT_Translate_pe_dst_test('rawfri', 'pe02_l1_to_pe_pei_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe03', 1, 'pe_pei', 1, 1000, NULL, 'dst'); -- Generates about 200 (204) DST rows
INSERT INTO casfri50_test.dst_pe_new 
SELECT * FROM TT_Translate_pe_dst_test('rawfri', 'pe03_l1_to_pe_pei_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe04', 1, 'pe_pei', 1, 700, NULL, 'dst'); -- Generates about 200 (208) DST rows
INSERT INTO casfri50_test.dst_pe_new 
SELECT * FROM TT_Translate_pe_dst_test('rawfri', 'pe04_l1_to_pe_pei_l1_map_700_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_pe_new_ordered AS
SELECT * FROM casfri50_test.dst_pe_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('dst', 'pe', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/