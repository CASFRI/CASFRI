------------------------------------------------------------------------------
-- CASFRI Helper functions installation file for CASFR v5 beta
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
--
--
--
-------------------------------------------------------------------------------
-- Begin Tools Function Definitions...
------------------------------------------------------------------------------- 
-- TT_TableColumnIsUnique
--
-- Return TRUE if the column values are unique. 
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_TableColumnIsUnique(name, name, name);
CREATE OR REPLACE FUNCTION TT_TableColumnIsUnique(
  schemaName name,
  tableName name,
  columnName name
)
RETURNS boolean AS $$
  DECLARE 
    isUnique boolean; 
  BEGIN
    EXECUTE 'SELECT (SELECT ' || columnName || 
           ' FROM ' || TT_FullTableName(schemaName, tableName) ||
           ' GROUP BY ' || columnName || 
           ' HAVING count(*) > 1
             LIMIT 1) IS NULL;'
    INTO isUnique;
    RETURN isUnique; 
  END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------

------------------------------------------------------------------------------- 
-- TT_TableColumnIsUnique 
--
-- Return the list of column for a table and their uniqueness. 
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_TableColumnIsUnique(name, name);
CREATE OR REPLACE FUNCTION TT_TableColumnIsUnique(
  schemaName name,
  tableName name
)
RETURNS TABLE (col_name text, is_unique boolean) AS $$
  WITH column_names AS (
    SELECT unnest(TT_TableColumnNames(schemaName, tableName)) cname
  )
  SELECT cname, TT_TableColumnIsUnique(schemaName, tableName, cname) is_unique
FROM column_names;
$$ LANGUAGE sql;
-------------------------------------------------------------------------------

------------------------------------------------------------------------------- 
-- TT_TableColumnType 
-- 
--   tableSchema name - Name of the schema containing the table. 
--   table name       - Name of the table. 
--   column name      - Name of the column. 
-- 
--   RETURNS text     - Type. 
-- 
-- Return the column names for the speficied table. 
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_TableColumnType(name, name, name);
CREATE OR REPLACE FUNCTION TT_TableColumnType( 
  schemaName name, 
  tableName name,
  columnName name
) 
RETURNS text AS $$ 
  SELECT data_type FROM information_schema.columns
  WHERE table_schema = schemaName AND table_name = tableName AND column_name = columnName;
$$ LANGUAGE sql VOLATILE; 
-------------------------------------------------------------------------------

------------------------------------------------------------------------------- 
-- TT_TableColumnNames 
-- 
--   tableSchema name - Name of the schema containing the table. 
--   table name       - Name of the table. 
-- 
--   RETURNS text[]   - ARRAY of column names. 
-- 
-- Return the column names for the speficied table. 
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_TableColumnNames(name, name);
CREATE OR REPLACE FUNCTION TT_TableColumnNames( 
  schemaName name, 
  tableName name 
) 
RETURNS text[] AS $$ 
  DECLARE 
    colNames text[]; 
  BEGIN 
    SELECT array_agg(column_name::text) 
    FROM information_schema.columns 
    WHERE table_schema = schemaName AND table_name = tableName 
    INTO STRICT colNames; 

    RETURN colNames; 
  END; 
$$ LANGUAGE plpgsql VOLATILE; 
------------------------------------------------------------------------------- 

-------------------------------------------------------------------------------
-- TT_ColumnExists
--
-- Returns true if a column exist in a table. Mainly defined to be used by 
-- ST_AddUniqueID().
-----------------------------------------------------------
-- Self contained example:
--
-- SELECT TT_ColumnExists('public', 'spatial_ref_sys', 'srid') ;
-----------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ColumnExists(name, name, name);
CREATE OR REPLACE FUNCTION TT_ColumnExists(
  schemaname name,
  tablename name,
  columnname name
)
RETURNS BOOLEAN AS $$
  DECLARE
  BEGIN
    PERFORM 1 FROM information_schema.COLUMNS
    WHERE lower(table_schema) = lower(schemaname) AND lower(table_name) = lower(tablename) AND lower(column_name) = lower(columnname);
    RETURN FOUND;
  END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CompareRows 
