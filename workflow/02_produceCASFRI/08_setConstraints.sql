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
-- Create a schema for lookup tables
-------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_lookup;
-------------------------------------------------------
-- Create a function that create the constraint in a non 
-- blocking way and return TRUE or FALSE upon succesfull completion
-------------------------------------------------------
DROP FUNCTION IF EXISTS TT_AddConstraint(name, name, text, text[], text[]);
CREATE OR REPLACE FUNCTION TT_AddConstraint(
  schemaName name,
  tableName name,
  cType text,
  args text[],
  lookup_vals text[] DEFAULT NULL
)
RETURNS RECORD AS $$ 
  DECLARE
    acceptableCType text[] = ARRAY['PK', 'FK', 'NOTNULL', 'CHECK', 'LOOKUP', 'LOOKUPTABLE'];
    nbArgs int[] = ARRAY[1, 4, 1, 2, 2, 2];
    queryStr text;
  BEGIN
    cType = upper(cType);
    BEGIN
      IF NOT cType = ANY (acceptableCType) THEN
        RAISE EXCEPTION 'TT_AddConstraint(): ERROR invalid constraint type (%)...', cType;
      END IF;
      IF cardinality(args) != nbArgs[array_position(acceptableCType, cType)] THEN
        RAISE EXCEPTION 'TT_AddConstraint(): ERROR invalid number of arguments (%). Should be %...', cardinality(args), nbArgs[array_position(acceptableCType, cType)];
      END IF;
      queryStr = 'ALTER TABLE ' || schemaName || '.' || tableName || ' '; 
      CASE WHEN cType = 'PK' THEN
             queryStr = queryStr || 'ADD PRIMARY KEY (' || args[1] || ');';

           WHEN cType = 'FK' THEN
             queryStr = queryStr || 'ADD FOREIGN KEY (' || args[1] || ') ' ||
                                    'REFERENCES ' || args[2] || '.' || args[3] || ' (' || args[4] || ') MATCH FULL;';
           
           WHEN cType = 'NOTNULL' THEN
             queryStr = queryStr || 'ALTER COLUMN ' || args[1] || ' SET NOT NULL;';
           
           WHEN cType = 'CHECK' THEN
             queryStr = queryStr || 'DROP CONSTRAINT IF EXISTS ' || args[1] || ';' ||
                                   ' ALTER TABLE ' || schemaName || '.' || tableName ||
                                   ' ADD CONSTRAINT ' || args[1] ||
                                   ' CHECK (' || args[2] || ');';

           WHEN cType = 'LOOKUP' THEN
             queryStr = 'DROP TABLE IF EXISTS ' || args[1] || '.' || args[2] || '_codes CASCADE;

                         CREATE TABLE ' || args[1] || '.' || args[2] || '_codes AS
                         SELECT * FROM (VALUES (''' || array_to_string(lookup_vals, '''), (''') || ''')) AS t(code);

                         ALTER TABLE ' || args[1] || '.' || args[2] || '_codes
                         ADD PRIMARY KEY (code);

                         ALTER TABLE ' || schemaName || '.' || tableName || '
                         DROP CONSTRAINT IF EXISTS ' || tableName || '_' || args[2] || '_fk;

                         ALTER TABLE ' || schemaName || '.' || tableName || '
                         ADD CONSTRAINT ' || tableName || '_' || args[2] || '_fk 
                         FOREIGN KEY (' || args[2] || ') 
                         REFERENCES ' || args[1] || '.' || args[2] || '_codes (code);';
           ELSE
             RAISE EXCEPTION 'TT_AddConstraint(): ERROR invalid constraint type (%)...', cType;
      END CASE;
      RAISE NOTICE 'TT_AddConstraint(): EXECUTING ''%''...', queryStr; 
      EXECUTE queryStr;
      RETURN (TRUE, queryStr);
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '%', SQLERRM;
      RETURN (FALSE, queryStr);
    END;
  END; 
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------
-- Create the species_codes lookup table
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50_lookup.species_codes CASCADE;
CREATE TABLE casfri50_lookup.species_codes AS
SELECT DISTINCT spec1 code
FROM (
SELECT spec1 FROM translation.ab_avi01_species
UNION ALL
SELECT spec1 FROM translation.bc_vri01_species
UNION ALL
SELECT spec1 FROM translation.nb_nbi01_species
UNION ALL
SELECT spec1 FROM translation.nt_fvi01_species
UNION ALL
SELECT spec1 FROM translation.on_fim02_species
UNION ALL
SELECT specie FROM translation.qc03_species
UNION ALL
SELECT spec1 FROM translation.sk_utm01_species
UNION ALL
SELECT spec1 FROM translation.sk_sfv01_species
UNION ALL
SELECT spec1 FROM translation.yt_yvi01_species
UNION ALL
SELECT * FROM (VALUES ('NULL_VALUE'), ('EMPTY_STRING'), ('NOT_IN_SET'), ('NOT_APPLICABLE')) AS t(scec1)
) foo
ORDER BY code;

