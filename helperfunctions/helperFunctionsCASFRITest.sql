------------------------------------------------------------------------------
-- CASFRI Helper functions test file for CASFR v5 beta
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
SELECT 'Sw'::text source_val, 'Pice glau'::text spec1
UNION ALL
SELECT 'Sb'::text, 'Pice mari'::text;

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
    SELECT 'TT_avi01_non_for_anth_translation'::text function_tested,         9 maj_num,  9 nb_test UNION ALL
    SELECT 'TT_nbi01_stand_structure_translation'::text function_tested,     10 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_validation'::text function_tested,              12 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_translation'::text function_tested,             13 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_nbi01_nb01_productive_for_translation'::text function_tested, 14 maj_num, 11 nb_test UNION ALL
    SELECT 'TT_nbi01_nb02_productive_for_translation'::text function_tested, 15 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_CreateFilterView'::text function_tested,                      16 maj_num, 23 nb_test UNION ALL
    SELECT 'TT_vri01_dist_yr_translation'::text function_tested,             17 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_tie01_crownclosure_translation'::text function_tested,        18 maj_num,  8 nb_test UNION ALL
    SELECT 'TT_tie01_height_translation'::text function_tested,              19 maj_num,  9 nb_test UNION ALL
    SELECT 'TT_tie01_2layer_age_codes_validation'::text function_tested,     20 maj_num,  8 nb_test UNION ALL
    SELECT 'TT_tie01_not_etage_notnull_validation'::text function_tested,    21 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_tie01_not_etage_layer1_validation'::text function_tested,     22 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_tie01_not_etage_dens_layers_validation'::text function_tested,23 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_fim_species_code'::text function_tested,                      24 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_fim_species_translation'::text function_tested,               25 maj_num,  6 nb_test UNION ALL
    SELECT 'TT_fim_species_percent_translation'::text function_tested,       26 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_yvi01_nat_non_veg_validation'::text function_tested,          27 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_yvi01_nat_non_veg_translation'::text function_tested,         28 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_yvi01_non_for_veg_translation'::text function_tested,         29 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_yvi01_nfl_soil_moisture_validation'::text function_tested,    30 maj_num,  5 nb_test UNION ALL
    SELECT 'TT_avi01_stand_structure_validation'::text function_tested,      31 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_avi01_stand_structure_translation'::text function_tested,     32 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_fvi01_stand_structure_validation'::text function_tested,      33 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_fvi01_countOfNotNull'::text function_tested,                  34 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_vri01_countOfNotNull'::text function_tested,                  35 maj_num, 16 nb_test UNION ALL
    SELECT 'TT_sk_utm01_species_percent_validation'::text function_tested,   36 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_sk_utm01_species_percent_translation'::text function_tested,  37 maj_num, 11 nb_test UNION ALL
    SELECT 'TT_sk_utm01_species_translation'::text function_tested,          38 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_sfv01_stand_structure_translation'::text function_tested,     39 maj_num,  4 nb_test UNION ALL
    SELECT 'TT_sfv01_countOfNotNull'::text function_tested,                  40 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_ns_nsi01_countOfNotNull'::text function_tested,               41 maj_num,  3 nb_test UNION ALL
    SELECT 'TT_HasNFLInfo'::text function_tested,                            42 maj_num,  13 nb_test
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
       TT_vri01_non_for_veg_translation('V'::text, 'BL'::text, ''::text, ''::text) = 'BR' passed
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
-- TT_avi01_non_for_anth_translation
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Pass with one empty string'::text description,
       TT_avi01_non_for_anth_translation('D'::text, ''::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                              '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) = 'dd' passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Pass with one null'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'H'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) = 'hh' passed
---------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Pass with ignore case true'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'h'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) = 'hh' passed
---------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Fail with ignore case false'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'h'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Not in set'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'x'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '9.6'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Two nulls'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, NULL::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '9.7'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Two empty'::text description,
       TT_avi01_non_for_anth_translation(''::text, ''::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '9.8'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'One Null one empty'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, ''::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '9.9'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Two values'::text description,
       TT_avi01_non_for_anth_translation('a'::text, 'b'::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
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
       TT_nbi01_wetland_translation('FE'::text, 'EV'::text, 'BP'::text, '1'::text) = 'F' passed
---------------------------------------------------------
UNION ALL
SELECT '13.2'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'pass 2'::text description,
       TT_nbi01_wetland_translation('BO'::text, 'OV'::text, 'MI'::text, '2'::text) = 'O'  passed
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
SELECT *
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.17'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test empty keywords in ''and'' second argument'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'eco', '[nfl3, eco]', 'dst2', 'eco_for_nfl3_and_eco_not_dst2') = 
       'DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl3_and_eco_not_dst2 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_eco_for_nfl3_and_eco_not_dst2 AS
SELECT *
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'');' passed
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
  -- TT_tie01_crownclosure_translation