-- 
-- Return all different attribute values with values from row1 and row2.
-- Does not return anything when rows are identical.
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_CompareRows(jsonb, jsonb);
CREATE OR REPLACE FUNCTION TT_CompareRows(
  row1 jsonb,
  row2 jsonb
)
RETURNS TABLE (attribute text, 
               row_1 text, 
               row_2 text) AS $$ 
  DECLARE
    i int = 0;
    keys text[];
    row1val text;
    row2val text;
  BEGIN
    attribute = 'row';

    IF row1 IS NULL THEN
        row_1 = 'do not exist';
        row_2 = 'exists';
        RETURN NEXT;
        RETURN;
    END IF;
    IF row2 IS NULL THEN
        row_1 = 'exists';
        row_2 = 'do not exist';
        RETURN NEXT;
        RETURN;
    END IF;
    SELECT array_agg(k) INTO keys
    FROM (SELECT jsonb_object_keys(row1) k) foo;

    FOR i IN 1..cardinality(keys) LOOP
      row1val = row1 -> keys[i];
      row2val = row2 -> keys[i];
      IF row1val != row2val THEN
        attribute = keys[i];
        row_1 = row1val::text;
        row_2 = row2val::text;
        RETURN NEXT;
      END IF;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CompareTables 
-- 
-- Return all different attribute values with values from table 1 and table 2.
-- Does not return anything when tables are identical.
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_CompareTables(name, name, name, name, name, boolean);
CREATE OR REPLACE FUNCTION TT_CompareTables(
  schemaName1 name,
  tableName1 name,
  schemaName2 name,
  tableName2 name,
  uniqueIDCol name DEFAULT NULL,
  ignoreColumnOrder boolean DEFAULT TRUE
)
RETURNS TABLE (row_id text, 
               attribute text, 
               value_table_1 text, 
               value_table_2 text) AS $$
  DECLARE
    columnName text;
    cols1 text[];
    cols2 text[];
    type1 text;
    type2 text;
    stop boolean := FALSE;
    query text;
  BEGIN
    IF NOT TT_TableExists(schemaName1, tableName1) THEN
      RAISE EXCEPTION 'Table %.% does not exists...', schemaName1, tableName1;
    END IF;
    IF NOT TT_TableExists(schemaName2, tableName2) THEN
      RAISE EXCEPTION 'Table %.% does not exists...', schemaName2, tableName2;
    END IF;
    cols1 = TT_TableColumnNames(schemaName1, tableName1);
    cols2 = TT_TableColumnNames(schemaName2, tableName2);
    -- Check that every column in table1 exists in table2
    FOREACH columnName IN ARRAY cols1 LOOP
      IF columnName != ALL(cols2) THEN
        RAISE EXCEPTION 'Column ''%'' does not exist in %.%...', columnName, schemaName2, tableName2;
        stop = TRUE;
      ELSE
        type1 = TT_TableColumnType(schemaName1, tableName1, columnName);
        type2 = TT_TableColumnType(schemaName2, tableName2, columnName);
        IF type1 != type2 THEN
          RAISE EXCEPTION 'Column ''%'' is of type ''%'' in %.% and of type ''%'' in table %.%...', columnName, type1, schemaName1, tableName1, type2, schemaName2, tableName2;
          stop = TRUE;
        END IF;
      END IF;
    END LOOP;
    -- Check that every column in table2 exists in table1
    FOREACH columnName IN ARRAY cols2 LOOP
      IF columnName != ALL(cols1) THEN
        RAISE EXCEPTION 'Column ''%'' does not exist in %.%...', columnName, schemaName1, tableName1;
        stop = TRUE;
      END IF;
    END LOOP;
    -- Stop for now
    IF stop THEN
      RETURN;
    END IF;
    -- Now that we know both tables have the same columns, check that they are in the same order
    IF NOT ignoreColumnOrder AND cols1 != cols2 THEN
      RAISE EXCEPTION 'Columns with the same names and types exist in both tables but are not in the same order...';
      RETURN;
    END IF;
    
    -- Check that uniqueIDCol is not NULL and exists
    IF uniqueIDCol IS NULL OR uniqueIDCol = '' THEN
      RAISE EXCEPTION 'Table have same structure. In order to report different rows, uniqueIDCol should not be NULL...';
    END IF;
    IF NOT TT_ColumnExists(schemaName1, tableName1, uniqueIDCol) THEN
      RAISE EXCEPTION 'Table have same structure. In order to report different rows, uniqueIDCol (%) should exist in both tables...', uniqueIDCol;
    END IF;
    query = 'SELECT ' || uniqueIDCol || '::text row_id, (TT_CompareRows(to_jsonb(a), to_jsonb(b))).* ' ||
            'FROM ' || schemaName1 || '.' || tableName1 || ' a ' ||
            'FULL OUTER JOIN ' || schemaName2 || '.' || tableName2 || ' b USING (' || uniqueIDCol || ')' ||
            'WHERE NOT coalesce(ROW(a.*) = ROW(b.*), FALSE);';
    RETURN QUERY EXECUTE query;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_RandomInt 
