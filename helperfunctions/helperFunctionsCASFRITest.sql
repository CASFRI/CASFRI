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
    SELECT 'TT_vri01_non_for_veg_validation'::text function_tested,           1 maj_num, 4 nb_test UNION ALL
    SELECT 'TT_vri01_nat_non_veg_validation'::text function_tested,           2 maj_num, 5 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_anth_validation'::text function_tested,          3 maj_num, 3 nb_test UNION ALL
    SELECT 'TT_vri01_origin_translation'::text function_tested,               4 maj_num, 1 nb_test UNION ALL
    SELECT 'TT_vri01_site_index_translation'::text function_tested,           5 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_veg_translation'::text function_tested,          6 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri01_nat_non_veg_translation'::text function_tested,          7 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri01_non_for_anth_translation'::text function_tested,         8 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_avi01_non_for_anth_translation'::text function_tested,         9 maj_num, 9 nb_test UNION ALL
    SELECT 'TT_nbi01_stand_structure_translation'::text function_tested,     10 maj_num, 5 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_validation'::text function_tested,              12 maj_num, 4 nb_test UNION ALL
    SELECT 'TT_nbi01_wetland_translation'::text function_tested,             13 maj_num, 4 nb_test UNION ALL
    SELECT 'TT_nbi01_nb01_productive_for_translation'::text function_tested, 14 maj_num, 11 nb_test UNION ALL
    SELECT 'TT_nbi01_nb02_productive_for_translation'::text function_tested, 15 maj_num, 5 nb_test UNION ALL
    SELECT 'TT_CreateFilterView'::text function_tested,                      16 maj_num, 22 nb_test UNION ALL
    SELECT 'TT_vri01_dist_yr_translation'::text function_tested,             17 maj_num,  4 nb_test 
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
       TT_vri01_nat_non_veg_translation('V'::text, 'BE'::text, ''::text, ''::text, ''::text) = 'BE' passed
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
       TT_vri01_non_for_anth_translation('V'::text, 'AP'::text, ''::text, ''::text) = 'FA' passed
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
       TT_nbi01_stand_structure_translation('Forest'::text, '0'::text, '0'::text) = 'S' passed
---------------------------------------------------------
UNION ALL
SELECT '10.3'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Single layer l1vs > 0'::text description,
       TT_nbi01_stand_structure_translation('geonb_forest-foret'::text, '2'::text, '0'::text) = 'S' passed
---------------------------------------------------------
UNION ALL
SELECT '10.4'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Multi layer'::text description,
       TT_nbi01_stand_structure_translation('Forest'::text, '1'::text, '1'::text) = 'M' passed
