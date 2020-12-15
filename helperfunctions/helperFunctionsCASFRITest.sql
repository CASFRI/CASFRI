------------------------------------------------------------------------------
-- CASFRI Helper functions test file for CASFRI v5 beta
-- For use with PostgreSQL Table Tranlation Engine v0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
-- https://github.com/edwardsmarc/casfri
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
-------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';

-- Create some test lookup table
DROP TABLE IF EXISTS test_lookup_qc_stdstr;
CREATE TABLE test_lookup_qc_stdstr AS
SELECT 'VIR'::text source_val, '1'::text num_of_layers, 'VIR'::text layer_1_age, ''::text layer_2_age
UNION ALL
SELECT 'VIN'::text, '1'::text, 'VIN'::text, ''::text
UNION ALL
SELECT 'VIN10'::text, '2'::text, 'VIN'::text, '10'::text
UNION ALL
SELECT 'VIN20'::text, '2'::text, 'VIN'::text, '20'::text
UNION ALL
SELECT '2010'::text, '2'::text, '20'::text, '10'::text
UNION ALL
SELECT '10'::text, '1'::text, '10'::text, ''::text
UNION ALL
SELECT '1010'::text, '2'::text, '10'::text, '10'::text;

-- Create some test lookup table
DROP TABLE IF EXISTS test_lookup_on_species;
CREATE TABLE test_lookup_on_species AS
SELECT 'Sw'::text source_val, 'PICE_GLAU'::text spec1
UNION ALL
SELECT 'Sb'::text, 'PICE_MARI'::text;