-- 
-- Return a list of random nb integer from val_min to val_max (both inclusives).
-- Seed can be set to get always the same repeated list.
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_RandomInt(int, int, int, double precision);
CREATE OR REPLACE FUNCTION TT_RandomInt(
  nb int, 
  val_min int,
  val_max int,
  seed double precision
)
RETURNS TABLE (id int) AS $$
  DECLARE
    newnb int = nb * (1 + 3 * nb::double precision / (val_max - val_min + 1));
  BEGIN
--RAISE NOTICE 'newnb = %', newnb;
    IF nb < 0 THEN
      RAISE EXCEPTION 'ERROR random_int_id(): nb (%) must be greater than 0...', nb;
    END IF;
    IF nb = 0 THEN
      RETURN;
    END IF;
    IF val_max < val_min THEN
      RAISE EXCEPTION 'ERROR TT_RandomInt(): val_max (%) must be greater or equal to val_min (%)...', val_max, val_min;
    END IF;
    IF nb > (val_max - val_min + 1) THEN
      RAISE EXCEPTION 'ERROR TT_RandomInt(): nb (%) must be smaller or equal to the range of values (%)...', nb, val_max - val_min + 1;
    END IF;
    IF nb = (val_max - val_min + 1) THEN
       RAISE NOTICE 'nb is equal to the range of requested values. Returning a series from % to %...', val_min, val_min + nb - 1;
       RETURN QUERY SELECT val_min + generate_series(0, nb - 1);
       RETURN;
    END IF;
    IF nb > (val_max - val_min + 1) / 2 THEN
       RAISE NOTICE 'nb is greater than half the range of requested values. Returning a % to % series EXCEPT TT_RandomInt(%, %, %, %)...', val_min, val_min + val_max - val_min, (val_max - val_min + 1) - nb, val_min, val_max, seed;
       RETURN QUERY SELECT * FROM (
                      SELECT val_min + generate_series(0, val_max - val_min) id
                      EXCEPT 
                      SELECT TT_RandomInt((val_max - val_min + 1) - nb, val_min, val_max, seed)
                    ) foo ORDER BY id;
       RETURN;
    END IF;
--RAISE NOTICE 'seed = %', nb / (nb + abs(seed) + 1);
    PERFORM setseed(nb / (nb + abs(seed) + 1));
    RETURN QUERY WITH rd AS (
                   SELECT (val_min + floor((val_max - val_min + 1) * foo.rd))::int id, foo.rd
                   FROM (SELECT generate_series(1, newnb), random() rd) foo
                 ), list AS (
                   SELECT DISTINCT rd.id 
                   FROM rd LIMIT nb
                 ) SELECT * FROM list ORDER BY id;
  END;
$$ LANGUAGE plpgsql;
------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_RandomInt(int, int, int);
CREATE OR REPLACE FUNCTION TT_RandomInt(
  nb int, 
  val_min int,
  val_max int
)
RETURNS SETOF int AS $$
  SELECT TT_RandomInt(nb, val_min, val_max, random());