---------------------------------------------------------
UNION ALL
SELECT '18.1'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test num_of_layers 1, layer 1 in_etage'::text description,
       TT_tie01_crownclosure_translation('VIR', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'NULL', 'VIR', 'NULL', '85', 'NULL', 'A', '1', 'lower') = 85::int passed
---------------------------------------------------------
UNION ALL
SELECT '18.2'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test num_of_layers 1, layer 2 in_etage'::text description,
       TT_tie01_crownclosure_translation('VIR', 'public', 'test_lookup_qc_stdstr', 'layer_2_age', 'O', 'NULL', 'VIR', NULL, '85', NULL, 'A', '2', 'lower') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '18.3'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test num_of_layers 2, layer 1 sup in_etage'::text description,
       TT_tie01_crownclosure_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'EQU', 'VIN', '10', '85', '100', 'A', '1', 'lower') = 85 passed
---------------------------------------------------------
UNION ALL
SELECT '18.4'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test num_of_layers 2, layer 1 inf in_etage'::text description,
       TT_tie01_crownclosure_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'EQU', '10', 'VIN', '85', '100', 'A', '1', 'lower') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '18.5'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test not in_etage, 1 layer, layer 1'::text description,
       TT_tie01_crownclosure_translation('VIN', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'N', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'A', '1', 'lower') = 80 passed
---------------------------------------------------------
UNION ALL
SELECT '18.6'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test not in_etage, 2 layers'::text description,
       TT_tie01_crownclosure_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'N', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'A', '1', 'lower') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '18.7'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test not in_etage, 1 layer, layer 2'::text description,
       TT_tie01_crownclosure_translation('VIN', 'public', 'test_lookup_qc_stdstr', 'layer_2_age', 'N', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'A', '2', 'lower') IS NULL passed
  ---------------------------------------------------------
UNION ALL
SELECT '18.8'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'cl_age doesn`t match'::text description,
       TT_tie01_crownclosure_translation('VIN20', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'NULL', 'VIR', '10', '15', '20', '1', '1', 'lower') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '18.9'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'Test using et_domi'::text description,
       TT_tie01_crownclosure_translation('2010', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'SUP', '', '', '85', '80', 'A', '1', 'lower') = 85::int passed
---------------------------------------------------------
UNION ALL
SELECT '18.10'::text number,
       'TT_tie01_crownclosure_translation'::text function_tested,
       'test using et_domi INF'::text description,
       TT_tie01_crownclosure_translation('2010', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'INF', '', '', '85', '80', 'A', '1', 'lower') = 80::int passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_tie01_height_translation
---------------------------------------------------------
UNION ALL
SELECT '19.1'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test num_of_layers 1, layer 1 in_etage'::text description,
       TT_tie01_height_translation('VIR', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', NULL::text, 'VIR', 'NULL', '15', 'NULL', '1', '1', 'lower') = 15 passed
---------------------------------------------------------
UNION ALL
SELECT '19.2'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test num_of_layers 1, layer 2 in_etage'::text description,
       TT_tie01_height_translation('VIR', 'public', 'test_lookup_qc_stdstr', 'layer_2_age', 'O', NULL::text, 'VIR', NULL::text, '15', NULL::text, '1', '2', 'lower') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '19.3'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test num_of_layers 2, layer 1 sup in_etage'::text description,
       TT_tie01_height_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'EQU', 'VIN', '10', '15', '100', '1', '1', 'lower') = 15 passed
---------------------------------------------------------
UNION ALL
SELECT '19.4'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test num_of_layers 2, layer 1 inf in_etage'::text description,
       TT_tie01_height_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'EQU', '10', 'VIN', '15', '100', '1', '1', 'lower') = 100 passed
---------------------------------------------------------
UNION ALL
SELECT '19.5'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test not in_etage, 1 layer, layer 1'::text description,
       TT_tie01_height_translation('VIN', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'N', NULL::text, 'NULL', 'NULL', 'NULL', 'NULL', '1', '1', 'lower') = 22 passed
