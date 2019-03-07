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
    SELECT 'TT_CasId'::text function_tested, 1 maj_num, 4 nb_test
     


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
---------------------------------------------------------
-- Test 1 - TT_CasId
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_CasId'::text function_tested,
       'Test AB06'::text description,
       TT_CasId('ab06', 'GB_S21_TWP', '81145', '811451038', '1') = 'AB06-xxxxxGB_S21_TWP-xxxxx81145-0811451038-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_CasId'::text function_tested,
       'Test AB16'::text description,
       TT_CasId('ab16', 'CANFOR', 't059R04M6', '109851', '1') = 'AB16-xxxxxxxxxCANFOR-xT059R04M6-0000109851-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_CasId'::text function_tested,
       'Test NB01'::text description,
       TT_CasId('nb01', 'waterbody', '', '', '1') = 'NB01-xxxxxxWATERBODY-xxxxxxxxxx-0000000000-0000001' passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_CasId'::text function_tested,
       'Test BC08'::text description,
       TT_CasId('bc08', 'VEG_COMP_LYR_R1', '83D093', '2035902', '1') = 'BC08-VEG_COMP_LYR_R1-xxxx83D093-0002035902-0000001' passed
---------------------------------------------------------
              
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
--) foo WHERE NOT passed;

