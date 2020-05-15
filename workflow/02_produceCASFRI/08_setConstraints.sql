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
CREATE SCHEMA IF NOT EXISTS casfri50_lookup ;
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
RETURNS boolean AS $$ 
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
      RETURN TRUE;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '%', SQLERRM;
      RETURN FALSE;
    END;
  END; 
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------
-- Add some constraints to the CAS_ALL table
-------------------------------------------------------
-- Add foreign key to HDR_ALL
SELECT TT_AddConstraint('casfri50', 'cas_all', 'FK', 
                        ARRAY['inventory_id', 'casfri50', 'hdr_all', 'inventory_id']);

-- Ensure attributes are NOT NULL
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['cas_id']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['inventory_id']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['orig_stand_id']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['stand_structure']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['num_of_layers']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['map_sheet_id']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['casfri_area']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['casfri_perimeter']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['src_inv_area']);
SELECT TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['stand_photo_year']);

-- Ensure CAS table CAS_ID is 50 characters long
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']);


-- Ensure CAS table INVENTORY_ID is 4 characters long
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(inventory_id) = 4']);

-- Ensure CAS table NUM_OF_LAYERS is greater than 0
-- Issue on replacing 0 with UNKNOWN_VALUE
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['num_of_layers_greater_than_zero', 
                              'num_of_layers > 0 OR 
                               num_of_layers = -8886 -- UNKNOWN_VALUE
                              ']); 

-- Ensure CAS table STAND_STRUCTURE values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'cas_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'stand_structure'],
                        ARRAY['S', 'M', 'H', 'C',
                             'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET']);

