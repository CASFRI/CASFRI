CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_bc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 1, 'bc', 1, 3600, NULL, 'dst'); -- Generates about 800 (813) DST rows
CREATE TABLE  casfri50_test.dst_bc_new AS
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc04_l1_to_bc_l1_map_3600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 3300, NULL, 'dst'); -- Generates about 800 (820) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc08_l1_to_bc_l1_map_3300_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, 3000, NULL, 'dst'); -- Generates about 800 (852) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc10_l1_to_bc_l1_map_3000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 1, 'bc', 1, 3200, NULL, 'dst'); -- Generates about 800 (824) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc11_l1_to_bc_l1_map_3200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1, 3400, NULL, 'dst'); -- Generates about 800 (828) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc12_l1_to_bc_l1_map_3400_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 1, 'bc', 1, 2600, NULL, 'dst'); -- Generates about 800 (824) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc14_l1_to_bc_l1_map_2600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 1, 'bc', 1, 2600, NULL, 'dst'); -- Generates about 800 (860) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc15_l1_to_bc_l1_map_2600_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 1, 'bc', 1, 2000, NULL, 'dst'); -- Generates about 800 (817) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc16_l1_to_bc_l1_map_2000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 1, 'bc', 1, 2900, NULL, 'dst'); -- Generates about 800 (818) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc17_l1_to_bc_l1_map_2900_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 1, 'bc', 1, 1900, NULL, 'dst'); -- Generates about 800 (820) DST rows
INSERT INTO casfri50_test.dst_bc_new
SELECT * FROM TT_Translate_bc_dst_test('rawfri', 'bc18_l1_to_bc_l1_map_1900_dst');
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_bc_new_ordered AS
SELECT * FROM casfri50_test.dst_bc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT (TT_CheckTestNumber('dst', 'bc')).*