CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'ns_nsi01_lyr', '_ns_lyr_test', 'ab_avi01_lyr', FALSE); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_ns_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ns_species_codes_idx
ON translation.species_code_mapping (ns_species_codes)
WHERE TT_NotEmpty(ns_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 1, 'ns_nsi', 1, 500, NULL, 'lyr'); -- Generates 395 LYR rows
CREATE TABLE casfri50_test.lyr_ns_new AS
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns01_l1_to_ns_nsi_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns01', 2, 'ns_nsi', 1, 4100, NULL, 'lyr'); -- Generates 675 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns01_l2_to_ns_nsi_l1_map_4100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 1, 'ns_nsi', 1, 500, NULL, 'lyr'); -- Generates 385 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns02_l1_to_ns_nsi_l1_map_500_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns02', 2, 'ns_nsi', 1, 4100, NULL, 'lyr'); -- Generates 696 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns02_l2_to_ns_nsi_l1_map_4100_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 50, NULL, 'lyr'); -- Generates 39 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l1_to_ns_nsi_l1_map_50_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, 4550, NULL, 'lyr'); -- Generates 1079 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns03_l2_to_ns_nsi_l1_map_4550_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns04', 1, 'ns_nsi', 1, 50, NULL, 'lyr'); -- Generates 39 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns04_l1_to_ns_nsi_l1_map_50_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'ns04', 2, 'ns_nsi', 1, 4300, NULL, 'lyr'); -- Generates 1156 LYR rows
INSERT INTO casfri50_test.lyr_ns_new
SELECT * FROM TT_Translate_ns_lyr_test('rawfri', 'ns04_l2_to_ns_nsi_l1_map_4300_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_ns_new_ordered AS
SELECT * FROM casfri50_test.lyr_ns_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'ns', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;