-- Ensure CAS table STAND_STRUCTURE fits with NUM_OF_LAYERS
-- Issue on replacing 0 with UNKNOWN_VALUE
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['num_of_layers_greater_than_zero', 
                              '((stand_structure = ''M'' OR 
                                 stand_structure = ''H'' OR 
                                 stand_structure = ''C'') AND 
                                num_of_layers > 1) OR 
                               ((stand_structure = ''S'' OR stand_structure = ''C'') AND num_of_layers = 1) OR 
                                num_of_layers = -8886 OR -- UNKNOWN_VALUE
                                stand_structure = ''NULL_VALUE'' OR
                                stand_structure = ''EMPTY_STRING'' OR
                                stand_structure = ''NOT_IN_SET''']);

-- Ensure CAS table CASFRI_AREA is greater than 0
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['casfri_area_greater_than_zero', 
                              'casfri_area > 0']);

-- Ensure CAS table CASFRI_PERIMETER is greater than 0
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['casfri_perimeter_greater_than_zero', 
                              'casfri_perimeter > 0']);

-- Ensure CAS table SRC_INV_AREA is greater than 0
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['src_inv_area_greater_than_zero', 
                              'src_inv_area >= 0 OR 
                               src_inv_area = -9997 OR -- INVALID_VALUE
                               src_inv_area = -8888 OR -- NULL_VALUE
                               src_inv_area = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure CAS table STAND_PHOTO_YEAR is greater than 0
-- Issue #248
SELECT TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['stand_photo_year_greater_than_zero', 
                              'stand_photo_year > 0']);

-------------------------------------------------------
-- Add some constraints to the DST_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
SELECT TT_AddConstraint('casfri50', 'dst_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']);

-- Ensure attributes are NOT NULL
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['cas_id']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_1']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_1']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_1']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_1']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_2']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_2']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_2']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_2']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_3']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_3']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_3']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_3']);
SELECT TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['layer']);

-- Ensure DST table CAS_ID is 50 characters long
SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']);

-- Ensure DST table LAYER is greater than 0
SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 
                              'layer > 0 OR 
                               layer = -8886 -- UNKNOWN_VALUE
                              ']); 

-- Ensure DST table DIST_TYPE_1 values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'dst_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'dist_type_1'],
                        ARRAY['CO', 'PC', 'BU', 'WF', 'DI', 'IK', 'FL', 
                              'WE', 'SL', 'OT', 'DT', 'SI', 'CL', 'UK',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET']);

-- Ensure DST table DIST_TYPE_2 and DIST_TYPE_3 values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'dst_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'dist_type_2'],
                        ARRAY['CO', 'PC', 'BU', 'WF', 'DI', 'IK', 'FL', 
                              'WE', 'SL', 'OT', 'DT', 'SI', 'CL', 'UK',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET', 'NOT_APPLICABLE']);

SELECT TT_AddConstraint('casfri50', 'dst_all', 'FK', 
                        ARRAY['dist_type_3', 'casfri50_lookup', 'dist_type_2_codes', 'code']);

-- Ensure DST table DIST_YEAR_1, DIST_YEAR_2 and DIST_YEAR_2 are greater than 1900 and below 2020
-- Issue #337
SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_1_greater_than_1900', 
                              '(1900 <= dist_year_1 AND dist_year_1 <= 2020) OR 
                                dist_year_1 = -9999 OR -- OUT_OF_RANGE
                                dist_year_1 = -9997 OR -- INVALID_VALUE
                                dist_year_1 = -8888    -- UNKNOWN_VALUE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_2_greater_than_1900', 
                              '(1900 <= dist_year_2 AND dist_year_2 <= 2020) OR 
                                dist_year_2 = -9999 OR -- OUT_OF_RANGE
                                dist_year_2 = -9997 OR -- INVALID_VALUE
                                dist_year_2 = -8888 OR -- NULL_VALUE
                                dist_year_2 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_3_greater_than_1900', 
                              '(1900 <= dist_year_3 AND dist_year_3 <= 2020) OR 
                                dist_year_3 = -9999 OR -- OUT_OF_RANGE
                                dist_year_3 = -9997 OR -- INVALID_VALUE
                                dist_year_3 = -8888 OR -- NULL_VALUE
                                dist_year_3 = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure DST table DIST_EXT_UPPER_1, DIST_EXT_UPPER_2 and DIST_EXT_UPPER_3 
-- are greater than 10 and below 100
-- Issue #338
SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_1_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_1 AND dist_ext_upper_1 <= 100) OR 
                               dist_ext_upper_1 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_upper_1 = -9997 OR -- INVALID_VALUE
                               dist_ext_upper_1 = -8888 OR -- NULL_VALUE
                               dist_ext_upper_1 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_2_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_2 AND dist_ext_upper_2 <= 100) OR 
                               dist_ext_upper_2 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_upper_2 = -9997 OR -- INVALID_VALUE
                               dist_ext_upper_2 = -8888 OR -- NULL_VALUE
                               dist_ext_upper_2 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_3_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_3 AND dist_ext_upper_3 <= 100) OR 
                               dist_ext_upper_3 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_upper_3 = -9997 OR -- INVALID_VALUE
                               dist_ext_upper_3 = -8888 OR -- NULL_VALUE
                               dist_ext_upper_3 = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure DST table DIST_EXT_LOWER_1, DIST_EXT_LOWER_2 and DIST_EXT_LOWER_3 
-- are greater than 10 and below 100
-- Issue #338
SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_1_betweeen_10_and_100', 
                              '(10 <= dist_ext_lower_1 AND dist_ext_lower_1 <= 100) OR 
                               dist_ext_lower_1 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_lower_1 = -9997 OR -- INVALID_VALUE
                               dist_ext_lower_1 = -8888 OR -- NULL_VALUE
                               dist_ext_lower_1 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_2_betweeen_10_and_100', 
                              '(10 <= dist_ext_lower_2 AND dist_ext_lower_2 <= 100) OR 
                               dist_ext_lower_2 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_lower_2 = -9997 OR -- INVALID_VALUE
                               dist_ext_lower_2 = -8888 OR -- NULL_VALUE
                               dist_ext_lower_2 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_3_betweeen_10_and_100', 
                              '(10 <= dist_ext_lower_3 AND dist_ext_lower_3 <= 100) OR 
                               dist_ext_lower_3 = -9999 OR -- OUT_OF_RANGE
                               dist_ext_lower_3 = -9997 OR -- INVALID_VALUE
                               dist_ext_lower_3 = -8888 OR -- NULL_VALUE
                               dist_ext_lower_3 = -8887    -- NOT_APPLICABLE
                              ']); 

-------------------------------------------------------
-- Add some constraints to the ECO_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
SELECT TT_AddConstraint('casfri50', 'eco_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']);

-- Ensure attributes are NOT NULL
SELECT TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['cas_id']);
SELECT TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wetland_type']);
SELECT TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_veg_cover']);
SELECT TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_landform_mod']);
SELECT TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_local_mod']);
SELECT TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['eco_site']);

-- Ensure ECO table CAS_ID is 50 characters long
SELECT TT_AddConstraint('casfri50', 'eco_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']);

-- Ensure ECO table WETLAND_TYPE values match the corresponding lookup table
-- Issue 'S' is in the database and not in the specs
-- 'NA', 'E' and 'Z' are in the specs but not in the database.
SELECT TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wetland_type'],
                        ARRAY['B', 'F', 'M', 'O', 'T', 'W',
                              'NOT_APPLICABLE']);

-- Ensure ECO table WET_VEG_COVER values match the corresponding lookup table
-- Issue 'P' is in the database and not in the specs
SELECT TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_veg_cover'],
                        ARRAY['F', 'T', 'O', 'C', 'M',
                              'NOT_APPLICABLE']);


-- Ensure ECO table WET_LANDFORM_MOD values match the corresponding lookup table
-- Issue 'P' is in the database and not in the specs
SELECT TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_landform_mod'],
                        ARRAY['X', 'P', 'N', 'A',
                              'NOT_APPLICABLE']);

-- Ensure ECO table WET_LOCAL_MOD values match the corresponding lookup table
-- Issue 'B' is found in the database but not in the specs.
SELECT TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_local_mod'],
                        ARRAY['C', 'R', 'I', 'N', 'S', 'G',
                              'NOT_APPLICABLE']);

-- Ensure ECO table ECO_SITE values match the corresponding lookup table
-- Issue eco_site does not seems to be translated
SELECT TT_AddConstraint('casfri50', 'eco_all', 'CHECK', 
                        ARRAY['eco_site_not_applicable', 'eco_site = ''NOT_APPLICABLE''']);

