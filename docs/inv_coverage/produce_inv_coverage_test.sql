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
CREATE SCHEMA IF NOT EXISTS casfri50_coverage;
-----------------------------------------------------------
-- Create a 3x3 grid of polygons to test TT_IsSurrounded()
DROP TABLE IF EXISTS casfri50_coverage.test3x3;
CREATE TABLE casfri50_coverage.test3x3 AS
SELECT generate_series(1, 9) id, 
       (ST_PixelAsPolygons(ST_AddBand(ST_MakeEmptyRaster(3, 3, 0, 0, 1.0), '8BSI'::text, 1, 0), 1, FALSE)).geom;

CREATE INDEX test3x3_geom_idx ON casfri50_coverage.test3x3 USING gist(geom);

SELECT * FROM casfri50_coverage.test3x3;
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
    SELECT 'TT_RemoveHoles'::text function_tested,  1 maj_num,  9 nb_test UNION ALL
    SELECT 'TT_IsSurrounded'::text function_tested, 2 maj_num, 12 nb_test
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
-- TT_RemoveHoles
---------------------------------------------------------
SELECT '1.1'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Test for NULL'::text description,
       TT_RemoveHoles(NULL) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Empty geometry'::text description,
       ST_IsEmpty(TT_RemoveHoles(ST_GeomFromText('MULTIPOLYGON EMPTY'))) passed
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with no holes'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))')) = 
                      ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with no holes'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))'), 2) = 
                      ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with a SRID'::text description,
       ST_SRID(TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))', 4269))) = 4269 passed
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with two holes'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), 
                                               (1 1, 1 2, 2 2, 2 1, 1 1), 
                                               (2 2, 2 3, 3 3, 3 2, 2 2))')) = 
                      ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with two holes smaller than provided area'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), 
                                               (1 1, 1 2, 2 2, 2 1, 1 1), 
                                               (2 2, 2 3, 3 3, 3 2, 2 2))'), 2) = 
                      ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with two holes bigger than provided area'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), 
                                               (1 1, 1 2, 2 2, 2 1, 1 1), 
                                               (2 2, 2 3, 3 3, 3 2, 2 2))'), 0.5) = 
                      ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0), 
                                               (1 1, 2 1, 2 2, 1 2, 1 1), 
                                               (2 2, 3 2, 3 3, 2 3, 2 2))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with two holes, one bigger than provided area'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), 
                                               (1 1, 1 2, 2 2, 2 1, 1 1), 
                                               (2 2, 2 3.5, 3.5 3.5, 3.5 2, 2 2))'), 1.1) = 
                      ST_GeomFromText('POLYGON((0 0, 0 4, 4 4, 4 0, 0 0), 
                                               (2 2, 3.5 2, 3.5 3.5, 2 3.5, 2 2))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.10'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with a hole and an island'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0), 
                                               (1 1, 1 4, 4 4, 4 1, 1 1), 
                                               (2 2, 2 3, 3 3, 3 2, 2 2))')) = 
                      ST_GeomFromText('POLYGON((0 0, 0 5, 5 5, 5 0, 0 0))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.11'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Simple polygon with a hole and an island'::text description,
       TT_RemoveHoles(ST_GeomFromText('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0), 
                                               (1 1, 1 4, 4 4, 4 1, 1 1), 
                                               (2 2, 2 3, 3 3, 3 2, 2 2))'), 0.5) = 
                      ST_GeomFromText('MULTIPOLYGON(((0 0, 0 5, 5 5, 5 0, 0 0),
                                                     (1 1, 4 1, 4 4, 1 4, 1 1)),
                                                    ((2 2, 2 3, 3 3, 3 2, 2 2)))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.12'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Multipolygon made of two simple polygons'::text description,
       TT_RemoveHoles(ST_GeomFromText('MULTIPOLYGON(((0 0, 1 0, 1 1, 0 1, 0 0)), 
                                                   ((1 1, 2 1, 2 2, 1 2, 1 1)))')) = 
                      ST_GeomFromText('MULTIPOLYGON(((1 1, 1 0, 0 0, 0 1, 1 1)),
                                                    ((1 1, 1 2, 2 2, 2 1, 1 1)))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.13'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Multipolygon made of two holed polygons'::text description,
       TT_RemoveHoles(ST_GeomFromText('MULTIPOLYGON(((0 0, 3 0, 3 3, 0 3, 0 0), 
                                                     (1 1, 2 1, 2 2, 1 2, 1 1)), 
                                                    ((4 4, 7 4, 7 7, 4 7, 4 4), 
                                                     (5 5, 6 5, 6 6, 5 6, 5 5)))')) = 
                      ST_GeomFromText('MULTIPOLYGON(((0 0, 0 3, 3 3, 3 0, 0 0)), 
                                                    ((4 4, 4 7, 7 7, 7 4, 4 4)))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.14'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Multipolygon made of one holed polygons with a polygon inside the hole'::text description,
       TT_RemoveHoles(ST_GeomFromText('MULTIPOLYGON(((0 0, 5 0, 5 5, 0 5, 0 0), 
                                                     (1 1, 4 1, 4 4, 1 4, 1 1)), 
                                                     ((2 2, 3 2, 3 3, 2 3, 2 2)))')) = 
                      ST_GeomFromText('POLYGON((0 0, 0 5, 5 5, 5 0, 0 0))') passed
---------------------------------------------------------
UNION ALL
SELECT '1.15'::text number,
       'TT_RemoveHoles'::text function_tested,
       'Test not a polygon'::text description,
       TT_RemoveHoles(ST_GeomFromText('LINESTRING(0 0,1 1,1 2)')) = ST_GeomFromText('LINESTRING(0 0,1 1,1 2)') passed
---------------------------------------------------------
-- TT_IsSurroundedAgg
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test for NULL'::text description,
       TT_IsSurroundedAgg(NULL, NULL) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test surrounded NULL'::text description,
       TT_IsSurroundedAgg(NULL, ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))')) IS NULL passed
---------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test surrounding NULL'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0))'), NULL) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Simple test'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 
						  ST_GeomFromText('POLYGON((0 0, 3 0, 3 3, 0 3, 0 0))')) passed