---------------------------------------------------------
UNION ALL
SELECT '19.6'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test not in_etage, 2 layers, layer 1'::text description,
       TT_tie01_height_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'N', NULL::text, 'NULL', 'NULL', 'NULL', 'NULL', '7', '1', 'upper') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '19.7'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test not in_etage, 2 layers, layer 2'::text description,
       TT_tie01_height_translation('VIN10', 'public', 'test_lookup_qc_stdstr', 'layer_2_age', 'N', NULL::text, 'NULL', 'NULL', 'NULL', 'NULL', '7', '2', 'upper') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '19.8'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test not in_etage, 1 layer, layer 2'::text description,
       TT_tie01_height_translation('VIN', 'public', 'test_lookup_qc_stdstr', 'layer_2_age', 'N', NULL::text, 'NULL', 'NULL', 'NULL', 'NULL', '1', '2', 'lower') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '19.9'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'cl_age doesn`t match'::text description,
       TT_tie01_height_translation('VIN20', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', NULL::text, 'VIR', '10', '15', '20', '1', '1', 'lower') IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '19.10'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'Test using et_domi'::text description,
       TT_tie01_height_translation('2010', 'public', 'test_lookup_qc_stdstr', 'layer_1_age', 'O', 'SUP', '', '', '15', '20', 'A', '1', 'lower') = 15::int passed
---------------------------------------------------------
UNION ALL
SELECT '19.11'::text number,
       'TT_tie01_height_translation'::text function_tested,
       'test using et_domi INF'::text description,
       TT_tie01_height_translation('2010', 'translation', 'qc03_standstructure', 'layer_1_age', 'O', 'INF', '', '', '15', '20', 'A', '1', 'lower') = 20::int passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_tie01_2layer_age_codes_validation
---------------------------------------------------------
UNION ALL
SELECT '20.1'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Only 1 layer, rule is skipped so should return true'::text description,
       TT_tie01_2layer_age_codes_validation('VIR', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, 'VIN', 'NULL') passed
---------------------------------------------------------
UNION ALL
SELECT '20.2'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Codes match'::text description,
       TT_tie01_2layer_age_codes_validation('VIR10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, 'VIN', '10') passed
---------------------------------------------------------
UNION ALL
SELECT '20.3'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Codes match'::text description,
       TT_tie01_2layer_age_codes_validation('VIR10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, '10', 'VIN') passed
---------------------------------------------------------
UNION ALL
SELECT '20.4'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Codes dont match'::text description,
       TT_tie01_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, 'VIN', 'VIN') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.5'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Codes dont match'::text description,
       TT_tie01_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, '10', '10') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.6'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Codes dont match'::text description,
       TT_tie01_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', NULL::text, '', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '20.7'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'et_domi not null'::text description,
       TT_tie01_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', 'VAL', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '20.8'::text number,
       'TT_tie01_2layer_age_codes_validation'::text function_tested,
       'Should still run test if et_domi is EQU'::text description,
       TT_tie01_2layer_age_codes_validation('VIN10', 'public', 'test_lookup_qc_stdstr', 'O', 'EQU', '', '') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_tie01_not_etage_notnull_validation
---------------------------------------------------------
UNION ALL
SELECT '21.1'::text number,
       'TT_tie01_not_etage_notnull_validation'::text function_tested,
       'Test not null'::text description,
       TT_tie01_not_etage_notnull_validation('N', 'val') passed
---------------------------------------------------------
UNION ALL
SELECT '21.2'::text number,
       'TT_tie01_not_etage_notnull_validation'::text function_tested,
       'Test null'::text description,
       TT_tie01_not_etage_notnull_validation('N', NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '21.3'::text number,
       'TT_tie01_not_etage_notnull_validation'::text function_tested,
       'Test in_etage = O'::text description,
       TT_tie01_not_etage_notnull_validation('O', NULL::text) passed
--------------------------------------------------------
---------------------------------------------------------
  -- TT_tie01_not_etage_layer1_validation
---------------------------------------------------------
UNION ALL
SELECT '22.1'::text number,
       'TT_tie01_not_etage_layer1_validation'::text function_tested,
       'Test layer = 1'::text description,
       TT_tie01_not_etage_layer1_validation('N', '1') passed
---------------------------------------------------------
UNION ALL
SELECT '22.2'::text number,
       'TT_tie01_not_etage_layer1_validation'::text function_tested,
       'Test layer = 2'::text description,
       TT_tie01_not_etage_layer1_validation('N', '2') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '22.3'::text number,
       'TT_tie01_not_etage_layer1_validation'::text function_tested,
       'in etage = O'::text description,
       TT_tie01_not_etage_layer1_validation('O', '2') passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_tie01_not_etage_dens_layers_validation
---------------------------------------------------------
UNION ALL
SELECT '23.1'::text number,
       'TT_tie01_not_etage_dens_layers_validation'::text function_tested,
       'In etage = O'::text description,
       TT_tie01_not_etage_dens_layers_validation('O', '10', 'public', 'test_lookup_qc_stdstr') passed
---------------------------------------------------------
UNION ALL
SELECT '23.2'::text number,
       'TT_tie01_not_etage_dens_layers_validation'::text function_tested,
       'In etage = N, num_of_layers = 1'::text description,
       TT_tie01_not_etage_dens_layers_validation('N', '10', 'public', 'test_lookup_qc_stdstr') passed
---------------------------------------------------------
UNION ALL
SELECT '23.3'::text number,
       'TT_tie01_not_etage_dens_layers_validation'::text function_tested,
       'In etage = N, num_of_layers = 2'::text description,
       TT_tie01_not_etage_dens_layers_validation('N', '1010', 'public', 'test_lookup_qc_stdstr') IS FALSE passed
---------------------------------------------------------
---------------------------------------------------------
  -- TT_fim_species_code
---------------------------------------------------------
UNION ALL
SELECT '24.1'::text number,
       'TT_fim_species_code'::text function_tested,
       'Get species code 1'::text description,
       TT_fim_species_code('Sw  10Sb  90', '1') = 'Sw  10' passed
---------------------------------------------------------
UNION ALL
SELECT '24.2'::text number,
       'TT_fim_species_code'::text function_tested,
       'Get species code 2'::text description,
       TT_fim_species_code('Sw  10Sb  90', '2') = 'Sb  90' passed
---------------------------------------------------------
UNION ALL
SELECT '24.3'::text number,
       'TT_fim_species_code'::text function_tested,
       'Get species code 100%'::text description,
       TT_fim_species_code('Sw 100', '1') = 'Sw 100' passed
---------------------------------------------------------
UNION ALL
SELECT '24.4'::text number,
       'TT_fim_species_code'::text function_tested,
       'Species code not available'::text description,
       TT_fim_species_code('Sw 100', '2') = '' passed
---------------------------------------------------------
UNION ALL
SELECT '24.5'::text number,
       'TT_fim_species_code'::text function_tested,
       'Species code null'::text description,
       TT_fim_species_code('', '1') IS NULL passed
---------------------------------------------------------
  -- TT_fim_species_translation
---------------------------------------------------------
UNION ALL
SELECT '25.1'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Get species code 1'::text description,
       TT_fim_species_translation('Sw  10Sb  90', '1', 'public', 'test_lookup_on_species', 'source_val', 'spec1') = 'Pice glau' passed
---------------------------------------------------------
UNION ALL
SELECT '25.2'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Get species code 2'::text description,
       TT_fim_species_translation('Sw  10Sb  90', '2', 'public', 'test_lookup_on_species', 'source_val', 'spec1') = 'Pice mari' passed
---------------------------------------------------------
UNION ALL
SELECT '25.3'::text number,
       'TT_fim_species_translation'::text function_tested,
       'Get species code 100'::text description,
       TT_fim_species_translation('Sw 100', '1', 'public', 'test_lookup_on_species', 'source_val', 'spec1') = 'Pice glau' passed
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
       TT_yvi01_non_for_veg_translation('VN', 'C', 'TS') = 'ST' passed
---------------------------------------------------------
UNION ALL
SELECT '29.5'::text number,
       'TT_yvi01_non_for_veg_translation'::text function_tested,
       'Test correct class with no cl_mod match'::text description,
       TT_yvi01_non_for_veg_translation('VN', 'C', 'TSS') = 'BR' passed
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
       TT_fvi01_stand_structure_validation('H', '', '', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '33.2'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test nfl'::text description,
       TT_fvi01_stand_structure_validation('S', 'ST','', '', '', '', '') passed
---------------------------------------------------------
UNION ALL
SELECT '33.3'::text number,
       'TT_fvi01_stand_structure_validation'::text function_tested,
       'Test not nfl'::text description,
       TT_fvi01_stand_structure_validation('', '', '', '', '', '', '') IS FALSE passed
---------------------------------------------------------
 -- TT_fvi01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '34.1'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 4'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'SL', 'ST', '4', 'FALSE') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '34.2'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 3'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'SL', 'WRONG', '4', 'FALSE') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '34.3'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 3 with NULL'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'SL', NULL::text, '4', 'FALSE') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '34.4'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 2 with NULL and empty string'::text description,
       TT_fvi01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', '', NULL::text, '4', 'FALSE') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '34.5'::text number,
       'TT_fvi01_countOfNotNull'::text function_tested,
       'Count of 0'::text description,
       TT_fvi01_countOfNotNull('{'''',''''}', '{'''',''''}', '', NULL::text, '4', 'FALSE') = 0 passed
---------------------------------------------------------
---------------------------------------------------------
 -- TT_vri01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '35.1'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 5, all 3 nfl layers present'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', 'AP', '5', 'FALSE', 'BC10') = 5 passed
---------------------------------------------------------
UNION ALL
SELECT '35.2'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 4, 2 nfl layer present'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'BL', 'EL', '', '', '5', 'FALSE', 'BC10') = 4 passed
---------------------------------------------------------
UNION ALL
SELECT '35.3'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, 1 nfl layer'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', '', '', 'OR', '', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.4'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_veg 4'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', '', 'ST', '', '', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.5'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'non_for_veg fail'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', '', '', '', '', '5', 'FALSE', 'BC10') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '35.6'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 1'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', '', '', '', 'MU', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.7'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 2'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'LL', 'XX', 'XX', 'XX', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.8'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 3'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'I', 'XX', 'SI', 'XX', 'XX', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.9'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 4'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', 'LL', 'XX', 'ICE', '', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.10'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, nat_non_veg 5'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', NULL::text, 'RO', NULL::text, NULL::text, '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.11'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'nat_non_veg fail'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'XX', 'XX', 'XX', 'XX', '5', 'FALSE', 'BC10') = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '35.12'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_anth 1'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', '', '', '', 'AP', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.13'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_anth 2'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'V', 'AP', 'XX', 'XX', 'XX', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.14'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 3, non_for_anth 3'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{''val'',''val''}', 'F', 'XX', 'XX', 'C', 'XX', '5', 'FALSE', 'BC10') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '35.15'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 1'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{'''',''''}', '', 'XX', 'XX', 'C', 'XX', '5', 'FALSE', 'BC10') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '35.16'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Count of 0'::text description,
       TT_vri01_countOfNotNull('{'''',''''}', '{'''',''''}', '', '', '', '', '', '5', 'FALSE', 'BC10') = 0 passed