$$ LANGUAGE sql;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CreateMappingView 
-- 
-- Return a view mapping attributes of fromTableName to attributes of toTableName
-- according to the translation.attribute_dependencies table.
-- Can also be used to create a view selecting the minimal set of useful attribute
-- and to get a random sample of the source table when randomNb is provided.
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(name, name, int, name, int, int); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName name, 
  fromTableName name,
  fromLayer int,
  toTableName name,
  toLayer int,
  randomNb int DEFAULT NULL
) 
RETURNS text AS $$ 
  DECLARE
      queryStr text;
      attribute_map text;
      nb int;
      viewName text;
  BEGIN
    -- Check if table 'attribute_dependencies' exists
    IF NOT TT_TableExists('translation', 'attribute_dependencies') THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): Could not find table ''translation.dependencies''...';
      RETURN 'ERROR: Could not find table ''translation.dependencies''...';
    END IF;

    -- Check if table fromTableName exists
    IF NOT TT_TableExists(schemaName, fromTableName) THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): Could not find table ''translation.%''...', fromTableName;
      RETURN 'ERROR: Could not find table ''translation..' || fromTableName || '''...';
    END IF;

    -- Check if table fromTableName exists
    IF NOT TT_TableExists(schemaName, toTableName) THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): Could not find table ''translation.%''...', toTableName;
      RETURN 'ERROR: Could not find table ''translation.' || toTableName || '''...';
    END IF;

    -- Check if an entry for fromTableName, fromLayer exists in table 'attribute_dependencies'
    SELECT count(*) FROM translation.attribute_dependencies
    WHERE lower(btrim(btrim(inventory_id, ' '), '''')) = lower(fromTableName) AND layer = fromLayer::text
    INTO nb;
    IF nb = 0 THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): No entry found for inventory_id ''%'' layer % in table ''translation.dependencies''...', fromTableName, fromLayer;
      RETURN 'ERROR: No entry could be found for inventory_id '''  || fromTableName || ''' layer ' || fromLayer || ' in table ''translation.dependencies''...';
    ELSIF nb > 1 THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): More than one entry match inventory_id ''%'' layer % in table ''translation.dependencies''...', fromTableName, fromLayer;
      RETURN 'ERROR: More than one entry match inventory_id '''  || fromTableName || ''' layer ' || fromLayer || ' in table ''translation.dependencies''...';
    END IF;

    -- Check if an entry for toTableName, toLayer exists in table 'attribute_dependencies'
    SELECT count(*) FROM translation.attribute_dependencies
    WHERE lower(btrim(btrim(inventory_id, ' '), '''')) = lower(toTableName) AND layer = toLayer::text
    INTO nb;
    IF nb = 0 THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): No entry found for inventory_id ''%'' layer % in table ''translation.dependencies''...', toTableName, toLayer;
      RETURN 'ERROR: No entry could be found for inventory_id '''  || toTableName || ''' layer ' || toLayer || ' in table ''translation.dependencies''...';
    ELSIF nb > 1 THEN
      RAISE NOTICE 'ERROR TT_CreateMappingView(): More than one entry match inventory_id ''%'' layer % in table ''translation.dependencies''...', toTableName, toLayer;
      RETURN 'ERROR: More than one entry match inventory_id '''  || toTableName || ''' layer ' || toLayer || ' in table ''translation.dependencies''...';
    END IF;

    -- Build the attribute mapping
    WITH from_att AS (
      SELECT (jsonb_each(to_jsonb(a.*))).*
      FROM translation.attribute_dependencies a
      WHERE lower(btrim(btrim(inventory_id, ' '), '''')) = lower(fromTableName) AND layer = fromLayer::text
    ), to_att AS (
      SELECT (jsonb_each(to_jsonb(a.*))).*
      FROM translation.attribute_dependencies a
      WHERE lower(btrim(btrim(inventory_id, ' '), '''')) = lower(toTableName) AND layer = toLayer::text
    ), splitted AS (
      SELECT from_att.key, 
         trim(regexp_split_to_table(btrim(from_att.value::text, '"'), E',')) from_att, 
         trim(regexp_split_to_table(btrim(to_att.value::text, '"'), E',')) to_att
      FROM from_att, to_att
      WHERE from_att.key = to_att.key AND from_att.key != 'ogc_fid' AND from_att.key != 'ttable_exists'
    ), mapping AS (
      SELECT DISTINCT ON (to_att)
         --key, from_att orig_from_att, TT_IsName(from_att), to_att orig_to_att, TT_IsName(to_att),
         CASE WHEN TT_IsName(from_att) THEN from_att
              ELSE '''' || btrim(from_att, '''') || ''''
         END from_att,
         CASE WHEN TT_IsName(to_att) THEN to_att
              WHEN TT_IsName(from_att) THEN from_att
              ELSE key
         END to_att
      FROM splitted
      WHERE TT_NotEmpty(from_att)
      ORDER BY to_att, from_att
    )
    SELECT string_agg(from_att || CASE WHEN from_att = to_att THEN '' ELSE ' ' || to_att END, ', ')
    FROM mapping INTO attribute_map;
--RAISE NOTICE 'attribute_map=%', attribute_map;

    viewName = TT_FullTableName(schemaName, fromTableName || 
               CASE WHEN fromTableName = toTableName AND fromLayer = toLayer THEN '_min' 
                    ELSE '_l' || fromLayer || '_to_' || toTableName || '_l' || toLayer || '_map' 
               END || coalesce('_' || randomNb, ''));
    -- Build the VIEW query
    queryStr = 'DROP VIEW IF EXISTS ' || viewName || ' CASCADE;CREATE OR REPLACE VIEW ' || viewName || ' AS' ||
              ' SELECT ' || attribute_map || 
              ' FROM ' || TT_FullTableName(schemaName, fromTableName) || ' r';

    -- Make it random if requested
    IF randomNb IS NULL THEN
      queryStr = queryStr || ';';
    ELSE
      EXECUTE 'SELECT count(*) FROM ' || TT_FullTableName(schemaName, fromTableName) INTO nb;
      queryStr = queryStr || ', TT_RandomInt(' || randomNb || ', 1, ' || nb || ', 1.0) rd WHERE rd.id = r.ogc_fid;';
    END IF;
    RAISE NOTICE 'TT_CreateMappingView(): Creating VIEW ''%''...', viewName;
    EXECUTE queryStr;
    RETURN queryStr;
  END; 
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMappingView(name, name, name, int); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName name, 
  fromTableName name,
  toTableName name,
  randomNb int DEFAULt NULL
) 
RETURNS text AS $$ 
  SELECT TT_CreateMappingView(schemaName, fromTableName, 1, toTableName, 1, randomNb);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMappingView(name, name, int); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName name, 
  tableName name,
  randomNb int DEFAULt NULL
) 
RETURNS text AS $$ 
  SELECT TT_CreateMappingView(schemaName, tableName, 1, tableName, 1, randomNb);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------
