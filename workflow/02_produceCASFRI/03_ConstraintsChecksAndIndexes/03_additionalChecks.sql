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
GROUP BY inventory_id;
' list_query
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
       'Check that CAS number_of_layers matches the actual number of LYR and NFL layers' description, 
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
ORDER BY c.num_of_layers, a.cnt;' list_query
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
       'Check that all layer numbers for a same cas_id are different and have no gap in their order (no missing 2 when there is 1 and 3)' description, 
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
      layers_order != ''nfl1_nfl2_nfl3_nfl4'';
' list_query
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
UNION ALL
SELECT '1.5'::text number,
       'Issue #475. Check that LYR table layers are in height order (layer 1  = highest)' description, 
       passed, 
       'SELECT cas_id, 
       string_agg(layer::text, ''_'' ORDER BY height_upper DESC, layer ASC) lyr_ordering,
       string_agg(height_upper::text, ''_'' ORDER BY height_upper DESC, layer ASC) heights
FROM casfri50.lyr_all
GROUP BY cas_id
HAVING NOT (string_agg(layer::text, ''_'' ORDER BY height_upper DESC, layer ASC) = ANY(ARRAY[''1'', ''1_2'', ''1_2_3'', ''1_2_3_4'', ''1_2_3_4_5'']));
' list_query
FROM (
WITH orderings AS (
  SELECT DISTINCT string_agg(layer::text, '_' ORDER BY height_upper DESC, layer ASC) lyr_ordering
  FROM casfri50.lyr_all
  GROUP BY cas_id
) 
SELECT array_agg(lyr_ordering) = ARRAY['1', '1_2', '1_2_3', '1_2_3_4', '1_2_3_4_5'] passed
FROM orderings
) foo
-------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'Issue #676. Check that LYR species are in order without gaps' description, 
       passed, 
       'SELECT cas_id, 
  species_1, 
  species_2,
  species_3,
  species_4,
  species_5,
  species_6,
  species_7,
  species_8,
  species_9,
  species_10
FROM casfri50.lyr_all
WHERE NOT (CASE WHEN species_1 = ANY(TT_IsMissingOrNotInSetCode()) AND species_1 != ''NOT_IN_SET'' THEN '''' ELSE ''01'' END || 
    CASE WHEN species_2 = ANY(TT_IsMissingOrNotInSetCode()) AND species_2 != ''NOT_IN_SET'' THEN '''' ELSE ''_02'' END || 
    CASE WHEN species_3 = ANY(TT_IsMissingOrNotInSetCode()) AND species_3 != ''NOT_IN_SET'' THEN '''' ELSE ''_03'' END || 
    CASE WHEN species_4 = ANY(TT_IsMissingOrNotInSetCode()) AND species_4 != ''NOT_IN_SET'' THEN '''' ELSE ''_04'' END || 
    CASE WHEN species_5 = ANY(TT_IsMissingOrNotInSetCode()) AND species_5 != ''NOT_IN_SET'' THEN '''' ELSE ''_05'' END || 
    CASE WHEN species_6 = ANY(TT_IsMissingOrNotInSetCode()) AND species_6 != ''NOT_IN_SET'' THEN '''' ELSE ''_06'' END || 
    CASE WHEN species_7 = ANY(TT_IsMissingOrNotInSetCode()) AND species_7 != ''NOT_IN_SET'' THEN '''' ELSE ''_07'' END || 
    CASE WHEN species_8 = ANY(TT_IsMissingOrNotInSetCode()) AND species_8 != ''NOT_IN_SET'' THEN '''' ELSE ''_08'' END || 
    CASE WHEN species_9 = ANY(TT_IsMissingOrNotInSetCode()) AND species_9 != ''NOT_IN_SET'' THEN '''' ELSE ''_09'' END || 
    CASE WHEN species_10 =ANY(TT_IsMissingOrNotInSetCode()) AND species_10 != ''NOT_IN_SET'' THEN '''' ELSE ''10'' END) = 
    ANY(ARRAY['''', ''01'', ''01_02'', ''01_02_03'', ''01_02_03_04'', ''01_02_03_04_05'', ''01_02_03_04_05_06'', ''01_02_03_04_05_06_07'', ''01_02_03_04_05_06_07_08'', ''01_02_03_04_05_06_07_08_09'', ''01_02_03_04_05_06_07_08_09_10''])
    ORDER BY cas_id;
' list_query
FROM (
WITH species_orderings AS (
  SELECT DISTINCT 
    CASE WHEN species_1 = ANY(TT_IsMissingOrNotInSetCode()) AND species_1 != 'NOT_IN_SET' THEN '' ELSE '01' END || 
    CASE WHEN species_2 = ANY(TT_IsMissingOrNotInSetCode()) AND species_2 != 'NOT_IN_SET' THEN '' ELSE '_02' END || 
    CASE WHEN species_3 = ANY(TT_IsMissingOrNotInSetCode()) AND species_3 != 'NOT_IN_SET' THEN '' ELSE '_03' END || 
    CASE WHEN species_4 = ANY(TT_IsMissingOrNotInSetCode()) AND species_4 != 'NOT_IN_SET' THEN '' ELSE '_04' END || 
    CASE WHEN species_5 = ANY(TT_IsMissingOrNotInSetCode()) AND species_5 != 'NOT_IN_SET' THEN '' ELSE '_05' END || 
    CASE WHEN species_6 = ANY(TT_IsMissingOrNotInSetCode()) AND species_6 != 'NOT_IN_SET' THEN '' ELSE '_06' END || 
    CASE WHEN species_7 = ANY(TT_IsMissingOrNotInSetCode()) AND species_7 != 'NOT_IN_SET' THEN '' ELSE '_07' END || 
    CASE WHEN species_8 = ANY(TT_IsMissingOrNotInSetCode()) AND species_8 != 'NOT_IN_SET' THEN '' ELSE '_08' END || 
    CASE WHEN species_9 = ANY(TT_IsMissingOrNotInSetCode()) AND species_9 != 'NOT_IN_SET' THEN '' ELSE '_09' END || 
    CASE WHEN species_10 = ANY(TT_IsMissingOrNotInSetCode()) AND species_10 != 'NOT_IN_SET' THEN '' ELSE '10' END  lyr_ordering
  FROM casfri50.lyr_all
) 
SELECT array_agg(lyr_ordering) = ARRAY['', '01', '01_02', '01_02_03', '01_02_03_04', '01_02_03_04_05', '01_02_03_04_05_06', '01_02_03_04_05_06_07', '01_02_03_04_05_06_07_08', '01_02_03_04_05_06_07_08_09', '01_02_03_04_05_06_07_08_09_10'] passed
FROM species_orderings
) foo
-------------------------------------------------------
--) foo WHERE NOT passed;