---------------------------------------------------------
UNION ALL
SELECT '10.5'::text number,
       'TT_nbi01_stand_structure_translation'::text function_tested,
       'Complex layer'::text description,
       TT_nbi01_stand_structure_translation('geonb_forest-foret'::text, '2'::text, '2'::text) = 'C' passed
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
       TT_nbi01_nb01_productive_for_translation(NULL::text, '10'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '14.2'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 2'::text description,
       TT_nbi01_nb01_productive_for_translation('6'::text, '10'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '14.3'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 3'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, NULL::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '14.4'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 4'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '0.05'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '14.5'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 5'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '101'::text, 'CC'::text, 'XX'::text, '5'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '14.6'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6a'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, ''::text, 'CC'::text, '0'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '14.7'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6b'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'CC'::text, 'CC'::text, '0'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '14.8'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6c'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'F'::text, 'CC'::text, '1'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '14.9'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 6d'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'F'::text, 'CC'::text, '0'::text) = 'PP' passed
---------------------------------------------------------
UNION ALL
SELECT '14.10'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 7a'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'CC'::text, ''::text, '0'::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '14.11'::text number,
       'TT_nbi01_nb01_productive_for_translation'::text function_tested,
       'Test PP if statement 7b'::text description,
       TT_nbi01_nb01_productive_for_translation('5'::text, '100'::text, 'CC'::text, 'F'::text, '0'::text) = 'PP' passed
---------------------------------------------------------
  -- TT_nbi01_nb02_productive_for_translation
---------------------------------------------------------
UNION ALL
SELECT '15.1'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 1'::text description,
       TT_nbi01_nb02_productive_for_translation(1::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '15.2'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 2'::text description,
       TT_nbi01_nb02_productive_for_translation(2::text) = 'PF' passed
---------------------------------------------------------
UNION ALL
SELECT '15.3'::text number,
       'TT_nbi01_nb02_productive_for_translation'::text function_tested,
       'Test fst = 3'::text description,
       TT_nbi01_nb02_productive_for_translation(3::text) = 'PP' passed
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
       TT_CreateFilterView('rawfri', 'ab06', 'nfl1', NULL, NULL, 'nfl1') = 'DROP VIEW IF EXISTS rawfri.ab06_nfl1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_nfl1 AS
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
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1, nfl1, dst1', NULL, NULL, 'lyr1_nfl1_dst1') = 'DROP VIEW IF EXISTS rawfri.ab06_lyr1_nfl1_dst1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_nfl1_dst1 AS
SELECT sp1, sp2, sp3, nat_non, anth_veg, anth_non, nfl, mod1, mod1_yr, mod1_ext, mod2, mod2_yr, mod2_ext
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.5'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Wrong first argument test 1'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr', NULL, NULL, 'lyr') = 
       'ERROR TT_CreateFilterView(): ''selectAttrList'' parameter''s ''lyr'' attribute not found in table ''rawfri.ab06''...' passed
---------------------------------------------------------
UNION ALL
SELECT '16.6'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Wrong first argument test 2'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr, lyr1, nfl1, dst1', NULL, NULL, 'lyr1_nfl1_dst1') = 
       'ERROR TT_CreateFilterView(): ''selectAttrList'' parameter''s ''lyr'' attribute not found in table ''rawfri.ab06''...' passed
---------------------------------------------------------
UNION ALL
SELECT '16.7'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl1', NULL, 'lyr1_for_nfl1') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1 AS
SELECT sp1, sp2, sp3
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.8'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Wrong second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'lyr', NULL, 'lyr1_for_lyr') = 
       'ERROR TT_CreateFilterView(): ''whereInAttrList'' parameter''s ''lyr'' attribute not found in table ''rawfri.ab06''...' passed
---------------------------------------------------------
UNION ALL
SELECT '16.9'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl1, nfl2', NULL, 'lyr1_for_nfl1_nfl2') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_nfl2 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_nfl2 AS
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
SELECT '16.10'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''and'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl1, nfl2]', NULL, 'lyr1_for_nfl1_and_nfl2') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_and_nfl2 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_and_nfl2 AS
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
SELECT '16.11'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''or/and'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'dst1, [nfl1, nfl2]', NULL, 'lyr1_for_dst_or_nfl1_and_nfl2') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_dst_or_nfl1_and_nfl2 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_dst_or_nfl1_and_nfl2 AS
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
SELECT '16.12'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Complex ''and/or'' second argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', '[nfl1, nfl2], dst1', NULL, 'lyr1_for_nfl1_and_nfl2_or_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_and_nfl2_or_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_and_nfl2_or_dst AS
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
SELECT '16.13'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Simple third argument test'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1', 'nfl1, nfl2', 'dst1', 'lyr1_for_nfl1_or_nfl2_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_for_nfl1_or_nfl2_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_for_nfl1_or_nfl2_not_dst AS
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
SELECT '16.15'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test empty ''eco'' keywords'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'eco', 'nfl1, eco', NULL, 'eco_for_nfl1_or_eco') = 
       'DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl1_or_eco CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_eco_for_nfl1_or_eco AS
SELECT *
FROM rawfri.ab06
WHERE (TT_NotEmpty(nat_non::text) AND nat_non::text != ''0'') OR 
      (TT_NotEmpty(anth_veg::text) AND anth_veg::text != ''0'') OR 
      (TT_NotEmpty(anth_non::text) AND anth_non::text != ''0'') OR 
      (TT_NotEmpty(nfl::text) AND nfl::text != ''0'');' passed
---------------------------------------------------------
UNION ALL
SELECT '16.16'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test empty keywords in ''and'' second argument'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'eco', '[nfl1, eco]', 'dst2', 'eco_for_nfl1_and_eco_not_dst2') = 
       'DROP VIEW IF EXISTS rawfri.ab06_eco_for_nfl1_and_eco_not_dst2 CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_eco_for_nfl1_and_eco_not_dst2 AS
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
       'Test with some source attributes in each parameter'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'lyr1, wkb_geometry', '[nfl1, inventory_id, nfl2]', 'dst1, trm', 'extra_lyr1_for_nfl1_and_nfl2_not_dst') = 
       'DROP VIEW IF EXISTS rawfri.ab06_extra_lyr1_for_nfl1_and_nfl2_not_dst CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_extra_lyr1_for_nfl1_and_nfl2_not_dst AS
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
SELECT '16.18'::text number,
       'TT_CreateFilterView'::text function_tested,
       'All arguments NULL'::text description,
       TT_CreateFilterView('rawfri', 'ab06', NULL, NULL, NULL, 'null') = 
       'DROP VIEW IF EXISTS rawfri.ab06_null CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_null AS
SELECT *
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.19'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test one CASFRI attribute to be replaced by source attributes'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'CAS_ID', NULL, NULL, 'cas_id') = 
       'DROP VIEW IF EXISTS rawfri.ab06_cas_id CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_cas_id AS
SELECT inventory_id, src_filename, trm_1, poly_num, ogc_fid
FROM rawfri.ab06;' passed
---------------------------------------------------------
UNION ALL
SELECT '16.20'::text number,
       'TT_CreateFilterView'::text function_tested,
       'Test CASFRI attribute inside ''and'' braquets'::text description,
       TT_CreateFilterView('rawfri', 'ab06', 'cas_id', '[lyr1, cas_id]', 'nat_non_veg', 'lyr1_cas_id_nfl') = 
       'DROP VIEW IF EXISTS rawfri.ab06_lyr1_cas_id_nfl CASCADE;
CREATE OR REPLACE VIEW rawfri.ab06_lyr1_cas_id_nfl AS
SELECT inventory_id, src_filename, trm_1, poly_num, ogc_fid
FROM rawfri.ab06
WHERE (((TT_NotEmpty(sp1::text) AND sp1::text != ''0'') OR 
        (TT_NotEmpty(sp2::text) AND sp2::text != ''0'') OR 
        (TT_NotEmpty(sp3::text) AND sp3::text != ''0''))
       AND
        ((TT_NotEmpty(inventory_id::text) AND inventory_id::text != ''0'') OR 
        (TT_NotEmpty(src_filename::text) AND src_filename::text != ''0'') OR 
        (TT_NotEmpty(trm_1::text) AND trm_1::text != ''0'') OR 
        (TT_NotEmpty(poly_num::text) AND poly_num::text != ''0'') OR 
        (TT_NotEmpty(ogc_fid::text) AND ogc_fid::text != ''0''))
      )
      AND NOT
       ((TT_NotEmpty(nat_non::text) AND nat_non::text != ''0''));' passed
---------------------------------------------------------
UNION ALL
SELECT '16.21'::text number,
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
SELECT '16.22'::text number,
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
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

