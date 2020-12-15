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
------------------------------------------------------------------------------
-- Comment out the following line and the last one of the file to display 
-- only failing tests
SELECT * FROM (
-----------------------------------------------------------
-- The first table in the next WITH statement list all the function tested
-- with the number of test for each. It must be adjusted for every new test.
-- It is required to list tests which would not appear because they failed
-- by returning nothing.
WITH test_nb AS (
    SELECT 'Check count'::text function_tested,  1 maj_num, 29 nb_test

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
SELECT '1.1'::text number,
       'Check count'::text function_tested,
       'ab_photoyear'::text description,
       count(*) = 901 passed
FROM rawfri.ab_photoyear
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'Check count'::text function_tested,
       'AB06'::text description,
       count(*) = 11484 passed
FROM rawfri.ab06
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'Check count'::text function_tested,
       'AB16'::text description,
       count(*) = 120476 passed
FROM rawfri.ab16
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'Check count'::text function_tested,
       'BC08'::text description,
       count(*) = 4677411 passed
FROM rawfri.bc08
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'Check count'::text function_tested,
       'BC10'::text description,
       count(*) = 5151772 passed
FROM rawfri.bc10
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'Check count'::text function_tested,
       'MB05'::text description,
       count(*) = 1644808 passed
FROM rawfri.mb05
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'Check count'::text function_tested,
       'MB06'::text description,
       count(*) = 163064 passed
FROM rawfri.mb06
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'Check count'::text function_tested,
       'NB01'::text description,
       count(*) = 927177 passed
FROM rawfri.nb01
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'Check count'::text function_tested,
       'NB02'::text description,
       count(*) = 1123893 passed
FROM rawfri.nb02
---------------------------------------------------------
UNION ALL
SELECT '1.10'::text number,
       'Check count'::text function_tested,
       'nl_photoyear'::text description,
       count(*) = 8083 passed
FROM rawfri.nl_photoyear
---------------------------------------------------------
UNION ALL
SELECT '1.11'::text number,
       'Check count'::text function_tested,
       'NL01'::text description,
       count(*) = 1863664 passed
FROM rawfri.nl01
---------------------------------------------------------
UNION ALL
SELECT '1.12'::text number,
       'Check count'::text function_tested,
       'NS03'::text description,
       count(*) = 995886 passed
FROM rawfri.ns03
---------------------------------------------------------
UNION ALL
SELECT '1.13'::text number,
       'Check count'::text function_tested,
       'NT01'::text description,
       count(*) = 281388 passed
FROM rawfri.nt01
---------------------------------------------------------
UNION ALL
SELECT '1.14'::text number,
       'Check count'::text function_tested,
       'NT02'::text description,
       count(*) = 320944 passed
FROM rawfri.nt02
---------------------------------------------------------
UNION ALL
SELECT '1.15'::text number,
       'Check count'::text function_tested,
       'ON02'::text description,
       count(*) = 3629072 passed
FROM rawfri.on02
---------------------------------------------------------
UNION ALL
SELECT '1.16'::text number,
       'Check count'::text function_tested,
       'PC02'::text description,
       count(*) = 1053 passed
FROM rawfri.pc02
---------------------------------------------------------
UNION ALL
SELECT '1.17'::text number,
       'Check count'::text function_tested,
       'PE01'::text description,
       count(*) = 107220 passed
FROM rawfri.pe01
---------------------------------------------------------
UNION ALL
SELECT '1.18'::text number,
       'Check count'::text function_tested,
       'QC01'::text description,
       count(*) = 5886005 passed
FROM rawfri.qc01
---------------------------------------------------------
UNION ALL
SELECT '1.19'::text number,
       'Check count'::text function_tested,
       'QC02'::text description,
       count(*) = 6581710 passed
FROM rawfri.qc02
---------------------------------------------------------
UNION ALL
SELECT '1.20'::text number,
       'Check count'::text function_tested,
       'QC03'::text description,
       count(*) = 401188 passed
FROM rawfri.qc03
---------------------------------------------------------
UNION ALL
SELECT '1.21'::text number,
       'Check count'::text function_tested,
       'QC04'::text description,
       count(*) = 2487519 passed
FROM rawfri.qc04
---------------------------------------------------------
UNION ALL
SELECT '1.22'::text number,
       'Check count'::text function_tested,
       'QC05'::text description,
       count(*) = 6768074 passed
FROM rawfri.qc05
---------------------------------------------------------
UNION ALL
SELECT '1.23'::text number,
       'Check count'::text function_tested,
       'SK01'::text description,
       count(*) = 1501667 passed
FROM rawfri.sk01
---------------------------------------------------------
UNION ALL
SELECT '1.24'::text number,
       'Check count'::text function_tested,
       'SK02'::text description,
       count(*) = 27312 passed
FROM rawfri.sk02
---------------------------------------------------------
UNION ALL
SELECT '1.25'::text number,
       'Check count'::text function_tested,
       'SK03'::text description,
       count(*) = 8964 passed
FROM rawfri.sk03
---------------------------------------------------------
UNION ALL
SELECT '1.26'::text number,
       'Check count'::text function_tested,
       'SK04'::text description,
       count(*) = 633522 passed
FROM rawfri.sk04
---------------------------------------------------------
UNION ALL
SELECT '1.27'::text number,
       'Check count'::text function_tested,
       'SK05'::text description,
       count(*) = 421977 passed
FROM rawfri.sk05
---------------------------------------------------------
UNION ALL
SELECT '1.28'::text number,
       'Check count'::text function_tested,
       'SK06'::text description,
       count(*) = 211482 passed
FROM rawfri.sk06
---------------------------------------------------------
UNION ALL
SELECT '1.29'::text number,
       'Check count'::text function_tested,
       'YT02'::text description,
       count(*) = 231137 passed
FROM rawfri.yt02
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed;

