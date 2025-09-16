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
-- DROP FUNCTION IF EXISTS TT_CountAndDiff(name, int);
CREATE OR REPLACE FUNCTION TT_CountAndDiff(
  tName name,
  expectedCount int
)
RETURNS TABLE(tableName text, expected int, counted int, passed boolean, diff text)
AS $$
  DECLARE
    queryStr text;
BEGIN
  RETURN QUERY SELECT 
    upper(tName) tableName, 
    expectedCount expected,
    TT_Count('rawfri', lower(tName)) counted,
    TT_Count('rawfri', lower(tName)) = expectedCount passed,
    CASE WHEN TT_Count('rawfri', lower(tName)) = 0 THEN 'absent'
         ELSE (TT_Count('rawfri', lower(tName)) - expectedCount)::text
    END diff;
END;
$$ LANGUAGE plpgsql;

--SELECT (TT_CountAndDiff('AB03', 3456)).*
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
    SELECT 'AB'::text juridiction,  1 maj_num, 19 nb_test UNION ALL
    SELECT 'BC'::text juridiction,  2 maj_num,  6 nb_test UNION ALL
    SELECT 'MB'::text juridiction,  3 maj_num,  7 nb_test UNION ALL
    SELECT 'NB'::text juridiction,  4 maj_num,  2 nb_test UNION ALL
    SELECT 'NL'::text juridiction,  5 maj_num,  4 nb_test UNION ALL
    SELECT 'NS'::text juridiction,  6 maj_num,  3 nb_test UNION ALL
    SELECT 'NT'::text juridiction,  7 maj_num,  2 nb_test UNION ALL
    SELECT 'ON'::text juridiction,  8 maj_num,  2 nb_test UNION ALL
    SELECT 'PC'::text juridiction,  9 maj_num,  2 nb_test UNION ALL
    SELECT 'PE'::text juridiction, 10 maj_num,  4 nb_test UNION ALL
    SELECT 'QC'::text juridiction, 11 maj_num,  7 nb_test UNION ALL
    SELECT 'SK'::text juridiction, 12 maj_num,  6 nb_test UNION ALL
    SELECT 'YT'::text juridiction, 13 maj_num,  3 nb_test UNION ALL
    SELECT 'DS'::text juridiction, 14 maj_num,  5 nb_test
), test_series AS (
-- Build a table of function names with a sequence of number for each function to be tested
SELECT maj_num::text, juridiction, nb_test, generate_series(1, nb_test)::text min_num
FROM test_nb
ORDER BY maj_num, min_num
)
SELECT coalesce(maj_num || '.' || min_num, b.number) AS number,
       coalesce(a.juridiction, 'ERROR: Insufficient number of tests for ' || 
                b.juridiction || ' in the initial table...') AS juridiction,
       coalesce(tableName, 'ERROR: Too many tests (' || nb_test || ') for ' || a.juridiction || ' in the initial table...') description,
       expected,
       counted,
       NOT passed IS NULL AND 
          (regexp_split_to_array(number, '\.'))[1] = maj_num AND 
          (regexp_split_to_array(number, '\.'))[2] = min_num AND passed passed,
       diff