-------------------------------------------------------
-- Add some constraints to the LYR_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']);

-- Ensure attributes are NOT NULL
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['cas_id']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['soil_moist_reg']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['layer']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['layer_rank']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['crown_closure_upper']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['crown_closure_lower']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['height_upper']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['height_lower']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['productive_for']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_1']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_1']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_2']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_2']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_3']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_3']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_4']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_4']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_5']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_5']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_6']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_6']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_7']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_7']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_8']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_8']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_1']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_1']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_9']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_9']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_10']);
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_10']);

-- Ensure LYR table CAS_ID is 50 characters long
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']);

-- Ensure LYR table STRUCTURE_PER is greater than 0 and smaller or equal to 100
-- Issue 338
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['structure_per_between_0_and_100', 
                              '(structure_per > 0 AND structure_per <= 100) OR 
                                structure_per = -9999 OR -- OUT_OF_RANGE
                                structure_per = -9997 OR -- INVALID_VALUE
                                structure_per = -8888 OR -- NULL_VALUE
                                structure_per = -8887    -- NOT_APPLICABLE
                              ']); 


-- Ensure LYR table SOIL_MOIST_REG values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'soil_moist_reg'],
                        ARRAY['D', 'F', 'M', 'W', 'A',
                              'NULL_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']);

-- Ensure LYR table LAYER is greater than 0
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 'layer > 0']);

