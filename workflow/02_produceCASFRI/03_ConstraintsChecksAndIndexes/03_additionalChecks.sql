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
SELECT '1.1'::text number,
       'Issue #592. Check that STAND_STRUCTURE is correct based on the number of LYR layers' description, 
       passed, 
       'WITH lyr_structure AS (
  SELECT cas_id, min(stand_structure) stand_structure, count(*) nb_lyrlayers
  FROM casfri50.cas_all cas 
  LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
  GROUP BY cas.cas_id
)
SELECT cas_id, stand_structure, nb_lyrlayers
FROM lyr_structure
WHERE NOT (((stand_structure = ''SINGLE_LAYERED'' OR stand_structure = ''COMPLEX'') AND nb_lyrlayers = 1) OR
           (stand_structure = ''MULTI_LAYERED'' AND nb_lyrlayers > 1) OR 
           (stand_structure != ''SINGLE_LAYERED'' AND stand_structure != ''MULTI_LAYERED'' AND stand_structure != ''COMPLEX''));
' list_query
FROM (
WITH lyr_structure AS (
  SELECT DISTINCT stand_structure, count(*) nb_lyrlayers
  FROM casfri50.cas_all cas 
  LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
  GROUP BY cas.cas_id
)
SELECT count(*) = 0 passed
FROM lyr_structure
WHERE NOT (((stand_structure = 'SINGLE_LAYERED' OR stand_structure = 'COMPLEX') AND nb_lyrlayers = 1) OR
           (stand_structure = 'MULTI_LAYERED' AND nb_lyrlayers > 1) OR 
           (stand_structure != 'SINGLE_LAYERED' AND stand_structure != 'MULTI_LAYERED' AND stand_structure != 'COMPLEX'))
           
) foo
-------------------------------------------------------
UNION ALL
-- Have a look at https://github.com/CASFRI/CASFRI/issues/625 for more details about this test.
SELECT '1.2'::text number,
       'Issue #625. Check that all cas_all rows have at least one matching row in LYR, NFL, DST or ECO' description, 
       passed, 
       'SELECT inventory_id, count(*) nb
FROM casfri50.cas_all cas
LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
LEFT JOIN casfri50.nfl_all nfl USING (cas_id)
LEFT JOIN casfri50.dst_all dst USING (cas_id)
LEFT JOIN casfri50.eco_all eco USING (cas_id)
WHERE lyr.cas_id IS NULL AND
      nfl.cas_id IS NULL AND
      dst.cas_id IS NULL AND
      eco.cas_id IS NULL
