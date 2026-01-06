CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'pe_pei01_lyr', '_pe_lyr_test', 'ab_avi01_lyr', FALSE); 
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_pe_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pe_species_codes_idx
ON translation.species_code_mapping (pe_species_codes)
WHERE TT_NotEmpty(pe_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, 300, NULL, 'lyr'); -- Generates about 200 (227) LYR rows
CREATE TABLE casfri50_test.lyr_pe_new AS
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe01_l1_to_pe_pei_l1_map_300_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe02', 1, 'pe_pei', 1, 450, NULL, 'lyr'); -- Generates about 200 (222) LYR rows
INSERT INTO casfri50_test.lyr_pe_new
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe02_l1_to_pe_pei_l1_map_450_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe03', 1, 'pe_pei', 1, 400, NULL, 'lyr'); -- Generates about 200 (208) LYR rows
INSERT INTO casfri50_test.lyr_pe_new
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe03_l1_to_pe_pei_l1_map_400_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'pe04', 1, 'pe_pei', 1, 400, NULL, 'lyr'); -- Generates about 200 (200) LYR rows
INSERT INTO casfri50_test.lyr_pe_new
SELECT * FROM TT_Translate_pe_lyr_test('rawfri', 'pe04_l1_to_pe_pei_l1_map_400_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_pe_new_ordered AS
SELECT * FROM casfri50_test.lyr_pe_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT  *
FROM TT_CheckNumberOfTests('lyr', 'pe', TRUE)
WHERE NOT sufficient OR diff_pct >= 20;
*/