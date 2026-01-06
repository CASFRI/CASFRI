CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'qc_ini03_lyr', '_qc_ini03_lyr_test', 'ab_avi01_lyr', FALSE);
SELECT TT_Prepare('translation', 'qc_ini04_lyr', '_qc_ini04_lyr_test', 'ab_avi01_lyr', FALSE);
SELECT TT_Prepare('translation', 'qc_ipf05_lyr', '_qc_ipf05_lyr_test', 'ab_avi01_lyr', FALSE);
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_qc_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1, 1700, NULL, 'lyr'); -- Generates about 1000 (1072) LYR rows
CREATE TABLE casfri50_test.lyr_qc_new AS
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc01_l1_to_qc_ini03_l1_map_1700_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc01', 2, 'qc_ini03', 1, 20000, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc01_l2_to_qc_ini03_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 1, 'qc_ini03', 1, 1600, NULL, 'lyr'); -- Generates about 800 (819) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc02_l1_to_qc_ini03_l1_map_1600_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc02', 2, 'qc_ini03', 1, 50000, NULL, 'lyr'); -- Generates about 200 (227) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc02_l2_to_qc_ini03_l1_map_50000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, 800, NULL, 'lyr'); -- Generates about 300 (321) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc03_l1_to_qc_ini03_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc03', 2, 'qc_ini03', 1, 77000, NULL, 'lyr'); -- Generates about 50 (55) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc03_l2_to_qc_ini03_l1_map_77000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, 1400, NULL, 'lyr'); -- Generates about 900 (942) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc04_l1_to_qc_ini04_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc04', 2, 'qc_ini04', 1, 20000, NULL, 'lyr'); -- Generates about 200 (215) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc04_l2_to_qc_ini04_l1_map_20000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, 1400, NULL, 'lyr'); -- Generates about 1000 (1021) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc05_l1_to_qc_ipf_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc05', 2, 'qc_ipf', 1, 24000, NULL, 'lyr'); -- Generates about 200 (222) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc05_l2_to_qc_ipf_l1_map_24000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 1, 'qc_ini04', 1, 1500, NULL, 'lyr'); -- Generates about 1000 (1051) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc06_l1_to_qc_ini04_l1_map_1500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc06', 2, 'qc_ini04', 1, 15000, NULL, 'lyr'); -- Generates about 200 (216) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc06_l2_to_qc_ini04_l1_map_15000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1, 300, NULL, 'lyr'); -- Generates about 200 (220) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc07_l1_to_qc_ipf_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc07', 2, 'qc_ipf', 1, 5500, NULL, 'lyr'); -- Generates about 100 (106) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc07_l2_to_qc_ipf_l1_map_5500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc08', 1, 'qc_ini03', 1, 750, NULL, 'lyr'); -- Generates about 300 (315) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc08_l1_to_qc_ini03_l1_map_750_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc08', 2, 'qc_ini03', 1, 96000, NULL, 'lyr'); -- Generates about 50 (56) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini03_lyr_test('rawfri', 'qc08_l2_to_qc_ini03_l1_map_96000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc09', 1, 'qc_ini04', 1, 800, NULL, 'lyr'); -- Generates about 400 (423) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc09_l1_to_qc_ini04_l1_map_800_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc09', 2, 'qc_ini04', 1, 13000, NULL, 'lyr'); -- Generates about 100 (118) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ini04_lyr_test('rawfri', 'qc09_l2_to_qc_ini04_l1_map_13000_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc10', 1, 'qc_ipf', 1, 1400, NULL, 'lyr'); -- Generates about 1000 (1085) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc10_l1_to_qc_ipf_l1_map_1400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'qc10', 2, 'qc_ipf', 1, 20500, NULL, 'lyr'); -- Generates about 200 (212) LYR rows
INSERT INTO casfri50_test.lyr_qc_new
SELECT * FROM TT_Translate_qc_ipf05_lyr_test('rawfri', 'qc10_l2_to_qc_ipf_l1_map_20500_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_qc_new_ordered AS
SELECT * FROM casfri50_test.lyr_qc_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT  *
-- FROM TT_CheckNumberOfTests('lyr', 'qc', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;