---------------------------------------------------------
---------------------------------------------------------
UNION ALL
SELECT '35.13'::text number,
       'TT_vri01_countOfNotNull'::text function_tested,
       'Test BC08 option'::text description,
       TT_vri01_countOfNotNull('{''val'',''val''}', '{'''',''''}', 'V', '', '', '', 'AP', '5', 'FALSE', 'BC08') = 2 passed
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
       TT_sk_utm01_species_translation('2', 'WS','BF','','','') = 'Abie bals' passed
---------------------------------------------------------
UNION ALL
SELECT '38.2'::text number,
       'TT_sk_utm01_species_translation'::text function_tested,
       'Expected species with empty strings'::text description,
       TT_sk_utm01_species_translation('2', 'WS','','','','BF') = 'Abie bals' passed
---------------------------------------------------------
UNION ALL
SELECT '38.3'::text number,
       'TT_sk_utm01_species_translation'::text function_tested,
       'Expected species with empty strings and nulls'::text description,
       TT_sk_utm01_species_translation('2', 'WS','',NULL::text,'','BF') = 'Abie bals' passed
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
       TT_sfv01_countOfNotNull('bf', '', '', '', '', '', '', '', '', '6', 'FALSE') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '40.2'::text number,
       'TT_sfv01_countOfNotNull'::text function_tested,
       'Test six layers'::text description,
       TT_sfv01_countOfNotNull('bf', 'bf', 'bf', 'bf', 'bf', 'WA', '', '', '', '6', 'FALSE') = 6 passed