-- Overwrrite the TT_DefaultProjectErrorCode() function to define default error 
-- codes for these helper functions...
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DefaultProjectErrorCode(text, text);
CREATE OR REPLACE FUNCTION TT_DefaultProjectErrorCode(
  rule text, 
  targetType text
)
RETURNS text AS $$
  DECLARE
    rulelc text = lower(rule);
    targetTypelc text = lower(targetType);
  BEGIN
    IF targetTypelc = 'integer' OR targetTypelc = 'int' OR targetTypelc = 'double precision' THEN 
      RETURN CASE WHEN rulelc = 'projectrule1' THEN '-9999'
                  ELSE TT_DefaultErrorCode(rulelc, targetTypelc) END;
    ELSIF targetTypelc = 'geometry' THEN
      RETURN CASE WHEN rulelc = 'projectrule1' THEN NULL
                  ELSE TT_DefaultErrorCode(rulelc, targetTypelc) END;
    ELSE
      RETURN CASE WHEN rulelc = 'nbi01_wetland_validation' THEN 'NOT_APPLICABLE'
                  WHEN rulelc = 'vri01_nat_non_veg_validation' THEN 'INVALID_VALUE'
                  WHEN rulelc = 'vri01_non_for_anth_validation' THEN 'INVALID_VALUE'
                  WHEN rulelc = 'vri01_non_for_veg_validation' THEN 'INVALID_VALUE'
                  ELSE TT_DefaultErrorCode(rulelc, targetTypelc) END;
    END IF;
  END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-------------------------------------------------------------------------------
-- TT_vri01_non_for_veg_validation(text, text, text, text)
--
-- Check the correct combination of values exists based on the translation rules.
-- If not return FALSE
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_veg_validation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text
)
RETURNS boolean AS $$
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('AF', 'M', 'NPBR', 'OR') THEN
        RETURN TRUE;
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        RETURN TRUE;
      END IF;
    END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_nat_non_veg_validation(text, text, text, text, text)
