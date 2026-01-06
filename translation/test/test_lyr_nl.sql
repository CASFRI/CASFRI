CREATE SCHEMA IF NOT EXISTS casfri50_test;
SELECT TT_Prepare('translation', 'nl_nli01_lyr', '_nl_nli01_lyr_test', 'ab_avi01_lyr', FALSE);
SELECT TT_Prepare('translation', 'nl_nli02_lyr', '_nl_nli02_lyr_test', 'ab_avi01_lyr', FALSE);
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_nl_new CASCADE;
-------------------------
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nl_species_codes_idx
ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli1', 1, 1350, NULL, 'lyr'); -- Generates about 800 (861) LYR rows
CREATE TABLE casfri50_test.lyr_nl_new AS
SELECT * FROM TT_Translate_nl_nli01_lyr_test('rawfri', 'nl01_l1_to_nl_nli1_l1_map_1350_lyr');
------------------------
SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1, 1500, NULL, 'lyr'); -- Generates about 800 (820) LYR rows
INSERT INTO casfri50_test.lyr_nl_new
SELECT * FROM TT_Translate_nl_nli02_lyr_test('rawfri', 'nl02_l1_to_nl_nli2_l1_map_1500_lyr');
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_nl_new_ordered AS
SELECT * FROM casfri50_test.lyr_nl_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
------------------------
-- SELECT *
-- FROM TT_CheckNumberOfTests('lyr', 'nl', TRUE)
-- WHERE NOT sufficient OR diff_pct >= 20;