ALTER TABLE casfri50_lookup.species_codes
ADD PRIMARY KEY (code);
-------------------------------------------------------
-- Begin test section
-------------------------------------------------------
-- Uncomment to display only failing tests (at the end also)
--SELECT * FROM (
-------------------------------------------------------
-- Add some constraints to the CAS_ALL table
-------------------------------------------------------
SELECT '1.1'::text number,
       'cas_all' target_table,
       'Add foreign key to HDR_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'FK', 
                        ARRAY['inventory_id', 'casfri50', 'hdr_all', 'inventory_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'cas_all' target_table,
       'Ensure CAS_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'cas_all' target_table,
       'Ensure INVENTORY_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['inventory_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'cas_all' target_table,
       'Ensure ORIG_STAND_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['orig_stand_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'cas_all' target_table,
       'Ensure STAND_STRUCTURE is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['stand_structure']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'cas_all' target_table,
       'Ensure NUM_OF_LAYERS is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['num_of_layers']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'cas_all' target_table,
       'Ensure MAP_SHEET_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['map_sheet_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'cas_all' target_table,
       'Ensure CASFRI_AREA is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['casfri_area']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'cas_all' target_table,
       'Ensure CASFRI_PERIMETER is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['casfri_perimeter']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.10'::text number,
       'cas_all' target_table,
       'Ensure SRC_INV_AREA is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['src_inv_area']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.11'::text number,
       'cas_all' target_table,
       'Ensure STAND_PHOTO_YEAR is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['stand_photo_year']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.12'::text number,
       'cas_all' target_table,
       'Ensure CAS table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.13'::text number,
       'cas_all' target_table,
       'Ensure CAS table INVENTORY_ID is 4 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(inventory_id) = 4']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.14'::text number,
       'cas_all' target_table,
       'Issue #340 on replacing 0 with UNKNOWN_VALUE for NUM_OF_LAYERS. Ensure CAS table NUM_OF_LAYERS is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['num_of_layers_greater_than_zero', 
                              'num_of_layers > 0 OR 
                               num_of_layers = -8886 -- UNKNOWN_VALUE
                              ']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.15'::text number,
       'cas_all' target_table,
       'Ensure CAS table STAND_STRUCTURE values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'stand_structure'],
                        ARRAY['S', 'M', 'H', 'C',
                             'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.16'::text number,
       'cas_all' target_table,
       'Issue #340 on replacing 0 with UNKNOWN_VALUE for NUM_OF_LAYERS. Ensure CAS table STAND_STRUCTURE fits with NUM_OF_LAYERS' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['num_of_layers_greater_than_zero', 
                              '((stand_structure = ''M'' OR 
                                 stand_structure = ''H'' OR 
                                 stand_structure = ''C'') AND 
                                num_of_layers > 1) OR 
                               ((stand_structure = ''S'' OR stand_structure = ''C'') AND num_of_layers = 1) OR 
                                num_of_layers = -8886 OR -- UNKNOWN_VALUE
                                stand_structure = ''NULL_VALUE'' OR
                                stand_structure = ''EMPTY_STRING'' OR
                                stand_structure = ''NOT_IN_SET''']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.17'::text number,
       'cas_all' target_table,
       'Ensure CAS table CASFRI_AREA is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['casfri_area_greater_than_zero', 
                              'casfri_area > 0']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.18'::text number,
       'cas_all' target_table,
       'Ensure CAS table CASFRI_PERIMETER is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['casfri_perimeter_greater_than_zero', 
                              'casfri_perimeter > 0']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.19'::text number,
       'cas_all' target_table,
       'Ensure CAS table SRC_INV_AREA is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['src_inv_area_greater_than_zero', 
                              'src_inv_area >= 0 OR 
                               src_inv_area = -9997 OR -- INVALID_VALUE
                               src_inv_area = -8888 OR -- NULL_VALUE
                               src_inv_area = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.20'::text number,
       'cas_all' target_table,
       'Issue #248. Ensure CAS table STAND_PHOTO_YEAR is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['stand_photo_year_greater_than_zero', 
                              'stand_photo_year > 0']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the DST_ALL table
-------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'dst_all' target_table,
       'Add foreign key to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.7'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.8'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.9'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.10'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.11'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.12'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.13'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.14'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.15'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.16'::text number,
       'dst_all' target_table,
       'Ensure DST table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.17'::text number,
       'dst_all' target_table,
       'Ensure DST table LAYER is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 
                              'layer > 0 OR 
                               layer = -8886 -- UNKNOWN_VALUE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.18'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_TYPE_1 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'dist_type_1'],
                        ARRAY['CO', 'PC', 'BU', 'WF', 'DI', 'IK', 'FL', 
                              'WE', 'SL', 'OT', 'DT', 'SI', 'CL', 'UK',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.19'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_TYPE_2 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'dist_type_2'],
                        ARRAY['CO', 'PC', 'BU', 'WF', 'DI', 'IK', 'FL', 
                              'WE', 'SL', 'OT', 'DT', 'SI', 'CL', 'UK',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET', 'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.20'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_TYPE_3 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'FK', 
                        ARRAY['dist_type_3', 'casfri50_lookup', 'dist_type_2_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.21'::text number,
       'dst_all' target_table,
       'Issue #337. Ensure DST table DIST_YEAR_1 is greater than 1900 and below 2020' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_1_greater_than_1900', 
                              '(1900 <= dist_year_1 AND dist_year_1 <= 2020) OR 
                                dist_year_1 = -9999 OR -- OUT_OF_RANGE
                                dist_year_1 = -9997 OR -- INVALID_VALUE
                                dist_year_1 = -8888    -- UNKNOWN_VALUE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.22'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_YEAR_2 is greater than 1900 and below 2020' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_2_greater_than_1900', 
                              '(1900 <= dist_year_2 AND dist_year_2 <= 2020) OR 
                                dist_year_2 = -9999 OR -- OUT_OF_RANGE
                                dist_year_2 = -9997 OR -- INVALID_VALUE
                                dist_year_2 = -8888 OR -- NULL_VALUE
                                dist_year_2 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.23'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_YEAR_3 is greater than 1900 and below 2020' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_3_greater_than_1900', 
                              '(1900 <= dist_year_3 AND dist_year_3 <= 2020) OR 
                                dist_year_3 = -9999 OR -- OUT_OF_RANGE
                                dist_year_3 = -9997 OR -- INVALID_VALUE
                                dist_year_3 = -8888 OR -- NULL_VALUE
                                dist_year_3 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.24'::text number,
       'dst_all' target_table,
       'Issue #338. Ensure DST table DIST_EXT_UPPER_1 is greater than 10 and below 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_1_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_1 AND dist_ext_upper_1 <= 100) OR 
                               dist_ext_upper_1 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_upper_1 = -9997 OR -- INVALID_VALUE
                               dist_ext_upper_1 = -8888 OR -- NULL_VALUE
                               dist_ext_upper_1 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.25'::text number,
       'dst_all' target_table,
       'Issue #338. Ensure DST table DIST_EXT_UPPER_2 is greater than 10 and below 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_2_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_2 AND dist_ext_upper_2 <= 100) OR 
                               dist_ext_upper_2 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_upper_2 = -9997 OR -- INVALID_VALUE
                               dist_ext_upper_2 = -8888 OR -- NULL_VALUE
                               dist_ext_upper_2 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.26'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_3 is greater than 10 and below 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_3_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_3 AND dist_ext_upper_3 <= 100) OR 
                               dist_ext_upper_3 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_upper_3 = -9997 OR -- INVALID_VALUE
                               dist_ext_upper_3 = -8888 OR -- NULL_VALUE
                               dist_ext_upper_3 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.27'::text number,
       'dst_all' target_table,
       'Issue #338. Ensure DST table DIST_EXT_LOWER_1 is greater than 10 and below 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_1_betweeen_10_and_100', 
                              '(10 <= dist_ext_lower_1 AND dist_ext_lower_1 <= 100) OR 
                               dist_ext_lower_1 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_lower_1 = -9997 OR -- INVALID_VALUE
                               dist_ext_lower_1 = -8888 OR -- NULL_VALUE
                               dist_ext_lower_1 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.28'::text number,
       'dst_all' target_table,
       'Issue #338. Ensure DST table DIST_EXT_LOWER_2 is greater than 10 and below 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_2_betweeen_10_and_100', 
                              '(10 <= dist_ext_lower_2 AND dist_ext_lower_2 <= 100) OR 
                               dist_ext_lower_2 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_lower_2 = -9997 OR -- INVALID_VALUE
                               dist_ext_lower_2 = -8888 OR -- NULL_VALUE
                               dist_ext_lower_2 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.29'::text number,
       'dst_all' target_table,
       'Issue #338. Ensure DST table DIST_EXT_LOWER_3 is greater than 10 and below 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_3_betweeen_10_and_100', 
                              '(10 <= dist_ext_lower_3 AND dist_ext_lower_3 <= 100) OR 
                               dist_ext_lower_3 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_lower_3 = -9997 OR -- INVALID_VALUE
                               dist_ext_lower_3 = -8888 OR -- NULL_VALUE
                               dist_ext_lower_3 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the ECO_ALL table
-------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'eco_all' target_table,
       'Add foreign key to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wetland_type']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_veg_cover']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_landform_mod']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_local_mod']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['eco_site']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'eco_all' target_table,
       'Ensure ECO table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'eco_all' target_table,
       'Issue ''S'' is in the database and not in the specs ''NA'', ''E'' and ''Z'' are in the specs but not in the database. Ensure ECO table WETLAND_TYPE values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wetland_type'],
                        ARRAY['B', 'F', 'M', 'O', 'T', 'W',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.10'::text number,
       'eco_all' target_table,
       'Issue ''P'' is in the database and not in the specs. Ensure ECO table WET_VEG_COVER values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_veg_cover'],
                        ARRAY['F', 'T', 'O', 'C', 'M',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.11'::text number,
       'eco_all' target_table,
       'Ensure ECO table WET_LANDFORM_MOD values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_landform_mod'],
                        ARRAY['X', 'P', 'N', 'A',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.12'::text number,
       'eco_all' target_table,
       'Issue ''B'' is found in the database but not in the specs. Ensure ECO table WET_LOCAL_MOD values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_local_mod'],
                        ARRAY['C', 'R', 'I', 'N', 'S', 'G',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.13'::text number,
       'eco_all' target_table,
       'Issue eco_site does not seems to be translated. Ensure ECO table ECO_SITE values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'CHECK', 
                        ARRAY['eco_site_not_applicable', 'eco_site = ''NOT_APPLICABLE''']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the LYR_ALL table
