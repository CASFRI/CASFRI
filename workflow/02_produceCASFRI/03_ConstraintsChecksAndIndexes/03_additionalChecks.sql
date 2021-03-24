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
SELECT '1.2'::text number,
       'Check that that CAS number_of_layers matches the actual layers and that all layer numbers for a same cas_id are different and have no gap in their order (no missing 2 when there is 1 and 3)' description, 
       passed, 
       'WITH cas_only AS ( 
  SELECT cas_id, 
         num_of_layers, ''lyr'' || lyr.layer lyr_layer, ''nfl'' || nfl.layer nfl_layer
  FROM casfri50.cas_all 
  LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
  LEFT JOIN casfri50.nfl_all nfl USING (cas_id)
), cas_lyr_nfl AS (
  SELECT cas_id, 
         num_of_layers, lyr_layer layers
  FROM cas_only
  WHERE nfl_layer IS NULL
  UNION ALL
  SELECT cas_id, num_of_layers, nfl_layer layers
  FROM cas_only
  WHERE nfl_layer IS NOT NULL
), final AS (
  SELECT cas_id,
         max(num_of_layers) max_num_of_layers,
         string_agg(layers, ''_'' ORDER BY layers) layers
  FROM cas_lyr_nfl
  GROUP BY cas_id
)
SELECT *
FROM final
WHERE NOT ((max_num_of_layers = 0 AND layers IS NULL) OR
           (max_num_of_layers = 1 AND layers = ''nfl1'') OR 
           (max_num_of_layers = 2 AND layers = ''nfl1_nfl2'') OR 
           (max_num_of_layers = 3 AND layers = ''nfl1_nfl2_nfl3'') OR 
           (max_num_of_layers = 1 AND layers = ''lyr1'') OR 
           (max_num_of_layers = 2 AND layers = ''lyr1_lyr2'') OR 
           (max_num_of_layers = 3 AND layers = ''lyr1_lyr2_lyr3'') OR 
           (max_num_of_layers = 2 AND layers = ''lyr1_nfl2'') OR 
           (max_num_of_layers = 3 AND layers = ''lyr1_nfl2_nfl3'') OR 
           (max_num_of_layers = 4 AND layers = ''lyr1_nfl2_nfl3_nfl4'') OR 
           (max_num_of_layers = 3 AND layers = ''lyr1_lyr2_nfl3'') OR 
           (max_num_of_layers = 4 AND layers = ''lyr1_lyr2_lyr3_nfl4'') OR 
           (max_num_of_layers = 5 AND layers = ''lyr1_lyr2_lyr3_nfl4_nfl5'') OR 
           (max_num_of_layers = 6 AND layers = ''lyr1_lyr2_lyr3_nfl4_nfl5_nfl6''));' list_query
FROM (WITH cas_only AS ( 
  SELECT cas_id, 
         num_of_layers, 'lyr' || lyr.layer lyr_layer, 'nfl' || nfl.layer nfl_layer
  FROM casfri50.cas_all 
  LEFT JOIN casfri50.lyr_all lyr USING (cas_id)
  LEFT JOIN casfri50.nfl_all nfl USING (cas_id)
), cas_lyr_nfl AS (
  SELECT cas_id, 
         num_of_layers, lyr_layer layers
  FROM cas_only
  WHERE nfl_layer IS NULL
  UNION ALL
  SELECT cas_id, num_of_layers, nfl_layer layers
  FROM cas_only
  WHERE nfl_layer IS NOT NULL
), final AS (
  SELECT cas_id,
         max(num_of_layers) max_num_of_layers,
         string_agg(layers, '_' ORDER BY layers) layers
  FROM cas_lyr_nfl
  GROUP BY cas_id
)
SELECT count(*) = 0 passed
FROM final
WHERE NOT ((max_num_of_layers = 0 AND layers IS NULL) OR
           (max_num_of_layers = 1 AND layers = 'nfl1') OR 
           (max_num_of_layers = 2 AND layers = 'nfl1_nfl2') OR 
           (max_num_of_layers = 3 AND layers = 'nfl1_nfl2_nfl3') OR 
           (max_num_of_layers = 1 AND layers = 'lyr1') OR 
           (max_num_of_layers = 2 AND layers = 'lyr1_lyr2') OR 
           (max_num_of_layers = 3 AND layers = 'lyr1_lyr2_lyr3') OR 
           (max_num_of_layers = 2 AND layers = 'lyr1_nfl2') OR 
           (max_num_of_layers = 3 AND layers = 'lyr1_nfl2_nfl3') OR 
           (max_num_of_layers = 4 AND layers = 'lyr1_nfl2_nfl3_nfl4') OR 
           (max_num_of_layers = 3 AND layers = 'lyr1_lyr2_nfl3') OR 
           (max_num_of_layers = 4 AND layers = 'lyr1_lyr2_lyr3_nfl4') OR 
           (max_num_of_layers = 5 AND layers = 'lyr1_lyr2_lyr3_nfl4_nfl5') OR 
           (max_num_of_layers = 6 AND layers = 'lyr1_lyr2_lyr3_nfl4_nfl5_nfl6'))) foo
-------------------------------------------------------
--) foo WHERE NOT passed;