-- test photo year table with geometry
DROP TABLE IF EXISTS photo_test2;
CREATE TABLE photo_test2 AS
SELECT ST_GeometryFromText('MULTIPOLYGON(((0 0, 0 7, 7 7, 7 0, 0 0)))', 4268) AS the_geom, 1990::text AS YEAR
UNION ALL
SELECT ST_GeometryFromText('MULTIPOLYGON(((0 0, 0 2, 2 2, 2 0, 0 0)))', 4268), 1999::text
UNION ALL
SELECT ST_GeometryFromText('MULTIPOLYGON(((6 6, 6 15, 15 15, 15 6, 6 6)))', 4268), 2000::text;
-----------------------------------------------------------
-- Comment out the following line and the last one of the file to display 
-- only failing tests
SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    SELECT 'TT_vri01_non_for_veg_validation'::text function_tested,           1 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_vri01_nat_non_veg_validation'::text function_tested,           2 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_anth_validation'::text function_tested,          3 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_vri01_origin_translation'::text function_tested,               4 maj_num,  1 nb_test UNION ALL
    SELECT 'TT_vri01_site_index_translation'::text function_tested,           5 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_veg_translation'::text function_tested,          6 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_vri01_nat_non_veg_translation'::text function_tested,          7 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_anth_translation'::text function_tested,         8 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_avi01_non_for_veg_translation'::text function_tested,          9 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_nbi01_stand_structure_translation'::text function_tested,     10 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_validation'::text function_tested,              12 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_translation'::text function_tested,             13 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_nbi01_nb01_productive_for_translation'::text function_tested, 14 maj_num, 11 nb_test UNION ALL
    SELECT 'TT_nbi01_nb02_productive_for_translation'::text function_tested, 15 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_CreateFilterView'::text function_tested,                      16 maj_num, 23 nb_test UNION ALL
    SELECT 'TT_vri01_dist_yr_translation'::text function_tested,             17 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,     20 maj_num,  8 nb_test UNION ALL
    SELECT 'TT_qc_ipf_not_etage_notnull_validation'::text function_tested,    21 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_qc_ipf_not_etage_layer1_validation'::text function_tested,     22 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_qc_ipf_not_etage_dens_layers_validation'::text function_tested,23 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_fim_species_code'::text function_tested,                      24 maj_num,  7 nb_test UNION ALL
    SELECT 'TT_fim_species_translation'::text function_tested,               25 maj_num,  6 nb_test UNION ALL
    SELECT 'TT_fim_species_percent_translation'::text function_tested,       26 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_yvi01_nat_non_veg_validation'::text function_tested,          27 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_yvi01_nat_non_veg_translation'::text function_tested,         28 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_yvi01_non_for_veg_translation'::text function_tested,         29 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,    30 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_avi01_stand_structure_validation'::text function_tested,      31 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_avi01_stand_structure_translation'::text function_tested,     32 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_fvi01_stand_structure_validation'::text function_tested,      33 maj_num,  7 nb_test UNION ALL
    SELECT 'TT_fvi01_countOfNotNull'::text function_tested,                  34 maj_num,  7 nb_test UNION ALL
    SELECT 'TT_vri01_countOfNotNull'::text function_tested,                  35 maj_num, 17 nb_test UNION ALL
    SELECT 'TT_sk_utm01_species_percent_validation'::text function_tested,   36 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_sk_utm01_species_percent_translation'::text function_tested,  37 maj_num, 11 nb_test UNION ALL
    SELECT 'TT_sk_utm01_species_translation'::text function_tested,          38 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_sfv01_stand_structure_translation'::text function_tested,     39 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_sfv01_countOfNotNull'::text function_tested,                  40 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_ns_nsi01_countOfNotNull'::text function_tested,               41 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_HasNFLInfo'::text function_tested,                            42 maj_num, 13 nb_test UNION ALL
    SELECT 'TT_pe_pei01_countOfNotNull'::text function_tested,               43 maj_num,  8 nb_test UNION ALL
    SELECT 'TT_vri01_hasCountOfNotNull'::text function_tested,               44 maj_num,  6 nb_test UNION ALL
    SELECT 'TT_ns_nsi01_hasCountOfNotNull'::text function_tested,            45 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_fvi01_hasCountOfNotNull'::text function_tested,               46 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_on_fim02_countOfNotNull'::text function_tested,               47 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_on_fim02_hasCountOfNotNull'::text function_tested,            48 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_pe_pei01_hasCountOfNotNull'::text function_tested,            49 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_sfv01_hasCountOfNotNull'::text function_tested,               50 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_sk_utm_countOfNotNull'::text function_tested,                 51 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_sk_utm_hasCountOfNotNull'::text function_tested,              52 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_bc_height'::text function_tested,                             53 maj_num,  6 nb_test UNION ALL
    SELECT 'TT_fvi01_structure_per'::text function_tested,                   54 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_fvi01_structure_per_validation'::text function_tested,        55 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_wetland_code_translation'::text function_tested,              56 maj_num,  6 nb_test UNION ALL
    SELECT 'TT_qc_prg3_wetland_validation'::text function_tested,            57 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_qc_prg5_wetland_validation'::text function_tested,            58 maj_num,  2 nb_test UNION ALL
    SELECT 'TT_row_translation_rule_nt_lyr'::text function_tested,           59 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_qc_prg4_species_translation'::text function_tested,           60 maj_num,  14 nb_test UNION ALL
    SELECT 'TT_qc_prg5_species_translation'::text function_tested,           61 maj_num,  7 nb_test UNION ALL
    SELECT 'TT_qc_prg4_species_per_translation'::text function_tested,       62 maj_num,  12 nb_test UNION ALL
    SELECT 'TT_qc_prg5_species_per_translation'::text function_tested,       63 maj_num,  7 nb_test UNION ALL
    SELECT 'TT_qc_prg4_not_double_species_validation'::text function_tested, 64 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_qc_prg5_species_matchTable_validation'::text function_tested, 65 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_mb_fri_countOfNotNull'::text function_tested,                 66 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_mb_fri_hasCountOfNotNull'::text function_tested,              67 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_mb_fli01_stand_structure_translation'::text function_tested,  68 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_isCommercial'::text function_tested,                 69 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_isNonCommercial'::text function_tested,              70 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_crown_closure_upper_translation'::text function_tested,71 maj_num,3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_crown_closure_lower_translation'::text function_tested,72 maj_num,3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_height_upper_translation'::text function_tested,     73 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_height_lower_translation'::text function_tested,     74 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_isForest'::text function_tested,                     75 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_productivity_translation'::text function_tested,     76 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_productivity_type_translation'::text function_tested,77 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_qc_prg4_lengthMatchList'::text function_tested,               78 maj_num,  13 nb_test UNION ALL
    SELECT 'TT_nl_nli01_origin_upper_translation'::text function_tested,     79 maj_num,   4 nb_test UNION ALL
    SELECT 'TT_nl_nli01_origin_lower_translation'::text function_tested,     80 maj_num,   5 nb_test UNION ALL
    SELECT 'TT_nl_nli01_origin_lower_validation'::text function_tested,      81 maj_num,   4 nb_test UNION ALL
    SELECT 'TT_qc_origin_translation'::text function_tested,                 82 maj_num,   3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_origin_newfoundland_validation'::text function_tested,83 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_nl_nli01_crown_closure_validation'::text function_tested,     84 maj_num,   2 nb_test UNION ALL
    SELECT 'TT_nl_nli01_height_validation'::text function_tested,            85 maj_num,   2 nb_test UNION ALL
    SELECT 'TT_qc_prg3_wetland_translation'::text function_tested,           86 maj_num,   15 nb_test UNION ALL
    SELECT 'TT_qc_prg5_wetland_translation'::text function_tested,           87 maj_num,   7 nb_test UNION ALL
    SELECT 'TT_qc_prg4_wetland_translation'::text function_tested,           88 maj_num,   7 nb_test UNION ALL
    SELECT 'TT_qc_prg4_wetland_validation'::text function_tested,            89 maj_num,   2 nb_test UNION ALL
    SELECT 'TT_qc_countOfNotNull'::text function_tested,                     90 maj_num,   5 nb_test UNION ALL
    SELECT 'TT_qc_hasCountOfNotNull'::text function_tested,                  91 maj_num,   4 nb_test UNION ALL
	SELECT 'TT_lyr_layer_translation'::text function_tested,                 92 maj_num,   15 nb_test UNION ALL
	SELECT 'TT_bc_lyr_layer_translation'::text function_tested,              93 maj_num,   6 nb_test
),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, nb_test, generate_series(1, nb_test)::text min_num
FROM test_nb
ORDER BY maj_num, min_num
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of tests for ' || 
                b.function_tested || ' in the initial table...') AS function_tested,
       coalesce(description, 'ERROR: Too many tests (' || nb_test || ') for ' || a.function_tested || ' in the initial table...') description, 
       NOT passed IS NULL AND 
          (regexp_split_to_array(number, '\.'))[1] = maj_num::text AND 
          (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series AS a FULL OUTER JOIN (


---------------------------------------------------------
-- TT_vri01_non_for_veg_validation
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_vri01_non_for_veg_validation'::text function_tested,
       'Good combo V'::text description,
       TT_vri01_non_for_veg_validation('V', 'BL', NULL, NULL) passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_vri01_non_for_veg_validation'::text function_tested,
       'Bad combo V'::text description,
       TT_vri01_non_for_veg_validation('V', 'XXX', NULL, NULL) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_vri01_non_for_veg_validation'::text function_tested,
       'Good combo F'::text description,
      TT_vri01_non_for_veg_validation('F', NULL, 'BL', NULL) passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_vri01_non_for_veg_validation'::text function_tested,
       'Good combo F'::text description,
      TT_vri01_non_for_veg_validation('F', NULL, NULL, 'AF') passed
---------------------------------------------------------
-- TT_vri01_nat_non_veg_validation
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_vri01_nat_non_veg_validation'::text function_tested,
       'Good combo V'::text description,
       TT_vri01_nat_non_veg_validation('V', NULL, NULL, NULL, 'BE') passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_vri01_nat_non_veg_validation'::text function_tested,
       'Good combo V'::text description,
       TT_vri01_nat_non_veg_validation('V', 'BE', NULL, NULL, NULL) passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_vri01_nat_non_veg_validation'::text function_tested,
       'Bad combo V'::text description,
       TT_vri01_nat_non_veg_validation('V', NULL, NULL, NULL, NULL) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_vri01_nat_non_veg_validation'::text function_tested,
       'Good combo F'::text description,
       TT_vri01_nat_non_veg_validation('F', NULL, NULL, 'TIDE', NULL) passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_vri01_nat_non_veg_validation'::text function_tested,
       'Good combo F'::text description,
       TT_vri01_nat_non_veg_validation('F', NULL, 'EL', NULL, NULL) passed
---------------------------------------------------------
-- TT_vri01_non_for_anth_validation
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_vri01_non_for_anth_validation'::text function_tested,
       'Good combo V'::text description,
       TT_vri01_non_for_anth_validation('V', 'AP', NULL, NULL) passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_vri01_non_for_anth_validation'::text function_tested,
       'Bad combo V'::text description,
       TT_vri01_non_for_anth_validation('V', 'XXX', NULL, NULL) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_vri01_non_for_anth_validation'::text function_tested,
       'Good combo F'::text description,
       TT_vri01_non_for_anth_validation('F', NULL, 'C', NULL) passed
---------------------------------------------------------
-- TT_vri01_origin_translation
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_vri01_origin_translation'::text function_tested,
       'Good year and age'::text description,
       TT_vri01_origin_translation('2001-04-10', '10') = 1991 passed
---------------------------------------------------------
-- TT_vri01_site_index_translation
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_vri01_site_index_translation'::text function_tested,
       'site_index present'::text description,
       TT_vri01_site_index_translation('12.1', '10') = 12.1::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_vri01_site_index_translation'::text function_tested,
       'site_index null'::text description,
       TT_vri01_site_index_translation(NULL::text, '10') = 10::double precision passed
---------------------------------------------------------
-- TT_vri01_non_for_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_vri01_non_for_veg_translation'::text function_tested,
       'Good test'::text description,
       TT_vri01_non_for_veg_translation('V'::text, 'BL'::text, ''::text, ''::text) = 'BRYOID' passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_vri01_non_for_veg_translation'::text function_tested,
       'No matches test'::text description,
       TT_vri01_non_for_veg_translation('V'::text, ''::text, ''::text, ''::text) IS NULL passed
---------------------------------------------------------
-- TT_vri01_nat_non_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_vri01_nat_non_veg_translation'::text function_tested,
       'Good test'::text description,
       TT_vri01_nat_non_veg_translation('V'::text, 'BE'::text, ''::text, ''::text, ''::text) = 'BEACH' passed
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_vri01_nat_non_veg_translation'::text function_tested,
       'No matches test'::text description,
       TT_vri01_nat_non_veg_translation('V'::text, ''::text, ''::text, ''::text, ''::text) IS NULL passed
---------------------------------------------------------
-- TT_vri01_non_for_anth_translation
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_vri01_non_for_anth_translation'::text function_tested,
       'Good test'::text description,
       TT_vri01_non_for_anth_translation('V'::text, 'AP'::text, ''::text, ''::text) = 'FACILITY_INFRASTRUCTURE' passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_vri01_non_for_anth_translation'::text function_tested,
       'No matches test'::text description,
       TT_vri01_non_for_anth_translation('V'::text, ''::text, ''::text, ''::text) IS NULL passed
---------------------------------------------------------
-- TT_avi01_non_for_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_avi01_non_for_veg_translation'::text function_tested,
       'Pass tall shrub'::text description,
       TT_avi01_non_for_veg_translation('SO', '2') = 'TALL_SHRUB' passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_avi01_non_for_veg_translation'::text function_tested,
       'Pass low shrub'::text description,
       TT_avi01_non_for_veg_translation('SC', '1.1') = 'LOW_SHRUB' passed
---------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_avi01_non_for_veg_translation'::text function_tested,
       'Pass other veg'::text description,
       TT_avi01_non_for_veg_translation('HG', '1.1') = 'GRAMINOIDS' passed
---------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_avi01_non_for_veg_translation'::text function_tested,
       'Wring code'::text description,
       TT_avi01_non_for_veg_translation('', '1.1') IS NULL passed
---------------------------------------------------------
  
---------------------------------------------------------
-- TT_nbi01_stand_structure_translation
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Wrong source dataset'::text description,
       TT_nbi01_stand_structure_translation('Wetland'::text, '0'::text, '0'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Single layer all zero'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '0'::text, '0'::text) = 'SINGLE_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '10.3'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Single layer l1vs > 0'::text description,
       TT_nbi01_stand_structure_translation('geonb_forest-foret'::text, '2'::text, '0'::text) = 'SINGLE_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Multi layer'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '1'::text, '1'::text) = 'MULTI_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '10.5'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Complex layer'::text description,
       TT_nbi01_stand_structure_translation('geonb_forest-foret'::text, '2'::text, '2'::text) = 'COMPLEX' passed
---------------------------------------------------------
  -- TT_nbi01_wetland_validation
---------------------------------------------------------
UNION ALL
SELECT '12.1'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'pass 1'::text description,
       TT_nbi01_wetland_validation('FE'::text, 'EV'::text, 'BP'::text, '1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '12.2'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'pass 2'::text description,
       TT_nbi01_wetland_validation('BO'::text, 'OV'::text, 'MI'::text, '2'::text)  passed
---------------------------------------------------------
UNION ALL
SELECT '12.3'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'Fail due to dash'::text description,
       TT_nbi01_wetland_validation('BO'::text, 'OV'::text, 'MI'::text, '3'::text) IS FALSE  passed
---------------------------------------------------------
UNION ALL
SELECT '12.4'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'Fail due to no case'::text description,
       TT_nbi01_wetland_validation('XX'::text, 'OV'::text, 'MI'::text, '3'::text) IS FALSE  passed
---------------------------------------------------------
  -- TT_nbi01_wetland_translation
---------------------------------------------------------
UNION ALL
SELECT '13.1'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'pass 1'::text description,
       TT_nbi01_wetland_translation('FE'::text, 'EV'::text, 'BP'::text, '1'::text) = 'FEN' passed
---------------------------------------------------------
UNION ALL
SELECT '13.2'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'pass 2'::text description,
       TT_nbi01_wetland_translation('BO'::text, 'OV'::text, 'MI'::text, '2'::text) = 'OPEN_NON_TREED_FRESHWATER'  passed
---------------------------------------------------------
UNION ALL
SELECT '13.3'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'Null due to dash'::text description,
       TT_nbi01_wetland_translation('BO'::text, 'OV'::text, 'MI'::text, '3'::text) IS NULL  passed
---------------------------------------------------------
UNION ALL
SELECT '13.4'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'Null due to no case'::text description,
       TT_nbi01_wetland_translation('XX'::text, 'OV'::text, 'MI'::text, '3'::text) IS NULL
---------------------------------------------------------
  -- TT_nbi01_nb01_productive_for_translation
---------------------------------------------------------
UNION ALL
SELECT '14.1'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 1'::text description,
       TT_nbi01_nb01_productive_for_translation(NULL::text, '10'::text, 'CC'::text, 'XX'::text, '5'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '14.2'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 2'::text description,
       TT_nbi01_nb01_productive_for_translation('6'::text, '10'::text, 'CC'::text, 'XX'::text, '5'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '14.3'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 3'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, NULL::text, 'CC'::text, 'XX'::text, '5'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '14.4'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 4'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '0.05'::text, 'CC'::text, 'XX'::text, '5'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '14.5'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 5'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '101'::text, 'CC'::text, 'XX'::text, '5'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '14.6'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6a'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, ''::text, 'CC'::text, '0'::text) = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '14.7'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6b'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'CC'::text, 'CC'::text, '0'::text) = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '14.8'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6c'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'F'::text, 'CC'::text, '1'::text) = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '14.9'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6d'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'F'::text, 'CC'::text, '0'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '14.10'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 7a'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'CC'::text, ''::text, '0'::text) = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '14.11'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 7b'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'CC'::text, 'F'::text, '0'::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
  -- TT_nbi01_nb02_productive_for_translation
---------------------------------------------------------
UNION ALL
SELECT '15.1'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 1'::text description,
       TT_nbi01_nb02_productive_for_translation(1::text) = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '15.2'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 2'::text description,
       TT_nbi01_nb02_productive_for_translation(2::text) = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '15.3'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 3'::text description,
       TT_nbi01_nb02_productive_for_translation(3::text) = 'POTENTIALLY_PRODUCTIVE' passed
---------------------------------------------------------
UNION ALL
SELECT '15.4'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 0'::text description,
       TT_nbi01_nb02_productive_for_translation(0::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '15.5'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst is null'::text description,
       TT_nbi01_nb02_productive_for_translation(NULL::text) IS NULL passed
---------------------------------------------------------
  -- TT_CreateFilterView
---------------------------------------------------------
UNION ALL
SELECT '16.1'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple lyr1 first argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', NULL, NULL, 'lyr1') = 'DROP VIEW IF EXISTS rawfri.ab06_lyr1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1 AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.2'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple nfl1 first argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'nfl3', NULL, NULL, 'nfl3') = 'DROP VIEW IF EXISTS rawfri.ab06_nfl3 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_nfl3 AS
SELECT nat_non, anth_veg, anth_non, nfl
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.3'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple dst1 first argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'dst1', NULL, NULL, 'dst1') = 'DROP VIEW IF EXISTS rawfri.ab06_dst1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_dst1 AS
SELECT mod1, mod1_yr, mod1_ext, mod2, mod2_yr, mod2_ext
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.4'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Group of many attributes for selectAttrList'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1, nfl3, dst1', NULL, NULL, 'lyr1_nfl3_dst1') = 'DROP VIEW IF EXISTS rawfri.ab06_lyr1_nfl3_dst1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_nfl3_dst1 AS
SELECT sp1, sp2, sp3, nat_non, anth_veg, anth_non, nfl, mod1, mod1_yr, mod1_ext, mod2, mod2_yr, mod2_ext
FROM rawfri.ab06;' passed
---------------------------------------------------------
--UNION ALL
--SELECT '16.5'::text number,
--       'TT_CreateFilterView'::text function_tested,
--       'Wrong first argument test 1'::text description,
--       TT_CreateFilterView('rawfri', 'ab06', 'lyr', NULL, NULL, 'lyr') = 
--       'ERROR TT_CreateFilterView(): ''selectAttrList'' parameter''s ''lyr'' attribute not found in table ''rawfri.ab06''...' passed
---------------------------------------------------------
--UNION ALL
--SELECT '16.6'::text number,
--       'TT_CreateFilterView'::text function_tested,
--       'Wrong first argument test 2'::text description,
--       TT_CreateFilterView('rawfri', 'ab06', 'lyr, lyr1, nfl1, dst1', NULL, NULL, 'lyr1_nfl1_dst1') = 
--       'ERROR TT_CreateFilterView(): ''selectAttrList'' parameter''s ''lyr'' attribute not found in table ''rawfri.ab06''...' passed
---------------------------------------------------------
UNION ALL
SELECT '16.5'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl3', NULL, 'lyr1_for_nfl3') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl3 AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.6'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Wrong second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'lyr', NULL, 'lyr1_for_lyr') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_lyr CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_lyr AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.7'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl3, nfl4', NULL, 'lyr1_for_nfl3_nfl4') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_nfl4 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl3_nfl4 AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'') OR 
      (TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
      (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
      (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
      (TT_NotEmpty(unfl::text) AND unfl::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.8'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''and'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl3, nfl4]', NULL, 'lyr1_for_nfl3_and_nfl4') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_and_nfl4 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl3_and_nfl4 AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE ((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
        (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0''))
       AND
        ((TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
        (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
        (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
        (TT_NotEmpty(unfl::text) AND unfl::text != ''0''))
      ;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.9'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''or/and'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'dst1, [nfl3, nfl4]', NULL, 'lyr1_for_dst_or_nfl3_and_nfl4') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_dst_or_nfl3_and_nfl4 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_dst_or_nfl3_and_nfl4 AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE (TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
        (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
        (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
        (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
        (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
        (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0'')
       OR
        ((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
        (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0''))
       AND
        ((TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
        (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
        (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
        (TT_NotEmpty(unfl::text) AND unfl::text != ''0''))
      ;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.10'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''and/or'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl1, nfl2], dst1', NULL, 'lyr1_for_nfl1_and_nfl2_or_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_and_nfl2_or_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_and_nfl2_or_dst AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE (TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
      (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
      (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
      (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
      (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
      (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.11'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''and/or'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl3, nfl4], dst1', NULL, 'lyr1_for_nfl3_and_nfl4_or_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_and_nfl4_or_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl3_and_nfl4_or_dst AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE ((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
        (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0''))
       AND
        ((TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
        (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
        (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
        (TT_NotEmpty(unfl::text) AND unfl::text != ''0''))
       OR 
        (TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
        (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
        (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
        (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
        (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
        (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.12'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple third argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl1, nfl2', 'dst1', 'lyr1_for_nfl1_or_nfl2_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_or_nfl2_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_or_nfl2_not_dst AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE NOT
       ((TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
      (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
      (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
      (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
      (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
      (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.13'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple third argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl3, nfl4', 'dst1', 'lyr1_for_nfl3_or_nfl4_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_or_nfl4_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl3_or_nfl4_not_dst AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE ((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'') OR 
      (TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
      (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
      (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
      (TT_NotEmpty(unfl::text) AND unfl::text != ''0''))
      AND NOT
       ((TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
      (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
      (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
      (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
      (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
      (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.14'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple ''and'' second argument with third argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl1, nfl2]', 'dst1', 'lyr1_for_nfl1_and_nfl2_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_and_nfl2_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_and_nfl2_not_dst AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE NOT
       ((TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
      (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
      (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
      (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
      (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
      (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.15'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple ''and'' second argument with third argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl3, nfl4]', 'dst1', 'lyr1_for_nfl3_and_nfl4_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl3_and_nfl4_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl3_and_nfl4_not_dst AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE (((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
        (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0''))
       AND
        ((TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
        (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
        (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
        (TT_NotEmpty(unfl::text) AND unfl::text != ''0''))
      )
      AND NOT
       ((TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
        (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
        (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
        (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
        (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
        (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.16'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test empty ''eco'' keywords'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'eco', 'nfl3, eco', NULL, 'eco_for_nfl3_or_eco') = 
       'DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl3_or_eco CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_eco_for_nfl3_or_eco AS
SELECT moist_reg, nfl, nat_non, sp1, sp2, density, sp1_per
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'') OR 
      (TT_NotEmpty(moist_reg::text) AND moist_reg::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'') OR 
      (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(sp1::text) AND sp1::text != ''0'') OR 
      (TT_NotEmpty(sp2::text) AND sp2::text != ''0'') OR 
      (TT_NotEmpty(density::text) AND density::text != ''0'') OR 
      (TT_NotEmpty(sp1_per::text) AND sp1_per::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.17'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test empty keywords in ''and'' second argument'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'eco', '[nfl3, eco]', 'dst2', 'eco_for_nfl3_and_eco_not_dst2') = 
       'DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl3_and_eco_not_dst2 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_eco_for_nfl3_and_eco_not_dst2 AS
SELECT moist_reg, nfl, nat_non, sp1, sp2, density, sp1_per
FROM rawfri.ab06
WHERE ((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
        (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0''))
       AND
        ((TT_NotEmpty(moist_reg::text) AND moist_reg::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0'') OR 
        (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(sp1::text) AND sp1::text != ''0'') OR 
        (TT_NotEmpty(sp2::text) AND sp2::text != ''0'') OR 
        (TT_NotEmpty(density::text) AND density::text != ''0'') OR 
        (TT_NotEmpty(sp1_per::text) AND sp1_per::text != ''0''))
      ;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.18'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test with some source attributes in each parameter'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1, wkb_geometry', '[nfl3, inventory_id, nfl4]', 'dst1, trm', 'extra_lyr1_for_nfl3_and_nfl4_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_extra_lyr1_for_nfl3_and_nfl4_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_extra_lyr1_for_nfl3_and_nfl4_not_dst AS
SELECT sp1, sp2, sp3, wkb_geometry
FROM rawfri.ab06
WHERE (((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
        (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
        (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
        (TT_NotEmpty(nfl::text) AND nfl::text != ''0''))
       AND
        ((TT_NotEmpty(inventory_id::text) AND inventory_id::text != ''0''))
       AND
        ((TT_NotEmpty(unat_non::text) AND unat_non::text != ''0'') OR 
        (TT_NotEmpty(uanth_veg::text) AND uanth_veg::text != ''0'') OR 
        (TT_NotEmpty(uanth_non::text) AND uanth_non::text != ''0'') OR 
        (TT_NotEmpty(unfl::text) AND unfl::text != ''0''))
      )
      AND NOT
       ((TT_NotEmpty(mod1::text) AND mod1::text != ''0'') OR 
        (TT_NotEmpty(mod1_yr::text) AND mod1_yr::text != ''0'') OR 
        (TT_NotEmpty(mod1_ext::text) AND mod1_ext::text != ''0'') OR 
        (TT_NotEmpty(mod2::text) AND mod2::text != ''0'') OR 
        (TT_NotEmpty(mod2_yr::text) AND mod2_yr::text != ''0'') OR 
        (TT_NotEmpty(mod2_ext::text) AND mod2_ext::text != ''0'') OR 
        (TT_NotEmpty(trm::text) AND trm::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.19'::text number,
       'TT_CreateFilterView'::text function_tested,
       'All arguments NULL'::text description,
       TT_CreateFilterView('rawfri', 'ab06', NULL, NULL, NULL, 'null') = 
       'DROP VIEW IF EXISTS rawfri.ab06_null CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_null AS
SELECT *
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.20'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test one CASFRI attribute to be replaced by source attributes'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'CAS_ID', NULL, NULL, 'cas_id') = 
       'DROP VIEW IF EXISTS rawfri.ab06_cas_id CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_cas_id AS
SELECT inventory_id, src_filename, trm_1, poly_num, ogc_fid
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.21'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test CASFRI attribute inside ''and'' braquets'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'cas_id', '[lyr1, cas_id]', 'nat_non_veg', 'lyr1_cas_id_nfl') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_cas_id_nfl CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_cas_id_nfl AS
SELECT inventory_id, src_filename, trm_1, poly_num, ogc_fid
FROM rawfri.ab06
WHERE ((TT_NotEmpty(sp1::text) AND sp1::text != ''0'') OR 
        (TT_NotEmpty(sp2::text) AND sp2::text != ''0'') OR 
        (TT_NotEmpty(sp3::text) AND sp3::text != ''0''))
       AND
        ((TT_NotEmpty(inventory_id::text) AND inventory_id::text != ''0'') OR 
        (TT_NotEmpty(src_filename::text) AND src_filename::text != ''0'') OR 
        (TT_NotEmpty(trm_1::text) AND trm_1::text != ''0'') OR 
        (TT_NotEmpty(poly_num::text) AND poly_num::text != ''0'') OR 
        (TT_NotEmpty(ogc_fid::text) AND ogc_fid::text != ''0''))
      ;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.22'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test with whereOutAttrList attribute only'::text description,
       TT_CreateFilterView('rawfri', 'ab06', NULL, NULL, 'LYR1', 'not_lyr1') = 
       'DROP VIEW IF EXISTS rawfri.ab06_not_lyr1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_not_lyr1 AS
SELECT *
FROM rawfri.ab06
WHERE NOT
       ((TT_NotEmpty(sp1::text) AND sp1::text != ''0'') OR 
      (TT_NotEmpty(sp2::text) AND sp2::text != ''0'') OR 
      (TT_NotEmpty(sp3::text) AND sp3::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.23'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test with whereOutAttrList attribute only'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'site_class, LYR1', NULL, NULL, 'site_class') = 
       'DROP VIEW IF EXISTS rawfri.ab06_site_class CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_site_class AS
SELECT tpr, sp1, sp2, sp3
FROM rawfri.ab06;' passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_vri01_dist_yr_translation
---------------------------------------------------------
UNION ALL
SELECT '17.1'::text number,
       'TT_vri01_dist_yr_translation'::text function_tested,
       'Test value <10, equal to cutoff'::text description,
       TT_vri01_dist_yr_translation('B05', '05') = 2005::int passed
---------------------------------------------------------
UNION ALL
SELECT '17.2'::text number,
       'TT_vri01_dist_yr_translation'::text function_tested,
       'Test value <10, greater than cutoff'::text description,
       TT_vri01_dist_yr_translation('B05', '04') = 1905::int passed
  ---------------------------------------------------------
UNION ALL
SELECT '17.3'::text number,
       'TT_vri01_dist_yr_translation'::text function_tested,
       'Test value >10, equal to cutoff'::text description,
       TT_vri01_dist_yr_translation('B17', '17') = 2017::int passed
---------------------------------------------------------
UNION ALL
SELECT '17.4'::text number,
       'TT_vri01_dist_yr_translation'::text function_tested,
       'Test value >10, greater than cutoff'::text description,
       TT_vri01_dist_yr_translation('B17', '16') = 1917::int passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_qc_ipf_2layer_age_codes_validation
---------------------------------------------------------
UNION ALL
SELECT '20.1'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Only 1 layer, rule is skipped so should return true'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIR', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, 'VIN', 'NULL') passed
---------------------------------------------------------
UNION ALL
SELECT '20.2'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Codes match'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIR10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, 'VIN', '10') passed
---------------------------------------------------------
UNION ALL
SELECT '20.3'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Codes match'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIR10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, '10', 'VIN') passed
---------------------------------------------------------
UNION ALL
SELECT '20.4'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Codes dont match'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, 'VIN', 'VIN') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.5'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Codes dont match'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, '10', '10') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.6'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Codes dont match'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.7'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'et_domi not null'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', 'VAL', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '20.8'::text number,
       'TT_qc_ipf_2layer_age_codes_validation'::text function_tested,
       'Should still run test if et_domi is EQU'::text description,
       TT_qc_ipf_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', 'EQU', '', '') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_qc_ipf_not_etage_notnull_validation
---------------------------------------------------------
UNION ALL
SELECT '21.1'::text number,
       'TT_qc_ipf_not_etage_notnull_validation'::text function_tested,
       'Test not null'::text description,
       TT_qc_ipf_not_etage_notnull_validation('N', 'val') passed
---------------------------------------------------------
UNION ALL
SELECT '21.2'::text number,
       'TT_qc_ipf_not_etage_notnull_validation'::text function_tested,
       'Test null'::text description,
       TT_qc_ipf_not_etage_notnull_validation('N', NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '21.3'::text number,
       'TT_qc_ipf_not_etage_notnull_validation'::text function_tested,
       'Test in_etage = O'::text description,
       TT_qc_ipf_not_etage_notnull_validation('O', NULL::text) passed
--------------------------------------------------------
---------------------------------------------------------
  -- TT_qc_ipf_not_etage_layer1_validation
---------------------------------------------------------
UNION ALL
SELECT '22.1'::text number,
       'TT_qc_ipf_not_etage_layer1_validation'::text function_tested,
       'Test layer = 1'::text description,
       TT_qc_ipf_not_etage_layer1_validation('N', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '22.2'::text number,
       'TT_qc_ipf_not_etage_layer1_validation'::text function_tested,
       'Test layer = 2'::text description,
       TT_qc_ipf_not_etage_layer1_validation('N', '2') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '22.3'::text number,
       'TT_qc_ipf_not_etage_layer1_validation'::text function_tested,
       'in etage = O'::text description,
       TT_qc_ipf_not_etage_layer1_validation('O', '2') passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_qc_ipf_not_etage_dens_layers_validation
---------------------------------------------------------
UNION ALL
SELECT '23.1'::text number,
       'TT_qc_ipf_not_etage_dens_layers_validation'::text function_tested,
       'In etage = O'::text description,
       TT_qc_ipf_not_etage_dens_layers_validation('O', '10', 'public', 'test_lookup_qc_stdstr') passed
---------------------------------------------------------
UNION ALL
SELECT '23.2'::text number,
       'TT_qc_ipf_not_etage_dens_layers_validation'::text function_tested,
       'In etage = N, num_of_layers = 1'::text description,
       TT_qc_ipf_not_etage_dens_layers_validation('N', '10', 'public', 'test_lookup_qc_stdstr') passed
---------------------------------------------------------
UNION ALL
SELECT '23.3'::text number,
       'TT_qc_ipf_not_etage_dens_layers_validation'::text function_tested,
       'In etage = N, num_of_layers = 2'::text description,
       TT_qc_ipf_not_etage_dens_layers_validation('N', '1010', 'public', 'test_lookup_qc_stdstr') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_fim_species_code
---------------------------------------------------------
UNION ALL
SELECT '24.1'::text number,
       'TT_fim_species_code'::text function_tested,
       'Get species code 1'::text description,
       TT_fim_species_code('Sw  10Sb  90', 1) = 'Sw  10' passed
---------------------------------------------------------
UNION ALL
SELECT '24.2'::text number,
       'TT_fim_species_code'::text function_tested,
       'Get species code 2'::text description,
       TT_fim_species_code('Sw  10Sb  90', 2) = 'Sb  90' passed
---------------------------------------------------------
UNION ALL
SELECT '24.3'::text number,
       'TT_fim_species_code'::text function_tested,
       'Get species code 100%'::text description,
       TT_fim_species_code('Sw 100', 1) = 'Sw 100' passed
---------------------------------------------------------
UNION ALL
SELECT '24.4'::text number,
       'TT_fim_species_code'::text function_tested,
       'Species code not available'::text description,
       TT_fim_species_code('Sw 100', 2) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '24.5'::text number,
       'TT_fim_species_code'::text function_tested,
       'Species code null'::text description,
       TT_fim_species_code('', 1) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '24.6'::text number,
       'TT_fim_species_code'::text function_tested,
       'Species code with preceding space in the middle. Issue #346'::text description,
       TT_fim_species_code('Sb  40Pj  20 Sw 20Bf  10Pt  10', 3) = 'Sw 20' passed
---------------------------------------------------------
UNION ALL
SELECT '24.7'::text number,
       'TT_fim_species_code'::text function_tested,
       'Species code with preceding space at the beginning. Issue #346'::text description,
       TT_fim_species_code(' PO 100', 1) = 'PO 100' passed
---------------------------------------------------------
  -- TT_fim_species_translation
---------------------------------------------------------
UNION ALL
SELECT '25.1'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Get species code 1'::text description,
       TT_fim_species_translation('Sw  10Sb  90', '1', 'public', 'test_lookup_on_species', 'source_val', 'spec1') = 'PICE_GLAU' passed
---------------------------------------------------------
UNION ALL
SELECT '25.2'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Get species code 2'::text description,
       TT_fim_species_translation('Sw  10Sb  90', '2', 'public', 'test_lookup_on_species', 'source_val', 'spec1') = 'PICE_MARI' passed
---------------------------------------------------------
UNION ALL
SELECT '25.3'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Get species code 100'::text description,
       TT_fim_species_translation('Sw 100', '1', 'public', 'test_lookup_on_species', 'source_val', 'spec1') = 'PICE_GLAU' passed
---------------------------------------------------------
UNION ALL
SELECT '25.4'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Species code doesnt exist'::text description,
       TT_fim_species_translation('Sw 100', '2', 'public', 'test_lookup_on_species', 'source_val', 'spec1') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '25.5'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Species code not in table'::text description,
       TT_fim_species_translation('Ss 100', '1', 'public', 'test_lookup_on_species', 'source_val', 'spec1') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '25.6'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Null string'::text description,
       TT_fim_species_translation(null::text, '1', 'public', 'test_lookup_on_species', 'source_val', 'spec1') IS NULL passed
---------------------------------------------------------
  -- TT_fim_species_percent_translation
---------------------------------------------------------
UNION ALL
SELECT '26.1'::text number,
       'TT_fim_species_percent_translation'::text function_tested,
       'Get species percent 1'::text description,
       TT_fim_species_percent_translation('Sw  10Sb  90', '1') = 10 passed
---------------------------------------------------------
UNION ALL
SELECT '26.2'::text number,
       'TT_fim_species_percent_translation'::text function_tested,
       'Get species percent 2'::text description,
       TT_fim_species_percent_translation('Sw  10Sb  90', '2') = 90 passed
---------------------------------------------------------
UNION ALL
SELECT '26.3'::text number,
       'TT_fim_species_percent_translation'::text function_tested,
       'Get species percent 100'::text description,
       TT_fim_species_percent_translation('Sw 100', '1') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '26.4'::text number,
       'TT_fim_species_percent_translation'::text function_tested,
       'Species number doesnt exist'::text description,
       TT_fim_species_percent_translation('Sw 100', '2') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '26.5'::text number,
       'TT_fim_species_percent_translation'::text function_tested,
       'Null string'::text description,
       TT_fim_species_percent_translation(null::text, '1') IS NULL passed
---------------------------------------------------------
  -- TT_yvi01_nat_non_veg_validation
---------------------------------------------------------
UNION ALL
SELECT '27.1'::text number,
       'TT_yvi01_nat_non_veg_validation'::text function_tested,
       'Test wrong type_lnd'::text description,
       TT_yvi01_nat_non_veg_validation('VF', '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '27.2'::text number,
       'TT_yvi01_nat_non_veg_validation'::text function_tested,
       'test Alpine'::text description,
       TT_yvi01_nat_non_veg_validation('NE', '', 'A') passed
---------------------------------------------------------
UNION ALL
SELECT '27.3'::text number,
       'TT_yvi01_nat_non_veg_validation'::text function_tested,
       'test class true'::text description,
       TT_yvi01_nat_non_veg_validation('NE', 'R', '') passed
---------------------------------------------------------
UNION ALL
SELECT '27.4'::text number,
       'TT_yvi01_nat_non_veg_validation'::text function_tested,
       'test class false'::text description,
       TT_yvi01_nat_non_veg_validation('NE', NULL::text, NULL::text) IS FALSE passed
---------------------------------------------------------
  -- TT_yvi01_nat_non_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '28.1'::text number,
       'TT_yvi01_nat_non_veg_translation'::text function_tested,
       'Test wrong type_lnd'::text description,
       TT_yvi01_nat_non_veg_translation('VF', '', '') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '28.2'::text number,
       'TT_yvi01_nat_non_veg_translation'::text function_tested,
       'test Alpine'::text description,
       TT_yvi01_nat_non_veg_translation('NE', '', 'A') = 'ALPINE' passed
---------------------------------------------------------
UNION ALL
SELECT '28.3'::text number,
       'TT_yvi01_nat_non_veg_translation'::text function_tested,
       'test class true'::text description,
       TT_yvi01_nat_non_veg_translation('NE', 'R', '') = 'RIVER' passed
---------------------------------------------------------
UNION ALL
SELECT '28.4'::text number,
       'TT_yvi01_nat_non_veg_translation'::text function_tested,
       'test class false'::text description,
       TT_yvi01_nat_non_veg_translation('NE', NULL::text, NULL::text) IS NULL passed
---------------------------------------------------------
  -- TT_yvi01_non_for_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '29.1'::text number,
       'TT_yvi01_non_for_veg_translation'::text function_tested,
       'Test wrong type_lnd'::text description,
       TT_yvi01_non_for_veg_translation('NU', '', '') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '29.2'::text number,
       'TT_yvi01_non_for_veg_translation'::text function_tested,
       'Test wrong class'::text description,
       TT_yvi01_non_for_veg_translation('VN', 'SS', '') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '29.3'::text number,
       'TT_yvi01_non_for_veg_translation'::text function_tested,
       'Test wrong cl_mod'::text description,
       TT_yvi01_non_for_veg_translation('VN', 'S', 'X') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '29.4'::text number,
       'TT_yvi01_non_for_veg_translation'::text function_tested,
       'Test correct cl_mod'::text description,
       TT_yvi01_non_for_veg_translation('VN', 'C', 'TS') = 'TALL_SHRUB' passed
---------------------------------------------------------
UNION ALL
SELECT '29.5'::text number,
       'TT_yvi01_non_for_veg_translation'::text function_tested,
       'Test correct class with no cl_mod match'::text description,
       TT_yvi01_non_for_veg_translation('VN', 'C', 'TSS') = 'BRYOID' passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_yvi01_nfl_soil_moisture_validation
---------------------------------------------------------
UNION ALL
SELECT '30.1'::text number,
       'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,
       'Test non_for_veg pass'::text description,
       TT_yvi01_nfl_soil_moisture_validation('VN', 'C', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '30.2'::text number,
       'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,
       'Test non_for_veg fail'::text description,
       TT_yvi01_nfl_soil_moisture_validation('VN', 'S', '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '30.3'::text number,
       'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,
       'Test non_for_veg pass 2'::text description,
       TT_yvi01_nfl_soil_moisture_validation('VN', 'S', 'TS', '') passed
---------------------------------------------------------
UNION ALL
SELECT '30.4'::text number,
       'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,
       'Test nat_non_veg fail, not EX'::text description,
       TT_yvi01_nfl_soil_moisture_validation('NW', '', '', 'A') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '30.5'::text number,
       'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,
       'Test nat_non_veg pass, is EX'::text description,
       TT_yvi01_nfl_soil_moisture_validation('NW', 'E', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '30.6'::text number,
       'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,
       'Test nat_non_veg fail, wrong type'::text description,
       TT_yvi01_nfl_soil_moisture_validation('VN', 'E', '', '') IS FALSE passed
---------------------------------------------------------
  -- TT_avi01_stand_structure_validation
---------------------------------------------------------
UNION ALL
SELECT '31.1'::text number,
       'TT_avi01_stand_structure_validation'::text function_tested,
       'Test Horizontal stand'::text description,
       TT_avi01_stand_structure_validation('H', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '31.2'::text number,
       'TT_avi01_stand_structure_validation'::text function_tested,
       'Test Horizontal stand'::text description,
       TT_avi01_stand_structure_validation('h', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '31.3'::text number,
       'TT_avi01_stand_structure_validation'::text function_tested,
       'Test not nfl'::text description,
       TT_avi01_stand_structure_validation('M', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '31.4'::text number,
       'TT_avi01_stand_structure_validation'::text function_tested,
       'Test nfl'::text description,
       TT_avi01_stand_structure_validation('M', '', 'val', '', '') IS FALSE passed
---------------------------------------------------------
  -- TT_avi01_stand_structure_translation
---------------------------------------------------------
UNION ALL
SELECT '32.1'::text number,
       'TT_avi01_stand_structure_translation'::text function_tested,
       'Test Horizontal stand'::text description,
       TT_avi01_stand_structure_translation('H', '', '', '', '', '', '') = 'HORIZONTAL' passed
---------------------------------------------------------
UNION ALL
SELECT '32.2'::text number,
       'TT_avi01_stand_structure_translation'::text function_tested,
       'Test Complex stand'::text description,
       TT_avi01_stand_structure_translation('C4', '', '', '', '', '', '') = 'COMPLEX' passed
---------------------------------------------------------
UNION ALL
SELECT '32.3'::text number,
       'TT_avi01_stand_structure_translation'::text function_tested,
       'Test S stand'::text description,
       TT_avi01_stand_structure_translation('M', 'bf', '', '', '', '', '') = 'SINGLE_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '32.4'::text number,
       'TT_avi01_stand_structure_translation'::text function_tested,
       'Test S stand'::text description,
       TT_avi01_stand_structure_translation('', '', 'bs', '', '', '', '') = 'SINGLE_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '32.5'::text number,
       'TT_avi01_stand_structure_translation'::text function_tested,
       'Test M stand'::text description,
       TT_avi01_stand_structure_translation('', 'bf', 'bs', '', 'bf', '', '') = 'MULTI_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '32.6'::text number,
       'TT_avi01_stand_structure_translation'::text function_tested,
       'Test M stand'::text description,
       TT_avi01_stand_structure_translation('S', 'bf', 'bs', 'bs', 'bf', 'bs', 'ws') = 'MULTI_LAYERED' passed
---------------------------------------------------------
 -- TT_fvi01_stand_structure_validation
---------------------------------------------------------
UNION ALL
SELECT '33.1'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test Horizontal stand'::text description,
       TT_fvi01_stand_structure_validation('H', '', '', '', '', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '33.2'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test nfl'::text description,
       TT_fvi01_stand_structure_validation('S', 'SL', '', '','', '', '', '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '33.3'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test understory nfl'::text description,
       TT_fvi01_stand_structure_validation('M', '', 'SL', '', '', '', '', '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '33.4'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test layer 1 present'::text description,
       TT_fvi01_stand_structure_validation('M', 'TC', 'SL', 'bf', '', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '33.5'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test layer 1 present but no typeclas'::text description,
       TT_fvi01_stand_structure_validation('M', '', 'SL', 'bf', '', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '33.6'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test layer 2 present'::text description,
       TT_fvi01_stand_structure_validation('M', 'SL', 'TC', '', '', '', '', 'bf', '') passed
---------------------------------------------------------
UNION ALL
SELECT '33.7'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test layer 2 present but no typeclas'::text description,
       TT_fvi01_stand_structure_validation('M', 'SL', '', '', '', '', '', 'bf', '') passed

---------------------------------------------------------
 -- TT_fvi01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '34.1'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 2 NFL'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'SL', 'ST', '4') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '34.2'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 1'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{'''',''''}', 'SL', 'TC', '4') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '34.3'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 2 LYR'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'TC', 'TM', '4') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '34.4'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 1 LYR'::text description,
       TT_fvi01_countOfNotNull('{'''',''''}', '{''val'',''val''}', '', 'TC', '4') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '34.5'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 0'::text description,
       TT_fvi01_countOfNotNull('{'''',''''}', '{'''',''''}', '', NULL::text, '4') = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '34.6'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 1 LYR 1 NFL'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{'''',''''}', 'TB', 'SL', '4') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '34.7'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 1 LYR but no values'::text description,
       TT_fvi01_countOfNotNull('{'''',''''}', '{'''',''''}', 'TB', '', '4') = 0 passed

---------------------------------------------------------
---------------------------------------------------------
 -- TT_vri01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '35.1'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 5, all 3 nfl layers present'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', 'AP', '5', 'BC10') = 5 passed
---------------------------------------------------------
UNION ALL
SELECT '35.2'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 4, 2 nfl layer present'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', '', '5', 'BC10') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '35.3'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, 1 nfl layer'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', '', '', 'OR', '', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.4'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_veg 4'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', '', 'ST', '', '', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.5'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'non_for_veg fail'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', '', '', '', '', '5', 'BC10') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '35.6'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 1'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', '', '', '', 'MU', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.7'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 2'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'LL', 'XX', 'XX', 'XX', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.8'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 3'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'I', 'XX', 'SI', 'XX', 'XX', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.9'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 4'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', 'LL', 'XX', 'ICE', '', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.10'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 5'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', NULL::text, 'RO', NULL::text, NULL::text, '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.11'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'nat_non_veg fail'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'XX', 'XX', 'XX', 'XX', '5', 'BC10') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '35.12'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_anth 1'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', '', '', '', 'AP', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.13'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_anth 2'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'AP', 'XX', 'XX', 'XX', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.14'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_anth 3'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', 'XX', 'XX', 'C', 'XX', '5', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.15'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 1'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{'''',''''}', '', 'XX', 'XX', 'C', 'XX', '5', 'BC10') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '35.16'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 0'::text description,
       TT_vri01_countOfNotNull('{'''',''''}', '{'''',''''}', '', '', '', '', '', '5', 'BC10') = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '35.17'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Test BC08 option'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{'''',''''}', 'V', '', '', '', 'AP', '5', 'BC08') = 2 passed
---------------------------------------------------------
 -- TT_sk_utm01_species_percent_validation
---------------------------------------------------------
UNION ALL
SELECT '36.1'::text number,
       'TT_sk_utm01_species_percent_validation'::text function_tested,
       'Expected code 1'::text description,
       TT_sk_utm01_species_percent_validation('WS', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '36.2'::text number,
       'TT_sk_utm01_species_percent_validation'::text function_tested,
       'Expected code 2'::text description,
       TT_sk_utm01_species_percent_validation('WS', '', '', 'GA', '') passed
---------------------------------------------------------
UNION ALL
SELECT '36.3'::text number,
       'TT_sk_utm01_species_percent_validation'::text function_tested,
       'Non-expected code 1'::text description,
       TT_sk_utm01_species_percent_validation('WS', 'GA', 'WA', 'GA', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '36.4'::text number,
       'TT_sk_utm01_species_percent_validation'::text function_tested,
       'Non-expected code 2'::text description,
       TT_sk_utm01_species_percent_validation('', '', '', '', '') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
 -- TT_sk_utm01_species_percent_translation
---------------------------------------------------------
UNION ALL
SELECT '37.1'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 1'::text description,
       TT_sk_utm01_species_percent_translation('1', 'WS','','',NULL::text,'') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '37.2'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 2, with empty strings and NULLs'::text description,
       TT_sk_utm01_species_percent_translation('2', 'WS','',NULL::text,'BF','') = 20 passed
---------------------------------------------------------
UNION ALL
SELECT '37.3'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 3'::text description,
       TT_sk_utm01_species_percent_translation('1', 'WS','WS','',NULL::text,'') = 70 passed
---------------------------------------------------------
UNION ALL
SELECT '37.4'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 4'::text description,
       TT_sk_utm01_species_percent_translation('2', 'WS','WS','',NULL::text,'') = 30 passed
---------------------------------------------------------
UNION ALL
SELECT '37.5'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 5'::text description,
       TT_sk_utm01_species_percent_translation('1', 'BS','JP','',NULL::text,'') = 60 passed
---------------------------------------------------------
UNION ALL
SELECT '37.6'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 6::text description',
       TT_sk_utm01_species_percent_translation('2', 'WS','WS','',NULL::text,'') = 30 passed
---------------------------------------------------------
UNION ALL
SELECT '37.7'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 7'::text description,
       TT_sk_utm01_species_percent_translation('2', 'GA','GA','GA','','') = 30 passed
---------------------------------------------------------
UNION ALL
SELECT '37.8'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 8'::text description,
       TT_sk_utm01_species_percent_translation('2', 'GA','GA','GA','WS','') = 25 passed
---------------------------------------------------------
UNION ALL
SELECT '37.9'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 9'::text description,
       TT_sk_utm01_species_percent_translation('1', 'WS','WS','WS','GA','GA') = 25 passed
---------------------------------------------------------
UNION ALL
SELECT '37.10'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 10'::text description,
       TT_sk_utm01_species_percent_translation('5', 'WS','WS','WS','GA','GA') = 15 passed
---------------------------------------------------------
UNION ALL
SELECT '37.11'::text number,
       'TT_sk_utm01_species_percent_translation'::text function_tested,
       'Expected percent 11'::text description,
       TT_sk_utm01_species_percent_translation('1', '','','','','') IS NULL passed
---------------------------------------------------------
---------------------------------------------------------
 -- TT_sk_utm01_species_translation
---------------------------------------------------------
UNION ALL
SELECT '38.1'::text number,
       'TT_sk_utm01_species_translation'::text function_tested,
       'Expected species'::text description,
       TT_sk_utm01_species_translation('2', 'WS','BF','','','') = 'ABIE_BALS' passed
---------------------------------------------------------
UNION ALL
SELECT '38.2'::text number,
       'TT_sk_utm01_species_translation'::text function_tested,
       'Expected species with empty strings'::text description,
       TT_sk_utm01_species_translation('2', 'WS','','','','BF') = 'ABIE_BALS' passed
---------------------------------------------------------
UNION ALL
SELECT '38.3'::text number,
       'TT_sk_utm01_species_translation'::text function_tested,
       'Expected species with empty strings and nulls'::text description,
       TT_sk_utm01_species_translation('2', 'WS','',NULL::text,'','BF') = 'ABIE_BALS' passed
---------------------------------------------------------
  -- TT_sfv01_stand_structure_translation
---------------------------------------------------------
UNION ALL
SELECT '39.1'::text number,
       'TT_sfv01_stand_structure_translation'::text function_tested,
       'Test Horizontal stand'::text description,
       TT_sfv01_stand_structure_translation('H', '', '', '') = 'HORIZONTAL' passed
---------------------------------------------------------
UNION ALL
SELECT '39.2'::text number,
       'TT_sfv01_stand_structure_translation'::text function_tested,
       'Test Complex stand'::text description,
       TT_sfv01_stand_structure_translation('c', '', '', '') = 'COMPLEX' passed
---------------------------------------------------------
UNION ALL
SELECT '39.3'::text number,
       'TT_sfv01_stand_structure_translation'::text function_tested,
       'Test S stand'::text description,
       TT_sfv01_stand_structure_translation('M', 'bf', '', '') = 'SINGLE_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '39.4'::text number,
       'TT_sfv01_stand_structure_translation'::text function_tested,
       'Test M stand'::text description,
       TT_sfv01_stand_structure_translation('', 'bf', 'bf', 'bf') = 'MULTI_LAYERED' passed
---------------------------------------------------------
  -- TT_sfv01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '40.1'::text number,
       'TT_sfv01_countOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_sfv01_countOfNotNull('bf', '', '', '', '', '', '', '', '', '6') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '40.2'::text number,
       'TT_sfv01_countOfNotNull'::text function_tested,
       'Test six layers'::text description,
       TT_sfv01_countOfNotNull('bf', 'bf', 'bf', 'bf', 'bf', 'WA', '', '', '', '6') = 6 passed
---------------------------------------------------------
UNION ALL
SELECT '40.3'::text number,
       'TT_sfv01_countOfNotNull'::text function_tested,
       'Test six layers'::text description,
       TT_sfv01_countOfNotNull('bf', 'bf', 'bf', 'bf', 'bf', 'xx', '', '', '', '6') = 5 passed
---------------------------------------------------------
  -- TT_ns_nsi01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '41.1'::text number,
       'TT_ns_nsi01_countOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_ns_nsi01_countOfNotNull('bf', '', '', '3') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '41.2'::text number,
       'TT_ns_nsi01_countOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_ns_nsi01_countOfNotNull('bf', 'bf', '89', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '41.3'::text number,
       'TT_ns_nsi01_countOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_ns_nsi01_countOfNotNull('', '', '', '3') = 0 passed
---------------------------------------------------------
-- TT_HasNFLInfo
---------------------------------------------------------
UNION ALL
SELECT '42.1'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - nat_non_veg, passes'::text description,
       TT_HasNFLInfo('BC08', '{''nat_non_veg''}', '{''V'', ''BE'', '''', '''', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.2'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - nat_non_veg, fails'::text description,
       TT_HasNFLInfo('BC08', '{''nat_non_veg''}', '{''V'', ''B'', '''', '''', ''''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '42.3'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - non_for_anth, passes. Also tests two attributes.'::text description,
       TT_HasNFLInfo('BC08', '{''nat_non_veg'', ''non_for_anth''}', '{''F'', '''', '''', ''C'', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.4'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - non_for_anth, fails. Also tests two attributes.'::text description,
       TT_HasNFLInfo('BC08', '{''nat_non_veg'', ''non_for_anth''}', '{''V'', '''', '''', ''C'', ''''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '42.5'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - non_for_veg, passes.'::text description,
       TT_HasNFLInfo('BC08', '{''non_for_veg''}', '{''I'', '''', ''ST'', '''', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.6'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - non_for_veg, passes with 2 attributes.'::text description,
       TT_HasNFLInfo('BC08', '{''non_for_veg'',''nat_non_veg''}', '{''I'', '''', ''ST'', '''', ''LL''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.7'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'BC - non_for_veg, fails.'::text description,
       TT_HasNFLInfo('BC08', '{''non_for_veg'',''nat_non_veg''}', '{'''', '''', ''ST'', '''', ''LL''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '42.8'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - non_for_veg, passes.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_veg''}', '{''Ts'', '''', '''', '''', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.9'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - non_for_veg, fails.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_veg''}', '{''T'', '''', '''', '''', ''''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '42.9'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - non_for_anth, passes.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_anth, nat_non_veg''}', '{'''', '''', '''', ''POP'', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.10'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - non_for_veg, fails.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_veg''}', '{'''', '''', '''', ''PO'', ''''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '42.11'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - nat_non_veg, passes.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_anth, nat_non_veg''}', '{'''', ''WA'', ''SF'', '''', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.12'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - nat_non_veg, passes.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_veg, nat_non_veg''}', '{'''', ''WA'', '''', '''', ''''}') passed
---------------------------------------------------------
UNION ALL
SELECT '42.13'::text number,
       'TT_HasNFLInfo'::text function_tested,
       'SK - nat_non_veg, fails.'::text description,
       TT_HasNFLInfo('SK02', '{''non_for_veg, nat_non_veg''}', '{'''', ''W'', '''', '''', ''''}') IS FALSE passed
---------------------------------------------------------
  -- TT_pe_pei01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '43.1'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test spec1'::text description,
       TT_pe_pei01_countOfNotNull('BS', '', '', '', '', '', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '43.2'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test spec2'::text description,
       TT_pe_pei01_countOfNotNull('', 'BS', '', '', '', '', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '43.3'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test spec3'::text description,
       TT_pe_pei01_countOfNotNull('', '', 'BS', '', '', '', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '43.4'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test spec4'::text description,
       TT_pe_pei01_countOfNotNull('', '', '', 'BS', '', '', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '43.5'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test spec5'::text description,
       TT_pe_pei01_countOfNotNull('', '', '', '', 'BS', '', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '43.6'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test spec1 and nfl'::text description,
       TT_pe_pei01_countOfNotNull('BS', '', '', '', '', 'SO', '2') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '43.7'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test nfl only'::text description,
       TT_pe_pei01_countOfNotNull('', '', '', '', '', 'SO', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '43.8'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_pe_pei01_countOfNotNull('', '', '', '', '', '', '2') = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '43.9'::text number,
       'TT_pe_pei01_countOfNotNull'::text function_tested,
       'Test all spec and nfl'::text description,
       TT_pe_pei01_countOfNotNull('BS', 'BS', 'BS', 'BS', 'BS', 'SO', '2') = 2 passed

---------------------------------------------------------
 -- TT_vri01_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '44.1'::text number,
       'TT_vri01_hasCountOfNotNull'::text function_tested,
       'Test exact'::text description,
       TT_vri01_hasCountOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', 'AP', 'BC10', '5', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '44.2'::text number,
       'TT_vri01_hasCountOfNotNull'::text function_tested,
       'Test exact'::text description,
       TT_vri01_hasCountOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', 'AP', 'BC10', '4', 'TRUE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '44.3'::text number,
       'TT_vri01_hasCountOfNotNull'::text function_tested,
       'Test exact false'::text description,
       TT_vri01_hasCountOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', 'AP', 'BC10', '4', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '44.4'::text number,
       'TT_vri01_hasCountOfNotNull'::text function_tested,
       'Count of 1'::text description,
       TT_vri01_hasCountOfNotNull('{''val'',''val''}', '{'''',''''}', '', 'XX', 'XX', 'C', 'XX', 'BC10', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '44.5'::text number,
       'TT_vri01_hasCountOfNotNull'::text function_tested,
       'Count of 0'::text description,
       TT_vri01_hasCountOfNotNull('{'''',''''}', '{'''',''''}', '', 'XX', 'XX', 'C', 'XX', 'BC10', '1', 'FALSE') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '44.6'::text number,
       'TT_vri01_hasCountOfNotNull'::text function_tested,
       'Test BC08 option'::text description,
       TT_vri01_hasCountOfNotNull('{''val'',''val''}', '{'''',''''}', 'V', '', '', '', 'AP', 'BC08', '1', 'FALSE') passed
---------------------------------------------------------
 -- TT_ns_nsi01_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '45.1'::text number,
       'TT_ns_nsi01_hasCountOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_ns_nsi01_hasCountOfNotNull('bf', '', '', '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '45.2'::text number,
       'TT_ns_nsi01_hasCountOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_ns_nsi01_hasCountOfNotNull('bf', 'bf', '89', '3', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '45.3'::text number,
       'TT_ns_nsi01_hasCountOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_ns_nsi01_hasCountOfNotNull('', '', '', '0', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '45.4'::text number,
       'TT_ns_nsi01_hasCountOfNotNull'::text function_tested,
       'Test two layers exact false'::text description,
       TT_ns_nsi01_hasCountOfNotNull('bf', '', '89', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '45.5'::text number,
       'TT_ns_nsi01_hasCountOfNotNull'::text function_tested,
       'Test two layers exact true'::text description,
       TT_ns_nsi01_hasCountOfNotNull('bf', '', '89', '1', 'TRUE') IS FALSE passed
---------------------------------------------------------
 -- TT_fvi01_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '46.1'::text number,
       'TT_fvi01_hasCountOfNotNull'::text function_tested,
       'Test 2 NFL layers'::text description,
       TT_fvi01_hasCountOfNotNull('bf', 'bf', 'SL', 'ST', '2', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '46.2'::text number,
       'TT_fvi01_hasCountOfNotNull'::text function_tested,
       'Test 1 NFL layers'::text description,
       TT_fvi01_hasCountOfNotNull('', 'bf', '', 'ST', '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '46.3'::text number,
       'TT_fvi01_hasCountOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_fvi01_hasCountOfNotNull('', '', '', '', '0', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '46.4'::text number,
       'TT_fvi01_hasCountOfNotNull'::text function_tested,
       'Test two LYR layers'::text description,
       TT_fvi01_hasCountOfNotNull('bf', 'bf', 'TM', 'TM', '2', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '46.5'::text number,
       'TT_fvi01_hasCountOfNotNull'::text function_tested,
       'Test two layers exact false'::text description,
       TT_fvi01_hasCountOfNotNull('bf', 'bf', 'TM', 'TM', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '46.6'::text number,
       'TT_fvi01_hasCountOfNotNull'::text function_tested,
       'Test two layers exact true'::text description,
       TT_fvi01_hasCountOfNotNull('bf', 'bf', 'TM', 'TM', '1', 'TRUE') IS FALSE passed
---------------------------------------------------------
  -- TT_on_fim02_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '47.1'::text number,
       'TT_on_fim02_countOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_on_fim02_countOfNotNull('bf', '', '', '3') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '47.2'::text number,
       'TT_on_fim02_countOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_on_fim02_countOfNotNull('bf', 'bf', 'RCK', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '47.3'::text number,
       'TT_on_fim02_countOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_on_fim02_countOfNotNull('', '', '', '3') = 0 passed
---------------------------------------------------------
 -- TT_on_fim02_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '48.1'::text number,
       'TT_on_fim02_hasCountOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_on_fim02_hasCountOfNotNull('bf', '', '', '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '48.2'::text number,
       'TT_on_fim02_hasCountOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_on_fim02_hasCountOfNotNull('bf', 'bf', 'RCK', '3', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '48.3'::text number,
       'TT_on_fim02_hasCountOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_on_fim02_hasCountOfNotNull('', '', '', '0', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '48.4'::text number,
       'TT_on_fim02_hasCountOfNotNull'::text function_tested,
       'Test two layers exact false'::text description,
       TT_on_fim02_hasCountOfNotNull('bf', '', 'RCK', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '48.5'::text number,
       'TT_on_fim02_hasCountOfNotNull'::text function_tested,
       'Test two layers exact true'::text description,
       TT_on_fim02_hasCountOfNotNull('bf', '', 'RCK', '1', 'TRUE') IS FALSE passed
---------------------------------------------------------
 -- TT_pe_pei01_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '49.1'::text number,
       'TT_pe_pei01_hasCountOfNotNull'::text function_tested,
       'Test spec and nfl'::text description,
       TT_pe_pei01_hasCountOfNotNull('BS', 'BS', 'BS', 'BS', 'BS', 'SO', '2', 'TRUE')  passed
---------------------------------------------------------
UNION ALL
SELECT '49.2'::text number,
       'TT_pe_pei01_hasCountOfNotNull'::text function_tested,
       'Test exact FALSE'::text description,
       TT_pe_pei01_hasCountOfNotNull('BS', 'BS', 'BS', 'BS', 'BS', 'SO', '1', 'FALSE')  passed  
---------------------------------------------------------
UNION ALL
SELECT '49.3'::text number,
       'TT_pe_pei01_hasCountOfNotNull'::text function_tested,
       'Test exact TRUE fail'::text description,
       TT_pe_pei01_hasCountOfNotNull('BS', 'BS', 'BS', 'BS', 'BS', 'SO', '1', 'TRUE') IS FALSE passed  
---------------------------------------------------------
 -- TT_sfv01_hasCountOfNotNull  
---------------------------------------------------------
UNION ALL
SELECT '50.1'::text number,
       'TT_sfv01_hasCountOfNotNull'::text function_tested,
       'Test six layers'::text description,
       TT_sfv01_hasCountOfNotNull('bf', 'bf', 'bf', 'bf', 'bf', 'WA', '', '', '', '6', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '50.2'::text number,
       'TT_sfv01_hasCountOfNotNull'::text function_tested,
       'Test zero layers'::text description,
       TT_sfv01_hasCountOfNotNull('', '', '', '', '', '', '', '', '', '0', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '50.3'::text number,
       'TT_sfv01_hasCountOfNotNull'::text function_tested,
       'Test two layers, exact false'::text description,
       TT_sfv01_hasCountOfNotNull('bf', '', '', '', '', 'WA', '', '', '', '1', 'FALSE') passed  
---------------------------------------------------------
UNION ALL
SELECT '50.4'::text number,
       'TT_sfv01_hasCountOfNotNull'::text function_tested,
       'Test two layers, exact true fails'::text description,
       TT_sfv01_hasCountOfNotNull('bf', '', '', '', '', 'WA', '', '', '', '1', 'TRUE') IS FALSE passed  
---------------------------------------------------------
  -- TT_sk_utm_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '51.1'::text number,
       'TT_sk_utm_countOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_sk_utm_countOfNotNull('bf', '', '', '3') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '51.2'::text number,
       'TT_sk_utm_countOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_sk_utm_countOfNotNull('bf', 'bf', '3300', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '51.3'::text number,
       'TT_sk_utm_countOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_sk_utm_countOfNotNull('', '', '', '3') = 0 passed
---------------------------------------------------------
 -- TT_sk_utm_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '52.1'::text number,
       'TT_sk_utm_hasCountOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_sk_utm_hasCountOfNotNull('bf', '', '', '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '52.2'::text number,
       'TT_sk_utm_hasCountOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_sk_utm_hasCountOfNotNull('bf', 'bf', '3300', '3', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '52.3'::text number,
       'TT_sk_utm_hasCountOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_sk_utm_hasCountOfNotNull('', '', '', '0', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '52.4'::text number,
       'TT_sk_utm_hasCountOfNotNull'::text function_tested,
       'Test two layers exact false'::text description,
       TT_sk_utm_hasCountOfNotNull('bf', '', '3300', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '52.5'::text number,
       'TT_sk_utm_hasCountOfNotNull'::text function_tested,
       'Test two layers exact true'::text description,
       TT_sk_utm_hasCountOfNotNull('bf', '', '3300', '1', 'TRUE') IS FALSE passed
---------------------------------------------------------
 -- TT_bc_height
---------------------------------------------------------
UNION ALL
SELECT '53.1'::text number,
       'TT_bc_height'::text function_tested,
       'Test with all values present'::text description,
       TT_bc_height('10', '5', '50', '50') = 7.5 passed
---------------------------------------------------------
UNION ALL
SELECT '53.2'::text number,
       'TT_bc_height'::text function_tested,
       'Test with all values present, different weights'::text description,
       TT_bc_height('4', '1', '75', '25') = 3.25 passed
---------------------------------------------------------
UNION ALL
SELECT '53.3'::text number,
       'TT_bc_height'::text function_tested,
       'Test with zero height'::text description,
       TT_bc_height('4', '0', '75', '25') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '53.4'::text number,
       'TT_bc_height'::text function_tested,
       'Test with other zero height'::text description,
       TT_bc_height('0', '1', '75', '25') = 0.25 passed
---------------------------------------------------------
UNION ALL
SELECT '53.5'::text number,
       'TT_bc_height'::text function_tested,
       'Test zero pct 1'::text description,
       TT_bc_height('4', '1', '0', '25') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '53.6'::text number,
       'TT_bc_height'::text function_tested,
       'Test zero pct 2'::text description,
       TT_bc_height('4', '1', '75', '0') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '53.7'::text number,
       'TT_bc_height'::text function_tested,
       'Both height zero'::text description,
       TT_bc_height('0', '0', '75', '25') = 0 passed
---------------------------------------------------------
UNION ALL
SELECT '53.8'::text number,
       'TT_bc_height'::text function_tested,
       'Both pct zero'::text description,
       TT_bc_height('4', '1', '0', '0') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '53.9'::text number,
       'TT_bc_height'::text function_tested,
       'All zero'::text description,
       TT_bc_height('0', '0', '0', '0') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '53.10'::text number,
       'TT_bc_height'::text function_tested,
       'Test with null height'::text description,
       TT_bc_height('4', NULL::text, '75', '25') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '53.11'::text number,
       'TT_bc_height'::text function_tested,
       'Test with other zero height'::text description,
       TT_bc_height(NULL::text, '1', '75', '25') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '53.12'::text number,
       'TT_bc_height'::text function_tested,
       'Test NULL pct 1'::text description,
       TT_bc_height('4', '1', NULL::text, '25') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '53.13'::text number,
       'TT_bc_height'::text function_tested,
       'Test NULL pct 2'::text description,
       TT_bc_height('4', '1', '75', NULL::text) = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '53.14'::text number,
       'TT_bc_height'::text function_tested,
       'Both height NULL'::text description,
       TT_bc_height(NULL::text, NULL::text, '75', '25') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '53.15'::text number,
       'TT_bc_height'::text function_tested,
       'Both pct zero'::text description,
       TT_bc_height('4', '1', NULL::text, NULL::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '53.16'::text number,
       'TT_bc_height'::text function_tested,
       'All zero'::text description,
       TT_bc_height(NULL::text, NULL::text, NULL::text, NULL::text) IS NULL passed
---------------------------------------------------------
 -- TT_fvi01_structure_per
---------------------------------------------------------
UNION ALL
SELECT '54.1'::text number,
       'TT_fvi01_structure_per'::text function_tested,
       'Test C'::text description,
       TT_fvi01_structure_per('C', '5') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '54.2'::text number,
       'TT_fvi01_structure_per'::text function_tested,
       'Test H'::text description,
       TT_fvi01_structure_per('H', '5') = 50 passed
---------------------------------------------------------
UNION ALL
SELECT '54.3'::text number,
       'TT_fvi01_structure_per'::text function_tested,
       'Test H and 0'::text description,
       TT_fvi01_structure_per('H', '0') = 100 passed
---------------------------------------------------------
 -- TT_fvi01_structure_per_validation
---------------------------------------------------------
UNION ALL
SELECT '55.1'::text number,
       'TT_fvi01_structure_per_validation'::text function_tested,
       'Test pass'::text description,
       TT_fvi01_structure_per_validation('H', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '55.2'::text number,
       'TT_fvi01_structure_per_validation'::text function_tested,
       'Test fail'::text description,
       TT_fvi01_structure_per_validation('H', '2') IS FALSE passed
---------------------------------------------------------
 -- TT_wetland_code_translation
---------------------------------------------------------
UNION ALL
SELECT '56.1'::text number,
       'TT_wetland_code_translation'::text function_tested,
       'Test char 1'::text description,
       TT_wetland_code_translation('BTNN', '1') = 'BOG' passed
---------------------------------------------------------
UNION ALL
SELECT '56.2'::text number,
       'TT_wetland_code_translation'::text function_tested,
       'Test char 2'::text description,
       TT_wetland_code_translation('BTNN', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '56.3'::text number,
       'TT_wetland_code_translation'::text function_tested,
       'Test char 3'::text description,
       TT_wetland_code_translation('BTNN', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
UNION ALL
SELECT '56.4'::text number,
       'TT_wetland_code_translation'::text function_tested,
       'Test char 4'::text description,
       TT_wetland_code_translation('BTNN', '4') = 'NO_LAWN' passed
---------------------------------------------------------
UNION ALL
SELECT '56.5'::text number,
       'TT_wetland_code_translation'::text function_tested,
       'Test dash'::text description,
       TT_wetland_code_translation('BTN-', '4') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '56.6'::text number,
       'TT_wetland_code_translation'::text function_tested,
       'Test null'::text description,
       TT_wetland_code_translation(NULL::text, '4') IS NULL passed
---------------------------------------------------------
 -- TT_qc_prg3_wetland_validation
 -- full set of tests done for TT_qc_prg3_wetland_translation which uses saem internal function
---------------------------------------------------------
UNION ALL
SELECT '57.1'::text number,
       'TT_qc_prg3_wetland_validation'::text function_tested,
       'Test all NULL'::text description,
       TT_qc_prg3_wetland_validation(NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '57.2'::text number,
       'TT_qc_prg3_wetland_validation'::text function_tested,
       'Test SONS 1'::text description,
       TT_qc_prg3_wetland_validation('DH', '', '', '0', '0', '') passed
---------------------------------------------------------
 -- TT_qc_prg5_wetland_validation
 -- full set of tests done for TT_qc_prg3_wetland_translation which uses saem internal function
---------------------------------------------------------
UNION ALL
SELECT '58.1'::text number,
       'TT_qc_prg5_wetland_validation'::text function_tested,
       'Test all NULL'::text description,
       TT_qc_prg5_wetland_validation(NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '58.2'::text number,
       'TT_qc_prg5_wetland_validation'::text function_tested,
       'Test SONS 1'::text description,
       TT_qc_prg5_wetland_validation('DH', '', '', NULL::text, NULL::text, '') passed
---------------------------------------------------------
 -- TT_row_translation_rule_nt_lyr
---------------------------------------------------------
UNION ALL
SELECT '59.1'::text number,
       'TT_row_translation_rule_nt_lyr'::text function_tested,
       'Test sp1 true'::text description,
       TT_row_translation_rule_nt_lyr('TC', 'bf', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '59.2'::text number,
       'TT_row_translation_rule_nt_lyr'::text function_tested,
       'Test sp2 true'::text description,
       TT_row_translation_rule_nt_lyr('TC', '', 'bf', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '59.3'::text number,
       'TT_row_translation_rule_nt_lyr'::text function_tested,
       'Test sp1 but not typeclas'::text description,
       TT_row_translation_rule_nt_lyr('SL', '', 'bf', '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '59.4'::text number,
       'TT_row_translation_rule_nt_lyr'::text function_tested,
       'Test typeclas but no sp'::text description,
       TT_row_translation_rule_nt_lyr('TM', '', '', '', '') IS FALSE passed
---------------------------------------------------------
 -- tt_qc_prg4_species_translation
---------------------------------------------------------
UNION ALL
SELECT '60.1'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'no_prg 4 species 1'::text description,
       TT_qc_prg4_species_translation('FXPU', '1') = 'HARD_UNKN' passed
---------------------------------------------------------
UNION ALL
SELECT '60.2'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'no_prg 4 species 2'::text description,
       TT_qc_prg4_species_translation('FXPU', '2') = 'TSUG_CANA' passed
---------------------------------------------------------
UNION ALL
SELECT '60.3'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'null gr_ess'::text description,
       TT_qc_prg4_species_translation(NULL::text, '2') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '60.4'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'no_prg 4 no species 3'::text description,
       TT_qc_prg4_species_translation('FXPU', '3') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '60.5'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'Double species and species 1 requested'::text description,
       TT_qc_prg4_species_translation('FXFX', '1') = 'HARD_UNKN' passed
---------------------------------------------------------
UNION ALL
SELECT '60.6'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'Double species and species 2 requested'::text description,
       TT_qc_prg4_species_translation('FXFX', '2') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '60.7'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'Triple species, species 1'::text description,
       TT_qc_prg4_species_translation('FXPUFX', '1') = 'HARD_UNKN' passed
---------------------------------------------------------
UNION ALL
SELECT '60.8'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'Triple species, species 2'::text description,
       TT_qc_prg4_species_translation('FXPUFX', '2') = 'TSUG_CANA' passed
---------------------------------------------------------
UNION ALL
SELECT '60.9'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'Triple species, species 3'::text description,
       TT_qc_prg4_species_translation('FXPUFX', '3') = 'HARD_UNKN' passed
---------------------------------------------------------
UNION ALL
SELECT '60.10'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       '6 char double, species 1'::text description,
       TT_qc_prg4_species_translation('FXFXPU', '1') = 'HARD_UNKN' passed
---------------------------------------------------------
UNION ALL
SELECT '60.11'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       '6 char double, species 2'::text description,
       TT_qc_prg4_species_translation('FXFXPU', '2') = 'TSUG_CANA' passed
---------------------------------------------------------
UNION ALL
SELECT '60.12'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       '6 char double, species 3'::text description,
       TT_qc_prg4_species_translation('FXFXPU', '3') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '60.13'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'test single species'::text description,
       TT_qc_prg4_species_translation('PU', '1') = 'TSUG_CANA' passed
---------------------------------------------------------
UNION ALL
SELECT '60.14'::text number,
       'TT_qc_prg4_species_translation'::text function_tested,
       'test single species'::text description,
       TT_qc_prg4_species_translation('PU', '2') IS NULL passed
---------------------------------------------------------
 -- tt_qc_prg5_species_translation
---------------------------------------------------------
UNION ALL
SELECT '61.1'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_translation('BP20EO30PE10EN10SB30', '1') = 'ACER_RUBR' passed
---------------------------------------------------------
UNION ALL
SELECT '61.2'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv species 2'::text description,
       TT_qc_prg5_species_translation('BP20EO30PE10EN10SB30', '2') = 'ABIE_BALS' passed
---------------------------------------------------------
UNION ALL
SELECT '61.3'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv species 3'::text description,
       TT_qc_prg5_species_translation('BP20EO30PE10EN10SB30', '3') = 'BETU_PAPY' passed
---------------------------------------------------------
UNION ALL
SELECT '61.4'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv species 4'::text description,
       TT_qc_prg5_species_translation('BP20EO30PE10EN10SB30', '4') = 'POPU_SUBS' passed
---------------------------------------------------------
UNION ALL
SELECT '61.5'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv species 5'::text description,
       TT_qc_prg5_species_translation('BP20EO30PE10EN10SB30', '5') = 'PICE_MARI' passed
---------------------------------------------------------
UNION ALL
SELECT '61.6'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv species too high'::text description,
       TT_qc_prg5_species_translation('BP20EO30PE10EN10SB30', '20') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '61.7'::text number,
       'TT_qc_prg5_species_translation'::text function_tested,
       '5th inv null'::text description,
       TT_qc_prg5_species_translation('', '1') IS NULL passed
---------------------------------------------------------
 -- TT_qc_prg4_species_per_translation
---------------------------------------------------------
UNION ALL
SELECT '62.1'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'no_prg 4 species 1'::text description,
       TT_qc_prg4_species_per_translation('FXPU', '1') = 65 passed
---------------------------------------------------------
UNION ALL
SELECT '62.2'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'no_prg 4 species 2'::text description,
       TT_qc_prg4_species_per_translation('FXPU', '2') = 35 passed
---------------------------------------------------------
UNION ALL
SELECT '62.3'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'null gr_ess'::text description,
       TT_qc_prg4_species_per_translation(NULL::text, '2') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '62.4'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'no_prg 4 no species 3'::text description,
       TT_qc_prg4_species_per_translation('FXPU', '3') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '62.5'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Double species and species 1 requested'::text description,
       TT_qc_prg4_species_per_translation('FXFX', '1') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '62.6'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Double species and species 2 requested'::text description,
       TT_qc_prg4_species_per_translation('FXFX', '2') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '62.7'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Three species and species 1 requested'::text description,
       TT_qc_prg4_species_per_translation('FXPUFX', '1') = 37 passed
---------------------------------------------------------
UNION ALL
SELECT '62.8'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Three species and species 2 requested'::text description,
       TT_qc_prg4_species_per_translation('FXPUFX', '2') = 33 passed
---------------------------------------------------------
UNION ALL
SELECT '62.9'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Three species and species 3 requested'::text description,
       TT_qc_prg4_species_per_translation('FXPUFX', '3') = 30 passed
---------------------------------------------------------
UNION ALL
SELECT '62.10'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Three species, with double and species 1 requested'::text description,
       TT_qc_prg4_species_per_translation('FXFXPU', '1') = 65 passed
---------------------------------------------------------
UNION ALL
SELECT '62.11'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Three species, with double and species 2 requested'::text description,
       TT_qc_prg4_species_per_translation('FXFXPU', '2') = 35 passed
---------------------------------------------------------
UNION ALL
SELECT '62.12'::text number,
       'TT_qc_prg4_species_per_translation'::text function_tested,
       'Three species, with double and species 3 requested'::text description,
       TT_qc_prg4_species_per_translation('FXFXPU', '3') IS NULL passed
---------------------------------------------------------
 -- tt_qc_prg5_species_per_translation
---------------------------------------------------------
UNION ALL
SELECT '63.1'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_per_translation('BP20EO30PE10EN10SB30', '1') = 30 passed
---------------------------------------------------------
UNION ALL
SELECT '63.2'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_per_translation('BP20EO30PE10EN10SB30', '2') = 30 passed
---------------------------------------------------------
UNION ALL
SELECT '63.3'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_per_translation('BP20EO30PE10EN10SB30', '3') = 20 passed
---------------------------------------------------------
UNION ALL
SELECT '63.4'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_per_translation('BP20EO30PE10EN10SB30', '4') = 10 passed
---------------------------------------------------------
UNION ALL
SELECT '63.5'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_per_translation('BP20EO30PE10EN10SB30', '5') = 10 passed
---------------------------------------------------------
UNION ALL
SELECT '63.6'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv species too high'::text description,
       TT_qc_prg5_species_per_translation('BP20EO30PE10EN10SB30', '6') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '63.7'::text number,
       'TT_qc_prg5_species_per_translation'::text function_tested,
       '5th inv null'::text description,
       TT_qc_prg5_species_per_translation('', '1') IS NULL passed
---------------------------------------------------------
 -- TT_qc_prg4_not_double_species_validation
---------------------------------------------------------
UNION ALL
SELECT '64.1'::text number,
       'TT_qc_prg4_not_double_species_validation'::text function_tested,
       'Species is doubled'::text description,
       TT_qc_prg4_not_double_species_validation('FXFX') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '64.2'::text number,
       'TT_qc_prg4_not_double_species_validation'::text function_tested,
       'Species is not doubled'::text description,
       TT_qc_prg4_not_double_species_validation('FXFx') passed
---------------------------------------------------------
UNION ALL
SELECT '64.3'::text number,
       'TT_qc_prg4_not_double_species_validation'::text function_tested,
       'Species is null'::text description,
       TT_qc_prg4_not_double_species_validation(NULL::text) passed
---------------------------------------------------------
UNION ALL
SELECT '64.4'::text number,
       'TT_qc_prg4_not_double_species_validation'::text function_tested,
       'Species is empty'::text description,
       TT_qc_prg4_not_double_species_validation('') passed
---------------------------------------------------------
 -- tt_qc_prg5_species_matchTable_validation
---------------------------------------------------------
UNION ALL
SELECT '65.1'::text number,
       'TT_qc_prg5_species_matchTable_validation'::text function_tested,
       '5th inv species 1'::text description,
       TT_qc_prg5_species_matchTable_validation('BP20EO30PE10EN10SB30', '1')  passed
---------------------------------------------------------
UNION ALL
SELECT '65.2'::text number,
       'TT_qc_prg5_species_matchTable_validation'::text function_tested,
       '5th inv species fail'::text description,
       TT_qc_prg5_species_matchTable_validation('ZZ100', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '65.3'::text number,
       'TT_qc_prg5_species_matchTable_validation'::text function_tested,
       '5th inv species empty string'::text description,
       TT_qc_prg5_species_matchTable_validation('', '1') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '65.4'::text number,
       'TT_qc_prg5_species_matchTable_validation'::text function_tested,
       '5th inv species empty string'::text description,
       TT_qc_prg5_species_matchTable_validation(NULL::text, '1') IS FALSE passed
---------------------------------------------------------
  -- TT_mb_fri_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '66.1'::text number,
       'TT_mb_fri_countOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_mb_fri_countOfNotNull('bf', '', '2') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '66.2'::text number,
       'TT_mb_fri_countOfNotNull'::text function_tested,
       'Test 2 layers'::text description,
       TT_mb_fri_countOfNotNull('bf', '801', '2') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '66.3'::text number,
       'TT_mb_fri_countOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_mb_fri_countOfNotNull('', '', '2') = 0 passed
---------------------------------------------------------
 -- TT_mb_fri_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '67.1'::text number,
       'TT_mb_fri_hasCountOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_mb_fri_hasCountOfNotNull('bf', '', '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '67.2'::text number,
       'TT_mb_fri_hasCountOfNotNull'::text function_tested,
       'Test 2 layers'::text description,
       TT_mb_fri_hasCountOfNotNull('bf', '801', '2', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '67.3'::text number,
       'TT_mb_fri_hasCountOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_mb_fri_hasCountOfNotNull('', '', '0', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '67.4'::text number,
       'TT_mb_fri_hasCountOfNotNull'::text function_tested,
       'Test two layers exact false'::text description,
       TT_mb_fri_hasCountOfNotNull('bf', '801', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '67.5'::text number,
       'TT_mb_fri_hasCountOfNotNull'::text function_tested,
       'Test two layers exact true'::text description,
       TT_mb_fri_hasCountOfNotNull('bf', '801', '1', 'TRUE') IS FALSE passed  
---------------------------------------------------------
  -- TT_mb_fli01_stand_structure_translation
---------------------------------------------------------
UNION ALL
SELECT '68.1'::text number,
       'TT_mb_fli01_stand_structure_translation'::text function_tested,
       'Test Complex stand'::text description,
       TT_mb_fli01_stand_structure_translation('C', '', '', '','', '', '','', '', '','', '', '','', '', '') = 'COMPLEX' passed
---------------------------------------------------------
UNION ALL
SELECT '68.2'::text number,
       'TT_mb_fli01_stand_structure_translation'::text function_tested,
       'Test S stand'::text description,
       TT_mb_fli01_stand_structure_translation('', 'bf', '', '', '', '', '','', '', '','', '', '','', '', '') = 'SINGLE_LAYERED' passed
---------------------------------------------------------
UNION ALL
SELECT '68.3'::text number,
       'TT_mb_fli01_stand_structure_translation'::text function_tested,
       'Test M stand'::text description,
       TT_mb_fli01_stand_structure_translation('', 'bf', '', '', 'bf', '', '', 'bf', '', '', 'bf', '', '', 'bf', '', '') = 'MULTI_LAYERED' passed
---------------------------------------------------------
  -- TT_nl_nli01_isCommercial
---------------------------------------------------------
UNION ALL
SELECT '69.1'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial 1'::text description,
       TT_nl_nli01_isCommercial('1', '') passed
---------------------------------------------------------
UNION ALL
SELECT '69.2'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial 2'::text description,
       TT_nl_nli01_isCommercial('7000', '') passed
---------------------------------------------------------
UNION ALL
SELECT '69.3'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial fail 1'::text description,
       TT_nl_nli01_isCommercial('900', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '69.4'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial fail 2'::text description,
       TT_nl_nli01_isCommercial('7000', 'CS') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '69.5'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial fail 2'::text description,
       TT_nl_nli01_isCommercial(NULL::text, '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '69.6'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial fail 2'::text description,
       TT_nl_nli01_isCommercial('', 'CS') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '69.7'::text number,
       'TT_nl_nli01_isCommercial'::text function_tested,
       'Test commercial fail 2'::text description,
       TT_nl_nli01_isCommercial('', 'XX') IS FALSE passed
---------------------------------------------------------
  -- TT_nl_nli01_isNonCommercial
---------------------------------------------------------
UNION ALL
SELECT '70.1'::text number,
       'TT_nl_nli01_isNonCommercial'::text function_tested,
       'Test non commercial 1'::text description,
       TT_nl_nli01_isNonCommercial('900', '') passed
  ---------------------------------------------------------
UNION ALL
SELECT '70.2'::text number,
       'TT_nl_nli01_isNonCommercial'::text function_tested,
       'Test non commercial fail'::text description,
       TT_nl_nli01_isNonCommercial('901', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '70.3'::text number,
       'TT_nl_nli01_isNonCommercial'::text function_tested,
       'Test non commercial 2'::text description,
       TT_nl_nli01_isNonCommercial('', 'CS') passed
---------------------------------------------------------
UNION ALL
SELECT '70.4'::text number,
       'TT_nl_nli01_isNonCommercial'::text function_tested,
       'Test non commercial fail 2'::text description,
       TT_nl_nli01_isNonCommercial('', 'XX') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '70.5'::text number,
       'TT_nl_nli01_isNonCommercial'::text function_tested,
       'Test non commercial 1'::text description,
       TT_nl_nli01_isNonCommercial('900', 'DS') passed
---------------------------------------------------------
UNION ALL
SELECT '70.6'::text number,
       'TT_nl_nli01_isNonCommercial'::text function_tested,
       'Test non commercial 1'::text description,
       TT_nl_nli01_isNonCommercial('901', 'DS') passed
---------------------------------------------------------
  -- TT_nl_nli01_crown_closure_upper_translation
---------------------------------------------------------
UNION ALL
SELECT '71.1'::text number,
       'TT_nl_nli01_crown_closure_upper_translation'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_crown_closure_upper_translation('100', '', '1') = 50 passed
---------------------------------------------------------
UNION ALL
SELECT '71.2'::text number,
       'TT_nl_nli01_crown_closure_upper_translation'::text function_tested,
       'Test non-commercial'::text description,
       TT_nl_nli01_crown_closure_upper_translation('100', 'CS', '1') = 25 passed
---------------------------------------------------------
UNION ALL
SELECT '71.3'::text number,
       'TT_nl_nli01_crown_closure_upper_translation'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_crown_closure_upper_translation('0', 'XX', '1') IS NULL passed
---------------------------------------------------------
  -- TT_nl_nli01_crown_closure_lower_translation
---------------------------------------------------------
UNION ALL
SELECT '72.1'::text number,
       'TT_nl_nli01_crown_closure_lower_translation'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_crown_closure_lower_translation('100', '', '1') = 26 passed
---------------------------------------------------------
UNION ALL
SELECT '72.2'::text number,
       'TT_nl_nli01_crown_closure_lower_translation'::text function_tested,
       'Test non-commercial'::text description,
       TT_nl_nli01_crown_closure_lower_translation('100', 'CS', '1') = 10 passed
---------------------------------------------------------
UNION ALL
SELECT '72.3'::text number,
       'TT_nl_nli01_crown_closure_lower_translation'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_crown_closure_lower_translation('0', 'XX', '1') IS NULL passed
---------------------------------------------------------
  -- TT_nl_nli01_height_upper_translation
---------------------------------------------------------
UNION ALL
SELECT '73.1'::text number,
       'TT_nl_nli01_height_upper_translation'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_height_upper_translation('100', '', '5') = 15.5 passed
---------------------------------------------------------
UNION ALL
SELECT '73.2'::text number,
       'TT_nl_nli01_height_upper_translation'::text function_tested,
       'Test non commercial'::text description,
       TT_nl_nli01_height_upper_translation('100', '', '6') = 18.5 passed
---------------------------------------------------------
UNION ALL
SELECT '73.3'::text number,
       'TT_nl_nli01_height_upper_translation'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_height_upper_translation('0', 'XX', '1') IS NULL passed
---------------------------------------------------------
  -- TT_nl_nli01_height_lower_translation
---------------------------------------------------------
UNION ALL
SELECT '74.1'::text number,
       'TT_nl_nli01_height_lower_translation'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_height_lower_translation('100', '', '5') = 12.6 passed
---------------------------------------------------------
UNION ALL
SELECT '74.2'::text number,
       'TT_nl_nli01_height_lower_translation'::text function_tested,
       'Test non commercial'::text description,
       TT_nl_nli01_height_lower_translation('100', '', '6') = 15.6 passed
---------------------------------------------------------
UNION ALL
SELECT '74.3'::text number,
       'TT_nl_nli01_height_lower_translation'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_height_lower_translation('0', 'XX', '1') IS NULL passed
---------------------------------------------------------
  -- TT_nl_nli01_isForest
---------------------------------------------------------
UNION ALL
SELECT '75.1'::text number,
       'TT_nl_nli01_isForest'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_isForest('100', '') passed
---------------------------------------------------------
UNION ALL
SELECT '75.2'::text number,
       'TT_nl_nli01_isForest'::text function_tested,
       'Test non commercial'::text description,
       TT_nl_nli01_isForest('100', 'DS') passed
---------------------------------------------------------
UNION ALL
SELECT '75.3'::text number,
       'TT_nl_nli01_isForest'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_isForest('0', 'XX') IS FALSE passed
---------------------------------------------------------
  -- TT_nl_nli01_productivity_translation
---------------------------------------------------------
UNION ALL
SELECT '76.1'::text number,
       'TT_nl_nli01_productivity_translation'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_productivity_translation('100', '') = 'PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '76.2'::text number,
       'TT_nl_nli01_productivity_translation'::text function_tested,
       'Test non-commercial'::text description,
       TT_nl_nli01_productivity_translation('100', 'DS') = 'NON_PRODUCTIVE_FOREST' passed
---------------------------------------------------------
UNION ALL
SELECT '76.3'::text number,
       'TT_nl_nli01_productivity_translation'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_productivity_translation('0', 'XX') IS NULL passed
---------------------------------------------------------
  -- TT_nl_nli01_productivity_type_translation
---------------------------------------------------------
UNION ALL
SELECT '77.1'::text number,
       'TT_nl_nli01_productivity_type_translation'::text function_tested,
       'Test commercial'::text description,
       TT_nl_nli01_productivity_type_translation('100', '') = 'HARVESTABLE' passed
---------------------------------------------------------
UNION ALL
SELECT '77.2'::text number,
       'TT_nl_nli01_productivity_type_translation'::text function_tested,
       'Test non-commercial'::text description,
       TT_nl_nli01_productivity_type_translation('100', 'DS') = 'SCRUB_SHRUB' passed
---------------------------------------------------------
UNION ALL
SELECT '77.3'::text number,
       'TT_nl_nli01_productivity_type_translation'::text function_tested,
       'Test treed muskeg'::text description,
       TT_nl_nli01_productivity_type_translation('930', 'DS') = 'TREED_MUSKEG' passed
---------------------------------------------------------
UNION ALL
SELECT '77.4'::text number,
       'TT_nl_nli01_productivity_type_translation'::text function_tested,
       'Test neither'::text description,
       TT_nl_nli01_productivity_type_translation('0', 'XX') IS NULL passed
---------------------------------------------------------
  -- TT_qc_prg4_lengthMatchList
---------------------------------------------------------
UNION ALL
SELECT '78.1'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'test species 1, 2 characters'::text description,
       TT_qc_prg4_lengthMatchList('FX', '{''2'',''4'',''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.2'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'test species 1, 4 characters'::text description,
       TT_qc_prg4_lengthMatchList('FXPU', '{''2'',''4'',''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.3'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 1, 6 characters'::text description,
       TT_qc_prg4_lengthMatchList('FXPUFX', '{''2'', ''4'', ''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.4'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 1, 6 characters double'::text description,
       TT_qc_prg4_lengthMatchList('FXFXPU', '{''2'', ''4'', ''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.5'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'test species 1 null'::text description,
       TT_qc_prg4_lengthMatchList(NULL::text, '{''2'',''4'',''6''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '78.6'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'test species 2, 2 characters'::text description,
       TT_qc_prg4_lengthMatchList('FX', '{''4'',''6''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '78.7'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'test species 2, 4 characters'::text description,
       TT_qc_prg4_lengthMatchList('FXPU', '{''4'',''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.8'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 2, 6 characters'::text description,
       TT_qc_prg4_lengthMatchList('FXPUFX', '{''4'', ''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.9'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 2, 6 characters double'::text description,
       TT_qc_prg4_lengthMatchList('FXFXPU', '{''4'', ''6''}') passed
---------------------------------------------------------
UNION ALL
SELECT '78.10'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 2, 4 characters double'::text description,
       TT_qc_prg4_lengthMatchList('FXFX', '{''4'', ''6''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '78.11'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 3, 4 characters'::text description,
       TT_qc_prg4_lengthMatchList('FXPU', '{''6''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '78.12'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 3, 6 characters double'::text description,
       TT_qc_prg4_lengthMatchList('FXFXPU', '{''6''}') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '78.13'::text number,
       'TT_qc_prg4_lengthMatchList'::text function_tested,
       'Test species 3, 6 characters'::text description,
       TT_qc_prg4_lengthMatchList('FXPUFX', '{''6''}') passed

---------------------------------------------------------
  -- TT_nl_nli01_origin_upper_translation
---------------------------------------------------------
UNION ALL
SELECT '79.1'::text number,
       'TT_nl_nli01_origin_upper_translation'::text function_tested,
       'Test age class 1 Newfoundland'::text description,
       TT_nl_nli01_origin_upper_translation('1', 'mu001', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) = 1995 passed
---------------------------------------------------------
UNION ALL
SELECT '79.2'::text number,
       'TT_nl_nli01_origin_upper_translation'::text function_tested,
       'Test age class 2 Newfoundland'::text description,
       TT_nl_nli01_origin_upper_translation('2', 'mu001', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) = 1974 passed
---------------------------------------------------------
UNION ALL
SELECT '79.3'::text number,
       'TT_nl_nli01_origin_upper_translation'::text function_tested,
       'Test age class 9 Labrador'::text description,
       TT_nl_nli01_origin_upper_translation('9', 'mu300', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) = 1834 passed
---------------------------------------------------------
UNION ALL
SELECT '79.4'::text number,
       'TT_nl_nli01_origin_upper_translation'::text function_tested,
       'Test age class 9 Newfoundland, null'::text description,
       TT_nl_nli01_origin_upper_translation('9', 'mu001', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) IS NULL passed
---------------------------------------------------------
  -- TT_nl_nli01_origin_lower_translation
---------------------------------------------------------
UNION ALL
SELECT '80.1'::text number,
       'TT_nl_nli01_origin_lower_translation'::text function_tested,
       'Test age class 1 Newfoundland'::text description,
       TT_nl_nli01_origin_lower_translation('1', 'mu001', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) = 1975 passed
---------------------------------------------------------
UNION ALL
SELECT '80.2'::text number,
       'TT_nl_nli01_origin_lower_translation'::text function_tested,
       'Test age class 2 Newfoundland'::text description,
       TT_nl_nli01_origin_lower_translation('2', 'mu001', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) = 1955 passed
---------------------------------------------------------
UNION ALL
SELECT '80.3'::text number,
       'TT_nl_nli01_origin_lower_translation'::text function_tested,
       'Test age class 9 Labrador'::text description,
       TT_nl_nli01_origin_lower_translation('9', 'mu300', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '80.4'::text number,
       'TT_nl_nli01_origin_lower_translation'::text function_tested,
       'Test age class 8 Labrador, null'::text description,
       TT_nl_nli01_origin_lower_translation('8', 'mu300', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) = 1835 passed
---------------------------------------------------------
UNION ALL
SELECT '80.5'::text number,
       'TT_nl_nli01_origin_lower_translation'::text function_tested,
       'Test age class 8 Newfoundland, null'::text description,
       TT_nl_nli01_origin_lower_translation('8', 'mu001', ST_Multi(ST_MakePolygon(ST_SetSRID(ST_GeomFromText('LINESTRING(2632203 2088435,2628245 2094183,2635341 2099086,2639309 2093346,2632203 2088435)'), 900914)))::text) IS NULL passed
---------------------------------------------------------
  -- tt_nl_nli01_origin_lower_validation
---------------------------------------------------------
UNION ALL
SELECT '81.1'::text number,
       'TT_nl_nli01_origin_lower_validation'::text function_tested,
       'Test age class 6 Newfoundland, should pass'::text description,
       TT_nl_nli01_origin_lower_validation('6', 'mu001') passed
---------------------------------------------------------
UNION ALL
SELECT '81.2'::text number,
       'TT_nl_nli01_origin_lower_validation'::text function_tested,
       'Test age class 7 Newfoundland, should fail'::text description,
       TT_nl_nli01_origin_lower_validation('7', 'mu001') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '81.3'::text number,
       'TT_nl_nli01_origin_lower_validation'::text function_tested,
       'Test age class 8 Labrador, should pass'::text description,
       TT_nl_nli01_origin_lower_validation('8', 'mu300') passed
---------------------------------------------------------
UNION ALL
SELECT '81.4'::text number,
       'TT_nl_nli01_origin_lower_validation'::text function_tested,
       'Test age class 9 Labrador, should pass'::text description,
       TT_nl_nli01_origin_lower_validation('9', 'mu300') IS FALSE passed
---------------------------------------------------------
-- TT_qc_origin_translation
---------------------------------------------------------
UNION ALL
SELECT '82.1'::text number,
       'TT_qc_origin_translation'::text function_tested,
       'Simple test'::text description,
       TT_qc_origin_translation('JIR', '2000') = 1950 passed
---------------------------------------------------------
UNION ALL
SELECT '82.2'::text number,
       'TT_qc_origin_translation'::text function_tested,
       'Simple test 2'::text description,
       TT_qc_origin_translation('120', '2000') = 1880 passed
---------------------------------------------------------
UNION ALL
SELECT '82.3'::text number,
       'TT_qc_origin_translation'::text function_tested,
       'Fail'::text description,
       TT_qc_origin_translation('120xx', '2000') IS NULL passed
---------------------------------------------------------
-- TT_nl_nli01_origin_newfoundland_validation
---------------------------------------------------------
UNION ALL
SELECT '83.1'::text number,
       'TT_nl_nli01_origin_newfoundland_validation'::text function_tested,
       'Pass'::text description,
       TT_nl_nli01_origin_newfoundland_validation('7', 'mu001') passed
---------------------------------------------------------
UNION ALL
SELECT '83.2'::text number,
       'TT_nl_nli01_origin_newfoundland_validation'::text function_tested,
       'Fail'::text description,
       TT_nl_nli01_origin_newfoundland_validation('8', 'mu001') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '83.3'::text number,
       'TT_nl_nli01_origin_newfoundland_validation'::text function_tested,
       'Pass Labrador'::text description,
       TT_nl_nli01_origin_newfoundland_validation('8', 'mu300') passed
---------------------------------------------------------
-- TT_nl_nli01_crown_closure_validation
---------------------------------------------------------
UNION ALL
SELECT '84.1'::text number,
       'TT_nl_nli01_crown_closure_validation'::text function_tested,
       'Fail'::text description,
       TT_nl_nli01_crown_closure_validation('1', '', '4') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '84.2'::text number,
       'TT_nl_nli01_crown_closure_validation'::text function_tested,
       'Pass'::text description,
       TT_nl_nli01_crown_closure_validation('1', 'CS', '4') passed
---------------------------------------------------------
-- TT_nl_nli01_height_validation
---------------------------------------------------------
UNION ALL
SELECT '85.1'::text number,
       'TT_nl_nli01_height_validation'::text function_tested,
       'Fail'::text description,
       TT_nl_nli01_height_validation('6', '1', 'CS') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '85.2'::text number,
       'TT_nl_nli01_height_validation'::text function_tested,
       'Pass'::text description,
       TT_nl_nli01_height_validation('6', '1', '') passed
---------------------------------------------------------
 -- TT_qc_prg3_wetland_translation
---------------------------------------------------------
UNION ALL
SELECT '86.1'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test all empty'::text description,
       TT_qc_prg3_wetland_translation('', '', '', NULL::text, NULL::text, '', '') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '86.2'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test all NULL'::text description,
       TT_qc_prg3_wetland_translation(NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '86.3'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test SONS 1'::text description,
       TT_qc_prg3_wetland_translation('DH', '', '', NULL::text, NULL::text, '', '1') = 'SWAMP' passed
---------------------------------------------------------
UNION ALL
SELECT '86.4'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test SONS 2'::text description,
       TT_qc_prg3_wetland_translation('AL', '50', '', NULL::text, NULL::text, '', '2') = 'OPEN_NON_TREED_FRESHWATER' passed
---------------------------------------------------------
UNION ALL
SELECT '86.5'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test BTNN 1'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'EE', 'D', '4', '', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
UNION ALL
SELECT '86.6'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test FTNN 1'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'EME', 'D', '7', '', '4') = 'NO_LAWN' passed
---------------------------------------------------------
UNION ALL
SELECT '86.7'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test FTNN 2'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'MEME', NULL::text, '7', '', '1') = 'FEN' passed
---------------------------------------------------------
UNION ALL
SELECT '86.8'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test FTNN 3'::text description,
       TT_qc_prg3_wetland_translation('', '', '', NULL::text, NULL::text, 'RE38', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '86.9'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test FONS 1'::text description,
       TT_qc_prg3_wetland_translation('', '', '', NULL::text, NULL::text, 'TOF8A', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
UNION ALL
SELECT '86.9'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test BONS 1'::text description,
       TT_qc_prg3_wetland_translation('', '', '', NULL::text, NULL::text, 'TO18', '4') = 'SHRUB_COVER' passed
---------------------------------------------------------
UNION ALL
SELECT '86.10'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test STNN 1'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'CC', NULL::text, NULL::text, '', '1') = 'SWAMP' passed
---------------------------------------------------------
UNION ALL
SELECT '86.11'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test STNN 2'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'EC', 'C', '3', '', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '86.12'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test STNN 3'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'EE', 'C', NULL::text, '', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '86.13'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test STNN 4'::text description,
       TT_qc_prg3_wetland_translation('', '50', 'BJ', NULL::text, NULL::text, '', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
UNION ALL
SELECT '86.14'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test STNN 4'::text description,
       TT_qc_prg3_wetland_translation('', '50', '', NULL::text, NULL::text, 'FE10', '4') = 'NO_LAWN' passed
---------------------------------------------------------
UNION ALL
SELECT '86.15'::text number,
       'TT_qc_prg3_wetland_translation'::text function_tested,
       'Test STNN 6'::text description,
       TT_qc_prg3_wetland_translation('', '', '', NULL::text, NULL::text, 'FO18', '2') = 'WOODED' passed
---------------------------------------------------------
 -- TT_qc_prg5_wetland_translation
---------------------------------------------------------
UNION ALL
SELECT '87.1'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test BTNN 1'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'EPEP', 'D', '4', '', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
UNION ALL
SELECT '87.2'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test FTNN 1'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'EPML', 'D', NULL::text, '', '4') = 'NO_LAWN' passed
---------------------------------------------------------
UNION ALL
SELECT '87.3'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test FTNN 2'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'ML', NULL::text, '4', '', '1') = 'FEN' passed
---------------------------------------------------------
UNION ALL
SELECT '87.4'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test STNN 1'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'PUTO', '0', NULL::text, NULL::text, '1') = 'SWAMP' passed
---------------------------------------------------------
UNION ALL
SELECT '87.5'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test STNN 2'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'EPTO', 'C', '3', '', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '87.6'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test STNN 3'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'ML', 'C', NULL::text, '', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '87.7'::text number,
       'TT_qc_prg5_wetland_translation'::text function_tested,
       'Test STNN 4'::text description,
       TT_qc_prg5_wetland_translation('', '50', 'BJ', NULL::text, NULL::text, '', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
 -- TT_qc_prg4_wetland_translation
---------------------------------------------------------
UNION ALL
SELECT '88.1'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test BTNN 1'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'EPEP', 'D', '4', '', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
UNION ALL
SELECT '88.2'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test FTNN 1'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'EPML', 'D', NULL::text, '', '4') = 'NO_LAWN' passed
---------------------------------------------------------
UNION ALL
SELECT '88.3'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test FTNN 2'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'ML', NULL::text, '4', '', '1') = 'FEN' passed
---------------------------------------------------------
UNION ALL
SELECT '88.4'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test STNN 1'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'PUTO', NULL::text, NULL::text, '', '1') = 'SWAMP' passed
---------------------------------------------------------
UNION ALL
SELECT '88.5'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test STNN 2'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'EPTO', 'C', '3', '', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '88.6'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test STNN 3'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'ML', 'C', NULL::text, '', '2') = 'WOODED' passed
---------------------------------------------------------
UNION ALL
SELECT '88.7'::text number,
       'TT_qc_prg4_wetland_translation'::text function_tested,
       'Test STNN 4'::text description,
       TT_qc_prg4_wetland_translation('', '50', 'BJ', NULL::text, NULL::text, '', '3') = 'NO_PERMAFROST_PATTERNING' passed
---------------------------------------------------------
 -- TT_qc_prg4_wetland_validation
 -- full set of tests done for TT_qc_prg3_wetland_translation which uses saem internal function
---------------------------------------------------------
UNION ALL
SELECT '89.1'::text number,
       'TT_qc_prg4_wetland_validation'::text function_tested,
       'Test all NULL'::text description,
       TT_qc_prg4_wetland_validation(NULL::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '89.2'::text number,
       'TT_qc_prg4_wetland_validation'::text function_tested,
       'Test SONS 1'::text description,
       TT_qc_prg4_wetland_validation('DH', '', '', NULL::text, NULL::text, '') passed
---------------------------------------------------------
 -- TT_qc_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '90.1'::text number,
       'TT_qc_countOfNotNull'::text function_tested,
       'Count 1 lyr'::text description,
       TT_qc_countOfNotNull('JIR', '', '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '90.2'::text number,
       'TT_qc_countOfNotNull'::text function_tested,
       'Count 2 lyr'::text description,
       TT_qc_countOfNotNull('1010', '', '2') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '90.3'::text number,
       'TT_qc_countOfNotNull'::text function_tested,
       'Count 3 lyr'::text description,
       TT_qc_countOfNotNull('1010', 'AL', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '90.4'::text number,
       'TT_qc_countOfNotNull'::text function_tested,
       'Count 1 lyr, 1 nfl'::text description,
       TT_qc_countOfNotNull('JIR', 'AL', '3') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '90.5'::text number,
       'TT_qc_countOfNotNull'::text function_tested,
       'Test null'::text description,
       TT_qc_countOfNotNull(NULL::text, NULL::text, '3') = 0 passed
---------------------------------------------------------
 -- TT_qc_hasCountOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '91.1'::text number,
       'TT_qc_hasCountOfNotNull'::text function_tested,
       'Count 1 lyr'::text description,
       TT_qc_hasCountOfNotNull('JIR', '', '1', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '91.2'::text number,
       'TT_qc_hasCountOfNotNull'::text function_tested,
       'Count 2 lyr'::text description,
       TT_qc_hasCountOfNotNull('JIR', 'AL', '2', 'TRUE') passed
---------------------------------------------------------
UNION ALL
SELECT '91.3'::text number,
       'TT_qc_hasCountOfNotNull'::text function_tested,
       'Count 2 not exact'::text description,
       TT_qc_hasCountOfNotNull('JIR', 'AL', '1', 'FALSE') passed
---------------------------------------------------------
UNION ALL
SELECT '91.4'::text number,
       'TT_qc_hasCountOfNotNull'::text function_tested,
       'Test fail'::text description,
       TT_qc_hasCountOfNotNull('JIR', 'AL', '1', 'TRUE') IS FALSE passed
---------------------------------------------------------
 -- TT_lyr_layer_translation
---------------------------------------------------------
UNION ALL
SELECT '92.1'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 5 layers'::text description,
       TT_lyr_layer_translation('{8,9,10,11,12}', 'a', 'b', 'c', 'd', 'e', '1') = 5 passed
---------------------------------------------------------
UNION ALL
SELECT '92.2'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 4 layers'::text description,
       TT_lyr_layer_translation('{8,9,10,11}', 'a', 'b', 'c', 'd', '1') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '92.3'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 3 layers'::text description,
       TT_lyr_layer_translation('{8,9,10}', 'a', 'b', 'c', '1') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '92.4'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 2 layers'::text description,
       TT_lyr_layer_translation('{8,9}', 'a', 'b', '1') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '92.5'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test wrong height length'::text description,
       TT_lyr_layer_translation('{8,9}', 'a', 'b', 'c', '1') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '92.6'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test wrong height length 2'::text description,
       TT_lyr_layer_translation('{8,9,10}', 'a', 'b', '1') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '92.7'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 5 layers index 3'::text description,
       TT_lyr_layer_translation('{8,9,10,11,12}', 'a', 'b', 'c', 'd', 'e', '3') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '92.8'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 5 layers index 4'::text description,
       TT_lyr_layer_translation('{8,9,10,11,12}', 'a', 'b', 'c', 'd', 'e', '4') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '92.9'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 5 layers with one null'::text description,
       TT_lyr_layer_translation('{8,9,10,11,12}', 'a', 'b', 'c', 'd', '', '1') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '92.10'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 5 layers with two null'::text description,
       TT_lyr_layer_translation('{8,9,10,11,12}', 'a', 'b', '', 'd', '', '1') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '92.11'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test 5 layers with one null'::text description,
       TT_lyr_layer_translation('{8,9,10,11,NULL}', 'a', 'b', 'c', 'd', '', '1') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '92.12'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test null getting set to zero'::text description,
       TT_lyr_layer_translation('{8,9,10,NULL,12}', 'a', 'b', 'c', 'd', 'e', '4') = 5 passed
---------------------------------------------------------
UNION ALL
SELECT '92.13'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test null getting set to zero with ties'::text description,
       TT_lyr_layer_translation('{8,9,10,NULL,NULL}', 'a', 'b', 'c', 'd', 'e', '4') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '92.14'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test ties'::text description,
       TT_lyr_layer_translation('{8,8,10,11,12}', 'a', 'b', 'c', 'd', 'e', '1') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '92.15'::text number,
       'TT_lyr_layer_translation'::text function_tested,
       'test ties'::text description,
       TT_lyr_layer_translation('{8,8,10,11,12}', 'a', 'b', 'c', 'd', 'e', '2') = 5 passed
---------------------------------------------------------
 -- TT_bc_lyr_layer_translation
---------------------------------------------------------
UNION ALL
SELECT '93.1'::text number,
       'TT_bc_lyr_layer_translation'::text function_tested,
       'layer 1 shortest'::text description,
       TT_bc_lyr_layer_translation('10', '5', '50', '50', '11', '6', '50', '50', 'a', 'b', '1') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '93.2'::text number,
       'TT_bc_lyr_layer_translation'::text function_tested,
       'layer 1 tallest'::text description,
       TT_bc_lyr_layer_translation('11', '6', '50', '50', '10', '5', '50', '50', 'a', 'b', '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '93.3'::text number,
       'TT_bc_lyr_layer_translation'::text function_tested,
       'test null pcnt'::text description,
       TT_bc_lyr_layer_translation('10', '5', '50', '50', '11', '6', '50', NULL::text, 'a', 'b', '1') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '93.4'::text number,
       'TT_bc_lyr_layer_translation'::text function_tested,
       'test null height'::text description,
       TT_bc_lyr_layer_translation('10', '5', '50', '50', '11', NULL::text, '50', NULL::text, 'a', 'b', '1') = 2 passed	
---------------------------------------------------------
UNION ALL
SELECT '93.5'::text number,
       'TT_bc_lyr_layer_translation'::text function_tested,
       'test two null pcnt'::text description,
       TT_bc_lyr_layer_translation('10', '5', '50', '50', '11', '6', NULL::text, NULL::text, 'a', 'b', '1') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '93.6'::text number,
       'TT_bc_lyr_layer_translation'::text function_tested,
       'test layer 2 with two null pcnt'::text description,
       TT_bc_lyr_layer_translation('10', '5', '50', '50', '11', '6', NULL::text, NULL::text, 'a', 'b', '2') = 2 passed
	
	
	
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed;