---------------------------------------------------------
UNION ALL
SELECT '40.3'::text number,
       'TT_sfv01_countOfNotNull'::text function_tested,
       'Test six layers'::text description,
       TT_sfv01_countOfNotNull('bf', 'bf', 'bf', 'bf', 'bf', 'xx', '', '', '', '6', 'FALSE') = 5 passed
---------------------------------------------------------
  -- TT_ns_nsi01_countOfNotNull
---------------------------------------------------------
UNION ALL
SELECT '41.1'::text number,
       'TT_ns_nsi01_countOfNotNull'::text function_tested,
       'Test one layer'::text description,
       TT_ns_nsi01_countOfNotNull('bf', '', '', '3', 'FALSE') = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '41.2'::text number,
       'TT_ns_nsi01_countOfNotNull'::text function_tested,
       'Test 3 layers'::text description,
       TT_ns_nsi01_countOfNotNull('bf', 'bf', '89', '3', 'FALSE') = 3 passed
---------------------------------------------------------
UNION ALL
SELECT '41.3'::text number,
       'TT_ns_nsi01_countOfNotNull'::text function_tested,
       'Test 0 layers'::text description,
       TT_ns_nsi01_countOfNotNull('', '', '', '3', 'FALSE') = 0 passed
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
  
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed;

