--DROP PROCEDURE IF EXISTS TT_TranslateInventory(text, text);
CREATE OR REPLACE PROCEDURE TT_TranslateInventory(
  inventoryID text,
  translationType text DEFAULT 'F', -- can be 'F'ull translation, 'D'elete or 'T'est
  casfriTables text DEFAULT 'all'
)
LANGUAGE plpgsql AS $$
DECLARE
  upperInventoryID text;
  standardID text;
  juridiction text = lower(left(inventoryID, 2));
  nbEntry int;
  queryStr text;
  lyrMetadataTableName text = 'layer_metadata';
  invMetadataTableName text = 'inventory_metadata';
  casfriTablesArr text[];
  casfriTable text;
  layerMax int;
  layerMin int;
BEGIN
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

  IF translationType = 'F' OR translationType = 'T' THEN
    FOREACH casfriTable IN ARRAY casfriTablesArr LOOP
      ----------------------------------------------------------------------------------------------
      -- Check that table 'inventory_metadata' exists
      IF NOT TT_TableExists('public', invMetadataTableName) THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): Could not find table ''public.%''...', invMetadataTableName;
        RETURN;
      END IF;
      RAISE NOTICE '2 - TT_TranslateInventory(): Table ''public.%'' exists...', invMetadataTableName;
    
      ----------------------------------------------------------------------------------------------
      -- Check that one and only one entry for 'inventoryID' exists in table 'inventory_metadata'
      queryStr = 'SELECT count(*) FROM public.' || invMetadataTableName || ' im
      WHERE ''' || inventoryID || ''' = lower(im.inventory_id)';
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
      queryStr = 'SELECT count(*) FROM translation.' || lyrMetadataTableName || ' lm
      WHERE ''' || inventoryID || ''' = lower(lm.inventory_id)';
      EXECUTE queryStr INTO nbEntry;
      IF nbEntry = 0 THEN
        RAISE NOTICE 'ERROR TT_TranslateInventory(): No entry found for inventory_id ''%'' in table ''translation.%''...', inventoryID, lyrMetadataTableName;
        RETURN;
      END IF;
      RAISE NOTICE '5 - TT_TranslateInventory(): Table ''translation.%'' exists...', lyrMetadataTableName;
    
      ----------------------------------------------------------------------------------------------
      -- Extract standard info from 'inventory_metadata'
      queryStr = 'SELECT lower(standard_id) FROM public.' || invMetadataTableName || ' im
      WHERE ''' || inventoryID || '''  = lower(im.inventory_id)';
      EXECUTE queryStr INTO standardID;

      -- Extract lower and upper layer number to process
      --SELECT ARRAY[min(layer), max(layer)]
      --FROM translation.layer_metadata
      --WHERE inventory_id = 'AB06' AND STRPOS(casfri_table, 'NFL') > 0;
      queryStr = 'SELECT min(layer) layerMin, max(layer) layerMax
      FROM translation.' || lyrMetadataTableName || '
      WHERE inventory_id = ''' || upperInventoryID || ''' AND STRPOS(casfri_table, ''' || upper(casfriTable) || ''') > 0;';
      RAISE NOTICE 'queryStr=%', queryStr;
      EXECUTE queryStr INTO layerMin, layerMax;
      RAISE NOTICE '6 - TT_TranslateInventory(): Found layers % to % for ''%'' % table...', layerMin, layerMax, inventoryID, casfriTable;

      ----------------------------------------------------------------------------------------------
      -- Prepare the TT_Translate_%_%() function using the 'translation'.'%_%_%' translation table
      --SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab03_cas'); 
      RAISE NOTICE '7 - TT_TranslateInventory(): TT_Prepare() the TT_Translate_%_%() function using the ''translation''.''%_%_%'' translation table...', inventoryID, casfriTable, juridiction, standardID, casfriTable;
      PERFORM TT_Prepare('translation', juridiction || '_' || standardID || '_' || casfriTable, '_' || inventoryID || '_' || casfriTable); 

      FOR layer IN layerMin..layerMax LOOP
        ----------------------------------------------------------------------------------------------
        --For each layer, create the view mapping the rawfri attributes to the translated table ones
        --SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');
        RAISE NOTICE '8 - TT_TranslateInventory(): TT_CreateMappingView(''rawfri'', ''%'', ''%'', ''%'', 1)...', inventoryID, layer, juridiction;
        PERFORM TT_CreateMappingView('rawfri', inventoryID, layer, juridiction, 1);

        ----------------------------------------------------------------------------------------------
        -- Execute the TT_Translate_%_%() function to insert data into the casfri50.%_all table
        --INSERT INTO casfri50.cas_all  -- xmxs
        --SELECT * FROM TT_Translate_ab03_cas('rawfri', 'ab03_l1_to_ab_l1_map');
        RAISE NOTICE '9 - TT_TranslateInventory()): Insert translated data into ''casfri50.%_all'' table using TT_Translate_%_%(''rawfri'', ''%''_l%_to_%_l1_map)...', casfriTable, inventoryID, casfriTable, inventoryID, layer, juridiction;
        queryStr := 'INSERT INTO casfri50.' || casfriTable || '_all ' ||
                    ' SELECT * FROM TT_Translate_' || inventoryID || '_' || casfriTable || '(''rawfri'', ''' || inventoryID || '_l' || layer || '_to_' || juridiction || '_l1_map'');';
        EXECUTE queryStr;
        RAISE NOTICE 'To check execute: SELECT * FROM casfri50.%_all WHERE left(cas_id, 4) = ''%'';', casfriTable, upperInventoryID;
      END LOOP;
    END LOOP;
  ELSIF translationType = 'D' THEN
    FOREACH casfriTable IN ARRAY casfriTablesArr LOOP
      -- Delete existing entries
      RAISE NOTICE 'Delete ''%'' entries from ''casfri50.%_all'' table...', upperInventoryID, casfriTable;
      queryStr = 'DELETE FROM casfri50.' || casfriTable || '_all WHERE left(cas_id, 4) = ''' || upperInventoryID || ''';';
      EXECUTE queryStr;
      RAISE NOTICE 'To check execute: SELECT * FROM casfri50.%_all WHERE left(cas_id, 4) = ''%'';', casfriTable, upperInventoryID;
    END LOOP;
  ELSE
    RAISE NOTICE 'ERROR TT_TranslateInventory(): Unsupported translation type (%)...', translationType;
  END IF;
END;
$$;
--CALL TT_TranslateInventory('AB06', 'D', 'cas');
--CALL TT_TranslateInventory('Ab06', 'F', 'cas');
--CALL TT_TranslateInventory('AB06', 'F', 'nfl');