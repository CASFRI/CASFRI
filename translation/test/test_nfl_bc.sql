CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc_nfl_test', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_bc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 2, 'bc', 1, 2800, NULL, 'nfl'); -- Generates about 500 (515) NFL rows
CREATE TABLE casfri50_test.nfl_bc_new AS
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc04_l2_to_bc_l1_map_2800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 3, 'bc', 1, 4600, NULL, 'nfl'); -- Generates about 800 (823) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc04_l3_to_bc_l1_map_4600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 4, 'bc', 1, 6000, NULL, 'nfl'); -- Generates about 300 (315) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc04_l4_to_bc_l1_map_6000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, 3200, NULL, 'nfl'); -- Generates about 500 (507) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l3_to_bc_l1_map_3200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, 4300, NULL, 'nfl'); -- Generates about 800 (833) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l4_to_bc_l1_map_4300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 5, 'bc', 1, 7200, NULL, 'nfl'); -- Generates about 400 (422) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l5_to_bc_l1_map_7200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1, 3000, NULL, 'nfl'); -- Generates about 500 (518) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l3_to_bc_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1, 4300, NULL, 'nfl'); -- Generates about 800 (887) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l4_to_bc_l1_map_4300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1, 7000, NULL, 'nfl'); -- Generates about 400 (441) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l5_to_bc_l1_map_7000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 3, 'bc', 1, 3200, NULL, 'nfl'); -- Generates about 500 (511) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc11_l3_to_bc_l1_map_3200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 4, 'bc', 1, 4000, NULL, 'nfl'); -- Generates about 800 (812) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc11_l4_to_bc_l1_map_4000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 5, 'bc', 1, 7000, NULL, 'nfl'); -- Generates about 400 (455) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc11_l5_to_bc_l1_map_7000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 3, 'bc', 1, 3000, NULL, 'nfl'); -- Generates about 500 (514) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l3_to_bc_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 4, 'bc', 1, 4100, NULL, 'nfl'); -- Generates about 800 (823) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l4_to_bc_l1_map_4100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 5, 'bc', 1, 7000, NULL, 'nfl'); -- Generates about 400 (454) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l5_to_bc_l1_map_7000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 2, 'bc', 1, 2800, NULL, 'nfl'); -- Generates about 500 (506) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc13_l2_to_bc_l1_map_2800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 3, 'bc', 1, 4800, NULL, 'nfl'); -- Generates about 400 (405) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc13_l3_to_bc_l1_map_4800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 4, 'bc', 1, 22000, NULL, 'nfl'); -- Generates about 200 (201) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc13_l4_to_bc_l1_map_22000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 3, 'bc', 1, 4250, NULL, 'nfl'); -- Generates about 500 (541) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc14_l3_to_bc_l1_map_4250_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 4, 'bc', 1, 4600, NULL, 'nfl'); -- Generates about 800 (856) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc14_l4_to_bc_l1_map_4600_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 5, 'bc', 1, 6000, NULL, 'nfl'); -- Generates about 400 (443) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc14_l5_to_bc_l1_map_6000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 3, 'bc', 1, 4250, NULL, 'nfl'); -- Generates about 500 (553) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc15_l3_to_bc_l1_map_4250_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 4, 'bc', 1, 4800, NULL, 'nfl'); -- Generates about 800 (819) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc15_l4_to_bc_l1_map_4800_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 5, 'bc', 1, 6500, NULL, 'nfl'); -- Generates about 400 (467) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc15_l5_to_bc_l1_map_6500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 3, 'bc', 1, 3000, NULL, 'nfl'); -- Generates about 500 (514) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc16_l3_to_bc_l1_map_3000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 4, 'bc', 1, 4100, NULL, 'nfl'); -- Generates about 800 (823) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc16_l4_to_bc_l1_map_4100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 5, 'bc', 1, 7000, NULL, 'nfl'); -- Generates about 400 (454) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc16_l5_to_bc_l1_map_7000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 3, 'bc', 1, 4550, NULL, 'nfl'); -- Generates about 500 (530) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc17_l3_to_bc_l1_map_4550_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 4, 'bc', 1, 5000, NULL, 'nfl'); -- Generates about 800 (808) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc17_l4_to_bc_l1_map_5000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 5, 'bc', 1, 7000, NULL, 'nfl'); -- Generates about 400 (445) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc17_l5_to_bc_l1_map_7000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 3, 'bc', 1, 3500, NULL, 'nfl'); -- Generates about 500 (556) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc18_l3_to_bc_l1_map_3500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 4, 'bc', 1, 5000, NULL, 'nfl'); -- Generates about 800 (858) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc18_l4_to_bc_l1_map_5000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 5, 'bc', 1, 7000, NULL, 'nfl'); -- Generates about 400 (436) NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc18_l5_to_bc_l1_map_7000_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_bc_new_ordered AS
SELECT * FROM casfri50_test.nfl_bc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
-- SELECT (TT_CheckTestNumber('nfl', 'bc')).*