--
-- Check the correct combination of values exists based on the translation rules.
-- If not return FALSE
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_validation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_nat_non_veg_validation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS boolean AS $$
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'DW', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RS', 'TA') THEN
        RETURN TRUE;
      END IF;
    END IF;

    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'EL', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RO', 'RS', 'SI', 'TA') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('A', 'CL', 'G', 'ICE', 'L', 'MUD', 'R', 'RIV', 'S', 'SAND', 'TIDE') THEN
        RETURN TRUE;
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        RETURN TRUE;
      END IF;
    END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_anth_validation(text, text, text, text)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_anth_validation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS boolean AS $$
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        RETURN TRUE;
      END IF;
    END IF;
        
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        RETURN TRUE;
      END IF;
    END IF;
        
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('C', 'GR', 'P', 'U') THEN
        RETURN TRUE;
      END IF;
    END IF;    
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_code(
  wc text,
  vt text,
  im text
)
RETURNS text AS $$
  SELECT CASE
           WHEN wc='BO' AND vt='EV' AND im='BP' THEN 'BO-B'
           WHEN wc='FE' AND vt='EV' AND im='BP' THEN 'FO-B'
           WHEN wc='BO' AND vt='EV' AND im='DI' THEN 'BO--'
           WHEN wc='BO' AND vt='AW' AND im='BP' THEN 'BT-B'
           WHEN wc='BO' AND vt='OV' AND im='BP' THEN 'OO-B'
           WHEN wc='FE' AND vt='EV' AND im IN ('MI', 'DI') THEN 'FO--'
           WHEN wc='FE' AND vt='OV' AND im='MI' THEN 'OO--'
           WHEN wc='BO' AND vt='FS' THEN 'BTNN'
           WHEN wc='BO' AND vt='SV' THEN 'BONS'
           WHEN wc='FE' AND vt IN ('FH', 'FS') THEN 'FTNN'
           WHEN wc='FE' AND vt IN ('AW', 'SV') THEN 'FONS'
           WHEN wc='FW' AND im='BP' THEN 'OF-B'
           WHEN wc='FE' AND vt='EV' THEN 'FO--'
           WHEN wc IN ('FE', 'BO') AND vt='OV' THEN 'OO--'
           WHEN wc IN ('FE', 'BO') AND vt='OW' THEN 'O---'
           WHEN wc='BO' AND vt='EV' THEN 'BP--'
           WHEN wc='BO' AND vt='AW' THEN 'BT--'
           WHEN wc='AB' THEN 'OONN'
           WHEN wc='FM' THEN 'MONG'
           WHEN wc='FW' THEN 'STNN'
           WHEN wc='SB' THEN 'SONS'
           WHEN wc='CM' THEN 'MCNG'
           WHEN wc='TF' THEN 'TMNN'
           WHEN wc IN ('NP', 'WL') THEN 'W---'
           ELSE NULL
         END;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nbi01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_validation(
  wc text,
  vt text,
  im text,
	ret_char_pos text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_wetland_validation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	wetland_code = TT_nbi01_wetland_code(wc, vt, im);

    -- return true or false
    IF wetland_code IS NULL OR substring(wetland_code from ret_char_pos::int for 1) = '-' THEN
      RETURN FALSE;
		END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Translation Function Definitions...
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_vri01_origin_translation(text, text)
--
-- get projected year as first 4 characters of proj_date  
-- return projected year minus projected age
-- Validation should ensure projected year substring is an integer using TT_vri01_origin_validation,
-- and that projected age is not zero using TT_IsNotEqualToInt()
-- 
-- e.g. TT_vri01_origin_translation(proj_date, proj_age)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_origin_translation(text, text);
CREATE OR REPLACE FUNCTION TT_vri01_origin_translation(
  proj_date text,
  proj_age text
)
RETURNS integer AS $$
  BEGIN
    RETURN substring(proj_date from 1 for 4)::int - proj_age::int;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_site_index_translation(text, text)
--
-- If site_index not null, return it.
-- Otherwise return site_index_est.
-- If both are null, TT_vri01_site_index_validation should return error.
-- 
-- e.g. TT_vri01_site_index_translation(site_index, site_index_est)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_site_index_translation(text, text);
CREATE OR REPLACE FUNCTION TT_vri01_site_index_translation(
  site_index text,
  site_index_est text
)
RETURNS double precision AS $$
  BEGIN
    IF TT_NotEmpty(site_index) THEN
      RETURN site_index::double precision;
    ELSIF NOT TT_NotEmpty(site_index) AND TT_NotEmpty(site_index_est) THEN
      RETURN site_index_est::double precision;
	  END IF;
		RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_veg_translation(text, text, text, text)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_veg_translation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text
)
RETURNS text AS $$
  DECLARE
    result text = NULL;
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        result = TT_MapText(land_cover_class_cd_1, '{''BL'', ''BM'', ''BY'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}', '{''BR'', ''BR'', ''BR'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        result = TT_MapText(bclcs_level_4, '{''BL'', ''BM'', ''BY'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}', '{''BR'', ''BR'', ''BR'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('AF', 'M', 'NPBR', 'OR') THEN
        result = TT_MapText(non_productive_descriptor_cd, '{''AF'', ''M'', ''NPBR'', ''OR''}', '{''AF'', ''HG'', ''ST'', ''HG''}');
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        result = TT_MapText(bclcs_level_4, '{''BL'', ''BM'', ''BY'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}', '{''BR'', ''BR'', ''BR'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}');
      END IF;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_nat_non_veg_translation(text, text, text, text, text)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_translation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_nat_non_veg_translation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS text AS $$
  DECLARE
    result text = NULL;
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'DW', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RS', 'TA') THEN
        result = TT_MapText(non_veg_cover_type_1, '{''BE'', ''BI'', ''BR'', ''BU'', ''CB'', ''DW'', ''ES'', ''GL'', ''LA'', ''LB'', ''LL'', ''LS'', ''MN'', ''MU'', ''OC'', ''PN'', ''RE'', ''RI'', ''RM'', ''RS'', ''TA''}', '{''BE'', ''RK'', ''RK'', ''EX'', ''EX'', ''DW'', ''EX'', ''SI'', ''LA'', ''RK'', ''EX'', ''WS'', ''EX'', ''WS'', ''OC'', ''SI'', ''LA'', ''RI'', ''EX'', ''WS'', ''RK''}');
      END IF;
    END IF;

    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL AND result IS NULL THEN
      IF land_cover_class_cd_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'EL', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RO', 'RS', 'SI', 'TA') THEN
        result = TT_MapText(land_cover_class_cd_1, '{''BE'', ''BI'', ''BR'', ''BU'', ''CB'', ''EL'', ''ES'', ''GL'', ''LA'', ''LB'', ''LL'', ''LS'', ''MN'', ''MU'', ''OC'', ''PN'', ''RE'', ''RI'', ''RM'', ''RO'', ''RS'', ''SI'', ''TA''}', '{''BE'', ''RK'', ''RK'', ''EX'', ''EX'', ''EX'', ''EX'', ''SI'', ''LA'', ''RK'', ''EX'', ''WS'', ''EX'', ''WS'', ''OC'', ''SI'', ''LA'', ''RI'', ''EX'', ''RK'', ''WS'', ''SI'', ''RK''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        result = TT_MapText(bclcs_level_4, '{''EL'', ''RO'', ''SI''}', '{''EX'', ''RK'', ''SI''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('A', 'CL', 'G', 'ICE', 'L', 'MUD', 'R', 'RIV', 'S', 'SAND', 'TIDE') THEN
        result = TT_MapText(non_productive_descriptor_cd, '{''A'', ''CL'', ''G'', ''ICE'', ''L'', ''MUD'', ''R'', ''RIV'', ''S'', ''SAND'', ''TIDE''}', '{''AP'', ''EX'', ''WS'', ''SI'', ''LA'', ''EX'', ''RK'', ''RI'', ''SL'', ''SA'', ''TF''}');
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        result = TT_MapText(bclcs_level_4, '{''EL'', ''RO'', ''SI''}', '{''EX'', ''RK'', ''SI''}');
      END IF;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_anth_translation(text, text, text, text)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_anth_translation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS text AS $$
  DECLARE
    result text = NULL;
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        result = TT_MapText(non_veg_cover_type_1, '{''AP'', ''GP'', ''MI'', ''MZ'', ''OT'', ''RN'', ''RZ'', ''TZ'', ''UR''}', '{''FA'', ''IN'', ''IN'', ''IN'', ''OT'', ''FA'', ''FA'', ''IN'', ''FA''}');
      END IF;
    END IF;
        
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL AND result IS NULL THEN
      IF land_cover_class_cd_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        result = TT_MapText(land_cover_class_cd_1, '{''AP'', ''GP'', ''MI'', ''MZ'', ''OT'', ''RN'', ''RZ'', ''TZ'', ''UR''}', '{''FA'', ''IN'', ''IN'', ''IN'', ''OT'', ''FA'', ''FA'', ''IN'', ''FA''}');
      END IF;
    END IF;
        
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('C', 'GR', 'P', 'U') THEN
        result = TT_MapText(non_productive_descriptor_cd, '{''C'', ''GR'', ''P'', ''U''}', '{''CL'', ''IN'', ''CL'', ''FA''}');
      END IF;
    END IF;
    
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- THIS COULD BECOME A GENERIC FUNCTION IF IT'S USEFUL IN OTHER FRIs
--
-- TT_avi01_non_for_anth_translation(text, text, text, text, text)
--
--  For two values, if one of them is null or empty and the other is not null or empty.
--  use the value that is not null or empty in mapText.
--
-- e.g. TT_avi01_non_for_anth_translation(val1, val2, lst1, lst2, ignoreCase)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_avi01_non_for_anth_translation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_avi01_non_for_anth_translation(
  val1 text,
  val2 text,
  lst1 text,
  lst2 text,
  ignoreCase text)
RETURNS text AS $$
  BEGIN
    PERFORM TT_ValidateParams('TT_avi01_non_for_anth_translation',
                              ARRAY['lst1', lst1, 'stringlist',
                                    'lst2', lst2, 'stringlist',  
                                    'ignoreCase', ignoreCase, 'boolean']);

    IF NOT TT_NotEmpty(val1) AND TT_NotEmpty(val2) THEN
      RETURN TT_MapText(val2, lst1, lst2, ignoreCase);
    ELSIF TT_NotEmpty(val1) AND NOT TT_NotEmpty(val2) THEN
      RETURN TT_MapText(val1, lst1, lst2, ignoreCase);
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_stand_structure_translation(text, text, text)
--
-- If src_filename=“Forest” and l2vs=0, then stand_structure=“S”
-- If src_filename=“Forest” and (l1vs>0 and l2vs>0) then stand_structure=“M”
-- If src_filename=“Forest” and (l1vs>1 and l2vs>1) then stand_structure=“C”
--
-- For NB01 src_filename should match 'Forest'.
-- For NB02 src_filename should match 'geonb_forest-foret'.
--
-- e.g. TT_nbi01_stand_structure_translation(src_filename, l1vs, l2vs)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_stand_structure_translation(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_stand_structure_translation(
  src_filename text,
  l1vs text,
  l2vs text
)
RETURNS text AS $$
  DECLARE
    _l1vs int;
    _l2vs int;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_stand_structure_translation',
                              ARRAY['src_filename', src_filename, 'text',
                                    'l1vs', l1vs, 'int',  
                                    'l2vs', l2vs, 'int']);
    _l1vs = l1vs::int;
    _l2vs = l2vs::int;
		
	IF src_filename IN ('Forest', 'geonb_forest-foret') THEN
	  IF _l2vs = 0 THEN
		RETURN 'S';
	  ELSIF _l1vs > 1 AND _l2vs > 1 THEN
		  RETURN 'C';
	  ELSIF _l1vs > 0 AND _l2vs > 0 THEN
		  RETURN 'M';
	  END IF;
	END IF;				
	RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_num_of_layers_translation(text, text, text)
--
-- If src_filename=“Forest” stand_structure = S, num_of_layers = 1.
-- If src_filename=“Forest” stand_structure = M or C, then stand_structure=“M”
--
-- For NB01 src_filename should match 'Forest'.
-- For NB02 src_filename should match 'geonb_forest-foret'.
--
-- e.g. TT_nbi01_num_of_layers_translation(src_filename, l1vs, l2vs)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_num_of_layers_translation(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_num_of_layers_translation(
  src_filename text,
  l1vs text,
  l2vs text
)
RETURNS int AS $$
  DECLARE
    _l1vs int;
    _l2vs int;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_num_of_layers_translation',
                              ARRAY['src_filename', src_filename, 'text',
                                    'l1vs', l1vs, 'int',  
                                    'l2vs', l2vs, 'int']);
		
		IF src_filename IN ('Forest', 'geonb_forest-foret') THEN
		  IF TT_nbi01_stand_structure_translation(src_filename, l1vs, l2vs) = 'S' THEN
			  RETURN 1;
			ELSIF TT_nbi01_stand_structure_translation(src_filename, l1vs, l2vs) IN ('M', 'C') THEN
			  RETURN 2;
		  END IF;
		END IF;				
		RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nbi01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_translation(
  wc text,
  vt text,
  im text,
  ret_char_pos text
)
RETURNS text AS $$
  DECLARE
	wetland_code text;
    result text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_wetland_translation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	wetland_code = TT_nbi01_wetland_code(wc, vt, im);

    -- substring wetland_code
    IF wetland_code IS NOT NULL THEN
      result = substring(wetland_code from ret_char_pos::int for 1);
    END IF;
    
    -- return value or null
    IF wetland_code IS NULL OR result = '-' THEN
      RETURN NULL;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_nb01_productive_for_translation(text, text, text, text, text)
--
-- If no valid crown closure value, or no valid height value. Assign PP.
-- Or if forest stand type is 0, and l1 or l2 trt is neither CC or empty string. Assign PP.
-- Otherwise assign PF (productive forest).
--
-- e.g. TT_nbi01_nb01_productive_for_translation(l1cc, l1ht, l1trt, l2trt, fst)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_nb01_productive_for_translation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_nb01_productive_for_translation(
  l1cc text,
  l1ht text,
  l1trt text,
  l2trt text,
  fst text
)
RETURNS text AS $$
  BEGIN
    IF NOT TT_NotNull(l1cc) THEN
      RETURN 'PP';
    ELSIF NOT TT_MatchList(l1cc, '{''1'', ''2'', ''3'', ''4'', ''5''}') THEN
      RETURN 'PP';
    ELSEIF NOT TT_NotNull(l1ht) THEN
      RETURN 'PP';
    ELSIF NOT TT_IsGreaterThan(l1ht, '0.1') THEN
      RETURN 'PP';
    ELSIF NOT TT_IsLessThan(l1ht, '100') THEN
      RETURN 'PP';
    ELSIF fst = '0'::text AND l1trt != 'CC' AND btrim(l1trt, ' ') != '' THEN
      RETURN 'PP';
    ELSIF fst = '0'::text AND l2trt != 'CC' AND btrim(l2trt, ' ') != '' THEN
      RETURN 'PP';
    END IF;
    RETURN 'PF';
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------
-- TT_nbi01_nb02_productive_for_translation(text, text, text, text, text)
--
--  2 options for PRODUCTIVE_FOR, replicating NB02 using trt, l1cc, l1ht, l1s1.
--  Or using fst.
--  Here I`m using the simpler fst method until issue #181
--
-- If no valid crown closure value, or no valid height value. Assign PP.
-- Or if forest stand type is 0, and l1 or l2 trt is neither CC or empty string. Assign PP.
-- Otherwise assign PF (productive forest).
--
-- e.g. TT_nbi01_nb02_productive_for_translation(fst)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_nb02_productive_for_translation(text);
CREATE OR REPLACE FUNCTION TT_nbi01_nb02_productive_for_translation(
  fst text
)
RETURNS text AS $$
  DECLARE
    _fst int;
  BEGIN
    _fst = fst::int;
	
    IF _fst IN (1, 2) THEN
	  RETURN 'PF';
	ELSIF _fst = 3 THEN
	  RETURN 'PP';
	END IF;
	RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;