FROM test_series AS a FULL OUTER JOIN (
---------------------------------------------------------
  WITH tests AS (
    SELECT *
    FROM (VALUES
      ('1.1', 'AB', 'ab_photoyear', 560),
      ('1.2', 'AB', 'ab03', 61633),
      ('1.3', 'AB', 'ab06', 11484),
      ('1.4', 'AB', 'ab07', 23268),
      ('1.5', 'AB', 'ab08', 34474),
      ('1.6', 'AB', 'ab10', 194696),
      ('1.7', 'AB', 'ab11', 118624),
      ('1.8', 'AB', 'ab16', 120476),
      ('1.9', 'AB', 'ab21', 338501),
      ('1.10', 'AB', 'ab24', 144881),
      ('1.11', 'AB', 'ab25', 527038),
      ('1.12', 'AB', 'ab27', 32070),
      ('1.13', 'AB', 'ab29', 620944),
      ('1.14', 'AB', 'ab30', 4555),
      ('1.15', 'AB', 'ab_alpac_photoyear', 1595),
      ('1.16', 'AB', 'ab31', 802933),
      ('1.17', 'AB', 'ab_alpac_updated_photoyear', 767),
      ('1.18', 'AB', 'ab32', 834245),
      ('1.19', 'AB', 'ab34', 3631),
      ('2.1', 'BC', 'bc04', 4431314),
      ('2.2', 'BC', 'bc08', 4677411),
      ('2.3', 'BC', 'bc10', 5151772),
      ('2.4', 'BC', 'bc11', 5419596),
      ('2.5', 'BC', 'bc12', 4861240),
      ('2.6', 'BC', 'bc13', 3343257),
      ('3.1', 'MB', 'mb01', 134790),
      ('3.2', 'MB', 'mb02', 60370),
      ('3.3', 'MB', 'mb04', 27221),
      ('3.4', 'MB', 'mb05', 1644808),
      ('3.5', 'MB', 'mb06', 163064),
      ('3.6', 'MB', 'mb07', 219682),
      ('3.7', 'MB', 'mb08', 101508),
      ('4.1', 'NB', 'nb01', 927177),
      ('4.2', 'NB', 'nb02', 1123893),
      ('5.1', 'NL', 'nl_photoyear', 8083),
      ('5.2', 'NL', 'nl01', 1863664),
      ('5.3', 'NL', 'nl02_photoyear', 64),
      ('5.4', 'NL', 'nl02', 2612451),
      ('6.1', 'NS', 'ns01', 1127926),
      ('6.2', 'NS', 'ns02', 1090671),
      ('6.3', 'NS', 'ns03', 995886),
      ('7.1', 'NT', 'nt01', 281388),
      ('7.2', 'NT', 'nt03', 320526),
      ('8.1', 'ON', 'on01', 4106417),
      ('8.2', 'ON', 'on02', 3629072),
      ('9.1', 'PC', 'pc01', 8094),
      ('9.2', 'PC', 'pc02', 1053),
      ('10.1', 'PE', 'pe01', 107220),
      ('10.2', 'PE', 'pe02', 174944),
      ('10.3', 'PE', 'pe03', 188020),
      ('10.4', 'PE', 'pe04', 175592),
      ('11.1', 'QC', 'qc01', 5563194),
      ('11.2', 'QC', 'qc02', 2876326),
      ('11.3', 'QC', 'qc03', 401188),
      ('11.4', 'QC', 'qc04', 2487519),
      ('11.5', 'QC', 'qc05', 6768074),
      ('11.6', 'QC', 'qc06', 4809274),
      ('11.7', 'QC', 'qc07', 85057),
      ('12.1', 'SK', 'sk01', 1501667),
      ('12.2', 'SK', 'sk02', 27312),
      ('12.3', 'SK', 'sk03', 8964),
      ('12.4', 'SK', 'sk04', 633522),
      ('12.5', 'SK', 'sk05', 421977),
      ('12.6', 'SK', 'sk06', 211482),
      ('13.1', 'YT', 'yt01', 249636),
      ('13.2', 'YT', 'yt02', 231137),
      ('13.3', 'YT', 'yt03', 71073),
      ('14.1', 'DS', 'ds01', 59539),
      ('14.2', 'DS', 'ds02', 15358919),
      ('14.3', 'DS', 'ds03', 27593270),
      ('14.4', 'DS', 'ds04', 206849),
      ('14.5', 'DS', 'ds05', 13188798)
    ) AS t(number, juridiction, fri, ecnt)
   )
   SELECT number, juridiction, (TT_CountAndDiff(fri, ecnt)).*
   FROM tests
) AS b 
ON ((regexp_split_to_array(number, '\.'))[1] = maj_num AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo --WHERE NOT passed;


-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.2'::text number,
--        'Check count'::text function_tested,
--        'AB03'::text description,
--        TT_Count('rawfri', 'ab03') = 61633 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.3'::text number,
--        'Check count'::text function_tested,
--        'AB06'::text description,
--        TT_Count('rawfri', 'ab06') = 11484 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.4'::text number,
--        'Check count'::text function_tested,
--        'AB07'::text description,
--        TT_Count('rawfri', 'ab07') = 23268 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.5'::text number,
--        'Check count'::text function_tested,
--        'AB08'::text description,
--        TT_Count('rawfri', 'ab08') = 34474 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.6'::text number,
--        'Check count'::text function_tested,
--        'AB10'::text description,
--        TT_Count('rawfri', 'ab10') = 194696 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.7'::text number,
--        'Check count'::text function_tested,
--        'AB11'::text description,
--        TT_Count('rawfri', 'ab11') = 118624 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.8'::text number,
--        'Check count'::text function_tested,
--        'AB16'::text description,
--        TT_Count('rawfri', 'ab16') = 120476 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.9'::text number,
--        'Check count'::text function_tested,
--        'AB21'::text description,
--        TT_Count('rawfri', 'ab21') = 338501 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.10'::text number,
--        'Check count'::text function_tested,
--        'AB24'::text description,
--        TT_Count('rawfri', 'ab24') = 144881 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.11'::text number,
--        'Check count'::text function_tested,
--        'AB25'::text description,
--        TT_Count('rawfri', 'ab25') = 527038 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.12'::text number,
--        'Check count'::text function_tested,
--        'AB27'::text description,
--        TT_Count('rawfri', 'ab27') = 32070 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.13'::text number,
--        'Check count'::text function_tested,
--        'AB29'::text description,
--        TT_Count('rawfri', 'ab29') = 620944 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.14'::text number,
--        'Check count'::text function_tested,
--        'AB30'::text description,
--        TT_Count('rawfri', 'ab30') = 4555 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.15'::text number,
--        'Check count'::text function_tested,
--        'AB31'::text description,
--        TT_Count('rawfri', 'ab31') = 802933 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '1.16'::text number,
--        'Check count'::text function_tested,
--        'AB32'::text description,
--        TT_Count('rawfri', 'ab32') = 834245 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '2.1'::text number,
--        'Check count'::text function_tested,
--        'BC04'::text description,
--        TT_Count('rawfri', 'bc04') = 4431314 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '2.2'::text number,
--        'Check count'::text function_tested,
--        'BC08'::text description,
--        TT_Count('rawfri', 'bc08') = 4677411 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '2.3'::text number,
--        'Check count'::text function_tested,
--        'BC10'::text description,
--        TT_Count('rawfri', 'bc10') = 5151772 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '2.4'::text number,
--        'Check count'::text function_tested,
--        'BC11'::text description,
--        TT_Count('rawfri', 'bc11') = 5419596 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '2.5'::text number,
--        'Check count'::text function_tested,
--        'BC12'::text description,
--        TT_Count('rawfri', 'bc12') = 4861240 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '2.6'::text number,
--        'Check count'::text function_tested,
--        'BC13'::text description,
--        TT_Count('rawfri', 'bc13') = 3343257 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '3.1'::text number,
--        'Check count'::text function_tested,
--        'MB01'::text description,
--        TT_Count('rawfri', 'mb01') = 134790 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '3.2'::text number,
--        'Check count'::text function_tested,
--        'MB02'::text description,
--        TT_Count('rawfri', 'mb02') = 60370 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '3.3'::text number,
--        'Check count'::text function_tested,
--        'MB04'::text description,
--        TT_Count('rawfri', 'mb04') = 27221 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '3.4'::text number,
--        'Check count'::text function_tested,
--        'MB05'::text description,
--        TT_Count('rawfri', 'mb05') = 1644808 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '3.5'::text number,
--        'Check count'::text function_tested,
--        'MB06'::text description,
--        TT_Count('rawfri', 'mb06') = 163064 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '3.6'::text number,
--        'Check count'::text function_tested,
--        'MB07'::text description,
--        TT_Count('rawfri', 'mb07') = 219682 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '4.1'::text number,
--        'Check count'::text function_tested,
--        'NB01'::text description,
--        TT_Count('rawfri', 'nb01') = 927177 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '4.2'::text number,
--        'Check count'::text function_tested,
--        'NB02'::text description,
--        TT_Count('rawfri', 'nb02') = 1123893 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '5.1'::text number,
--        'Check count'::text function_tested,
--        'nl_photoyear'::text description,
--        TT_Count('rawfri', 'nl_photoyear') = 8083 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '5.2'::text number,
--        'Check count'::text function_tested,
--        'NL01'::text description,
--        TT_Count('rawfri', 'nl01') = 1863664 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '6.1'::text number,
--        'Check count'::text function_tested,
--        'NS01'::text description,
--        TT_Count('rawfri', 'ns01') = 1127926 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '6.2'::text number,
--        'Check count'::text function_tested,
--        'NS02'::text description,
--        TT_Count('rawfri', 'ns02') = 1090671 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '6.3'::text number,
--        'Check count'::text function_tested,
--        'NS03'::text description,
--        TT_Count('rawfri', 'ns03') = 995886 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '7.1'::text number,
--        'Check count'::text function_tested,
--        'NT01'::text description,
--        TT_Count('rawfri', 'nt01') = 281388 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '7.2'::text number,
--        'Check count'::text function_tested,
--        'NT03'::text description,
--        TT_Count('rawfri', 'nt03') = 320526 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '8.1'::text number,
--        'Check count'::text function_tested,
--        'ON01'::text description,
--        TT_Count('rawfri', 'on01') = 4106417 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '8.2'::text number,
--        'Check count'::text function_tested,
--        'ON02'::text description,
--        TT_Count('rawfri', 'on02') = 3629072 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '9.1'::text number,
--        'Check count'::text function_tested,
--        'PC01'::text description,
--        TT_Count('rawfri', 'pc01') = 8094 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '9.2'::text number,
--        'Check count'::text function_tested,
--        'PC02'::text description,
--        TT_Count('rawfri', 'pc02') = 1053 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '10.1'::text number,
--        'Check count'::text function_tested,
--        'PE01'::text description,
--        TT_Count('rawfri', 'pe01') = 107220 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.1'::text number,
--        'Check count'::text function_tested,
--        'QC01'::text description,
--        TT_Count('rawfri', 'qc01') = 5563194 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.2'::text number,
--        'Check count'::text function_tested,
--        'QC02'::text description,
--        TT_Count('rawfri', 'qc02') = 2876326 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.3'::text number,
--        'Check count'::text function_tested,
--        'QC03'::text description,
--        TT_Count('rawfri', 'qc03') = 401188 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.4'::text number,
--        'Check count'::text function_tested,
--        'QC04'::text description,
--        TT_Count('rawfri', 'qc04') = 2487519 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.5'::text number,
--        'Check count'::text function_tested,
--        'QC05'::text description,
--        TT_Count('rawfri', 'qc05') = 6768074 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.6'::text number,
--        'Check count'::text function_tested,
--        'QC06'::text description,
--        TT_Count('rawfri', 'qc06') = 4809274 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '11.7'::text number,
--        'Check count'::text function_tested,
--        'QC07'::text description,
--        TT_Count('rawfri', 'qc07') = 85057 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '12.1'::text number,
--        'Check count'::text function_tested,
--        'SK01'::text description,
--        TT_Count('rawfri', 'sk01') = 1501667 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '12.2'::text number,
--        'Check count'::text function_tested,
--        'SK02'::text description,
--        TT_Count('rawfri', 'sk02') = 27312 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '12.3'::text number,
--        'Check count'::text function_tested,
--        'SK03'::text description,
--        TT_Count('rawfri', 'sk03') = 8964 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '12.4'::text number,
--        'Check count'::text function_tested,
--        'SK04'::text description,
--        TT_Count('rawfri', 'sk04') = 633522 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '12.5'::text number,
--        'Check count'::text function_tested,
--        'SK05'::text description,
--        TT_Count('rawfri', 'sk05') = 421977 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '12.6'::text number,
--        'Check count'::text function_tested,
--        'SK06'::text description,
--        TT_Count('rawfri', 'sk06') = 211482 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '13.1'::text number,
--        'Check count'::text function_tested,
--        'YT01'::text description,
--        TT_Count('rawfri', 'yt01') = 249636 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '13.2'::text number,
--        'Check count'::text function_tested,
--        'YT02'::text description,
--        TT_Count('rawfri', 'yt02') = 231137 passed,
--        CASE WHEN TT_Count('rawfri', 'yt02') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'yt02')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '13.3'::text number,
--        'Check count'::text function_tested,
--        'YT03'::text description,
--        TT_Count('rawfri', 'yt03') = 71073 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '14.1'::text number,
--        'Check count'::text function_tested,
--        'DS01'::text description,
--        TT_Count('rawfri', 'ds01') = 59539 passed,
--        CASE WHEN TT_Count('rawfri', 'ab21') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ab21')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '14.2'::text number,
--        'Check count'::text function_tested,
--        'DS02'::text description,
--        TT_Count('rawfri', 'ds02') = 15358919 passed,
--        CASE WHEN TT_Count('rawfri', 'ds02') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ds02')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '14.3'::text number,
--        'Check count'::text function_tested,
--        'DS03'::text description,
--        TT_Count('rawfri', 'ds03') = 27593270 passed,
--        CASE WHEN TT_Count('rawfri', 'ds03') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ds03')
--        END AS comment
-- ---------------------------------------------------------
-- UNION ALL
-- SELECT '14.4'::text number,
--        'Check count'::text function_tested,
--        'DS04'::text description,
--        TT_Count('rawfri', 'ds04') = 206849 passed,
--        CASE WHEN TT_Count('rawfri', 'ds04') = 0 THEN 0
--             ELSE TT_Count('rawfri', 'ds04')
--        END AS comment
---------------------------------------------------------
