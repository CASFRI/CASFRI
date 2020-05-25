------------------------------------------------------------------------------
-- CASFRI Sample workflow file for CASFRI v5 beta
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
CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
RETURNS ANYARRAY LANGUAGE SQL
AS $$
SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$$;
-- Begin test section
-------------------------------------------------------
-- Uncomment to display only failing tests (at the end also)
--SELECT * FROM (
-------------------------------------------------------
-- Add some constraints to the CAS_ALL table
-------------------------------------------------------
SELECT '1.1'::text number,
       'Check that the number of cas_all rows matches the established number' description, 
       count(*) = 4518166 passed, 
       'SELECT count(*) nb
FROM casfri50.cas_all;' list_query
FROM casfri50.cas_all
-------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'Check that the number of dst_all rows matches the established number' description, 
       count(*) = 852871 passed, 
       'SELECT count(*) nb
FROM casfri50.dst_all;' list_query
FROM casfri50.dst_all
-------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'Check that the number of eco_all rows matches the established number' description, 
       count(*) = 184113 passed, 
       'SELECT count(*) nb
FROM casfri50.eco_all;' list_query
FROM casfri50.eco_all
-------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'Check that the number of lyr_all rows matches the established number' description, 
       count(*) = 3672374 passed, 
       'SELECT count(*) nb
FROM casfri50.lyr_all;' list_query
FROM casfri50.lyr_all
-------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'Check that the number of nfl_all rows matches the established number' description, 
       count(*) = 1795661 passed, 
       'SELECT count(*) nb
FROM casfri50.nfl_all;' list_query
FROM casfri50.nfl_all
-------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'Check that the number of geo_all rows matches the cas_all number of rows' description, 
       (SELECT count(*) nb FROM casfri50.cas_all) = 
       (SELECT count(*) nb FROM casfri50.geo_all) passed, 
       'SELECT ''cas_all'', count(*) nb FROM casfri50.cas_all
UNION ALL 
SELECT ''geo_all'', count(*) nb FROM casfri50.geo_all;' list_query
-------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'Check that the number of cas_all rows for AB06 matches the established number' description, 
       passed, 
       'SELECT count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = ''AB06'';' list_query
FROM (SELECT count(*) = 11484 passed
      FROM casfri50.cas_all
      WHERE left(cas_id, 4) = 'AB06') foo
-------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'Check that the number of dst_all rows for AB06 matches the established number' description, 
       count(*) = 1875 passed, 
       'SELECT count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = ''AB06'';' list_query
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB06'
-------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'Check that the number of dst_all rows matches the established number' description, 
       passed, 
       'SELECT count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = ''AB06'';' list_query
FROM (SELECT count(*) = 11484 passed
      FROM casfri50.cas_all
      WHERE left(cas_id, 4) = 'AB06') foo
-------------------------------------------------------
SELECT '1.1'::text number,
       'Check that the number of cas_all rows per inventory and per layer matches established numbers' description, 
       passed, 
       'SELECT left(cas_id, 4) inv, count(*) nb
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);' list_query
FROM (WITH numbers AS (
        SELECT ARRAY[left(cas_id, 4), count(*)::text] nb
        FROM casfri50.cas_all
        GROUP BY left(cas_id, 4)
      ) 
      SELECT array_agg(nb)::text-- = '{{AB06,11484},{AB16,120476},{NB01,927177},{NB02,1123893},{NT01,281388},{NT02,320944},{SK01,1501667},{YT02,231137}}' passed
      FROM numbers) foo
-------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'Check that all lyr_all rows have at leat one matching row in LYR, NFL, DST or ECO' description, 
       passed, 
       'SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer;' list_query
FROM (WITH numbers AS (
        SELECT ARRAY[left(cas_id, 4), layer::text, count(*)::text] nb
        FROM casfri50.lyr_all
        GROUP BY left(cas_id, 4), layer
      ) 
      SELECT array_agg(nb)::text = '{{AB06,1,9411},{AB06,2,9552},{AB16,1,104945},{NB01,1,767392},{NB01,2,164879},{NB02,1,870924},{NB02,2,182629},{NT01,1,236939},{NT01,2,9240},{NT02,1,266159},{NT02,2,84808},{SK01,1,846500},{SK01,2,13894},{YT02,1,105102}}' passed
      FROM numbers) foo
-------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'Check that all cas_all rows have at leat one matching row in LYR, NFL, DST or ECO' description, 
       passed, 
       'SELECT cas_id
