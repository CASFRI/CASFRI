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
-------------------------------------------------------------------------------
-- Begin Tools Function Definitions...
------------------------------------------------------------------------------- 
-- TT_TableColumnType 
-- 
--   tableSchema name - Name of the schema containing the table. 
--   table name       - Name of the table. 
--   column name      - Name of the column. 
-- 
--   RETURNS text     - Type. 
-- 
-- Return the column names for the specified table. 
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
--DROP FUNCTION IF EXISTS TT_RandomInt(int, int, int);
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
-- TT_Histogram 
-- 
-- Set function returnings a table representing an histogram of the values
-- for the specifed column.
--
-- The return table contains 3 columns:
--
--   'intervals' is a text column specifiing the lower and upper bounds of the
--               intervals (or bins). Start with '[' when the lower bound is
--               included in the interval and with ']' when the lowerbound is
--               not included in the interval. Complementarily ends with ']'
--               when the upper bound is included in the interval and with '['
--               when the upper bound is not included in the interval.
--
--   'cnt' is a integer column specifying the number of occurrence of the value
--         in this interval (or bin).
--
--   'query' is the query you can use to generate the rows accounted for in this
--           interval.
--
-- Self contained and typical example:
--
-- CREATE TABLE histogramtest AS
-- SELECT * FROM (VALUES (1), (2), (2), (3), (4), (5), (6), (7), (8), (9), (10)) AS t (val);
--
-- SELECT * FROM TT_Histogram('test', 'histogramtest1', 'val');
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_Histogram(text, text, text, int, text);
CREATE OR REPLACE FUNCTION TT_Histogram(
    schemaname text,
    tablename text,
    columnname text,
    nbinterval int DEFAULT 10, -- number of bins
    whereclause text DEFAULT NULL -- additional where clause
)
RETURNS TABLE (intervals text, cnt int, query text) AS $$
    DECLARE
    fqtn text;
    query text;
    newschemaname name;
    findnewcolumnname boolean := FALSE;
    newcolumnname text;
    columnnamecnt int := 0;
    whereclausewithwhere text := '';
    minval double precision := 0;
    maxval double precision := 0;
    columntype text;
    BEGIN
        IF nbinterval IS NULL THEN
            nbinterval = 10;
        END IF;
        IF nbinterval <= 0 THEN
            RAISE NOTICE 'nbinterval is smaller or equal to zero. Returning nothing...';
            RETURN;
        END IF;
        IF whereclause IS NULL OR whereclause = '' THEN
            whereclause = '';
        ELSE
            whereclausewithwhere = ' WHERE ' || whereclause || ' ';
            whereclause = ' AND (' || whereclause || ')';
        END IF;
        newschemaname := '';
        IF length(schemaname) > 0 THEN
            newschemaname := schemaname;
        ELSE
            newschemaname := 'public';
        END IF;
        fqtn := quote_ident(newschemaname) || '.' || quote_ident(tablename);

        -- Build an histogram with the column values.
        IF TT_ColumnExists(newschemaname, tablename, columnname) THEN

            -- Precompute the min and max values so we can set the number of interval to 1 if they are equal
            query = 'SELECT min(' || columnname || '), max(' || columnname || ') FROM ' || fqtn || whereclausewithwhere;
            EXECUTE QUERY query INTO minval, maxval;
            IF maxval IS NULL AND minval IS NULL THEN
                query = 'WITH values AS (SELECT ' || columnname || ' val FROM ' || fqtn || whereclausewithwhere || '),
                              histo  AS (SELECT count(*) cnt FROM values)
                         SELECT ''NULL''::text intervals,
                                cnt::int,
                                ''SELECT * FROM ' || fqtn || ' WHERE ' || columnname || ' IS NULL' || whereclause || ';''::text query
                         FROM histo;';
                RETURN QUERY EXECUTE query;
            ELSE
                IF maxval - minval = 0 THEN
                    RAISE NOTICE 'maximum value - minimum value = 0. Will create only 1 interval instead of %...', nbinterval;
                    nbinterval = 1;
                END IF;

                -- We make sure double precision values are converted to text using the maximum number of digits before computing summaries involving this type of values
                query = 'SELECT pg_typeof(' || columnname || ')::text FROM ' || fqtn || ' LIMIT 1';
                EXECUTE query INTO columntype;
                IF left(columntype, 3) != 'int' THEN
                    SET extra_float_digits = 3;
                END IF;

                -- Compute the histogram
                query = 'WITH values AS (SELECT ' || columnname || ' val FROM ' || fqtn || whereclausewithwhere || '),
                              bins   AS (SELECT val, CASE WHEN val IS NULL THEN -1 ELSE least(floor((val - ' || minval || ')*' || nbinterval || '::numeric/(' || (CASE WHEN maxval - minval = 0 THEN maxval + 0.000000001 ELSE maxval END) - minval || ')), ' || nbinterval || ' - 1) END bin, ' || (maxval - minval) || '/' || nbinterval || '.0 binrange FROM values),
                              histo  AS (SELECT bin, count(*) cnt FROM bins GROUP BY bin)
                         SELECT CASE WHEN serie = -1 THEN ''NULL''::text ELSE ''['' || (' || minval || ' + serie * binrange)::float8::text || '' - '' || (CASE WHEN serie = ' || nbinterval || ' - 1 THEN ' || maxval || '::float8::text || '']'' ELSE (' || minval || ' + (serie + 1) * binrange)::float8::text || ''['' END) END intervals,
                                coalesce(cnt, 0)::int cnt,
                                (''SELECT * FROM ' || fqtn || ' WHERE ' || columnname || ''' || (CASE WHEN serie = -1 THEN '' IS NULL'' || ''' || whereclause || ''' ELSE ('' >= '' || (' || minval || ' + serie * binrange)::float8::text || '' AND ' || columnname || ' <'' || (CASE WHEN serie = ' || nbinterval || ' - 1 THEN ''= '' || ' || maxval || '::float8::text ELSE '' '' || (' || minval || ' + (serie + 1) * binrange)::float8::text END) || ''' || whereclause || ''' || '' ORDER BY ' || columnname || ''') END) || '';'')::text query
                         FROM generate_series(-1, ' || nbinterval || ' - 1) serie
                              LEFT OUTER JOIN histo ON (serie = histo.bin),
                              (SELECT * FROM bins LIMIT 1) foo
                         ORDER BY serie;';
                RETURN QUERY EXECUTE query;
                IF left(columntype, 3) != 'int' THEN
                    RESET extra_float_digits;
                END IF;
            END IF;
        ELSE
            RAISE NOTICE '''%'' does not exists. Returning nothing...',columnname::text;
            RETURN;
        END IF;

        RETURN;
    END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ArrayDistinct
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ArrayDistinct(anyarray, boolean);
CREATE OR REPLACE FUNCTION TT_ArrayDistinct(
  anyarray, 
  purgeNulls boolean DEFAULT FALSE, 
  purgeEmptys boolean DEFAULT FALSE
) 
RETURNS anyarray AS $$
  WITH numbered AS (
    SELECT ROW_NUMBER() OVER() rn, x
    FROM unnest($1) x 
    WHERE (purgeNulls IS FALSE OR NOT x IS NULL) AND (purgeEmptys IS FALSE OR TT_NotEmpty(x::text))
  ), distincts AS (
    SELECT x, min(rn) rn FROM numbered GROUP BY x ORDER BY rn
)
SELECT array_agg(x) FROM distincts
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_DeleteAllViews
--
-- schemaName text
--
-- Delete all view in the specified schema.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_DeleteAllViews(text);
CREATE OR REPLACE FUNCTION TT_DeleteAllViews(
  schemaName text
)
RETURNS SETOF text AS $$
  DECLARE
    res RECORD;
  BEGIN
    FOR res IN SELECT 'DROP VIEW IF EXISTS ' || TT_FullTableName(schemaName, table_name) || ';' query
               FROM information_schema.tables 
               WHERE lower(table_schema) = lower(schemaName) AND table_type = 'VIEW'
               ORDER BY table_name LOOP
      EXECUTE res.query;
      RETURN NEXT res.query;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CountEstimate
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CountEstimate(text);
CREATE OR REPLACE FUNCTION TT_CountEstimate(query text)
RETURNS integer AS $$
  DECLARE
    rec record;
    rows integer;
  BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
      rows := substring(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
      EXIT WHEN rows IS NOT NULL;
    END LOOP;
    RETURN rows;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CreateMapping
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMapping(text, text, int, name, int); 
CREATE OR REPLACE FUNCTION TT_CreateMapping( 
  schemaName text, 
  fromTableName text,
  fromLayer int,
  toTableName text,
  toLayer int
) 
RETURNS TABLE (num int, key text, from_att text, to_att text, contributing boolean) AS $$
  WITH colnames AS (
    SELECT TT_TableColumnNames('translation', 'attribute_dependencies') col_name_arr
  ), colnames_num AS (
    SELECT generate_series(1, cardinality(col_name_arr)) num, unnest(col_name_arr) colname
    FROM colnames
  ), from_att AS (
    -- Vertical table of all 'from' attribute mapping
    SELECT (jsonb_each(to_jsonb(a.*))).*
    FROM translation.attribute_dependencies a
    WHERE lower(btrim(btrim(inventory_id, ' '), '''')) = lower(fromTableName) AND layer = fromLayer::text
  ), to_att AS (
    -- Vertical table of all 'to' attribute mapping
    SELECT (jsonb_each(to_jsonb(a.*))).*
    FROM translation.attribute_dependencies a
    WHERE lower(btrim(btrim(inventory_id, ' '), '''')) = lower(toTableName) AND layer = toLayer::text
  ), splitted AS (
    -- Splitted by comma, still vertically
    SELECT colnames_num.num, from_att.key, 
           --rtrim(ltrim(trim(regexp_split_to_table(btrim(from_att.value::text, '"'), E',')), '['), ']') from_att, 
           trim(regexp_split_to_table(btrim(from_att.value::text, '"'), E',')) from_att, 
           trim(regexp_split_to_table(btrim(to_att.value::text, '"'), E',')) to_att
    FROM from_att, to_att, colnames_num
    WHERE colnames_num.colname = from_att.key AND 
          from_att.key = to_att.key AND 
          from_att.key != 'ogc_fid' AND 
          from_att.key != 'ttable_exists'
  )
  SELECT num, key,
         rtrim(ltrim(from_att, '['), ']') from_att,
         rtrim(ltrim(to_att, '['), ']') to_att,
         CASE WHEN left(from_att, 1) = '[' AND right(from_att, 1) = ']' THEN FALSE
              ELSE TRUE
         END contributing
  FROM splitted;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CreateMappingView 
-- 
-- Return a view mapping attributes of fromTableName to attributes of toTableName
-- according to the translation.attribute_dependencies table.
-- Can also be used to create a view selecting the minimal set of useful attribute
-- and to get a random sample of the source table when randomNb is provided.
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, int, int, text, text); 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, int, int, text); 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, int, int);
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, int); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName text, 
  fromTableName text,
  fromLayer int,
  toTableName text,
  toLayer int,
  randomNb int DEFAULT NULL,
  rowSubset text DEFAULT NULL,
  viewNameSuffix text DEFAULT NULL
) 
RETURNS text AS $$ 
  DECLARE
    queryStr text;
    viewName text;
    mappingRec RECORD;
    sourceTableCols text[] = '{}';
    attributeMapStr text;
    attributeArr text[] = '{}';
    whereExpArr text[] = '{}';
    whereExpLyrAddArr text[] = '{}';
    whereExpLyrNFLArr text[] = '{}';
    whereExpStr text = '';
    nb int;
    attName text;
    filteredTableName text;
    filteredNbColName text;
    attributeList boolean = FALSE;
    validRowSubset boolean = FALSE;
    attListViewName text = '';
    rowSubsetKeywords text[] = ARRAY['lyr', 'lyr2', 'nfl', 'dst', 'eco'];
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

    -- Check if an entry for (fromTableName, fromLayer) exists in table 'attribute_dependencies'
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

    -- Support a variant where rowSubset is the third parameter (not toTableName)
    sourceTableCols = TT_TableColumnNames(schemaName, fromTableName);
    IF fromLayer = 1 AND toLayer = 1 AND randomNb IS NULL AND viewNameSuffix IS NULL AND
       (lower(toTableName) = ANY (rowSubsetKeywords)  OR
        strpos(toTableName, ',') != 0 OR btrim(toTableName, ' ') = ANY (sourceTableCols)) THEN
      RAISE NOTICE 'TT_CreateMappingView(): Switching viewNameSuffix, rowSubset and toTableName...';
      viewNameSuffix = rowSubset;
      rowSubset = toTableName;
      toTableName = fromTableName;
    END IF;
    rowSubset = lower(btrim(rowSubset, ' '));

    -- Check rowSubset is a valid value
    IF NOT rowSubset IS NULL THEN
      -- If rowSubset is a reserved keyword
      IF rowSubset = ANY (rowSubsetKeywords) THEN
        -- We will later name the VIEW based on rowSubset
        IF viewNameSuffix IS NULL THEN
          viewNameSuffix = rowSubset;
        ELSE
          viewNameSuffix = rowSubset || '_' || viewNameSuffix;
        END IF;
        validRowSubset = TRUE;
      -- If rowSubset is a list of attributes
      ELSIF (strpos(rowSubset, ',') != 0 OR rowSubset = ANY (sourceTableCols)) THEN
        attributeArr = string_to_array(rowSubset, ',');
        FOREACH attName IN ARRAY attributeArr LOOP
          attName = btrim(attName, ' ');
          IF NOT attName = ANY (sourceTableCols) THEN
            RAISE NOTICE 'ERROR TT_CreateMappingView(): Attribute ''%'' in ''rowSubset'' not found in table ''translation.%''...', attName, fromTableName;
            RETURN 'ERROR: Attribute ''' || attName || ''' in ''rowSubset'' not found in table ''translation.''' || fromTableName || '''...';
          END IF;
          whereExpArr = array_append(whereExpArr, '(TT_NotEmpty(' || attName || '::text) AND ' || attName || '::text != ''0'')');
          attListViewName = attListViewName || lower(left(attName, 1));
        END LOOP;
        IF viewNameSuffix IS NULL THEN
          viewNameSuffix = attListViewName;
        END IF;
        attributeList = TRUE;
        validRowSubset = TRUE;
      ELSE
        RAISE NOTICE 'ERROR TT_CreateMappingView(): Invalid rowSubset value (%)...', rowSubset;
        RETURN 'ERROR: Invalid rowSubset value (' || rowSubset || ')...';
      END IF;
    END IF;

    -- Check if an entry for (toTableName, toLayer) exists in table 'attribute_dependencies'
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

    -- Build the attribute mapping string
      WITH mapping AS (
        SELECT * FROM TT_CreateMapping(schemaName, fromTableName, fromLayer, toTableName, toLayer)
      ), unique_att AS (
      -- Create only one map for each 'to' attribute (there can not be more than one)
      SELECT DISTINCT ON (to_att)
         num, key,
         -- Make sure to quote the 'from' part if it is a constant
         CASE WHEN TT_IsName(from_att) THEN from_att
              ELSE '''' || btrim(from_att, '''') || ''''
         END from_att,
         -- If the 'to' part is a contant, map the 'from' attribute to itself. They will be fixed later.
         CASE WHEN TT_IsName(to_att) THEN to_att
              WHEN TT_IsName(from_att) THEN from_att
              ELSE key
         END to_att
      FROM mapping
      WHERE TT_NotEmpty(from_att)
      ORDER BY to_att, from_att
    ), ordered_maps AS (
      SELECT num, key, 
             from_att || CASE WHEN from_att = to_att THEN '' 
                              ELSE ' ' || to_att 
                         END mapstr,
             CASE WHEN key = ANY (ARRAY['inventory_id', 'layer', 'layer_rank', 'cas_id', 'orig_stand_id', 'stand_structure', 'num_of_layers', 'map_sheet_id', 'casfri_area', 'casfri_perimeter', 'src_inv_area', 'stand_photo_year']) THEN 1
                  WHEN key = ANY (ARRAY['soil_moist_reg', 'structure_per', 'crown_closure_upper', 'crown_closure_lower', 'height_upper', 'height_lower', 'productive_for']) THEN 2
                  WHEN key = ANY (ARRAY['species_1', 'species_per_1', 'species_2', 'species_per_2', 'species_3', 'species_per_3', 'species_4', 'species_per_4', 'species_5', 'species_per_5', 'species_6', 'species_per_6', 'species_7', 'species_per_7', 'species_8', 'species_per_8', 'species_9', 'species_per_9', 'species_10', 'species_per_10']) THEN 3
                  WHEN key = ANY (ARRAY['origin_upper', 'origin_lower', 'site_class', 'site_index']) THEN 4
                  WHEN key = ANY (ARRAY['nat_non_veg', 'non_for_anth', 'non_for_veg']) THEN 5
                  WHEN key = ANY (ARRAY['dist_type_1', 'dist_year_1', 'dist_ext_upper_1', 'dist_ext_lower_1']) THEN 6
                  WHEN key = ANY (ARRAY['dist_type_2', 'dist_year_2', 'dist_ext_upper_2', 'dist_ext_lower_2']) THEN 7
                  WHEN key = ANY (ARRAY['dist_type_3', 'dist_year_3', 'dist_ext_upper_3', 'dist_ext_lower_3']) THEN 8
                  WHEN key = ANY (ARRAY['wetland_type', 'wet_veg_cover', 'wet_landform_mod', 'wet_local_mod', 'eco_site']) THEN 9
                  ELSE 10
             END groupid
      FROM unique_att ORDER BY num
    )
    SELECT string_agg(str, ', ' || chr(10))
    FROM (SELECT string_agg(mapstr, ', ') str
          FROM ordered_maps
          GROUP BY groupid
          ORDER BY groupid) foo
    INTO attributeMapStr;
    
    -- Build the WHERE string
    IF validRowSubset AND NOT attributeList THEN
      FOR mappingRec IN SELECT * 
                        FROM TT_CreateMapping(schemaName, fromTableName, fromLayer, toTableName, toLayer)
                        WHERE TT_NotEmpty(from_att) LOOP
        IF mappingRec.contributing AND (((rowSubset = 'lyr' OR rowSubset = 'lyr2') AND (mappingRec.key = 'species_1' OR mappingRec.key = 'species_2' OR mappingRec.key = 'species_3')) OR
           (rowSubset = 'nfl' AND (mappingRec.key = 'nat_non_veg' OR mappingRec.key = 'non_for_anth' OR mappingRec.key = 'non_for_veg')) OR
           (rowSubset = 'dst' AND (mappingRec.key = 'dist_type_1' OR mappingRec.key = 'dist_year_1' OR mappingRec.key = 'dist_type_2' OR mappingRec.key = 'dist_year_2' OR mappingRec.key = 'dist_type_3' OR mappingRec.key = 'dist_year_3')) OR
           (rowSubset = 'eco' AND mappingRec.key = 'wetland_type'))
        THEN
          whereExpArr = array_append(whereExpArr, '(TT_NotEmpty(' || mappingRec.from_att || '::text) AND ' || mappingRec.from_att || '::text != ''0'')');
        END IF;
        IF rowSubset = 'lyr2' THEN
          -- Add soil_moist_reg, site_class and site_index
          IF mappingRec.contributing AND (mappingRec.key = 'soil_moist_reg' OR mappingRec.key = 'site_class' OR mappingRec.key = 'site_index') THEN
            whereExpLyrAddArr = array_append(whereExpLyrAddArr, '(TT_NotEmpty(' || mappingRec.from_att || '::text) AND ' || mappingRec.from_att || '::text != ''0'')');
          END IF;
          -- Except when any NFL attribute is set
          IF mappingRec.contributing AND (mappingRec.key = 'nat_non_veg' OR mappingRec.key = 'non_for_anth' OR mappingRec.key = 'non_for_veg' OR mappingRec.key = 'dist_type_1' OR mappingRec.key = 'dist_type_2') THEN
            whereExpLyrNFLArr = array_append(whereExpLyrNFLArr, '(TT_NotEmpty(' || mappingRec.from_att || '::text) AND ' || mappingRec.from_att || '::text != ''0'')');
          END IF;
        END IF;
      END LOOP;
    END IF;

    nb = NULL;
    -- Concatenate the WHERE attribute into a string
    IF cardinality(whereExpArr) = 0 AND validRowSubset THEN
      whereExpStr = '  WHERE FALSE = TRUE';
      nb = 0;
    ELSIF cardinality(whereExpArr) > 0 THEN
      whereExpStr = '  WHERE ' || array_to_string(TT_ArrayDistinct(whereExpArr), ' OR ' || chr(10) || '        ');
      
      -- Add extra condition for lyr including soil_moist_reg, site_class and site_index when NFL attributes are not set
      IF rowSubset = 'lyr2' THEN
        whereExpStr = whereExpStr || ' OR ' || chr(10) || 
                      '        ((' || array_to_string(TT_ArrayDistinct(whereExpLyrAddArr), ' OR ' || chr(10) || '          ') || ') AND ' || chr(10) || 
                      '         NOT (' || array_to_string(TT_ArrayDistinct(whereExpLyrNFLArr), ' OR ' || chr(10) || '              ') || '))';
      END IF;
    END IF;

    -- Contruct the name of the VIEW
    viewName = TT_FullTableName(schemaName, fromTableName || 
               CASE WHEN fromTableName = toTableName AND fromLayer = toLayer AND fromLayer != 1 THEN '_min_l' || fromLayer
                    WHEN fromTableName = toTableName AND fromLayer = toLayer THEN '_min' 
                    ELSE '_l' || fromLayer || '_to_' || toTableName || '_l' || toLayer || '_map' 
               END || coalesce('_' || randomNb, '') || coalesce('_' || viewNameSuffix, ''));

    -- Build the VIEW query
    queryStr = 'DROP VIEW IF EXISTS ' || viewName || ' CASCADE;' || chr(10) ||
               'CREATE OR REPLACE VIEW ' || viewName || ' AS' || chr(10);
    
    filteredTableName = TT_FullTableName(schemaName, fromTableName);
    filteredNbColName = 'ogc_fid';
    IF TT_NotEmpty(whereExpStr) THEN
      filteredTableName = 'filtered_rows_nb';
      filteredNbColName = 'rownb';
      queryStr = queryStr ||
                 'WITH filtered_rows AS (' || chr(10) ||
                 '  SELECT *' || chr(10) ||
                 '  FROM ' || TT_FullTableName(schemaName, fromTableName) || chr(10) ||
                 whereExpStr || chr(10) ||
                 '), filtered_rows_nb AS (' || chr(10) ||
                 '  SELECT ROW_NUMBER() OVER(ORDER BY ogc_fid) ' || filteredNbColName || ', filtered_rows.*' || chr(10) ||
                 '  FROM filtered_rows' || chr(10) ||
                 ')' || chr(10);
    END IF;
    queryStr = queryStr ||
               'SELECT ' || attributeMapStr || chr(10) ||
               'FROM ' || filteredTableName || ' fr';

    -- Make it random if requested
    IF NOT randomNb IS NULL THEN
      queryStr = queryStr || ', TT_RandomInt(' || randomNb || ', 1, (SELECT count(*) FROM ' || filteredTableName || ')::int, 1.0) rd' || chr(10) ||
                'WHERE rd.id = fr.' || filteredNbColName || chr(10) ||
                'LIMIT ' || randomNb || ';';
    END IF;
    RAISE NOTICE 'TT_CreateMappingView(): Creating VIEW ''%''...', viewName;
    EXECUTE queryStr;
    
    -- Display the approximate number of row returned by the view
    IF nb IS NULL THEN
      nb = TT_CountEstimate('SELECT 1 FROM ' || viewName);
    END IF;
    IF nb < 2 THEN
      RAISE NOTICE 'WARNING TT_CreateMappingView(): VIEW ''%'' should return 0 rows...', viewName; 
    ELSIF nb < 1000 THEN
       RAISE NOTICE 'TT_CreateMappingView(): VIEW ''%'' should return % rows...', viewName, nb;
    ELSE
      RAISE NOTICE 'TT_CreateMappingView(): VIEW ''%'' should return at least 1000 rows or more...', viewName;
    END IF;
    RETURN queryStr;
  END; 
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, name, int, text, text);
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, name, int, text);
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName text,
  fromTableName text,
  fromLayer int, 
  toTableName text,
  toLayer int,
  rowSubset text,
  viewNameSuffix text DEFAULT NULL
) 
RETURNS text AS $$ 
  SELECT TT_CreateMappingView(schemaName, fromTableName, fromLayer, toTableName, toLayer, NULL, rowSubset, viewNameSuffix);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, int, text, text);
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, int, text);
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, int); 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName text,
  fromTableName text,
  toTableName text,
  randomNb int DEFAULT NULL,
  rowSubset text DEFAULT NULL,
  viewNameSuffix text DEFAULT NULL
) 
RETURNS text AS $$ 
  SELECT TT_CreateMappingView(schemaName, fromTableName, 1, toTableName, 1, randomNb, rowSubset, viewNameSuffix);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, text, text); 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, text, text); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName text, 
  fromTableName text,
  toTableName text,
  rowSubset text,
  viewNameSuffix text DEFAULT NULL
) 
RETURNS text AS $$ 
  SELECT TT_CreateMappingView(schemaName, fromTableName, 1, toTableName, 1, NULL, rowSubset, viewNameSuffix);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text, text);
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int, text);
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text, int); 
--DROP FUNCTION IF EXISTS TT_CreateMappingView(text, text); 
CREATE OR REPLACE FUNCTION TT_CreateMappingView( 
  schemaName text,
  fromTableName text,
  randomNb int DEFAULT NULL,
  rowSubset text DEFAULT NULL,
  viewNameSuffix text DEFAULT NULL
) 
RETURNS text AS $$ 
  SELECT TT_CreateMappingView(schemaName, fromTableName, 1, fromTableName, 1, randomNb, rowSubset, viewNameSuffix);
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_CreateFilterView 
-- 
-- Create a VIEW listing only the 'selectAttrList' WHERE 'whereInAttrList' are 
-- TT_NotEmpty() and 'whereOutAttrList' are NOT TT_NotEmpty(). The name 
-- of the view can be suffixed with viewNameSuffix. Otherwise it will get a 
-- random number.
------------------------------------------------------------ 
--DROP FUNCTION IF EXISTS TT_CreateFilterView(text, text, text, text, text, text); 
CREATE OR REPLACE FUNCTION TT_CreateFilterView( 
  schemaName text, 
  tableName text,
  selectAttrList text,
  whereInAttrList text DEFAULT '',
  whereOutAttrList text DEFAULT '',
  viewNameSuffix text DEFAULT NULL
) 
RETURNS text AS $$ 
  DECLARE
    queryStr text;
    viewName text;
    fullTableName text = TT_FullTableName(schemaName, tableName);
    mappingRec RECORD;
    sourceTableCols text[] = '{}';
    keywordArr text[] = ARRAY['lyr1', 'lyr2', 'nfl1', 'nfl2', 'dst1', 'dst2', 'eco'];
    keyword text;
    nb int;
    layer text;
    attName text;
    attArr text[] = '{}';
    sigAttArr text[] = '{}';
    attList text;
    sigAttList text;
    selectAttrArr text[] = '{}';
    whereInAttrArr text[] = '{}';
    whereInAttrStrArr text[] = '{}';
    whereOutAttrArr text[] = '{}';
    whereOutAttrStrArr text[] = '{}';
  BEGIN
    -- Check if table 'attribute_dependencies' exists
    IF NOT TT_TableExists('translation', 'attribute_dependencies') THEN
      RAISE NOTICE 'ERROR TT_CreateFilterView(): Could not find table ''translation.dependencies''...';
      RETURN 'ERROR: Could not find table ''translation.dependencies''...';
    END IF;

    -- Check if tableName exists
    IF NOT TT_TableExists(schemaName, tableName) THEN
      RAISE NOTICE 'ERROR TT_CreateFilterView(): Could not find table ''translation.%''...', tableName;
      RETURN 'ERROR: Could not find table ''translation..' || tableName || '''...';
    END IF;
    
    FOREACH keyword IN ARRAY keywordArr LOOP
      layer = right(keyword, 1);
      IF NOT layer IN ('1', '2') THEN layer = '1'; END IF;
      attArr = '{}';
      sigAttArr = '{}';
      FOR mappingRec IN SELECT *
                        FROM TT_CreateMapping(schemaName, tableName, layer::int, tableName, layer::int)
                        WHERE TT_NotEmpty(from_att)
      LOOP
        IF ((keyword = 'lyr1' OR keyword = 'lyr2') AND (mappingRec.key = 'species_1' OR mappingRec.key = 'species_2' OR mappingRec.key = 'species_3')) OR
           ((keyword = 'nfl1' OR keyword = 'nfl2') AND (mappingRec.key = 'nat_non_veg' OR mappingRec.key = 'non_for_anth' OR mappingRec.key = 'non_for_veg')) OR
           ((keyword = 'dst1' OR keyword = 'dst2') AND (mappingRec.key = 'dist_type_1' OR mappingRec.key = 'dist_year_1' OR 
                                                        mappingRec.key = 'dist_ext_upper_1' OR mappingRec.key = 'dist_ext_lower_1' OR
                                                        mappingRec.key = 'dist_type_2' OR mappingRec.key = 'dist_year_2' OR 
                                                        mappingRec.key = 'dist_ext_upper_2' OR mappingRec.key = 'dist_ext_lower_2' OR
                                                        mappingRec.key = 'dist_type_3' OR mappingRec.key = 'dist_year_3' OR 
                                                        mappingRec.key = 'dist_ext_upper_3' OR mappingRec.key = 'dist_ext_lower_3')) OR
           (keyword = 'eco' AND (mappingRec.key = 'wetland_type' OR mappingRec.key = 'wet_veg_cover' OR mappingRec.key = 'wet_landform_mod' OR mappingRec.key = 'wet_local_mod'))
        THEN
          attArr = array_append(attArr, lower(mappingRec.from_att));
          sigAttArr = array_append(sigAttArr, CASE WHEN mappingRec.contributing THEN lower(mappingRec.from_att) ELSE NULL END);
        END IF;
      END LOOP;

      attList = array_to_string(TT_ArrayDistinct(attArr, TRUE), ', ');
--RAISE NOTICE '11 keyword = %', keyword;
--RAISE NOTICE '22 attList = %', attList;
--RAISE NOTICE '22 strpos(lower(selectAttrList), keyword) = %', strpos(lower(selectAttrList), keyword);
--RAISE NOTICE '33 attList = %', attList;

      IF strpos(lower(selectAttrList), keyword) != 0 AND attList IS NULL THEN
        RAISE NOTICE 'WARNING TT_CreateFilterView(): No attributes for keyword ''%'' found in table ''%.%''...', keyword, schemaName, tableName;
      END IF;
      selectAttrList = regexp_replace(lower(selectAttrList), keyword || '\s*,', CASE WHEN attList != '' THEN attList || ',' ELSE '' END);
      selectAttrList = regexp_replace(lower(selectAttrList), keyword || '\s*', CASE WHEN attList != '' THEN attList ELSE '' END);

      sigAttList = array_to_string(TT_ArrayDistinct(sigAttArr, TRUE), ', ');
      IF strpos(lower(whereInAttrList), keyword) != 0 AND sigAttList IS NULL THEN
        RAISE NOTICE 'WARNING TT_CreateFilterView(): No attributes for keyword ''%'' found in table ''%.%''...', keyword, schemaName, tableName;
      END IF;
--RAISE NOTICE '33 sigAttList = %', sigAttList;
      whereInAttrList = regexp_replace(lower(whereInAttrList), keyword || '\s*,', CASE WHEN sigAttList != '' THEN sigAttList || ',' ELSE '' END);
      whereInAttrList = regexp_replace(lower(whereInAttrList), keyword || '\s*', CASE WHEN sigAttList != '' THEN sigAttList ELSE '' END);

      IF strpos(lower(whereOutAttrList), keyword) != 0 AND sigAttList IS NULL THEN
        RAISE NOTICE 'WARNING TT_CreateFilterView(): No attributes for keyword ''%'' found in table ''%.%''...', keyword, schemaName, tableName;
      END IF;
      whereOutAttrList = regexp_replace(lower(whereOutAttrList), keyword || '\s*,', CASE WHEN sigAttList != '' THEN sigAttList || ',' ELSE '' END);
      whereOutAttrList = regexp_replace(lower(whereOutAttrList), keyword || '\s*', CASE WHEN sigAttList != '' THEN sigAttList ELSE '' END);
--RAISE NOTICE '66 selectAttrList = %', selectAttrList;
--RAISE NOTICE '77 whereInAttrList = %', whereInAttrList;
--RAISE NOTICE '88 whereOutAttrList = %', whereOutAttrList;
    END LOOP;

    -- Parse and validate the list of provided attributes against the list of attribute in the table
    sourceTableCols = TT_TableColumnNames(schemaName, tableName);

    selectAttrArr = TT_ArrayDistinct(regexp_split_to_array(selectAttrList, '\s*,\s*'), TRUE, TRUE);
    FOREACH attName IN ARRAY coalesce(selectAttrArr, '{}'::text[]) LOOP
      IF NOT attName = ANY (sourceTableCols) THEN
        RAISE NOTICE 'ERROR TT_CreateFilterView(): Attribute ''%'' not found in table ''%.%''...', attName, schemaName, tableName;
        RETURN 'ERROR TT_CreateFilterView(): Attribute ''' || attName || ''' not found in table ''' || schemaName || '.' || tableName || '''...';
      END IF;
    END LOOP;

    IF selectAttrArr IS NULL OR cardinality(selectAttrArr) = 0 THEN
      selectAttrList = '*';
    ELSE
      selectAttrList = array_to_string(selectAttrArr, ', ');
    END IF;
    
    whereInAttrArr = TT_ArrayDistinct(regexp_split_to_array(whereInAttrList, '\s*,\s*'), TRUE, TRUE);
--RAISE NOTICE '99 whereInAttrArr = %', whereInAttrArr;
    FOREACH attName IN ARRAY coalesce(whereInAttrArr, '{}'::text[]) LOOP
      IF NOT attName = ANY (sourceTableCols) THEN
        RAISE NOTICE 'ERROR TT_CreateFilterView(): Attribute ''%'' not found in table ''%.%''...', attName, schemaName, tableName;
        RETURN 'ERROR TT_CreateFilterView(): Attribute ''' || attName || ''' not found in table ''' || schemaName || '.' || tableName || '''...';
      END IF;
      whereInAttrStrArr = array_append(whereInAttrStrArr, '(TT_NotEmpty(' || attName || '::text) AND ' || attName || '::text != ''0'')');
    END LOOP;
    whereInAttrList = array_to_string(whereInAttrStrArr, ' OR ' || chr(10) || '       ');
    
    whereOutAttrArr = TT_ArrayDistinct(regexp_split_to_array(whereOutAttrList, '\s*,\s*'), TRUE, TRUE);
    --SELECT regexp_split_to_array('a,    g', '\s*,\s*');
    --SELECT TT_ArrayDistinct(regexp_split_to_array('', '\s*,\s*'), TRUE);

--RAISE NOTICE 'AA whereOutAttrArr = %', whereOutAttrArr;
    FOREACH attName IN ARRAY coalesce(whereOutAttrArr, '{}'::text[]) LOOP
      IF NOT attName = ANY (sourceTableCols) THEN
        RAISE NOTICE 'ERROR TT_CreateFilterView(): Attribute ''%'' not found in table ''%.%''...', attName, schemaName, tableName;
        RETURN 'ERROR TT_CreateFilterView(): Attribute ''' || attName || ''' not found in table ''' || schemaName || '.' || tableName || '''...';
      END IF;
      whereOutAttrStrArr = array_append(whereOutAttrStrArr, '(TT_NotEmpty(' || attName || '::text) AND ' || attName || '::text != ''0'')');
    END LOOP;
    whereOutAttrList = array_to_string(whereOutAttrStrArr, ' OR ' || chr(10) || '       ');

    -- Construct the name of the VIEW
    viewName = fullTableName || coalesce('_' || viewNamesuffix, '_' || (random()*100)::int::text);

    -- Build the VIEW query
    queryStr = 'DROP VIEW IF EXISTS ' || viewName || ' CASCADE;' || chr(10) ||
               'CREATE OR REPLACE VIEW ' || viewName || ' AS' || chr(10) ||
               'SELECT ' || selectAttrList || chr(10) ||
               'FROM ' || fullTableName;
               
    IF whereInAttrList != '' OR whereOutAttrList != '' THEN
      queryStr = queryStr  || chr(10) || 'WHERE ';
      IF whereInAttrList != '' THEN
        queryStr = queryStr || '(' || whereInAttrList || ')';
      END IF;
      IF whereInAttrList != '' AND whereOutAttrList != '' THEN
        queryStr = queryStr  || chr(10) || '      AND NOT' || chr(10) || '      ';
      END IF;
      IF whereOutAttrList != '' THEN
        queryStr = queryStr || '(' || whereOutAttrList || ')';
      END IF;
    END IF;
    queryStr = queryStr  || ';';

    -- Create the VIEW
    RAISE NOTICE 'TT_CreateFilterView(): Creating VIEW ''%''...', viewName;
    EXECUTE queryStr;
    
    -- Display the approximate number of row returned by the view
    nb = TT_CountEstimate('SELECT 1 FROM ' || viewName);
    IF nb < 2 THEN
      RAISE NOTICE 'WARNING TT_CreateFilterView(): VIEW ''%'' should return 0 rows...', viewName; 
    ELSIF nb < 1000 THEN
       RAISE NOTICE 'TT_CreateFilterView(): VIEW ''%'' should return % rows...', viewName, nb;
    ELSE
      RAISE NOTICE 'TT_CreateFilterView(): VIEW ''%'' should return at least 1000 rows or more...', viewName;
    END IF;
    RETURN queryStr;
  END; 
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Overwrite the TT_DefaultProjectErrorCode() function to define default error 
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