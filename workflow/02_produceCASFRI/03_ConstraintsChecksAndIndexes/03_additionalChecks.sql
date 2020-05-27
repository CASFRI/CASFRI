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
RETURNS ANYARRAY AS $$
  SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS TT_TestCount(int, text, int[]);
CREATE OR REPLACE FUNCTION TT_TestCount(
  majorNb int,
  expectedCnts int[],
  inv text DEFAULT NULL
)
RETURNS TABLE (number text,
               description text,
               passed boolean,
               list_query text) AS $$
  DECLARE
    cnt int;
    exptCnt int;
    minorNb int = 1;
    tableNames text[] = ARRAY['CAS_ALL', 'DST_ALL', 'ECO_ALL', 'LYR_ALL', 'NFL_ALL', 'GEO_ALL'];
  BEGIN
    IF cardinality(expectedCnts) != 5 THEN
      RAISE EXCEPTION 'TT_TestCount() ERROR: expectedCnts must have 5 values...';
    END IF;
    -- Make the expected count for GEO_ALL the same as for CAS_ALL
    expectedCnts = array_append(expectedCnts, expectedCnts[1]);
    FOREACH exptCnt IN ARRAY (expectedCnts) LOOP
      number = majorNb::text || '.' || minorNb::text;
      list_query = 'SELECT count(*) ' ||
                   'FROM casfri50.' || lower(tableNames[minorNb]);
      IF NOT inv IS NULL THEN
        list_query = list_query || ' WHERE left(cas_id, 4) = ''' || upper(inv) || '''';
      END IF;
      list_query = list_query || ';';
      RAISE NOTICE 'TT_TestCount(): Executing ''%''...', list_query;
      EXECUTE list_query INTO cnt;
      passed = cnt = exptCnt;
      description = tableNames[minorNb] || ' rows count';
      IF NOT inv IS NULL THEN
        description = description || ' for ' || upper(inv);
      END IF;
      description = description || ' = ' || cnt::text;
      RETURN NEXT;
      minorNb = minorNb + 1;
    END LOOP;
    RETURN;
  END
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------
-- Begin test section
-------------------------------------------------------
-- Uncomment to display only failing tests (at the end also)
--SELECT * FROM (
-------------------------------------------------------
-- Checks count for main CASFRI tables
-------------------------------------------------------
SELECT * FROM TT_TestCount(1, ARRAY[0, 0, 0, 0, 0])
-------------------------------------------------------
-- Checks count for main CASFRI tables per inventory
-------------------------------------------------------
UNION ALL
SELECT * FROM TT_TestCount(2, ARRAY[11484, 1875, 0, 18963, 3515], 'AB06')
UNION ALL
SELECT * FROM TT_TestCount(3, ARRAY[120476, 8873, 0, 104945, 26858], 'AB16')
UNION ALL
SELECT * FROM TT_TestCount(4, ARRAY[4677411, 4677411, 0, 0, 0], 'BC08')
UNION ALL
SELECT * FROM TT_TestCount(5, ARRAY[5151772, 5151772, 0, 4744673, 5141801], 'BC10')
UNION ALL
SELECT * FROM TT_TestCount(6, ARRAY[927177, 252564, 72978, 932271, 87371], 'NB01')
UNION ALL
SELECT * FROM TT_TestCount(7, ARRAY[1123893, 333114, 111135, 1053553, 141747], 'NB02')
UNION ALL
SELECT * FROM TT_TestCount(8, ARRAY[281388, 77270, 0, 246179, 312384], 'NT01')
UNION ALL
SELECT * FROM TT_TestCount(9, ARRAY[320944, 87974, 0, 350967, 480283], 'NT02')
UNION ALL
SELECT * FROM TT_TestCount(10, ARRAY[0, 0, 0, 0, 0], 'ON02')
UNION ALL
SELECT * FROM TT_TestCount(11, ARRAY[1501667, 72023, 0, 860394, 574487], 'SK01')
UNION ALL
SELECT * FROM TT_TestCount(12, ARRAY[231137, 19178, 0, 105102, 169016], 'YT02')
-------------------------------------------------------
UNION ALL
SELECT '13.1'::text number,
       'Check that all cas_all rows have at least one matching row in LYR, NFL, DST or ECO' description, 
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
UNION ALL
SELECT '14.1'::text number,
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