GROUP BY inventory_id;' list_query
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
UNION ALL
SELECT '1.3'::text number,
       'Issue #739. Check that CAS number_of_layers matches the actual number of LYR and NFL layers' description, 
       passed, 
       'WITH all_layers AS (
  SELECT cas_id FROM casfri50.lyr_all
  UNION ALL
  SELECT cas_id FROM casfri50.nfl_all
), all_layers_counts AS (
  SELECT cas_id, count(*) cnt
  FROM all_layers
  GROUP BY cas_id
)
SELECT c.cas_id, c.num_of_layers, a.cnt
FROM casfri50.cas_all c
NATURAL LEFT JOIN all_layers_counts a 
WHERE NOT ((c.num_of_layers = -8886 AND a.cnt IS NULL) OR (c.num_of_layers = a.cnt))
ORDER BY c.num_of_layers, a.cnt' list_query
FROM (
WITH all_layers AS (
  SELECT cas_id FROM casfri50.lyr_all
  UNION ALL
  SELECT cas_id FROM casfri50.nfl_all
), all_layers_counts AS (
  SELECT cas_id, count(*) cnt
  FROM all_layers
  GROUP BY cas_id
)
SELECT count(*) = 0 passed
FROM casfri50.cas_all c
NATURAL LEFT JOIN all_layers_counts a 
WHERE NOT ((c.num_of_layers = -8886 AND a.cnt IS NULL) OR (c.num_of_layers = a.cnt))
) foo
-------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'Issue #740. Check that all layer numbers for a same cas_id are different and have no gap in their order (no missing 2 when there is 1 and 3)' description, 
       passed, 
       'WITH all_layers_numbers AS (
  SELECT cas_id, ''lyr'' || layer::text layer  FROM casfri50.lyr_all
  UNION ALL
  SELECT cas_id, ''nfl'' || layer::text layer  FROM casfri50.nfl_all
), all_layers_orders AS (
  SELECT cas_id, string_agg(layer::text, ''_'' ORDER BY layer) layers_order
  FROM all_layers_numbers
  GROUP BY cas_id
)
SELECT cas_id, layers_order
FROM all_layers_orders
WHERE layers_order != ''lyr1'' AND
      layers_order != ''lyr1_lyr2'' AND
      layers_order != ''lyr1_lyr2_lyr3'' AND
      layers_order != ''lyr1_lyr2_lyr3_lyr4'' AND
      layers_order != ''lyr1_lyr2_lyr3_lyr4_lyr5'' AND
      layers_order != ''lyr1_lyr2_lyr3_lyr4_nfl5'' AND
      layers_order != ''lyr1_lyr2_lyr3_lyr4_nfl5_nfl6'' AND
      layers_order != ''lyr1_lyr2_lyr3_lyr4_nfl5_nfl6_nfl7'' AND
      layers_order != ''lyr1_lyr2_lyr3_nfl4'' AND
      layers_order != ''lyr1_lyr2_lyr3_nfl4_nfl5'' AND
      layers_order != ''lyr1_lyr2_lyr3_nfl4_nfl5_nfl6'' AND
      layers_order != ''lyr1_lyr2_lyr3_nfl4_nfl5_nfl6_nfl7'' AND
      layers_order != ''lyr1_lyr2_nfl3'' AND
      layers_order != ''lyr1_lyr2_nfl3_nfl4'' AND
      layers_order != ''lyr1_lyr2_nfl3_nfl4_nfl5'' AND
      layers_order != ''lyr1_lyr2_nfl3_nfl4_nfl5_nfl6'' AND
      layers_order != ''lyr1_nfl2'' AND
      layers_order != ''lyr1_nfl2_nfl3'' AND
      layers_order != ''lyr1_nfl2_nfl3_nfl4'' AND
      layers_order != ''lyr1_nfl2_nfl3_nfl4_nfl5'' AND
      layers_order != ''nfl1'' AND
      layers_order != ''nfl1_nfl2'' AND
      layers_order != ''nfl1_nfl2_nfl3'' AND
      layers_order != ''nfl1_nfl2_nfl3_nfl4''' list_query
FROM (
WITH all_layers_numbers AS (
  SELECT cas_id, 'lyr' || layer::text layer  FROM casfri50.lyr_all
  UNION ALL
  SELECT cas_id, 'nfl' || layer::text layer  FROM casfri50.nfl_all
), all_layers_orders AS (
  SELECT cas_id, string_agg(layer::text, '_' ORDER BY layer) layers_order
  FROM all_layers_numbers
  GROUP BY cas_id
)
SELECT count(*) = 0 passed
FROM all_layers_orders
WHERE layers_order != 'lyr1' AND
      layers_order != 'lyr1_lyr2' AND
      layers_order != 'lyr1_lyr2_lyr3' AND
      layers_order != 'lyr1_lyr2_lyr3_lyr4' AND
      layers_order != 'lyr1_lyr2_lyr3_lyr4_lyr5' AND
      layers_order != 'lyr1_lyr2_lyr3_lyr4_nfl5' AND
      layers_order != 'lyr1_lyr2_lyr3_lyr4_nfl5_nfl6' AND
      layers_order != 'lyr1_lyr2_lyr3_lyr4_nfl5_nfl6_nfl7' AND
      layers_order != 'lyr1_lyr2_lyr3_nfl4' AND
      layers_order != 'lyr1_lyr2_lyr3_nfl4_nfl5' AND
      layers_order != 'lyr1_lyr2_lyr3_nfl4_nfl5_nfl6' AND
      layers_order != 'lyr1_lyr2_lyr3_nfl4_nfl5_nfl6_nfl7' AND
      layers_order != 'lyr1_lyr2_nfl3' AND
      layers_order != 'lyr1_lyr2_nfl3_nfl4' AND
      layers_order != 'lyr1_lyr2_nfl3_nfl4_nfl5' AND
      layers_order != 'lyr1_lyr2_nfl3_nfl4_nfl5_nfl6' AND
      layers_order != 'lyr1_nfl2' AND
      layers_order != 'lyr1_nfl2_nfl3' AND
      layers_order != 'lyr1_nfl2_nfl3_nfl4' AND
      layers_order != 'lyr1_nfl2_nfl3_nfl4_nfl5' AND
      layers_order != 'nfl1' AND
      layers_order != 'nfl1_nfl2' AND
      layers_order != 'nfl1_nfl2_nfl3' AND
      layers_order != 'nfl1_nfl2_nfl3_nfl4'
) foo
-------------------------------------------------------
--) foo WHERE NOT passed;



