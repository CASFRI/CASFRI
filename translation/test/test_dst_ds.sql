CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ds_cfs01_dst', '_ds_cfs_dst_test', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_ds_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds01', 'ds', 200, NULL, 'dst'); -- Generates 200 DST rows
CREATE TABLE  casfri50_test.dst_ds_new AS
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds01_l1_to_ds_l1_map_200_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds02', 'ds', 1050, NULL, 'dst'); -- Generates about 1000 (1021) DST rows
INSERT INTO casfri50_test.dst_ds_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds02_l1_to_ds_l1_map_1050_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds03', 'ds', 1000, NULL, 'dst'); -- Generates 1000 DST rows
INSERT INTO casfri50_test.dst_ds_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds03_l1_to_ds_l1_map_1000_dst');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ds04', 'ds', 500, NULL, 'dst'); -- Generates about 200 (201) DST rows
INSERT INTO casfri50_test.dst_ds_new 
SELECT * FROM TT_Translate_ds_cfs_dst_test('rawfri', 'ds04_l1_to_ds_l1_map_500_dst'); -- return only about 400 rows because there is a ROW_TRANSATION_RULE for Cutblock
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_ds_new_ordered AS
SELECT * FROM casfri50_test.dst_ds_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
------------------------
-- SELECT (TT_CheckTestNumber('dst', 'ds')).*
