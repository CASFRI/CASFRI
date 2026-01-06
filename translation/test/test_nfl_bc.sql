CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc_nfl_test', 'ab_avi01_nfl', FALSE);
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_bc_new CASCADE;
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 2, 'bc', 1, 1200, NULL, 'nfl'); -- Generates 233 NFL rows
CREATE TABLE casfri50_test.nfl_bc_new AS
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc04_l2_to_bc_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 3, 'bc', 1, 2000, NULL, 'nfl'); -- Generates 365 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc04_l3_to_bc_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc04', 4, 'bc', 1, 6500, NULL, 'nfl'); -- Generates 372 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc04_l4_to_bc_l1_map_6500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, 1200, NULL, 'nfl'); -- Generates 190 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l3_to_bc_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, 2000, NULL, 'nfl'); -- Generates 404 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l4_to_bc_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc08', 5, 'bc', 1, 6500, NULL, 'nfl'); -- Generates 372 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc08_l5_to_bc_l1_map_6500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1, 1200, NULL, 'nfl'); -- Generates 211 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l3_to_bc_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1, 2000, NULL, 'nfl'); -- Generates 382 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l4_to_bc_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1, 6500, NULL, 'nfl'); -- Generates 433 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc10_l5_to_bc_l1_map_6500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 3, 'bc', 1, 2000, NULL, 'nfl'); -- Generates 190 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc11_l3_to_bc_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 4, 'bc', 1, 2000, NULL, 'nfl'); -- Generates 399 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc11_l4_to_bc_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc11', 5, 'bc', 1, 6500, NULL, 'nfl'); -- Generates 363 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc11_l5_to_bc_l1_map_6500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 3, 'bc', 1, 1500, NULL, 'nfl'); -- Generates 177 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l3_to_bc_l1_map_1500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 4, 'bc', 1, 2000, NULL, 'nfl'); -- Generates 393 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l4_to_bc_l1_map_2000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc12', 5, 'bc', 1, 6500, NULL, 'nfl'); -- Generates 432 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l5_to_bc_l1_map_6500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 2, 'bc', 1, 100, NULL, 'nfl'); -- Generates 21 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc13_l2_to_bc_l1_map_100_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 3, 'bc', 1, 8000, NULL, 'nfl'); -- Generates 676 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc13_l3_to_bc_l1_map_8000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc13', 4, 'bc', 1, 300, NULL, 'nfl'); -- Generates 4 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc13_l4_to_bc_l1_map_300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 3, 'bc', 1, 4000, NULL, 'nfl'); -- Generates 474 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc14_l3_to_bc_l1_map_4000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 4, 'bc', 1, 1500, NULL, 'nfl'); -- Generates 241 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc14_l4_to_bc_l1_map_1500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc14', 5, 'bc', 1, 2500, NULL, 'nfl'); -- Generates 186 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc14_l5_to_bc_l1_map_2500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 3, 'bc', 1, 5300, NULL, 'nfl'); -- Generates 636 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc15_l3_to_bc_l1_map_5300_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 4, 'bc', 1, 1200, NULL, 'nfl'); -- Generates 217 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc15_l4_to_bc_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc15', 5, 'bc', 1, 1200, NULL, 'nfl'); -- Generates 88 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc15_l5_to_bc_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 3, 'bc', 1, 4500, NULL, 'nfl'); -- Generates 673 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc16_l3_to_bc_l1_map_4500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 4, 'bc', 1, 1500, NULL, 'nfl'); -- Generates 179 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc16_l4_to_bc_l1_map_1500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc16', 5, 'bc', 1, 1500, NULL, 'nfl'); -- Generates 101 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc16_l5_to_bc_l1_map_1500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 3, 'bc', 1, 4500, NULL, 'nfl'); -- Generates 499 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc17_l3_to_bc_l1_map_4500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 4, 'bc', 1, 1500, NULL, 'nfl'); -- Generates 255 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc17_l4_to_bc_l1_map_1500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc17', 5, 'bc', 1, 2500, NULL, 'nfl'); -- Generates 161 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc17_l5_to_bc_l1_map_2500_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 3, 'bc', 1, 5000, NULL, 'nfl'); -- Generates 770 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc18_l3_to_bc_l1_map_5000_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 4, 'bc', 1, 1200, NULL, 'nfl'); -- Generates 194 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc18_l4_to_bc_l1_map_1200_nfl');
------------------------
SELECT TT_CreateMappingView('rawfri', 'bc18', 5, 'bc', 1, 1700, NULL, 'nfl'); -- Generates 84 NFL rows
INSERT INTO casfri50_test.nfl_bc_new
SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc18_l5_to_bc_l1_map_1700_nfl');
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_bc_new_ordered AS
SELECT * FROM casfri50_test.nfl_bc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
------------------------
/*
SELECT * 
FROM TT_CheckNumberOfTests('nfl', 'bc', FALSE)
WHERE NOT sufficient OR diff_pct >= 20;
*/
------------------------
-- Query to determine the right number of tested row per layer when the view generate row for different layers
-- SELECT TT_CreateMappingView('rawfri', 'bc12', 3, 'bc', 1, 5000, NULL, 'nfl'); -- Generates about 500 (514) NFL rows
-- SELECT TT_CreateMappingView('rawfri', 'bc12', 4, 'bc', 1, 5000, NULL, 'nfl'); -- Generates about 800 (823) NFL rows
-- SELECT TT_CreateMappingView('rawfri', 'bc12', 5, 'bc', 1, 20000, NULL, 'nfl'); -- Generates about 400 (454) NFL rows

-- WITH tested AS (
-- SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l3_to_bc_l1_map_5000_nfl')
--     UNION ALL
-- SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l4_to_bc_l1_map_5000_nfl')
--     UNION ALL
-- SELECT * FROM TT_Translate_bc_nfl_test('rawfri', 'bc12_l5_to_bc_l1_map_20000_nfl')
-- ) 
-- SELECT layer,
--   COUNT(*) cnt,
--   SUM(COUNT(*)) OVER () AS total_cnt
-- FROM tested
-- GROUP BY layer
-- ORDER BY layer;
