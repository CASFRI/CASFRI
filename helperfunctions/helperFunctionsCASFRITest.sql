------------------------------------------------------------------------------
-- PostgreSQL Table Tranlation Engine - Test file
-- Version 0.1 for PostgreSQL 9.x
-- https://github.com/edwardsmarc/postTranslationEngine
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2020 Pierre Racine <pierre.racine@sbf.ulaval.ca>,
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--
-------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';

-----------------------------------------------------------
-- Comment out the following line and the last one of the file to display 
-- only failing tests
--SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    SELECT 'TT_vri01_site_index_validation'::text function_tested,       1 maj_num, 9 nb_test UNION ALL
    SELECT 'TT_vri01_origin_translation'::text function_tested,          2 maj_num, 1 nb_test UNION ALL
    SELECT 'TT_vri01_site_index_translation'::text function_tested,      3 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_veg_translation'::text function_tested,     4 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri01_nat_non_veg_translation'::text function_tested,     5 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_anth_translation'::text function_tested,    6 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_avi01_non_for_anth_validation'::text function_tested,     7 maj_num, 9 nb_test UNION ALL
    SELECT 'TT_avi01_non_for_anth_translation'::text function_tested,    8 maj_num, 9 nb_test UNION ALL
	  SELECT 'TT_nbi01_stand_structure_translation'::text function_tested, 9 maj_num, 5 nb_test UNION ALL
		SELECT 'TT_nbi01_num_of_layers_translation'::text function_tested,  10 maj_num, 4 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_validation'::text function_tested,         11 maj_num, 4 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_translation'::text function_tested,        12 maj_num, 4 nb_test UNION ALL
    SELECT 'TT_nbi01_productive_for_translation'::text function_tested, 13 maj_num, 11 nb_test

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
-- TT_vri01_site_index_validation
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'Both not null'::text description,
       TT_vri01_site_index_validation('12.1', '10') passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'One null'::text description,
       TT_vri01_site_index_validation(NULL::text, '12.2') passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'One empty'::text description,
       TT_vri01_site_index_validation('1', '') passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'Both null'::text description,
       TT_vri01_site_index_validation(NULL::text, NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'Both empty'::text description,
       TT_vri01_site_index_validation('', '') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'First val not between 0-99'::text description,
       TT_vri01_site_index_validation('123', '22') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'Second val not between 0-99'::text description,
       TT_vri01_site_index_validation('', '222') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'First val not numeric'::text description,
       TT_vri01_site_index_validation('12a', '22') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'TT_vri01_site_index_validation'::text function_tested,
       'Second val not numeric'::text description,
       TT_vri01_site_index_validation('', '22a') IS FALSE passed
---------------------------------------------------------
-- TT_vri01_origin_translation
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_vri01_origin_translation'::text function_tested,
       'Good year and age'::text description,
       TT_vri01_origin_translation('2001-04-10', '10') = 1991 passed
---------------------------------------------------------
-- TT_vri01_site_index_translation
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_vri01_site_index_translation'::text function_tested,
       'site_index present'::text description,
       TT_vri01_site_index_translation('12.1', '10') = 12.1::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_vri01_site_index_translation'::text function_tested,
       'site_index null'::text description,
       TT_vri01_site_index_translation(NULL::text, '10') = 10::double precision passed
---------------------------------------------------------
-- TT_vri01_non_for_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_vri01_non_for_veg_translation'::text function_tested,
       'Good test'::text description,
       TT_vri01_non_for_veg_translation('V'::text, 'BL'::text, ''::text, ''::text) = 'BR' passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_vri01_non_for_veg_translation'::text function_tested,
       'No matches test'::text description,
       TT_vri01_non_for_veg_translation('V'::text, ''::text, ''::text, ''::text) IS NULL passed
---------------------------------------------------------
-- TT_vri01_nat_non_veg_translation
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_vri01_nat_non_veg_translation'::text function_tested,
       'Good test'::text description,
       TT_vri01_nat_non_veg_translation('V'::text, 'BE'::text, ''::text, ''::text, ''::text) = 'BE' passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_vri01_nat_non_veg_translation'::text function_tested,
       'No matches test'::text description,
       TT_vri01_nat_non_veg_translation('V'::text, ''::text, ''::text, ''::text, ''::text) IS NULL passed
---------------------------------------------------------
-- TT_vri01_non_for_anth_translation
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_vri01_non_for_anth_translation'::text function_tested,
       'Good test'::text description,
       TT_vri01_non_for_anth_translation('V'::text, 'AP'::text, ''::text, ''::text) = 'FA' passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_vri01_non_for_anth_translation'::text function_tested,
       'No matches test'::text description,
       TT_vri01_non_for_anth_translation('V'::text, ''::text, ''::text, ''::text) IS NULL passed
---------------------------------------------------------
-- TT_avi01_non_for_anth_validation
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Two empty strings'::text description,
       TT_avi01_non_for_anth_validation(''::text, ''::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Two NULL'::text description,
       TT_avi01_non_for_anth_validation(NULL::text, NULL::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.3'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Pass with an empty string'::text description,
       TT_avi01_non_for_anth_validation('C'::text, ''::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS TRUE passed
---------------------------------------------------------
UNION ALL
SELECT '7.4'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Pass with a NULL'::text description,
       TT_avi01_non_for_anth_validation(NULL::text, 'C'::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) passed
---------------------------------------------------------
UNION ALL
SELECT '7.5'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Two values'::text description,
       TT_avi01_non_for_anth_validation('A'::text, 'C'::text, '{''A'', ''B'', ''C''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.6'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Not in set'::text description,
       TT_avi01_non_for_anth_validation('C'::text, NULL::text, '{''A'', ''B'', ''S''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.7'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Not in set'::text description,
       TT_avi01_non_for_anth_validation(NULL::text, 'x'::text, '{''A'', ''B'', ''S''}'::text, TRUE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.8'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'Not in set, ignoreCase = false'::text description,
       TT_avi01_non_for_anth_validation(NULL::text, 'a'::text, '{''A'', ''B'', ''S''}'::text, FALSE::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '7.9'::text number,
       'TT_avi01_non_for_anth_validation'::text function_tested,
       'In set with ignoreCase = true'::text description,
       TT_avi01_non_for_anth_validation(NULL::text, 'a'::text, '{''A'', ''B'', ''S''}'::text, TRUE::text) passed
---------------------------------------------------------
-- TT_avi01_non_for_anth_translation
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Pass with one empty string'::text description,
       TT_avi01_non_for_anth_translation('D'::text, ''::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                              '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) = 'dd' passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Pass with one null'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'H'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) = 'hh' passed
---------------------------------------------------------
UNION ALL
SELECT '8.3'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Pass with ignore case true'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'h'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) = 'hh' passed
---------------------------------------------------------
UNION ALL
SELECT '8.4'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Fail with ignore case false'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'h'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, FALSE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.5'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Not in set'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, 'x'::text, '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                                                '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.6'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Two nulls'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, NULL::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.7'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Two empty'::text description,
       TT_avi01_non_for_anth_translation(''::text, ''::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.8'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'One Null one empty'::text description,
       TT_avi01_non_for_anth_translation(NULL::text, ''::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '8.9'::text number,
       'TT_avi01_non_for_anth_translation'::text function_tested,
       'Two values'::text description,
       TT_avi01_non_for_anth_translation('a'::text, 'b'::text, 
                                         '{''A'', ''B'', ''C'', ''D'', ''E'', ''F'', ''G'', ''H''}'::text, 
                                         '{''aa'', ''bb'', ''cc'', ''dd'', ''ee'', ''ff'', ''gg'', ''hh''}'::text, TRUE::text) IS NULL passed
---------------------------------------------------------
-- TT_nbi01_stand_structure_translation
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Wrong source dataset'::text description,
       TT_nbi01_stand_structure_translation('Wetland'::text, '0'::text, '0'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Single layer all zero'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '0'::text, '0'::text) = 'S' passed
---------------------------------------------------------
UNION ALL
SELECT '9.3'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Single layer l1vs > 0'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '2'::text, '0'::text) = 'S' passed
---------------------------------------------------------
UNION ALL
SELECT '9.4'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Multi layer'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '1'::text, '1'::text) = 'M' passed
---------------------------------------------------------
UNION ALL
SELECT '9.5'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Complex layer'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '2'::text, '2'::text) = 'C' passed
---------------------------------------------------------
-- TT_nbi01_num_of_layers
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_nbi01_num_of_layers_translation'::text function_tested,
       'Wrong source dataset'::text description,
       TT_nbi01_num_of_layers_translation('Wetland'::text, '0'::text, '0'::text) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_nbi01_num_of_layers_translation'::text function_tested,
       '1 layer, S'::text description,
       TT_nbi01_num_of_layers_translation('Forest'::text, '0'::text, '0'::text) = 1 passed
---------------------------------------------------------
UNION ALL
SELECT '10.3'::text number,
       'TT_nbi01_num_of_layers_translation'::text function_tested,
       '2 layer, M'::text description,
       TT_nbi01_num_of_layers_translation('Forest'::text, '1'::text, '1'::text) = 2 passed
---------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_nbi01_num_of_layers_translation'::text function_tested,
       '2 layer, C'::text description,
       TT_nbi01_num_of_layers_translation('Forest'::text, '2'::text, '2'::text) = 2 passed
---------------------------------------------------------
  -- TT_nbi01_wetland_validation
---------------------------------------------------------
UNION ALL
SELECT '11.1'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'pass 1'::text description,
       TT_nbi01_wetland_validation('FE'::text, 'EV'::text, 'BP'::text, '1'::text) passed
---------------------------------------------------------
UNION ALL
SELECT '11.2'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'pass 2'::text description,
       TT_nbi01_wetland_validation('BO'::text, 'OV'::text, 'MI'::text, '2'::text)  passed
---------------------------------------------------------
UNION ALL
SELECT '11.3'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'Fail due to dash'::text description,
       TT_nbi01_wetland_validation('BO'::text, 'OV'::text, 'MI'::text, '3'::text) IS FALSE  passed
---------------------------------------------------------
UNION ALL
SELECT '11.4'::text number,
       'TT_nbi01_wetland_validation'::text function_tested,
       'Fail due to no case'::text description,
       TT_nbi01_wetland_validation('XX'::text, 'OV'::text, 'MI'::text, '3'::text) IS FALSE  passed
---------------------------------------------------------
  -- TT_nbi01_wetland_translation
---------------------------------------------------------
UNION ALL
SELECT '12.1'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'pass 1'::text description,
       TT_nbi01_wetland_translation('FE'::text, 'EV'::text, 'BP'::text, '1'::text) = 'F' passed
---------------------------------------------------------
UNION ALL
SELECT '12.2'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'pass 2'::text description,
       TT_nbi01_wetland_translation('BO'::text, 'OV'::text, 'MI'::text, '2'::text) = 'O'  passed
---------------------------------------------------------
UNION ALL
SELECT '12.3'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'Null due to dash'::text description,
       TT_nbi01_wetland_translation('BO'::text, 'OV'::text, 'MI'::text, '3'::text) IS NULL  passed
---------------------------------------------------------
UNION ALL
SELECT '12.4'::text number,
       'TT_nbi01_wetland_translation'::text function_tested,
       'Null due to no case'::text description,
       TT_nbi01_wetland_translation('XX'::text, 'OV'::text, 'MI'::text, '3'::text) IS NULL
---------------------------------------------------------
  -- TT_nbi01_productive_for_translation
---------------------------------------------------------
UNION ALL
SELECT '13.1'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 1'::text description,
       TT_nbi01_productive_for_translation(NULL::text, '10'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '13.2'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 2'::text description,
       TT_nbi01_productive_for_translation('6'::text, '10'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '13.3'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 3'::text description,
       TT_nbi01_productive_for_translation('5'::text, NULL::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '13.4'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 4'::text description,
       TT_nbi01_productive_for_translation('5'::text, '0.05'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '13.5'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 5'::text description,
       TT_nbi01_productive_for_translation('5'::text, '101'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '13.6'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 6a'::text description,
       TT_nbi01_productive_for_translation('5'::text, '100'::text, ''::text, 'CC'::text, '0'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '13.7'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 6b'::text description,
       TT_nbi01_productive_for_translation('5'::text, '100'::text, 'CC'::text, 'CC'::text, '0'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '13.8'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 6c'::text description,
       TT_nbi01_productive_for_translation('5'::text, '100'::text, 'F'::text, 'CC'::text, '1'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '13.9'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 6d'::text description,
       TT_nbi01_productive_for_translation('5'::text, '100'::text, 'F'::text, 'CC'::text, '0'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '13.10'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 7a'::text description,
       TT_nbi01_productive_for_translation('5'::text, '100'::text, 'CC'::text, ''::text, '0'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '13.11'::text number,
       'TT_nbi01_productive_for_translation'::text function_tested,
       'Test PP if statement 7b'::text description,
       TT_nbi01_productive_for_translation('5'::text, '100'::text, 'CC'::text, 'F'::text, '0'::text) = 'PP' passed
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