-------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'lyr_all' target_table,
       'Issue #330. Add foreign key to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'lyr_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'lyr_all' target_table,
       'Ensure SOILMOIST_REG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['soil_moist_reg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'lyr_all' target_table,
       'Ensure LAYER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'lyr_all' target_table,
       'Ensure LAYER_RANK is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['layer_rank']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'lyr_all' target_table,
       'Ensure CROWN_CLOSURE_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['crown_closure_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'lyr_all' target_table,
       'Ensure CROWN_CLOSURE_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['crown_closure_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'lyr_all' target_table,
       'Ensure HEIGHT_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['height_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.9'::text number,
       'lyr_all' target_table,
       'Ensure HEIGHT_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['height_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.10'::text number,
       'lyr_all' target_table,
       'Ensure PRODUCTIVE_FOR is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['productive_for']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.11'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.12'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.13'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.14'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.15'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.16'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.17'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_4 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_4']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.18'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_4 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_4']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.19'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_5 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_5']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.20'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_5 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_5']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.21'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_6 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_6']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.22'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_6 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_6']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.23'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_7 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_7']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.24'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_7 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_7']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.25'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_8 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_8']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.26'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_8 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_8']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.29'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_9 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_9']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.30'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_9 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_9']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.31'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_10 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_10']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.32'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_10 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_10']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.33'::text number,
       'lyr_all' target_table,
       'Ensure LYR table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.34'::text number,
       'lyr_all' target_table,
       'Issue #338. Ensure LYR table STRUCTURE_PER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['structure_per_between_0_and_100', 
                              '(structure_per > 0 AND structure_per <= 100) OR 
                                structure_per = -9999 OR -- OUT_OF_RANGE
                                structure_per = -9997 OR -- INVALID_VALUE
                                structure_per = -8888 OR -- NULL_VALUE
                                structure_per = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.35'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SOIL_MOIST_REG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'soil_moist_reg'],
                        ARRAY['D', 'F', 'M', 'W', 'A',
                              'NULL_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.36'::text number,
       'lyr_all' target_table,
       'Ensure LYR table LAYER is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 'layer > 0']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.37'::text number,
       'lyr_all' target_table,
       'Ensure LYR table LAYER_RANK is greater than 0 and smaller than 10' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['layer_rank_greater_than_zero', 
                              '(layer_rank > 0 AND layer_rank < 10) OR 
                                layer_rank = -8888 OR -- NULL_VALUE
                                layer_rank = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.38'::text number,
       'lyr_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure LYR table CROWN_CLOSURE_UPPER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['crown_closure_upper_between_0_and_100',
                              '(crown_closure_upper >= 0 AND crown_closure_upper <= 100) OR 
                               crown_closure_upper = -9999 OR -- OUT_OF_RANGE
                               crown_closure_upper = -9997 OR -- INVALID_VALUE
                               crown_closure_upper = -8888 OR -- NULL_VALUE
                               crown_closure_upper = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.39'::text number,
       'lyr_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure LYR table CROWN_CLOSURE_LOWER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['crown_closure_lower_between_0_and_100',
                              '(crown_closure_lower >= 0 AND crown_closure_lower <= 100) OR 
                               crown_closure_lower = -9999 OR -- OUT_OF_RANGE
                               crown_closure_lower = -9997 OR -- INVALID_VALUE
                               crown_closure_lower = -8888 OR -- NULL_VALUE
                               crown_closure_lower = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.40'::text number,
       'lyr_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure LYR table HEIGHT_UPPER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['height_upper_between_0_and_100',
                              '(height_upper >= 0 AND height_upper <= 100) OR 
                               height_upper = -9999 OR -- OUT_OF_RANGE
                               height_upper = -9997 OR -- INVALID_VALUE
                               height_upper = -8888 OR -- NULL_VALUE
                               height_upper = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.41'::text number,
       'lyr_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure LYR table HEIGHT_LOWER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['height_lower_between_0_and_100',
                              '(height_lower >= 0 AND height_lower <= 100) OR 
                               height_lower = -9999 OR -- OUT_OF_RANGE
                               height_lower = -9997 OR -- INVALID_VALUE
                               height_lower = -8888 OR -- NULL_VALUE
                               height_lower = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.42'::text number,
       'lyr_all' target_table,
       'Ensure LYR table PRODUCTIVE_FOR values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'productive_for'],
                        ARRAY['TM', 'AL', 'SD', 'SC', 'NP', 'PP', 'PF',
                              'NULL_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.43'::text number,
       'lyr_all' target_table,
       'Issue #346: Some rows get TRANSLATION_ERROR. Ensure LYR table SPECIES_1 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_1', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.44'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_2 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_2', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.45'::text number,
       'lyr_all' target_table,
       'Issue #346: Some rows get TRANSLATION_ERROR. Ensure LYR table SPECIES_3 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_3', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.46'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_4 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_4', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.47'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_5 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_5', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.48'::text number,
       'lyr_all' target_table,
       'Issue #346: Some rows get TRANSLATION_ERROR. Ensure LYR table SPECIES_6 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_6', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.49'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_7 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_7', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.50'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_8 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_8', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.51'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_9 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_9', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.52'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_10 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_10', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.53'::text number,
       'lyr_all' target_table,
       'Issue #346 & #338: Some rows get TRANSLATION_ERROR and others get -9998 (NOT_IN_SET) and -8889 (EMPTY_STRING). Ensure LYR table SPECIES_PER_1 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_1_between_0_and_100',
                              '(species_per_1 >= 0 AND species_per_1 <= 100) OR 
                               species_per_1 = -9999 OR -- OUT_OF_RANGE
                               species_per_1 = -9997 OR -- INVALID_VALUE
                               species_per_1 = -8888 OR -- NULL_VALUE
                               species_per_1 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.54'::text number,
       'lyr_all' target_table,
       'Issue #346 & #338: Some rows get TRANSLATION_ERROR and others get -9998 (NOT_IN_SET) and -8889 (EMPTY_STRING). Ensure LYR table SPECIES_PER_2 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_2_between_0_and_100',
                              '(species_per_2 >= 0 AND species_per_2 <= 100) OR 
                               species_per_2 = -9999 OR -- OUT_OF_RANGE
                               species_per_2 = -9997 OR -- INVALID_VALUE
                               species_per_2 = -8888 OR -- NULL_VALUE
                               species_per_2 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.55'::text number,
       'lyr_all' target_table,
       'Issue #346 & #338: Some rows get TRANSLATION_ERROR and others get -9998 (NOT_IN_SET) and -8889 (EMPTY_STRING). Ensure LYR table SPECIES_PER_3 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_3_between_0_and_100',
                              '(species_per_3 >= 0 AND species_per_3 <= 100) OR 
                               species_per_3 = -9999 OR -- OUT_OF_RANGE
                               species_per_3 = -9997 OR -- INVALID_VALUE
                               species_per_3 = -8888 OR -- NULL_VALUE
                               species_per_3 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.56'::text number,
       'lyr_all' target_table,
       'Issue #346 & #338: Some rows get TRANSLATION_ERROR and others get -9998 (NOT_IN_SET) and -8889 (EMPTY_STRING). Ensure LYR table SPECIES_PER_4 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_4_between_0_and_100',
                              '(species_per_4 >= 0 AND species_per_4 <= 100) OR 
                               species_per_4 = -9999 OR -- OUT_OF_RANGE
                               species_per_4 = -9997 OR -- INVALID_VALUE
                               species_per_4 = -8888 OR -- NULL_VALUE
                               species_per_4 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.57'::text number,
       'lyr_all' target_table,
       'Issue #346 & #338: Some rows get TRANSLATION_ERROR and others get -9998 (NOT_IN_SET) and -8889 (EMPTY_STRING). Ensure LYR table SPECIES_PER_5 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_5_between_0_and_100',
                              '(species_per_5 >= 0 AND species_per_5 <= 100) OR 
                               species_per_5 = -9999 OR -- OUT_OF_RANGE
                               species_per_5 = -9997 OR -- INVALID_VALUE
                               species_per_5 = -8888 OR -- NULL_VALUE
                               species_per_5 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.58'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_6 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_6_between_0_and_100',
                              '(species_per_6 >= 0 AND species_per_6 <= 100) OR 
                               species_per_6 = -9999 OR -- OUT_OF_RANGE
                               species_per_6 = -9997 OR -- INVALID_VALUE
                               species_per_6 = -8888 OR -- NULL_VALUE
                               species_per_6 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.59'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_7 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_7_between_0_and_100',
                              '(species_per_7 >= 0 AND species_per_7 <= 100) OR 
                               species_per_7 = -9999 OR -- OUT_OF_RANGE
                               species_per_7 = -9997 OR -- INVALID_VALUE
                               species_per_7 = -8888 OR -- NULL_VALUE
                               species_per_7 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.60'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_8 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_8_between_0_and_100',
                              '(species_per_8 >= 0 AND species_per_8 <= 100) OR 
                               species_per_8 = -9999 OR -- OUT_OF_RANGE
                               species_per_8 = -9997 OR -- INVALID_VALUE
                               species_per_8 = -8888 OR -- NULL_VALUE
                               species_per_8 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.61'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_9 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_9_between_0_and_100',
                              '(species_per_9 >= 0 AND species_per_9 <= 100) OR 
                               species_per_9 = -9999 OR -- OUT_OF_RANGE
                               species_per_9 = -9997 OR -- INVALID_VALUE
                               species_per_9 = -8888 OR -- NULL_VALUE
                               species_per_9 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.62'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_10 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_10_between_0_and_100',
                              '(species_per_10 >= 0 AND species_per_10 <= 100) OR 
                               species_per_10 = -9999 OR -- OUT_OF_RANGE
                               species_per_10 = -9997 OR -- INVALID_VALUE
                               species_per_10 = -8888 OR -- NULL_VALUE
                               species_per_10 = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.63'::text number,
       'lyr_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure NFL table HEIGHT_UPPER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['height_upper_between_0_and_100',
                              '(height_upper >= 0 AND height_upper <= 100) OR 
                               height_upper = -9999 OR -- OUT_OF_RANGE
                               height_upper = -9997 OR -- INVALID_VALUE
                               height_upper = -8888 OR -- NULL_VALUE
                               height_upper = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.64'::text number,
       'lyr_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure NFL table HEIGHT_LOWER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['height_lower_between_0_and_100',
                              '(height_lower >= 0 AND height_lower <= 100) OR 
                               height_lower = -9999 OR -- OUT_OF_RANGE
                               height_lower = -9997 OR -- INVALID_VALUE
                               height_lower = -8888 OR -- NULL_VALUE
                               height_lower = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the NFL_ALL table
-------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'nfl_all' target_table,
       'Add foreign key to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'nfl_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'nfl_all' target_table,
       'Ensure SOIL_MOIST_REG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['soil_moist_reg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'nfl_all' target_table,
       'Ensure LAYER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'nfl_all' target_table,
       'Ensure LAYER_RANK is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['layer_rank']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'nfl_all' target_table,
       'Ensure CROWN_CLOSURE_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['crown_closure_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'nfl_all' target_table,
       'Ensure CROWN_CLOSURE_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['crown_closure_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.8'::text number,
       'nfl_all' target_table,
       'Ensure HEIGHT_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['height_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.9'::text number,
       'nfl_all' target_table,
       'Ensure HEIGHT_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['height_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.10'::text number,
       'nfl_all' target_table,
       'Ensure NAT_NON_VEG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['nat_non_veg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.11'::text number,
       'nfl_all' target_table,
       'Ensure NON_FOR_ANTH is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['non_for_anth']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.12'::text number,
       'nfl_all' target_table,
       'Ensure NON_FOR_VEG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['non_for_veg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.13'::text number,
       'nfl_all' target_table,
       'Ensure NFL table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.14'::text number,
       'nfl_all' target_table,
       'Ensure NFL table SOIL_MOIST_REG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'FK', 
                        ARRAY['soil_moist_reg', 'casfri50_lookup', 'soil_moist_reg_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.15'::text number,
       'nfl_all' target_table,
       'Ensure NFL table LAYER is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 'layer > 0']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.16'::text number,
       'nfl_all' target_table,
       'Ensure NFL table LAYER_RANK is greater than 0 and smaller than 10' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['layer_rank_greater_than_zero', 
                              '(layer_rank > 0 AND layer_rank < 10) OR 
                                layer_rank = -8888 OR -- NULL_VALUE
                                layer_rank = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.17'::text number,
       'nfl_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure NFL table CROWN_CLOSURE_UPPER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['crown_closure_upper_between_0_and_100',
                              '(crown_closure_upper >= 0 AND crown_closure_upper <= 100) OR 
                               crown_closure_upper = -9999 OR -- OUT_OF_RANGE
                               crown_closure_upper = -9997 OR -- INVALID_VALUE
                               crown_closure_upper = -8888 OR -- NULL_VALUE
                               crown_closure_upper = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.18'::text number,
       'nfl_all' target_table,
       'Issue #338: -9998 (NOT_IN_SET) should not be accepted for an integer. Ensure NFL table CROWN_CLOSURE_LOWER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['crown_closure_lower_between_0_and_100',
                              '(crown_closure_lower >= 0 AND crown_closure_lower <= 100) OR 
                               crown_closure_lower = -9999 OR -- OUT_OF_RANGE
                               crown_closure_lower = -9997 OR -- INVALID_VALUE
                               crown_closure_lower = -8888 OR -- NULL_VALUE
                               crown_closure_lower = -8887    -- NOT_APPLICABLE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.19'::text number,
       'nfl_all' target_table,
       'Issue #325: Some rows return TRANSLATION_ERROR. Ensure NFL table NAT_NON_VEG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'nat_non_veg'],
                        ARRAY['AP', 'LA', 'RI', 'OC', 'RK', 'SA', 'SI',
                              'SL', 'EX', 'BE', 'WS', 'FL', 'IS', 'TF',
                              'NULL_VALUE', 'EMPTY_STRING', 'INVALID_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.20'::text number,
       'nfl_all' target_table,
       'Issue #325: Some rows return TRANSLATION_ERROR. Ensure NFL table NON_FOR_ANTH values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'non_for_anth'],
                        ARRAY['IN', 'FA', 'CL', 'SE', 'LG', 'PB', 'OT',
                              'NULL_VALUE', 'EMPTY_STRING', 'INVALID_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.21'::text number,
       'nfl_all' target_table,
       'Issue #325: Some rows return TRANSLATION_ERROR. Ensure NFL table NON_FOR_VEG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'non_for_veg'],
                        ARRAY['ST', 'SL', 'HF', 'HE', 'HG', 'BR', 'OM', 'TN',
                              'NULL_VALUE', 'EMPTY_STRING', 'INVALID_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
--) foo WHERE NOT passed;