---------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Simple test inverted'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((0 0, 3 0, 3 3, 0 3, 0 0))'), 
						  ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))')) IS FALSE passed
---------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test open corner'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((1 1, 2 1, 1.5 2, 1 2, 1 1))'), 
						  ST_GeomFromText('POLYGON((0 0, 3 0, 3 1, 2 2, 2 1, 1 1, 1 2, 2 2, 1 3, 0 3, 0 0))')) IS FALSE passed
---------------------------------------------------------
UNION ALL
(
WITH surrounding AS (
  SELECT ST_GeomFromText('POLYGON((0 0, 0 3, 4 3, 4 2, 1 2, 1 1, 4 1, 4 0, 0 0))') geom
  UNION ALL
  SELECT ST_GeomFromText('POLYGON((3 1, 3 2, 4 2, 4 1, 3 1))')
)
SELECT '2.7'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test with hole between surrounding polygons - Would expect TRUE but FALSE because no way to intersect with furthest polygon'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 
						  geom) IS FALSE passed
FROM surrounding
WHERE ST_Intersects(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), geom)
)
---------------------------------------------------------
UNION ALL
SELECT '2.8'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test open corner'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((2 2, 3 2, 3 3, 2 3, 2 2))'), 
						  ST_GeomFromText('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0), (1 1, 4 1, 4 4, 1 4, 1 1))')) passed
---------------------------------------------------------
UNION ALL
(
WITH surrounding AS (
  SELECT ST_GeomFromText('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0), (1 1, 4 1, 4 4, 1 4, 1 1))') geom
)
SELECT '2.9'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test surrounding but not intersecting polygon'::text description,
       coalesce(TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((2 2, 3 2, 3 3, 2 3, 2 2))'), 
						  geom), FALSE) IS FALSE passed
FROM surrounding
WHERE ST_Intersects(ST_GeomFromText('POLYGON((2 2, 3 2, 3 3, 2 3, 2 2))'), geom)
)
---------------------------------------------------------
UNION ALL
(
WITH surrounding AS (
  SELECT ST_GeomFromText('POLYGON((0 0, 5 0, 5 5, 0 5, 0 0), (1 1, 4 1, 4 4, 1 4, 1 1))') geom
)
SELECT '2.10'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Previous test becomes TRUE if we remove holes from surrounding polygons'::text description,
       coalesce(TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((2 2, 3 2, 3 3, 2 3, 2 2))'), 
						  geom), FALSE) IS TRUE passed
FROM surrounding
WHERE ST_Intersects(ST_GeomFromText('POLYGON((2 2, 3 2, 3 3, 2 3, 2 2))'), TT_RemoveHoles(geom))
)---------------------------------------------------------
UNION ALL
(
WITH surrounding AS (
  SELECT ST_GeomFromText('POLYGON((0 0, 4 0, 4 4, 0 4, 0 0), (1 1, 3 1, 3 3, 1 3, 1 1))') geom
)
SELECT '2.11'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Test with hole between surrounding polygons'::text description,
       TT_IsSurroundedAgg(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), 
						  geom) IS TRUE passed
FROM surrounding
WHERE ST_Intersects(ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'), geom)
)
---------------------------------------------------------
UNION ALL
(
WITH surrounded AS (
  SELECT TT_IsSurroundedAgg(a.geom, b.geom) surrounded
  FROM casfri50_coverage.test3x3 a, casfri50_coverage.test3x3 b
  WHERE ST_Intersects(a.geom, b.geom)
  GROUP BY a.id, a.geom
)
SELECT '2.12'::text number,
       'TT_IsSurrounded'::text function_tested,
       'Simple on the 3x3 table of polygon'::text description,
       array_agg(surrounded) = ARRAY[FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE] passed
FROM surrounded
)
---------------------------------------------------------
) AS b 
ON (a.function_tested = b.function_tested AND (regexp_split_to_array(number, '\.'))[2] = min_num)
ORDER BY maj_num::int, min_num::int
-- This last line has to be commented out, with the line at the beginning,
-- to display only failing tests...
) foo WHERE NOT passed;

