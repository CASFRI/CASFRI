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

-- IsError(text)
-- function to test if helper functions return errors
CREATE OR REPLACE FUNCTION IsError(
  functionString text
)
RETURNS boolean AS $$
  DECLARE
    result boolean;
  BEGIN
    EXECUTE functionString INTO result;
    RETURN FALSE;
  EXCEPTION WHEN OTHERS THEN
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;

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
    SELECT 'TT_vri1_origin_validation'::text function_tested,        1 maj_num, 2 nb_test UNION ALL
    SELECT 'TT_vri1_site_class_validation'::text function_tested,    3 maj_num, 9 nb_test UNION ALL
    SELECT 'TT_vri1_origin_translation'::text function_tested,       4 maj_num, 1 nb_test UNION ALL
    SELECT 'TT_vri1_site_class_translation'::text function_tested,   5 maj_num, 2 nb_test
     


),
test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num, generate_series(1, nb_test)::text min_num
FROM test_nb
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of test for ' || 
                b.function_tested || ' in the initial table...') AS function_tested,
       description, 
       NOT passed IS NULL AND (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series AS a FULL OUTER JOIN (

---------------------------------------------------------
-- TT_vri1_origin_validation
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_vri1_origin_validation'::text function_tested,
       'Test that passes with a year value'::text description,
       TT_vri1_origin_validation('2001-02-02') passed
UNION ALL
SELECT '1.2'::text number,
       'TT_vri1_origin_validation'::text function_tested,
       'Test that fails with an incorrect year value'::text description,
       TT_vri1_origin_validation('200-02-02') IS FALSE passed
---------------------------------------------------------
-- 
---------------------------------------------------------
-- TT_vri1_site_class_validation
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'Both not null'::text description,
       TT_vri1_site_class_validation('12.1','10') passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'One null'::text description,
       TT_vri1_site_class_validation(NULL::text,'12.2') passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'One empty'::text description,
       TT_vri1_site_class_validation('1','') passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'Both null'::text description,
       TT_vri1_site_class_validation(NULL::text,NULL::text) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'Both empty'::text description,
       TT_vri1_site_class_validation('','') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'First val not between 0-99'::text description,
       TT_vri1_site_class_validation('123','22') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'Second val not between 0-99'::text description,
       TT_vri1_site_class_validation('','222') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'First val not numeric'::text description,
       TT_vri1_site_class_validation('12a','22') IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'TT_vri1_site_class_validation'::text function_tested,
       'Second val not numeric'::text description,
       TT_vri1_site_class_validation('','22a') IS FALSE passed
---------------------------------------------------------
-- TT_vri1_origin_translation
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_vri1_origin_translation'::text function_tested,
       'Good year and age'::text description,
       TT_vri1_origin_translation('2001-04-10','10') = 1991 passed
---------------------------------------------------------
-- TT_vri1_site_class_translation
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_vri1_site_class_translation'::text function_tested,
       'site_index present'::text description,
       TT_vri1_site_class_translation('12.1','10') = 12.1::double precision passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_vri1_site_class_translation'::text function_tested,
       'site_index null'::text description,
       TT_vri1_site_class_translation(NULL::text,'10') = 10::double precision passed
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

