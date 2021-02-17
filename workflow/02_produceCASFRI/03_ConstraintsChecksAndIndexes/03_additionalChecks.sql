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
      IF NOT passed THEN
        description = description || ' (expected ' || exptCnt || ')';
      END IF;
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
-- Checks counts for main CASFRI tables
-- Order of counts in the provided ARRAY is CAS, DST, ECO, LYR and NFL.
-- GEO is the same as CAS.
-------------------------------------------------------
SELECT * FROM TT_TestCount(1, ARRAY[21057159, 5768577, 184113, 17999158, 7499272])
-------------------------------------------------------
-- Checks counts for main CASFRI tables per inventory
-- Order of counts in the provided ARRAY is CAS, DST, ECO, LYR and NFL.
-- GEO is the same as CAS.
-------------------------------------------------------
UNION ALL
SELECT * FROM TT_TestCount(2, ARRAY[61633, 0, 0, 0, 0], 'AB03')
UNION ALL
SELECT * FROM TT_TestCount(3, ARRAY[11484, 1875, 0, 14179, 3515], 'AB06')
UNION ALL
SELECT * FROM TT_TestCount(4, ARRAY[23268, 0, 0, 0, 0], 'AB07')
UNION ALL
SELECT * FROM TT_TestCount(5, ARRAY[34474, 0, 0, 0, 0], 'AB08')
UNION ALL
SELECT * FROM TT_TestCount(6, ARRAY[194696, 0, 0, 0, 0], 'AB10')
UNION ALL
SELECT * FROM TT_TestCount(7, ARRAY[118624, 0, 0, 0, 0], 'AB11')
UNION ALL
SELECT * FROM TT_TestCount(8, ARRAY[120476, 8873, 0, 149674, 26858], 'AB16')
UNION ALL
SELECT * FROM TT_TestCount(9, ARRAY[527038, 0, 0, 0, 0], 'AB25')
UNION ALL
SELECT * FROM TT_TestCount(10, ARRAY[620944, 0, 0, 0, 0], 'AB29')
UNION ALL
SELECT * FROM TT_TestCount(11, ARRAY[4555, 0, 0, 0, 0], 'AB30')
UNION ALL
SELECT * FROM TT_TestCount(12, ARRAY[4677411, 1142604, 0, 4272025, 1998885], 'BC08')
UNION ALL
SELECT * FROM TT_TestCount(13, ARRAY[5151772, 1421223, 0, 4744673, 2276213], 'BC10')
UNION ALL
SELECT * FROM TT_TestCount(14, ARRAY[134790, 0, 0, 0, 0], 'MB01')
UNION ALL
SELECT * FROM TT_TestCount(15, ARRAY[60370, 0, 0, 0, 0], 'MB02')
UNION ALL
SELECT * FROM TT_TestCount(16, ARRAY[27221, 0, 0, 0, 0], 'MB04')
UNION ALL
SELECT * FROM TT_TestCount(17, ARRAY[514157, 0, 0, 237280, 203479], 'MB05')
UNION ALL
SELECT * FROM TT_TestCount(18, ARRAY[160218, 42149, 0, 211288, 9506], 'MB06')
UNION ALL
SELECT * FROM TT_TestCount(19, ARRAY[219682, 0, 0, 0, 0], 'MB07')
UNION ALL
SELECT * FROM TT_TestCount(20, ARRAY[927177, 252564, 72978, 932271, 78227], 'NB01')
UNION ALL
SELECT * FROM TT_TestCount(21, ARRAY[1123893, 333114, 111135, 1053554, 139930], 'NB02')
UNION ALL
SELECT * FROM TT_TestCount(22, ARRAY[1863664, 0, 0, 0, 0], 'NL01')
UNION ALL
SELECT * FROM TT_TestCount(23, ARRAY[1127926, 0, 0, 0, 0], 'NS01')
UNION ALL
SELECT * FROM TT_TestCount(24, ARRAY[1090671, 0, 0, 0, 0], 'NS02')
UNION ALL
SELECT * FROM TT_TestCount(25, ARRAY[995886, 69446, 0, 972710, 212453], 'NS03')
UNION ALL
SELECT * FROM TT_TestCount(26, ARRAY[281388, 77270, 0, 245832, 65299], 'NT01')
UNION ALL
SELECT * FROM TT_TestCount(27, ARRAY[320523, 0, 0, 0, 0], 'NT03')
UNION ALL
SELECT * FROM TT_TestCount(28, ARRAY[3629072, 1970285, 0, 2240815, 1318495], 'ON02')
UNION ALL
SELECT * FROM TT_TestCount(29, ARRAY[8094, 0, 0, 0, 0], 'PC01')
UNION ALL
SELECT * FROM TT_TestCount(30, ARRAY[1053, 0, 0, 0, 0], 'PC02')
UNION ALL
SELECT * FROM TT_TestCount(31, ARRAY[107220, 29517, 0, 81073, 22223], 'PE01')
UNION ALL
SELECT * FROM TT_TestCount(32, ARRAY[401188, 0, 0, 0, 0], 'QC03')
UNION ALL
SELECT * FROM TT_TestCount(33, ARRAY[2487519, 0, 0, 0, 0], 'QC04')
UNION ALL
SELECT * FROM TT_TestCount(34, ARRAY[6768074, 0, 0, 0, 0], 'QC05')
UNION ALL
SELECT * FROM TT_TestCount(35, ARRAY[1501667, 64052, 0, 860394, 340357], 'SK01')
UNION ALL
SELECT * FROM TT_TestCount(36, ARRAY[27312, 9020, 0, 28983, 17529], 'SK02')
UNION ALL
SELECT * FROM TT_TestCount(37, ARRAY[8964, 236, 0, 10767, 6845], 'SK03')
UNION ALL
SELECT * FROM TT_TestCount(38, ARRAY[633522, 93980, 0, 708553, 311133], 'SK04')
UNION ALL
SELECT * FROM TT_TestCount(39, ARRAY[421977, 58248, 0, 483663, 184184], 'SK05')
UNION ALL
SELECT * FROM TT_TestCount(40, ARRAY[211482, 45081, 0, 296399, 78506], 'SK06')
UNION ALL
SELECT * FROM TT_TestCount(41, ARRAY[249636, 0, 0, 0, 0], 'YT01')
UNION ALL
SELECT * FROM TT_TestCount(42, ARRAY[231137, 19173, 0, 105102, 76344], 'YT02')
-------------------------------------------------------
UNION ALL
SELECT '30.1'::text number,
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
SELECT '31.1'::text number,
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