FROM casfri50.cas_all cas
LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
LEFT JOIN casfri50.nfl_all nfl USING (cas_id)
LEFT JOIN casfri50.dst_all dst USING (cas_id)
LEFT JOIN casfri50.eco_all eco USING (cas_id)
WHERE lyr.cas_id IS NULL AND
      nfl.cas_id IS NULL AND
      dst.cas_id IS NULL AND
      eco.cas_id IS NULL;' list_query
FROM (SELECT count(*) = 0 passed
      FROM casfri50.cas_all cas
      LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
      LEFT JOIN casfri50.nfl_all nfl USING (cas_id)
      LEFT JOIN casfri50.dst_all dst USING (cas_id)
      LEFT JOIN casfri50.eco_all eco USING (cas_id)
      WHERE lyr.cas_id IS NULL AND
            nfl.cas_id IS NULL AND
            dst.cas_id IS NULL AND
            eco.cas_id IS NULL) foo
-------------------------------------------------------
--) foo WHERE NOT passed;
      
-- Check that the number of rows per inventory and per layers matches established numbers
WITH numbers AS (
  SELECT ARRAY[left(cas_id, 4), layer::text, count(*)::text] nb
  FROM casfri50.lyr_all
  GROUP BY left(cas_id, 4), layer
) 
SELECT array_agg(nb)::text = '{{AB06,1,9411},{AB06,2,9552},{AB16,1,104945},{NB01,1,767392},{NB01,2,164879},{NB02,1,870924},{NB02,2,182629},{NT01,1,236939},{NT01,2,9240},{NT02,1,266159},{NT02,2,84808},{SK01,1,846500},{SK01,2,13894},{YT02,1,105102}}'
FROM numbers;

-- List them
SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer;



-- Check that all layer number for a same cas_id are different and in the right order
WITH cas_all AS (
  SELECT cas_id, num_of_layers, layer
  FROM casfri50.cas_all 
  LEFT JOIN casfri50.lyr_all USING (cas_id)
  UNION ALL
  SELECT cas_id, num_of_layers, layer
  FROM casfri50.cas_all 
  LEFT JOIN casfri50.nfl_all USING (cas_id)
)
SELECT DISTINCT
       max(num_of_layers) max_num_of_layers,
       string_agg(layer::text, '_' ORDER BY layer) layers
FROM cas_all
GROUP BY cas_id;

-- Discover them
CREATE TABLE casfri50.check_1_1 AS
WITH cas_all AS (
  SELECT cas_id, num_of_layers, layer
  FROM casfri50.cas_all 
  LEFT JOIN casfri50.lyr_all USING (cas_id)
  UNION ALL
  SELECT cas_id, num_of_layers, layer
  FROM casfri50.cas_all 
  LEFT JOIN casfri50.nfl_all USING (cas_id)
), cas_ids AS (
  SELECT cas_id,
         max(num_of_layers) max_num_of_layers,
         string_agg(layer::text, '_' ORDER BY layer) layers
  FROM cas_all
  GROUP BY cas_id
  HAVING NOT ((max(num_of_layers) = 0 AND string_agg(layer::text, '_' ORDER BY layer) IS NULL) OR
              (max(num_of_layers) = 1 AND string_agg(layer::text, '_' ORDER BY layer) = '1') OR
              (max(num_of_layers) = 2 AND string_agg(layer::text, '_' ORDER BY layer) = '1_2') OR
              (max(num_of_layers) = 3 AND string_agg(layer::text, '_' ORDER BY layer) = '1_2_3') OR
              (max(num_of_layers) = 4 AND string_agg(layer::text, '_' ORDER BY layer) = '1_2_3_4'))
  --LIMIT 10
)
SELECT c.cas_id, 
       max(max_num_of_layers) max_num_of_layers, 
       max(layers) layers, 
       string_agg(lyr.layer::text, '_' ORDER BY lyr.layer) lyr_layer, 
       string_agg(nfl.layer::text, '_' ORDER BY nfl.layer) nfl_layer
FROM cas_ids c
LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
LEFT JOIN casfri50.nfl_all nfl USING (cas_id)
GROUP BY c.cas_id;

SELECT ch.*, flat.num_of_layers
FROM casfri50.check_1_1 ch
LEFT JOIN casfri50_flat.cas_flat_all_layers_same_row flat
USING (cas_id)
WHERE left(cas_id, 4) != 'AB06' AND 
LIMIT 100