-- Ensure LYR table LAYER_RANK is greater than 0 and smaller than 10
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['layer_rank_greater_than_zero', 
                              '(layer_rank > 0 AND layer_rank < 10) OR 
                                layer_rank = -8888 OR -- NULL_VALUE
                                layer_rank = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure LYR table CROWN_CLOSURE_UPPER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['crown_closure_upper_between_0_and_100',
                              '(crown_closure_upper >= 0 AND crown_closure_upper <= 100) OR 
                               crown_closure_upper = -9999 OR -- OUT_OF_RANGE
                               crown_closure_upper = -9997 OR -- INVALID_VALUE
                               crown_closure_upper = -8888 OR -- NULL_VALUE
                               crown_closure_upper = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure LYR table CROWN_CLOSURE_LOWER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['crown_closure_lower_between_0_and_100',
                              '(crown_closure_lower >= 0 AND crown_closure_lower <= 100) OR 
                               crown_closure_lower = -9999 OR -- OUT_OF_RANGE
                               crown_closure_lower = -9997 OR -- INVALID_VALUE
                               crown_closure_lower = -8888 OR -- NULL_VALUE
                               crown_closure_lower = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure LYR table HEIGHT_UPPER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['height_upper_between_0_and_100',
                              '(height_upper >= 0 AND height_upper <= 100) OR 
                               height_upper = -9999 OR -- OUT_OF_RANGE
                               height_upper = -9997 OR -- INVALID_VALUE
                               height_upper = -8888 OR -- NULL_VALUE
                               height_upper = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure LYR table HEIGHT_LOWER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['height_lower_between_0_and_100',
                              '(height_lower >= 0 AND height_lower <= 100) OR 
                               height_lower = -9999 OR -- OUT_OF_RANGE
                               height_lower = -9997 OR -- INVALID_VALUE
                               height_lower = -8888 OR -- NULL_VALUE
                               height_lower = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure LYR table PRODUCTIVE_FOR values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'productive_for'],
                        ARRAY['TM', 'AL', 'SD', 'SC', 'NP', 'PP', 'PF',
                              'NULL_VALUE', 'NOT_IN_SET', 'NOT_APPLICABLE']);

-- Ensure LYR table SPECIES_1-10 values match the corresponding lookup table
-- Issue #346 - Some rows get TRANSLATION_ERROR
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

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_1', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_2', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_3', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_4', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_5', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_6', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_7', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_8', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_9', 'casfri50_lookup', 'species_codes', 'code']);

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_10', 'casfri50_lookup', 'species_codes', 'code']);


-- Ensure LYR table SPECIES_PER_1-10 are greater or equal to 0 and smaller or equal to 100
-- Issue #346 - Some rows get -3333 (TRANSLATION_ERROR)
-- Issue #338 - Some rows get -9998 (NOT_IN_SET) and -8889 (EMPTY_STRING)
SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_1_between_0_and_100',
                              '(species_per_1 >= 0 AND species_per_1 <= 100) OR 
                               species_per_1 = -9999 OR -- OUT_OF_RANGE
                               species_per_1 = -9997 OR -- INVALID_VALUE
                               species_per_1 = -8888 OR -- NULL_VALUE
                               species_per_1 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_2_between_0_and_100',
                              '(species_per_2 >= 0 AND species_per_2 <= 100) OR 
                               species_per_2 = -9999 OR -- OUT_OF_RANGE
                               species_per_2 = -9997 OR -- INVALID_VALUE
                               species_per_2 = -8888 OR -- NULL_VALUE
                               species_per_2 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_3_between_0_and_100',
                              '(species_per_3 >= 0 AND species_per_3 <= 100) OR 
                               species_per_3 = -9999 OR -- OUT_OF_RANGE
                               species_per_3 = -9997 OR -- INVALID_VALUE
                               species_per_3 = -8888 OR -- NULL_VALUE
                               species_per_3 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_4_between_0_and_100',
                              '(species_per_4 >= 0 AND species_per_4 <= 100) OR 
                               species_per_4 = -9999 OR -- OUT_OF_RANGE
                               species_per_4 = -9997 OR -- INVALID_VALUE
                               species_per_4 = -8888 OR -- NULL_VALUE
                               species_per_4 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_5_between_0_and_100',
                              '(species_per_5 >= 0 AND species_per_5 <= 100) OR 
                               species_per_5 = -9999 OR -- OUT_OF_RANGE
                               species_per_5 = -9997 OR -- INVALID_VALUE
                               species_per_5 = -8888 OR -- NULL_VALUE
                               species_per_5 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_6_between_0_and_100',
                              '(species_per_6 >= 0 AND species_per_6 <= 100) OR 
                               species_per_6 = -9999 OR -- OUT_OF_RANGE
                               species_per_6 = -9997 OR -- INVALID_VALUE
                               species_per_6 = -8888 OR -- NULL_VALUE
                               species_per_6 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_7_between_0_and_100',
                              '(species_per_7 >= 0 AND species_per_7 <= 100) OR 
                               species_per_7 = -9999 OR -- OUT_OF_RANGE
                               species_per_7 = -9997 OR -- INVALID_VALUE
                               species_per_7 = -8888 OR -- NULL_VALUE
                               species_per_7 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_8_between_0_and_100',
                              '(species_per_8 >= 0 AND species_per_8 <= 100) OR 
                               species_per_8 = -9999 OR -- OUT_OF_RANGE
                               species_per_8 = -9997 OR -- INVALID_VALUE
                               species_per_8 = -8888 OR -- NULL_VALUE
                               species_per_8 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_9_between_0_and_100',
                              '(species_per_9 >= 0 AND species_per_9 <= 100) OR 
                               species_per_9 = -9999 OR -- OUT_OF_RANGE
                               species_per_9 = -9997 OR -- INVALID_VALUE
                               species_per_9 = -8888 OR -- NULL_VALUE
                               species_per_9 = -8887    -- NOT_APPLICABLE
                              ']); 

SELECT TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_10_between_0_and_100',
                              '(species_per_10 >= 0 AND species_per_10 <= 100) OR 
                               species_per_10 = -9999 OR -- OUT_OF_RANGE
                               species_per_10 = -9997 OR -- INVALID_VALUE
                               species_per_10 = -8888 OR -- NULL_VALUE
                               species_per_10 = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure NFL table HEIGHT_UPPER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['height_upper_between_0_and_100',
                              '(height_upper >= 0 AND height_upper <= 100) OR 
                               height_upper = -9999 OR -- OUT_OF_RANGE
                               height_upper = -9997 OR -- INVALID_VALUE
                               height_upper = -8888 OR -- NULL_VALUE
                               height_upper = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure NFL table HEIGHT_LOWER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['height_lower_between_0_and_100',
                              '(height_lower >= 0 AND height_lower <= 100) OR 
                               height_lower = -9999 OR -- OUT_OF_RANGE
                               height_lower = -9997 OR -- INVALID_VALUE
                               height_lower = -8888 OR -- NULL_VALUE
                               height_lower = -8887    -- NOT_APPLICABLE
                              ']); 
-------------------------------------------------------
-- Add some constraints to the NFL_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']);

-- Ensure attributes are NOT NULL
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['cas_id']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['soil_moist_reg']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['layer']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['layer_rank']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['crown_closure_upper']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['crown_closure_lower']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['height_upper']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['height_lower']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['nat_non_veg']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['non_for_anth']);
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['non_for_veg']);

-- Ensure NFL table CAS_ID is 50 characters long
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']);

-- Ensure NFL table SOIL_MOIST_REG values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'FK', 
                        ARRAY['soil_moist_reg', 'casfri50_lookup', 'soil_moist_reg_codes', 'code']);

-- Ensure NFL table LAYER is greater than 0
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 'layer > 0']);

