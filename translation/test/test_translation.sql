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
-- Usage
--
-- 1) Load the test tables from a command window:
--    >load_test_tables.bat 
-- 2) Execute the test in PostgreSQL (this file)
-- 3) If undesirable changes show up, fix your translation tables.
--    If desirable changes occurs, dump them as new test tables and commit:
--    >dump_test_tables.bat 
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
-- ST_ColumnExists
--
--   schemaname name - Name of the schema containing the table in which to
--                     check for the existance of a column.
--   tablename name  - Name of the table in which to check for the existance of
--                     a column.
--   columnname name - Name of the column to check for the existence of.
--
--   RETURNS boolean
--
-- Returns true if a column exist in a table. Mainly defined to be used by 
-- ST_AddUniqueID().
-----------------------------------------------------------
-- Self contained example:
--
-- SELECT ST_ColumnExists('public', 'spatial_ref_sys', 'srid') ;
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION ST_ColumnExists(
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

-- test
--SELECT (TT_CompareRows(to_jsonb(ROW(1, 'c', 2)), to_jsonb(ROW(1, 'x', 3)))).*

--SELECT coalesce(a.id1, b.id1) id1, (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
--FROM temp.table01 a 
--FULL OUTER JOIN temp.table05 b USING (id1);
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
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
    -- check that every column in table1 exists in table2
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
    -- check that every column in table2 exists in table1
    FOREACH columnName IN ARRAY cols2 LOOP
      IF columnName != ALL(cols1) THEN
        RAISE EXCEPTION 'Column ''%'' does not exist in %.%...', columnName, schemaName1, tableName1;
        stop = TRUE;
      END IF;
    END LOOP;
    -- stop for now
    IF stop THEN
      RETURN;
    END IF;
    -- now that we know both tables have the same columns, check that they are in the same order
    IF NOT ignoreColumnOrder AND cols1 != cols2 THEN
      RAISE EXCEPTION 'Columns with the same names and types exist in both tables but are not in the same order...';
      RETURN;
    END IF;
    
    -- check that uniqueIDCol is not NULL and exists
    IF uniqueIDCol IS NULL OR uniqueIDCol = '' THEN
      RAISE EXCEPTION 'Table have same structure. In order to report different rows, uniqueIDCol should not be NULL...';
    END IF;
    IF NOT ST_ColumnExists(schemaName1, tableName1, uniqueIDCol) THEN
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
CREATE SCHEMA IF NOT EXISTS casfri50_test;
-------------------------------------------------------------------------------
-- Create random views on the target tables
CREATE OR REPLACE VIEW casfri50_test.ab06_test AS
SELECT *
FROM rawfri.ab06 TABLESAMPLE SYSTEM (300.0*100/11484) REPEATABLE (1.0)
LIMIT 200;

CREATE OR REPLACE VIEW casfri50_test.ab16_test AS
SELECT *
FROM rawfri.ab16 TABLESAMPLE SYSTEM (450.0*100/120476) REPEATABLE (1.0)
LIMIT 400;

CREATE OR REPLACE VIEW casfri50_test.nb01_test AS
SELECT *
FROM rawfri.nb01 TABLESAMPLE SYSTEM (800.0*100/927177) REPEATABLE (1.0)
LIMIT 600;

CREATE OR REPLACE VIEW casfri50_test.nb02_test AS
SELECT *
FROM rawfri.nb02 TABLESAMPLE SYSTEM (800.0*100/1123893) REPEATABLE (1.0)
LIMIT 600;

CREATE OR REPLACE VIEW casfri50_test.bc08_test AS
SELECT *
FROM rawfri.bc08 TABLESAMPLE SYSTEM (1100.0*100/4677411) REPEATABLE (1.0)
LIMIT 1000;

CREATE OR REPLACE VIEW casfri50_test.bc09_test AS
SELECT *
FROM rawfri.bc09 TABLESAMPLE SYSTEM (1100.0*100/5151772) REPEATABLE (1.0)
LIMIT 1000;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_cas', '_ab06_cas_test');
SELECT TT_Prepare('translation', 'ab16_avi01_cas', '_ab16_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nb01_nbi01_cas', '_nb01_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc08_vri01_cas', '_bc08_cas_test', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc09_vri01_cas', '_bc09_cas_test', 'ab06_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50_test.cas_all_new;
CREATE TABLE casfri50_test.cas_all_new AS 
SELECT * FROM TT_Translate_ab06_cas_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_ab16_cas_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_nb01_cas_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc08_cas_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.cas_all_new 
SELECT * FROM TT_Translate_bc09_cas_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.cas_all_new; -- 1000
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_dst', '_ab06_dst_test');
SELECT TT_Prepare('translation', 'ab16_avi01_dst', '_ab16_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst', '_nb01_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc08_vri01_dst', '_bc08_dst_test', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc09_vri01_dst', '_bc09_dst_test', 'ab06_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_all_new;
CREATE TABLE casfri50_test.dst_all_new AS
SELECT * FROM TT_Translate_ab06_dst_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_ab16_dst_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_nb01_dst_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc08_dst_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.dst_all_new
SELECT * FROM TT_Translate_bc09_dst_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.dst_all_new;
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_eco', '_ab06_eco_test');
SELECT TT_Prepare('translation', 'ab16_avi01_eco', '_ab16_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'nb01_nbi01_eco', '_nb01_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'bc08_vri01_eco', '_bc08_eco_test', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'bc09_vri01_eco', '_bc09_eco_test', 'ab06_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50_test.eco_all_new;
CREATE TABLE casfri50_test.eco_all_new AS 
SELECT * FROM TT_Translate_ab06_eco_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_ab16_eco_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_nb01_eco_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc08_eco_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.eco_all_new
SELECT * FROM TT_Translate_bc09_eco_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.eco_all_new; -- 1000
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr_test');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb01_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr_test', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc09_vri01_lyr', '_bc09_lyr_test', 'ab06_avi01_lyr');
-------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_all_new;
CREATE TABLE casfri50_test.lyr_all_new AS 
SELECT * FROM TT_Translate_ab06_lyr_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_ab16_lyr_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_nb01_lyr_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc08_lyr_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.lyr_all_new
SELECT * FROM TT_Translate_bc09_lyr_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.lyr_all_new; 
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_nfl', '_ab06_nfl_test');
SELECT TT_Prepare('translation', 'ab16_avi01_nfl', '_ab16_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nb01_nbi01_nfl', '_nb01_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc08_vri01_nfl', '_bc08_nfl_test', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc09_vri01_nfl', '_bc09_nfl_test', 'ab06_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new;
CREATE TABLE casfri50_test.nfl_all_new AS 
SELECT * FROM TT_Translate_ab06_nfl_test('casfri50_test', 'ab06_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_ab16_nfl_test('casfri50_test', 'ab16_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_nb01_nfl_test('casfri50_test', 'nb01_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc08_nfl_test('casfri50_test', 'bc08_test', 'ogc_fid');
------------------------
INSERT INTO casfri50_test.nfl_all_new
SELECT * FROM TT_Translate_bc09_nfl_test('casfri50_test', 'bc09_test', 'ogc_fid');
------------------------
SELECT count(*) FROM casfri50_test.nfl_all_new;
-------------------------------------------------------

---------------------------------------------------------
SELECT '1.0' number, 
       'Compare "cas_all_new" and "cas_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_test'' , ''cas_all_new'', ''casfri50_test'' , ''cas_all_test'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.cas_all_new a 
      FULL OUTER JOIN casfri50_test.cas_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.0' number, 
       'Compare "dst_all_new" and "dst_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''dstfri50_test'' , ''dst_all_new'', ''dstfri50_test'' , ''dst_all_test'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.dst_all_new a 
      FULL OUTER JOIN casfri50_test.dst_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.0' number, 
       'Compare "eco_all_new" and "eco_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''ecofri50_test'' , ''eco_all_new'', ''ecofri50_test'' , ''eco_all_test'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.eco_all_new a 
      FULL OUTER JOIN casfri50_test.eco_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.0' number, 
       'Compare "lyr_all_new" and "lyr_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''lyrfri50_test'' , ''lyr_all_new'', ''lyrfri50_test'' , ''lyr_all_test'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.lyr_all_new a 
      FULL OUTER JOIN casfri50_test.lyr_all_test b USING (cas_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.0' number, 
       'Compare "nfl_all_new" and "nfl_all_test"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''nflfri50_test'' , ''nfl_all_new'', ''nflfri50_test'' , ''nfl_all_test'', ''cas_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_test.nfl_all_new a 
      FULL OUTER JOIN casfri50_test.nfl_all_test b USING (cas_id)) foo
---------------------------------------------------------




