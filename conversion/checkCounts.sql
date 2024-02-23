------------------------------------------------------------------------------
-- CASFRI - Check counts script
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
-------------------------------------------------------------------------------
SET lc_messages TO 'en_US.UTF-8';
------------------------------------------------------------------------------
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
    SELECT 'Check count'::text function_tested,  1 maj_num, 11 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  2 maj_num,  4 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  3 maj_num,  6 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  4 maj_num,  2 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  5 maj_num,  2 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  6 maj_num,  3 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  7 maj_num,  2 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  8 maj_num,  2 nb_test UNION ALL
    SELECT 'Check count'::text function_tested,  9 maj_num,  2 nb_test UNION ALL
    SELECT 'Check count'::text function_tested, 10 maj_num,  1 nb_test UNION ALL
    SELECT 'Check count'::text function_tested, 11 maj_num,  7 nb_test UNION ALL
    SELECT 'Check count'::text function_tested, 12 maj_num,  6 nb_test UNION ALL
    SELECT 'Check count'::text function_tested, 13 maj_num,  3 nb_test UNION ALL
    SELECT 'Check count'::text function_tested, 14 maj_num,  4 nb_test
), test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT function_tested, maj_num::text, nb_test, generate_series(1, nb_test)::text min_num
FROM test_nb
ORDER BY maj_num, min_num
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,
       coalesce(a.function_tested, 'ERROR: Insufficient number of tests for ' || 
                b.function_tested || ' in the initial table...') AS function_tested,
       coalesce(description, 'ERROR: Too many tests (' || nb_test || ') for ' || a.function_tested || ' in the initial table...') description, 
       NOT passed IS NULL AND 
          (regexp_split_to_array(number, '\.'))[1] = maj_num AND 
          (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed
FROM test_series AS a FULL OUTER JOIN (
---------------------------------------------------------
SELECT '1.1'::text number,
       'Check count'::text function_tested,
       'ab_photoyear'::text description,
       TT_Count('rawfri', 'ab_photoyear') = 560 passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'Check count'::text function_tested,
       'AB03'::text description,
       TT_Count('rawfri', 'ab03') = 61633 passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'Check count'::text function_tested,
       'AB06'::text description,
       TT_Count('rawfri', 'ab06') = 11484 passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'Check count'::text function_tested,
       'AB07'::text description,
       TT_Count('rawfri', 'ab07') = 23268 passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'Check count'::text function_tested,
       'AB08'::text description,
       TT_Count('rawfri', 'ab08') = 34474 passed
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'Check count'::text function_tested,
       'AB10'::text description,
       TT_Count('rawfri', 'ab10') = 194696 passed
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'Check count'::text function_tested,
       'AB11'::text description,
       TT_Count('rawfri', 'ab11') = 118624 passed
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'Check count'::text function_tested,
       'AB16'::text description,
       TT_Count('rawfri', 'ab16') = 120476 passed
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'Check count'::text function_tested,
       'AB25'::text description,
       TT_Count('rawfri', 'ab25') = 527038 passed
---------------------------------------------------------
UNION ALL
SELECT '1.10'::text number,
       'Check count'::text function_tested,
       'AB29'::text description,
       TT_Count('rawfri', 'ab29') = 620944 passed
---------------------------------------------------------
UNION ALL
SELECT '1.11'::text number,
       'Check count'::text function_tested,
       'AB30'::text description,
       TT_Count('rawfri', 'ab30') = 4555 passed
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'Check count'::text function_tested,
       'BC08'::text description,
       TT_Count('rawfri', 'bc08') = 4677411 passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'Check count'::text function_tested,
       'BC10'::text description,
       TT_Count('rawfri', 'bc10') = 5151772 passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'Check count'::text function_tested,
       'BC11'::text description,
       TT_Count('rawfri', 'bc11') = 5419596 passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'Check count'::text function_tested,
       'BC12'::text description,
       TT_Count('rawfri', 'bc12') = 4861240 passed
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'Check count'::text function_tested,
       'MB01'::text description,
       TT_Count('rawfri', 'mb01') = 134790 passed
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'Check count'::text function_tested,
       'MB02'::text description,
       TT_Count('rawfri', 'mb02') = 60370 passed
---------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'Check count'::text function_tested,
       'MB04'::text description,
       TT_Count('rawfri', 'mb04') = 27221 passed
---------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'Check count'::text function_tested,
       'MB05'::text description,
       TT_Count('rawfri', 'mb05') = 1644808 passed
---------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'Check count'::text function_tested,
       'MB06'::text description,
       TT_Count('rawfri', 'mb06') = 163064 passed
---------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'Check count'::text function_tested,
       'MB07'::text description,
       TT_Count('rawfri', 'mb07') = 219682 passed
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'Check count'::text function_tested,
       'NB01'::text description,
       TT_Count('rawfri', 'nb01') = 927177 passed
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'Check count'::text function_tested,
       'NB02'::text description,
       TT_Count('rawfri', 'nb02') = 1123893 passed
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'Check count'::text function_tested,
       'nl_photoyear'::text description,
       TT_Count('rawfri', 'nl_photoyear') = 8083 passed
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'Check count'::text function_tested,
       'NL01'::text description,
       TT_Count('rawfri', 'nl01') = 1863664 passed
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'Check count'::text function_tested,
       'NS01'::text description,
       TT_Count('rawfri', 'ns01') = 1127926 passed
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'Check count'::text function_tested,
       'NS02'::text description,
       TT_Count('rawfri', 'ns02') = 1090671 passed
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'Check count'::text function_tested,
       'NS03'::text description,
       TT_Count('rawfri', 'ns03') = 995886 passed
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'Check count'::text function_tested,
       'NT01'::text description,
       TT_Count('rawfri', 'nt01') = 281388 passed
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'Check count'::text function_tested,
       'NT03'::text description,
       TT_Count('rawfri', 'nt03') = 320523 passed
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'Check count'::text function_tested,
       'ON01'::text description,
       TT_Count('rawfri', 'on01') = 4106417 passed
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'Check count'::text function_tested,
       'ON02'::text description,
       TT_Count('rawfri', 'on02') = 3629073 passed
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'Check count'::text function_tested,
       'PC01'::text description,
       TT_Count('rawfri', 'pc01') = 8094 passed
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'Check count'::text function_tested,
       'PC02'::text description,
       TT_Count('rawfri', 'pc02') = 1053 passed
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'Check count'::text function_tested,
       'PE01'::text description,
       TT_Count('rawfri', 'pe01') = 107220 passed
---------------------------------------------------------
UNION ALL
SELECT '11.1'::text number,
       'Check count'::text function_tested,
       'QC01'::text description,
       TT_Count('rawfri', 'qc01') = 5563194 passed
---------------------------------------------------------
UNION ALL
SELECT '11.2'::text number,
       'Check count'::text function_tested,
       'QC02'::text description,
       TT_Count('rawfri', 'qc02') = 2876326 passed
---------------------------------------------------------
UNION ALL
SELECT '11.3'::text number,
       'Check count'::text function_tested,
       'QC03'::text description,
       TT_Count('rawfri', 'qc03') = 401188 passed
---------------------------------------------------------
UNION ALL
SELECT '11.4'::text number,
       'Check count'::text function_tested,
       'QC04'::text description,
       TT_Count('rawfri', 'qc04') = 2487519 passed
---------------------------------------------------------
UNION ALL
SELECT '11.5'::text number,
       'Check count'::text function_tested,
       'QC05'::text description,
       TT_Count('rawfri', 'qc05') = 6768074 passed
---------------------------------------------------------
UNION ALL
SELECT '11.6'::text number,
       'Check count'::text function_tested,
       'QC06'::text description,
       TT_Count('rawfri', 'qc06') = 4809274 passed
---------------------------------------------------------
UNION ALL
SELECT '11.7'::text number,
       'Check count'::text function_tested,
       'QC07'::text description,
       TT_Count('rawfri', 'qc07') = 85057 passed
---------------------------------------------------------
UNION ALL
SELECT '12.1'::text number,
       'Check count'::text function_tested,
       'SK01'::text description,
       TT_Count('rawfri', 'sk01') = 1501667 passed
---------------------------------------------------------
UNION ALL
SELECT '12.2'::text number,
       'Check count'::text function_tested,
       'SK02'::text description,
       TT_Count('rawfri', 'sk02') = 27312 passed
---------------------------------------------------------
UNION ALL
SELECT '12.3'::text number,
       'Check count'::text function_tested,
       'SK03'::text description,
       TT_Count('rawfri', 'sk03') = 8964 passed
---------------------------------------------------------
UNION ALL
SELECT '12.4'::text number,
       'Check count'::text function_tested,
       'SK04'::text description,
       TT_Count('rawfri', 'sk04') = 633522 passed
---------------------------------------------------------
UNION ALL
SELECT '12.5'::text number,
       'Check count'::text function_tested,
       'SK05'::text description,
       TT_Count('rawfri', 'sk05') = 421977 passed
---------------------------------------------------------
UNION ALL
SELECT '12.6'::text number,
       'Check count'::text function_tested,
       'SK06'::text description,
       TT_Count('rawfri', 'sk06') = 211482 passed
---------------------------------------------------------
UNION ALL
SELECT '13.1'::text number,
       'Check count'::text function_tested,
       'YT01'::text description,
       TT_Count('rawfri', 'yt01') = 249636 passed
---------------------------------------------------------
UNION ALL
SELECT '13.2'::text number,
       'Check count'::text function_tested,
       'YT02'::text description,
       TT_Count('rawfri', 'yt02') = 231137 passed
---------------------------------------------------------
UNION ALL
SELECT '13.3'::text number,
       'Check count'::text function_tested,
       'YT03'::text description,
       TT_Count('rawfri', 'yt03') = 71073 passed
---------------------------------------------------------
UNION ALL
SELECT '14.1'::text number,
       'Check count'::text function_tested,
       'DS01'::text description,
       TT_Count('rawfri', 'ds01') = 59539 passed
---------------------------------------------------------
UNION ALL
SELECT '14.2'::text number,
       'Check count'::text function_tested,
       'DS02'::text description,
       TT_Count('rawfri', 'ds02') = 15358919 passed
---------------------------------------------------------
UNION ALL
SELECT '14.3'::text number,
       'Check count'::text function_tested,
       'DS03'::text description,
       TT_Count('rawfri', 'ds03') = 27593270 passed
---------------------------------------------------------
UNION ALL
SELECT '14.4'::text number,
       'Check count'::text function_tested,
       'DS04'::text description,
       TT_Count('rawfri', 'ds04') = 206849 passed
---------------------------------------------------------
) AS b 
ON ((regexp_split_to_array(number, '\.'))[1] = maj_num AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo --WHERE NOT passed;