-- Ensure NFL table LAYER_RANK is greater than 0 and smaller than 10
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['layer_rank_greater_than_zero', 
                              '(layer_rank > 0 AND layer_rank < 10) OR 
                                layer_rank = -8888 OR -- NULL_VALUE
                                layer_rank = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure NFL table CROWN_CLOSURE_UPPER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['crown_closure_upper_between_0_and_100',
                              '(crown_closure_upper >= 0 AND crown_closure_upper <= 100) OR 
                               crown_closure_upper = -9999 OR -- OUT_OF_RANGE
                               crown_closure_upper = -9997 OR -- INVALID_VALUE
                               crown_closure_upper = -8888 OR -- NULL_VALUE
                               crown_closure_upper = -8887    -- NOT_APPLICABLE
                              ']); 

-- Ensure NFL table CROWN_CLOSURE_LOWER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['crown_closure_lower_between_0_and_100',
                              '(crown_closure_lower >= 0 AND crown_closure_lower <= 100) OR 
                               crown_closure_lower = -9999 OR -- OUT_OF_RANGE
                               crown_closure_lower = -9997 OR -- INVALID_VALUE
                               crown_closure_lower = -8888 OR -- NULL_VALUE
                               crown_closure_lower = -8887    -- NOT_APPLICABLE
                              ']);

-- Ensure NFL table NAT_NON_VEG values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'nat_non_veg'],
                        ARRAY['AP', 'LA', 'RI', 'OC', 'RK', 'SA', 'SI',
                              'SL', 'EX', 'BE', 'WS', 'FL', 'IS', 'TF',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET', 'NOT_APPLICABLE']);

-- Ensure NFL table NON_FOR_ANTH values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'non_for_anth'],
                        ARRAY['IN', 'FA', 'CL', 'SE', 'LG', 'PB', 'OT',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET', 'NOT_APPLICABLE']);

-- Ensure NFL table NON_FOR_VEG values match the corresponding lookup table
SELECT TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'non_for_veg'],
                        ARRAY['ST', 'SL', 'HF', 'HE', 'HG', 'BR', 'OM', 'TN',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET', 'NOT_APPLICABLE']);

-------------------------------------------------------

