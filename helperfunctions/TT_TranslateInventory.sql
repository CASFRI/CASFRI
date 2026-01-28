--DROP PROCEDURE IF EXISTS TT_RunAllTests(text, text);
CREATE OR REPLACE PROCEDURE TT_RunAllTests(
  juridiction text, -- 'ab', 'bc', etc.
  casfriTable text DEFAULT 'all' -- can be 'cas', 'eco', 'dst', 'lyr', 'nfl' or 'all'
)
LANGUAGE plpgsql AS $$
DECLARE
  validCasfriTables text[] := ARRAY['cas', 'eco', 'dst', 'lyr', 'nfl', 'all'];
  queryStr text;
  invMetadataTableName text := 'inventory_metadata';
  r RECORD;
BEGIN
  -- Check that casfriTable is valid
  IF lower(casfriTable) != ALL(validCasfriTables) THEN
    RAISE EXCEPTION 'TT_RunAllTests() ERROR: ''%'' is not a proper argument for ''casfriTable''. Valid values are ''cas'', ''eco'', ''dst'', ''lyr'', ''nfl'' and ''all''...', casfriTable;
  END IF;
  -- Get the list of inventories for this juridiction
  queryStr := format('
    SELECT inventory_id, *
    FROM public.%I
    WHERE left(inventory_id, 2) = upper(%L) AND
          (upper(translated_by_cfs) = ''YES'' OR
           upper(translated_by_ulaval) = ''YES'') AND
          TT_TableExists(''rawfri'', lower(inventory_id));
    ', invMetadataTableName, juridiction);
  --RAISE NOTICE 'queryStr=%', queryStr;
  FOR r IN EXECUTE queryStr LOOP
    RAISE NOTICE '-------------------------------------------------------------------------------';
    RAISE NOTICE '-------------------------------------------------------------------------------';
    RAISE NOTICE 'TT_RunAllTests(): 1 - Running ''%'' tests for inventory ''%''...', upper(casfriTable), upper(r.inventory_id);
    --RAISE NOTICE 'TT_RunAllTests(): 2 - Deleting table ''%.%''...', upper(casfriTable), upper(r.inventory_id);
    --EXECUTE format('
    --  DROP TABLE IF EXISTS casfri50_test.dst_%s CASCADE;
    --  ', juridiction);
    CALL TT_TranslateInventory(r.inventory_id, 'D', casfriTable, TRUE, FALSE, FALSE);
    RAISE NOTICE '-------------------------------------------------------------------------------';
    CALL TT_TranslateInventory(r.inventory_id, 'T', casfriTable, TRUE, FALSE, FALSE);
    RAISE NOTICE '-------------------------------------------------------------------------------';
    RAISE NOTICE '-------------------------------------------------------------------------------';
  END LOOP;
END;
$$;

/*
CALL TT_RunAllTests('ab', 'xxx')
CALL TT_RunAllTests('ab', 'cas')
CALL TT_RunAllTests('ab', 'nfl')
CALL TT_RunAllTests('ab')
*/

------------------------------------------------------------------------------
-- TT_TranslateInventory
--
-- Translate a CASFRI inventory into the casfri50 schema using the
-- translation tables stored in the 'translation' schema.
------------------------------------------------------------------------------
--DROP PROCEDURE IF EXISTS TT_TranslateInventory(text, text, text, boolean, boolean, boolean);
CREATE OR REPLACE PROCEDURE TT_TranslateInventory(
  inventoryID text,
  translationType text DEFAULT 'T', -- can be 'T'ranslate or 'D'elete
  casfriTables text DEFAULT 'all',
  test boolean DEFAULT FALSE,
  progress boolean DEFAULT TRUE
)
LANGUAGE plpgsql AS $$
DECLARE
  validCasfriTables text[] := ARRAY['cas', 'eco', 'dst', 'lyr', 'nfl', 'geo', 'all'];
  upperInventoryID text;
  standardID text;
  juridiction text = lower(left(inventoryID, 2));
  nbEntry int;
  queryStr text;
  lyrMetadataTableName text = 'layer_metadata';
  invMetadataTableName text = 'inventory_metadata';
  nbTestTableName text = 'nb_tests';
  targetSchema text := 'casfri50';
  targetTable text;
  translationTableName text;
  ttPrepareFctSuffix text;
  casfriTablesArr text[];
  casfriTable text;
  upperCasfriTable text;
  r RECORD;
  nbTestRows int;
  viewName text;
  nbTranslatedLayers int = 0;
  insertStatement text;
BEGIN
  RAISE NOTICE '-------------------------------------------------------------------------------';
  -- Check that casfriTable is valid
  IF test THEN
    -- Remove 'geo' as valid casfriTable when testing
    validCasfriTables := array_remove(validCasfriTables, 'geo');
  END IF;
  IF lower(casfriTable) != ALL(validCasfriTables) THEN
    queryStr := array_to_string(
        ARRAY(SELECT quote_literal(elem) FROM unnest(validCasfriTables) AS elem),
        ','
    );
    RAISE EXCEPTION 'TT_TranslateInventory() ERROR: ''%'' is not a proper argument for ''casfriTable''. Valid values are %...', casfriTable, queryStr;
  END IF;

  inventoryID := lower(btrim(btrim(inventoryID, ' '), ''''));
  upperInventoryID := upper(inventoryID);
  translationType = upper(translationType);

  -- Build an array with the list of CASFRI table to process
  casfriTables = lower(casfriTables);
  IF casfriTables = 'all' THEN
    casfriTables = 'cas, eco, dst, lyr, nfl, geo';
  END IF;
  casfriTablesArr = regexp_split_to_array(casfriTables, '\s*,\s*');
  
  -- Check that table 'inventoryID' exists
  IF NOT TT_TableExists('rawfri', inventoryID) THEN
    RAISE NOTICE 'ERROR TT_TranslateInventory(): Could not find table ''rawfri.%''...', inventoryID;
    RETURN;
  END IF;
  RAISE NOTICE '1 - TT_TranslateInventory(): Table ''rawfri.%'' exists...', inventoryID;

  IF translationType = 'T' THEN
    FOREACH casfriTable IN ARRAY casfriTablesArr LOOP
      upperCasfriTable = upper(casfriTable);
      targetTable := casfriTable || '_all';
      ----------------------------------------------------------------------------------------------
      -- Check that table 'inventory_metadata' exists
      IF NOT TT_TableExists('public', invMetadataTableName) THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): Could not find table ''public.%''...', invMetadataTableName;
        RETURN;
      END IF;
      RAISE NOTICE '2 - TT_TranslateInventory(): Table ''public.%'' exists...', invMetadataTableName;
    
      ----------------------------------------------------------------------------------------------
      -- Check that one and only one entry for 'inventoryID' exists in table 'inventory_metadata'
      queryStr = format('SELECT count(*) FROM public.%I im
      WHERE %L = lower(im.inventory_id);', invMetadataTableName, inventoryID);
      EXECUTE queryStr INTO nbEntry;
      IF nbEntry = 0 THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): No entry found for inventory_id ''%'' in table ''public.%''...', upperInventoryID, invMetadataTableName;
        RETURN;
      ELSIF nbEntry > 1 THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): More than one entry match inventoryID ''%'' in table ''public.%''...', upperInventoryID, invMetadataTableName;
        RETURN;
      END IF;
      RAISE NOTICE '3 - TT_TranslateInventory(): One entry for ''%'' was found in ''public.%''...', upperInventoryID, invMetadataTableName;
    
      ----------------------------------------------------------------------------------------------
      -- Check that table 'layer_metadata' exists
      IF NOT TT_TableExists('translation', lyrMetadataTableName) THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): Could not find table ''translation.%''...', lyrMetadataTableName;
        RETURN;
      END IF;
      RAISE NOTICE '4 - TT_TranslateInventory(): Table ''translation.%'' exists...', lyrMetadataTableName;
    
      ----------------------------------------------------------------------------------------------
      -- Check that at least one entry for 'inventoryID' exists in table 'layer_metadata'
      queryStr = format('SELECT count(*) FROM translation.%I lm
      WHERE %L = lower(lm.inventory_id);', lyrMetadataTableName, inventoryID);
      EXECUTE queryStr INTO nbEntry;
      IF nbEntry = 0 THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): No entry found for inventory_id ''%'' in table ''translation.%''...', upperInventoryID, lyrMetadataTableName;
        RETURN;
      END IF;
      RAISE NOTICE '5 - TT_TranslateInventory(): % entries were found for ''%'' in ''translation.%''...', nbEntry, upperInventoryID, lyrMetadataTableName;
    
      ----------------------------------------------------------------------------------------------
      -- Extract standard info from 'inventory_metadata'
      queryStr = format('SELECT lower(standard_id) FROM public.%I im
      WHERE %L  = lower(im.inventory_id);', invMetadataTableName, inventoryID);
      EXECUTE queryStr INTO standardID;
      -- Prepend it with the juridiction
      standardID = lower(juridiction || '_' || standardID);
      translationTableName := format('%s_%s', standardID, casfriTable);
      ttPrepareFctSuffix := format('_%s_%s', inventoryID, casfriTable);

      IF test THEN
        -- Set other test variable
        ttPrepareFctSuffix := ttPrepareFctSuffix || '_test';
        targetSchema := 'casfri50_test';
        targetTable := casfriTable || '_' || lower(juridiction);
        ----------------------------------------------------------------------------------------------
        -- Check that table 'nb_tests' exists
        IF NOT TT_TableExists(targetSchema, nbTestTableName) THEN
          RAISE NOTICE 'ERROR TT_TranslateInventory(): Could not find table ''casfri50_test.%''...', nbTestTableName;
          RETURN;
        END IF;
        RAISE NOTICE '4 - TT_TranslateInventory(): Table ''casfri50_test.%'' exists...', nbTestTableName;
      END IF;
      PERFORM TT_Prepare('translation', translationTableName, ttPrepareFctSuffix, showProgress, showTQuery);
      ----------------------------------------------------------------------------------------------
      -- Prepare the TT_Translate_%_%() function using the 'translation'.'%_%_%' translation table
      --SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab03_cas');
      RAISE NOTICE '6 - TT_TranslateInventory(): TT_Prepare() the TT_Translate_%_%() function using the ''translation''.''%_%'' translation table...', inventoryID, casfriTable, standardID, casfriTable;
      translationTableName = format('%s_%s', standardID, casfriTable);
      ttPrepareFctSuffix = format('_%s_%s', inventoryID, casfriTable);
      IF test THEN
        ttPrepareFctSuffix = ttPrepareFctSuffix || '_test';
      END IF;
      PERFORM TT_Prepare('translation', translationTableName, ttPrepareFctSuffix, progress);

      queryStr = format('
        SELECT layer::int
        FROM translation.%I
        WHERE inventory_id = %L AND STRPOS(casfri_table, %L) > 0;',
        lyrMetadataTableName, upperInventoryID, upperCasfriTable);
      RAISE NOTICE 'queryStr=%', queryStr;

      -- Iterate over all layers to translate
      FOR r IN EXECUTE queryStr LOOP
        nbTestRows = NULL;
        IF test THEN
          -- Get the number of rows to test from the 'nb_tests' table
          queryStr = format('
            SELECT nb_test_rows
            FROM casfri50_test.%I
            WHERE inventory_id = %L AND cas_table = %L AND layer = %L;',
            nbTestTableName, inventoryID, casfriTable, r.layer);
          EXECUTE queryStr INTO nbTestRows;
        END IF;

        -- Create the mapping VIEW
        --SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, 201, NULL, 'cas');
        RAISE NOTICE '7 - TT_TranslateInventory(): TT_CreateMappingView(''rawfri'', ''%'', %, ''%'', 1, %, NULL, ''%'')...', inventoryID, r.layer, standardID, nbTestRows, casfriTable;
        PERFORM TT_CreateMappingView('rawfri', inventoryID, r.layer, standardID, 1, nbTestRows, NULL, casfriTable);

        viewName = inventoryID || '_l' || r.layer || '_to_' || standardID || '_l1_map' || (CASE WHEN nbTestRows IS NULL THEN '' ELSE '_'|| nbTestRows END) || '_' || casfriTable;
        IF TT_TableExists('rawfri', viewName) THEN
          ----------------------------------------------------------------------------------------------
          -- Execute the TT_Translate_%_%() function to insert data into the casfri50.%_all table
          --INSERT INTO casfri50.cas_all  -- xmxs
          --SELECT * FROM TT_Translate_ab03_cas('rawfri', 'ab03_l1_to_ab_l1_map');
          RAISE NOTICE '8 - TT_TranslateInventory()): Insert translated data into ''casfri50.%_all'' table using TT_Translate_%_%(''rawfri'', ''%''_l%_to_%_l1_map). To check execute: SELECT * FROM casfri50.%_all WHERE left(cas_id, 4) = ''%'';', casfriTable, inventoryID, casfriTable, inventoryID, r.layer, juridiction, casfriTable, upperInventoryID;
          queryStr = format('INSERT INTO casfri50.%I ' ||
                      ' SELECT * FROM TT_Translate%s(''rawfri'', %L);', casfriTable || '_all', ttPrepareFctSuffix, viewName);
          EXECUTE queryStr;
          nbTranslatedLayers := nbTranslatedLayers + 1;
          RAISE NOTICE '   - TT_TranslateInventory(): % layer(s) translated for ''%'' % table...', nbTranslatedLayers, upperInventoryID, upperCasfriTable;
        ELSE
          RAISE NOTICE '8 - TT_TranslateInventory(): TT_CreateMappingView(''rawfri'', ''%'', %, ''%'', 1, %) FAILED...', inventoryID, r.layer, standardID, nbTestRows;
        END IF;
      END LOOP;

      IF nbTranslatedLayers = 0 THEN
        RAISE NOTICE '7 - TT_TranslateInventory(): No % layer to translate for ''%''...', upperCasfriTable, upperInventoryID;
      END IF;
    END LOOP;
  ELSIF translationType = 'D' THEN
    FOREACH casfriTable IN ARRAY casfriTablesArr LOOP
      targetTable := casfriTable || '_all';
      IF test THEN
        targetSchema := 'casfri50_test';
        targetTable := casfriTable || '_' || lower(juridiction);
      END IF;
      -- Check if table exists
      IF TT_TableExists(targetSchema, targetTable) THEN
        -- Delete existing entries
        RAISE NOTICE '1 - TT_TranslateInventory(): Deleting ''%'' entries from ''%.%'' table. To check, execute: SELECT * FROM %.% WHERE left(cas_id, 4) = ''%'';', upperInventoryID, targetSchema, targetTable, targetSchema, targetTable, upperInventoryID;
        queryStr := format('
          DELETE FROM %I.%I WHERE left(cas_id, 4) = %L;
          ', targetSchema, targetTable, upperInventoryID);
        --RAISE NOTICE 'DDDD queryStr=%', queryStr;
        EXECUTE queryStr;
    END LOOP;
  ELSE
    RAISE NOTICE 'ERROR TT_TranslateInventory(): Unsupported translation type (%)...', translationType;
  END IF;
END;
$$;
--CALL TT_TranslateInventory('AB06', 'D', 'cas');
--CALL TT_TranslateInventory('Ab06', 'T', 'cas');
--CALL TT_TranslateInventory('Ab06', 'T', 'cas', FALSE, FALSE);
--CALL TT_TranslateInventory('AB06', 'D', 'nfl');
--CALL TT_TranslateInventory('AB06', 'T', 'nfl');
--CALL TT_TranslateInventory('AB06', 'T', 'nfl', TRUE);
--CALL TT_TranslateInventory('AB34', 'T', 'nfl');
--CALL TT_TranslateInventory('AB34', 'T', 'nfl', TRUE);

--CALL TT_TranslateInventory('Ab06', 'T', 'cas', TRUE);
-- SELECT TT_CreateMappingView('rawfri', 'ab06', '1', 'ab_avi01', 1, 201, NULL, 'nfl')
-- SELECT ab06_l1_to_ab_avi01_l1_200_map