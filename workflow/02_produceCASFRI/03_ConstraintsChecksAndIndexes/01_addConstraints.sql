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
-- Create the species_codes lookup table
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50_lookup.species_codes CASCADE;
CREATE TABLE casfri50_lookup.species_codes AS
SELECT code
FROM (SELECT DISTINCT casfri_species_codes code FROM translation.species_code_mapping
      UNION ALL
      SELECT * FROM unnest(TT_IsMissingOrNotInSetCode())
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
       'Add primary key to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'PK', 
                        ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'cas_all' target_table,
       'Add foreign key from CAS_ALL to HDR_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'FK', 
                        ARRAY['inventory_id', 'casfri50', 'hdr_all', 'inventory_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.3'::text number,
       'cas_all' target_table,
       'Ensure CAS_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.4'::text number,
       'cas_all' target_table,
       'Ensure INVENTORY_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['inventory_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.5'::text number,
       'cas_all' target_table,
       'Ensure ORIG_STAND_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['orig_stand_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.6'::text number,
       'cas_all' target_table,
       'Ensure STAND_STRUCTURE is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['stand_structure']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.7'::text number,
       'cas_all' target_table,
       'Ensure NUM_OF_LAYERS is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['num_of_layers']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.8'::text number,
       'cas_all' target_table,
       'Ensure MAP_SHEET_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['map_sheet_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.9'::text number,
       'cas_all' target_table,
       'Ensure CASFRI_AREA is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['casfri_area']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.10'::text number,
       'cas_all' target_table,
       'Ensure CASFRI_PERIMETER is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['casfri_perimeter']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.11'::text number,
       'cas_all' target_table,
       'Ensure SRC_INV_AREA is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['src_inv_area']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.12'::text number,
       'cas_all' target_table,
       'Ensure STAND_PHOTO_YEAR is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'NOTNULL', ARRAY['stand_photo_year']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.13'::text number,
       'cas_all' target_table,
       'Ensure CAS table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.14'::text number,
       'cas_all' target_table,
       'Ensure CAS table INVENTORY_ID is 4 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(inventory_id) = 4']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.15'::text number,
       'cas_all' target_table,
       'Issue #609. Five rows still produce NUM_OF_LAYERS = 0. Ensure CAS table NUM_OF_LAYERS is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['num_of_layers_greater_than_zero', 
                              'num_of_layers > 0 OR 
                               num_of_layers = -8886 -- UNKNOWN_VALUE (Cannot be TT_IsMissingOrInvalidNumber())
                              ']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.16'::text number,
       'cas_all' target_table,
       'Ensure CAS table STAND_STRUCTURE values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'stand_structure'],
                        ARRAY['SINGLE_LAYERED', 'MULTI_LAYERED', 'HORIZONTAL', 'COMPLEX'] ||
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.17'::text number,
       'cas_all' target_table,
       'Issue #609. Five rows still produce NUM_OF_LAYERS = 0. Ensure CAS table STAND_STRUCTURE fits with NUM_OF_LAYERS' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['stand_structure_match_num_of_layers', 
                              '((stand_structure = ''MULTI_LAYERED'' OR 
                                 stand_structure = ''HORIZONTAL'' OR 
                                 stand_structure = ''COMPLEX'' OR
                                 stand_structure = ''SINGLE_LAYERED'') AND 
                                num_of_layers > 1) OR 
                               ((stand_structure = ''SINGLE_LAYERED'' OR 
                                 stand_structure = ''COMPLEX'' OR
                                 stand_structure = ''HORIZONTAL'') AND 
                                num_of_layers = 1) OR 
                               num_of_layers = -8886 OR -- UNKNOWN_VALUE
                               stand_structure = ANY(TT_IsMissingOrNotInSetCode())']) AS (passed boolean, cstr_query text)) foo
-- Multi-layered must have >1 layer
-- Simple could have >1 if nfl is present
-- Horizontal should have >1, but NT often only reports one horizontal component and we should report it.
-- So horizontal can have 1.
-- Complex could have >1 if NFL present
---------------------------------------------------------
UNION ALL
SELECT '1.18'::text number,
       'cas_all' target_table,
       'Ensure CAS table CASFRI_AREA is greater than 0. Cannot be TT_IsMissingOrInvalidNumber()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['casfri_area_greater_than_zero', 
                              'casfri_area > 0']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.19'::text number,
       'cas_all' target_table,
       'Ensure CAS table CASFRI_PERIMETER is greater than 0. Cannot be TT_IsMissingOrInvalidNumber()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['casfri_perimeter_greater_than_zero', 
                              'casfri_perimeter > 0']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.20'::text number,
       'cas_all' target_table,
       'Ensure CAS table SRC_INV_AREA is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['src_inv_area_greater_than_zero', 
                              'src_inv_area >= 0 OR 
                               src_inv_area = ANY(TT_IsMissingOrInvalidNumber())
                              ']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.21'::text number,
       'cas_all' target_table,
       'Ensure CAS table STAND_PHOTO_YEAR is greater than 0' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'cas_all', 'CHECK', 
                        ARRAY['stand_photo_year_greater_than_zero', 
                              'stand_photo_year > 0 OR 
                               stand_photo_year = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the DST_ALL table
-------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'dst_all' target_table,
       'Add primary key to DST_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'PK', 
                        ARRAY['cas_id, layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'dst_all' target_table,
       'Add foreign key from DST_ALL to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.3'::text number,
       'dst_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.4'::text number,
       'dst_all' target_table,
       'Ensure DIST_TYPE_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.5'::text number,
       'dst_all' target_table,
       'Ensure DIST_YEAR_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.6'::text number,
       'dst_all' target_table,
       'Ensure DIST_EXT_UPPER_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.7'::text number,
       'dst_all' target_table,
       'Ensure DIST_EXT_LOWER_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.8'::text number,
       'dst_all' target_table,
       'Ensure DIST_TYPE_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.9'::text number,
       'dst_all' target_table,
       'Ensure DIST_YEAR_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.10'::text number,
       'dst_all' target_table,
       'Ensure DIST_EXT_UPPER_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.11'::text number,
       'dst_all' target_table,
       'Ensure DIST_EXT_LOWER_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.12'::text number,
       'dst_all' target_table,
       'Ensure DIST_TYPE_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_type_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.13'::text number,
       'dst_all' target_table,
       'Ensure DIST_YEAR_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_year_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.14'::text number,
       'dst_all' target_table,
       'Ensure DIST_EXT_UPPER_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_upper_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.15'::text number,
       'dst_all' target_table,
       'Ensure DIST_EXT_LOWER_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['dist_ext_lower_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.16'::text number,
       'dst_all' target_table,
       'Ensure LAYER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'NOTNULL', ARRAY['layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.17'::text number,
       'dst_all' target_table,
       'Ensure DST table CAS_ID is 50 characters long. Cannot be TT_IsMissingOrInvalidText()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.18'::text number,
       'dst_all' target_table,
       'Ensure DST table LAYER is greater than 0 or UNKNOWN. Cannot be TT_IsMissingOrInvalidNumber()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 
                              'layer > 0 OR 
                               layer = -8886 -- UNKNOWN_VALUE
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.19'::text number,
       'dst_all' target_table,
       'Issue #610. DIST_TYPE_1 was wrongly assigned FIRE. Ensure DST table DIST_TYPE_1 values match the corresponding lookup table. Cannot be NOT_APPLICABLE' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'dist_type_1'],
                        ARRAY['CUT', 'PARTIAL_CUT', 'BURN', 'WINDFALL', 'DISEASE', 'INSECT', 'FLOOD', 
                              'WEATHER', 'SLIDE', 'OTHER', 'DEAD_UNKNOWN', 'SILVICULTURE_TREATMENT',
                              'NULL_VALUE', 'EMPTY_STRING', 'NOT_IN_SET', 'UNKNOWN_VALUE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.20'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_TYPE_2 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'dist_type_2'],
                        ARRAY['CUT', 'PARTIAL_CUT', 'BURN', 'WINDFALL', 'DISEASE', 'INSECT', 'FLOOD', 
                              'WEATHER', 'SLIDE', 'OTHER', 'DEAD_UNKNOWN', 'SILVICULTURE_TREATMENT'] ||
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.21'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_TYPE_3 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'FK', 
                        ARRAY['dist_type_3', 'casfri50_lookup', 'dist_type_2_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.22'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_YEAR_1 is greater than 1000 and smaller than 2020' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_1_greater_than_1000_and_smaller_2020', 
                              '(1000 <= dist_year_1 AND dist_year_1 <= 2020) OR
                               dist_year_1 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.23'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_YEAR_2 is greater than 1900 and smaller than 2020' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_2_greater_than_1900_and_smaller_2020', 
                              '(1900 <= dist_year_2 AND dist_year_2 <= 2020) OR 
                               dist_year_2 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.24'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_YEAR_3 is greater than 1900 and smaller than 2020' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_3_greater_than_1900_and_smaller_2020', 
                              '(1900 <= dist_year_3 AND dist_year_3 <= 2020) OR
                                dist_year_3 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.25'::text number,
       'dst_all' target_table,
       'Issue #408. DIST_YEAR_1 is sometimes not well ordered in time. Ensure DST table DIST_YEAR_1 smaller than or equal to DIST_YEAR_2' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_1_smaller_than_dist_year_2', 
                              '(dist_year_1 <= dist_year_2 OR
                                dist_year_2 = ANY(TT_IsMissingOrInvalidRange())
                               ) OR dist_year_1 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.26'::text number,
       'dst_all' target_table,
       'Issue #408. DIST_YEAR_1 is sometimes not well ordered in time. Ensure DST table DIST_YEAR_2 smaller than or equal to DIST_YEAR_3' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_year_2_smaller_than_dist_year_3', 
                              '(dist_year_2 <= dist_year_3 OR 
                                 dist_year_3 = ANY(TT_IsMissingOrInvalidRange())
                               ) OR dist_year_2 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.27'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_LOWER_1 is greater than 10 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_1_betweeen_10_and_100', 
                              '(1 <= dist_ext_lower_1 AND dist_ext_lower_1 <= 100) OR 
                               dist_ext_lower_1 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.28'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_LOWER_2 is greater than 10 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_2_betweeen_10_and_100', 
                              '(1 <= dist_ext_lower_2 AND dist_ext_lower_2 <= 100) OR 
                               dist_ext_lower_2 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.29'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_LOWER_3 is greater than 10 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_lower_3_betweeen_10_and_100', 
                              '(1 <= dist_ext_lower_3 AND dist_ext_lower_3 <= 100) OR 
                               dist_ext_lower_3 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.30'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_1 is greater than 10 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_1_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_1 AND dist_ext_upper_1 <= 100) OR
                                dist_ext_upper_1 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.31'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_2 is greater than 10 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_2_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_2 AND dist_ext_upper_2 <= 100) OR
                                dist_ext_upper_2 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.32'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_3 is greater than 10 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_3_betweeen_10_and_100', 
                              '(10 <= dist_ext_upper_3 AND dist_ext_upper_3 <= 100) OR 
                               dist_ext_upper_3 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.33'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_1 is greater than or equal to DIST_EXT_LOWER_1' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_1_greater_than_dist_ext_lower_1', 
                              '(dist_ext_upper_1 >= dist_ext_lower_1 OR 
                                dist_ext_lower_1 = ANY(TT_IsMissingOrInvalidRange())
                               ) OR
                               dist_ext_upper_1 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.34'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_2 is greater than or equal to DIST_EXT_LOWER_2' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_2_greater_than_dist_ext_lower_2', 
                              '(dist_ext_upper_2 >= dist_ext_lower_2 OR 
                                 dist_ext_lower_2 = ANY(TT_IsMissingOrInvalidRange())
                                ) OR
                               dist_ext_upper_2 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '2.35'::text number,
       'dst_all' target_table,
       'Ensure DST table DIST_EXT_UPPER_3 is greater than or equal to DIST_EXT_LOWER_3' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'dst_all', 'CHECK', 
                        ARRAY['dist_ext_upper_3_greater_than_dist_ext_lower_3', 
                              '(dist_ext_upper_3 >= dist_ext_lower_3 OR 
                                 dist_ext_lower_3 = ANY(TT_IsMissingOrInvalidRange())
                                ) OR
                               dist_ext_upper_3 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the ECO_ALL table
-------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'eco_all' target_table,
       'Add primary key to ECO_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'PK', 
                        ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'eco_all' target_table,
       'Add foreign key from ECO_ALL to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.3'::text number,
       'eco_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.4'::text number,
       'eco_all' target_table,
       'Ensure WETLAND_TYPE is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wetland_type']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.5'::text number,
       'eco_all' target_table,
       'Ensure WET_VEG_COVER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_veg_cover']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.6'::text number,
       'eco_all' target_table,
       'Ensure WET_LANDFORM_MOD is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_landform_mod']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.7'::text number,
       'eco_all' target_table,
       'Ensure WET_LOCAL_MOD is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['wet_local_mod']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.8'::text number,
       'eco_all' target_table,
       'Ensure ECO_SITE is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'NOTNULL', ARRAY['eco_site']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.9'::text number,
       'eco_all' target_table,
       'Ensure ECO table CAS_ID is 50 characters long. Cannot be TT_IsMissingOrInvalidText()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.10'::text number,
       'eco_all' target_table,
       'Ensure ECO table WETLAND_TYPE values match the corresponding lookup table. Cannot be TT_IsMissingOrNotInSetCode()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wetland_type'],
                        ARRAY['BOG', 'FEN', 'SWAMP', 'MARSH', 'SHALLOW_WATER', 'TIDAL_FLATS', 'ESTUARY', 'WETLAND', 'NOT_WETLAND',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.11'::text number,
       'eco_all' target_table,
       'Ensure ECO table WET_VEG_COVER values match the corresponding lookup table. Cannot be TT_IsMissingOrNotInSetCode()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_veg_cover'],
                        ARRAY['FORESTED', 'WOODED', 'OPEN_NON_TREED_FRESHWATER', 'OPEN_NON_TREED_COASTAL', 'MUD',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.12'::text number,
       'eco_all' target_table,
       'Ensure ECO table WET_LANDFORM_MOD values match the corresponding lookup table. Cannot be TT_IsMissingOrNotInSetCode()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_landform_mod'],
                        ARRAY['PERMAFROST_PRESENT', 'PATTERNING_PRESENT', 'NO_PERMAFROST_PATTERNING', 'SALINE_ALKALINE',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.13'::text number,
       'eco_all' target_table,
       'Issue #377. ''B'' is found in the database but not in the specs. Ensure ECO table WET_LOCAL_MOD values match the corresponding lookup table. Cannot be TT_IsMissingOrNotInSetCode()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'wet_local_mod'],
                        ARRAY['INT_LAWN_SCAR', 'INT_LAWN_ISLAND', 'INT_LAWN', 'NO_LAWN', 'SHRUB_COVER', 'GRAMINOIDS',
                              'NOT_APPLICABLE']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '3.14'::text number,
       'eco_all' target_table,
       'Issue #376. eco_site does not seems to be translated. Ensure ECO table ECO_SITE values match the corresponding lookup table. Cannot be TT_IsMissingOrInvalidText()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'eco_all', 'CHECK', 
                        ARRAY['eco_site_not_applicable', 'eco_site != ''NOT_APPLICABLE''']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
-- Add some constraints to the LYR_ALL table
-------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'lyr_all' target_table,
       'Add primary key to LYR_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'PK', 
                        ARRAY['cas_id, layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'lyr_all' target_table,
       'Add foreign key from LYR_ALL to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.3'::text number,
       'lyr_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.4'::text number,
       'lyr_all' target_table,
       'Ensure SOIL_MOIST_REG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['soil_moist_reg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.5'::text number,
       'lyr_all' target_table,
       'Ensure LAYER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.6'::text number,
       'lyr_all' target_table,
       'Ensure LAYER_RANK is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['layer_rank']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.7'::text number,
       'lyr_all' target_table,
       'Ensure CROWN_CLOSURE_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['crown_closure_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.8'::text number,
       'lyr_all' target_table,
       'Ensure CROWN_CLOSURE_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['crown_closure_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.9'::text number,
       'lyr_all' target_table,
       'Ensure HEIGHT_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['height_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.10'::text number,
       'lyr_all' target_table,
       'Ensure HEIGHT_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['height_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.11'::text number,
       'lyr_all' target_table,
       'Ensure PRODUCTIVITY is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['productivity']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.12'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.13'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_1 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_1']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.14'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.15'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_2 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_2']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.16'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.17'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_3 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_3']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.18'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_4 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_4']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.19'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_4 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_4']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.20'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_5 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_5']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.21'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_5 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_5']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.22'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_6 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_6']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.23'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_6 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_6']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.24'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_7 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_7']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.25'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_7 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_7']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.26'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_8 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_8']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.27'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_8 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_8']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.28'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_9 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_9']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.29'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_9 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_9']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.30'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_10 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_10']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.31'::text number,
       'lyr_all' target_table,
       'Ensure SPECIES_PER_10 is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['species_per_10']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.32'::text number,
       'lyr_all' target_table,
       'Ensure ORIGIN_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['origin_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.33'::text number,
       'lyr_all' target_table,
       'Ensure ORIGIN_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['origin_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.34'::text number,
       'lyr_all' target_table,
       'Ensure SITE_CLASS is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['site_class']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.35'::text number,
       'lyr_all' target_table,
       'Ensure SITE_INDEX is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'NOTNULL', ARRAY['site_index']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.36'::text number,
       'lyr_all' target_table,
       'Ensure LYR table CAS_ID is 50 characters long. Cannot be TT_IsMissingOrInvalidText()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.37'::text number,
       'lyr_all' target_table,
       'Ensure LYR table STRUCTURE_PER is greater than 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['structure_per_between_0_and_100', 
                              '(structure_per > 0 AND structure_per <= 100) OR 
                               structure_per = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.38'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SOIL_MOIST_REG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'soil_moist_reg'],
                        ARRAY['DRY', 'MESIC', 'MOIST', 'WET', 'AQUATIC'] || 
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.39'::text number,
       'lyr_all' target_table,
       'Ensure LYR table LAYER is greater than 0. Cannot be TT_IsMissingOrInvalidNumber()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 'layer > 0']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.40'::text number,
       'lyr_all' target_table,
       'Ensure LYR table LAYER_RANK is greater than 0 and smaller than 10' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['layer_rank_greater_than_zero', 
                              '(layer_rank > 0 AND layer_rank < 10) OR 
                                layer_rank = ANY(TT_IsMissingOrInvalidNumber()) 
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.41'::text number,
       'lyr_all' target_table,
       'Ensure LYR table CROWN_CLOSURE_UPPER is greater than 0, smaller than or equal to 100 and greater than CROWN_CLOSURE_LOWER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['crown_closure_upper_between_0_and_100_and_greater_than_crown_closure_lower',
                              '(crown_closure_upper >= 0 AND crown_closure_upper <= 100 AND 
                                (crown_closure_lower <= crown_closure_upper OR
                                 crown_closure_lower = ANY(TT_IsMissingOrInvalidRange())
                                )
                               ) OR crown_closure_upper = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.42'::text number,
       'lyr_all' target_table,
       'Ensure LYR table CROWN_CLOSURE_LOWER is greater than 0, smaller than or equal to 100 and smaller than CROWN_CLOSURE_UPPER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['crown_closure_lower_between_0_and_100_and_smaller_than_crown_closure_upper',
                              '(crown_closure_lower >= 0 AND crown_closure_lower <= 100 AND 
                                (crown_closure_lower <= crown_closure_upper OR 
                                 crown_closure_upper = ANY(TT_IsMissingOrInvalidRange())
                                )
                              ) OR crown_closure_lower = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.43'::text number,
       'lyr_all' target_table,
       'Ensure LYR table HEIGHT_UPPER is greater than 0, smaller than or equal to 100 and greater than HEIGHT_LOWER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['height_upper_between_0_and_100_and_greater_than_height_lower',
                              '(height_upper >= 0 AND height_upper <= 100 AND 
                                (height_upper >= height_lower OR 
                                 height_lower = ANY(TT_IsMissingOrInvalidRange())
                                )
                              ) OR height_upper = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.44'::text number,
       'lyr_all' target_table,
       'Ensure LYR table HEIGHT_LOWER is greater than 0, smaller than or equal to 100 and smaller than HEIGHT_UPPER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['height_lower_between_0_and_100_and_smaller_than_height_upper',
                              '(height_lower >= 0 AND height_lower <= 100 AND 
                                (height_upper >= height_lower OR 
                                 height_upper = ANY(TT_IsMissingOrInvalidRange())
                                )
                               ) OR height_lower = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.45'::text number,
       'lyr_all' target_table,
       'Ensure LYR table PRODUCTIVITY values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'productivity'],
                        ARRAY['NON_PRODUCTIVE_FOREST', 'PRODUCTIVE_FOREST'] || 
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.46'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_1 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_1', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.47'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_2 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_2', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.48'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_3 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_3', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.49'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_4 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_4', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.50'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_5 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_5', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.51'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_6 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_6', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.52'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_7 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_7', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.53'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_8 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_8', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.54'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_9 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_9', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.55'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_10 values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'FK', 
                        ARRAY['species_10', 'casfri50_lookup', 'species_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.56'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_1 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_1_between_0_and_100',
                              '(species_per_1 >= 0 AND species_per_1 <= 100) OR 
                               species_per_1 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.57'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_2 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_2_between_0_and_100',
                              '(species_per_2 >= 0 AND species_per_2 <= 100) OR 
                               species_per_2 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.58'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_3 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_3_between_0_and_100',
                              '(species_per_3 >= 0 AND species_per_3 <= 100) OR 
                               species_per_3 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.59'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_4 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_4_between_0_and_100',
                              '(species_per_4 >= 0 AND species_per_4 <= 100) OR 
                               species_per_4 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.60'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_5 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_5_between_0_and_100',
                              '(species_per_5 >= 0 AND species_per_5 <= 100) OR 
                               species_per_5 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.61'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_6 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_6_between_0_and_100',
                              '(species_per_6 >= 0 AND species_per_6 <= 100) OR 
                               species_per_6 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.62'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_7 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_7_between_0_and_100',
                              '(species_per_7 >= 0 AND species_per_7 <= 100) OR 
                               species_per_7 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.63'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_8 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_8_between_0_and_100',
                              '(species_per_8 >= 0 AND species_per_8 <= 100) OR 
                               species_per_8 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.64'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_9 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_9_between_0_and_100',
                              '(species_per_9 >= 0 AND species_per_9 <= 100) OR 
                               species_per_9 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.65'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SPECIES_PER_10 are greater or equal to 0 and smaller than or equal to 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['species_per_10_between_0_and_100',
                              '(species_per_10 >= 0 AND species_per_10 <= 100) OR 
                               species_per_10 = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.66'::text number,
       'lyr_all' target_table,
       'Ensure LYR table ORIGIN_UPPER is greater than 1000, smaller than 2050 and greater than ORIGIN_LOWER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['origin_upper_between_1000_and_2050_and_greater_than_origin_lower',
                              '(origin_upper > 1000 AND origin_upper <= 2050 AND 
                                (origin_lower <= origin_upper OR 
                                 origin_lower = ANY(TT_IsMissingOrInvalidRange())
                                )
                               ) OR origin_upper = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.67'::text number,
       'lyr_all' target_table,
       'Ensure LYR table ORIGIN_LOWER is greater than 1000, smaller than 2050 and smaller than ORIGIN_UPPER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['origin_lower_between_0_and_2050_and_smaller_than_origin_upper',
                              '(origin_lower > 1000 AND origin_lower <= 2050 AND 
                                (origin_lower <= origin_upper OR 
                                 origin_upper = ANY(TT_IsMissingOrInvalidRange())
                                )
                               ) OR origin_lower = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.68'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SITE_CLASS values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'site_class'],
                        ARRAY['UNPRODUCTIVE', 'POOR', 'MEDIUM', 'GOOD'] ||
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.69'::text number,
       'lyr_all' target_table,
       'Ensure LYR table SITE_INDEX is greater than 0 and smaller than 100' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'CHECK', 
                        ARRAY['site_index_between_0_and_100',
                              '(site_index >= 0 AND site_index < 100) OR 
                               site_index = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '4.70'::text number,
       'lyr_all' target_table,
       'Ensure LYR table PRODUCTIVITY_TYPE values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'lyr_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'productivity_type'],
                        ARRAY['HARVESTABLE', 'PROTECTION_FOREST', 'TREED_MUSKEG', 'TREED_ROCK', 'ALPINE_FOREST', 'SCRUB_SHRUB', 'ALDER'] || 
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo

-------------------------------------------------------
-- Add some constraints to the NFL_ALL table
-------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'nfl_all' target_table,
       'Issue #420. Duplicate cas_id/layer couple in NT02. Add primary key to NFL_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'PK', 
                        ARRAY['cas_id, layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'nfl_all' target_table,
       'Add foreign key from NFL_ALL to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.3'::text number,
       'nfl_all' target_table,
       'Ensure CAS_ID is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.4'::text number,
       'nfl_all' target_table,
       'Ensure SOIL_MOIST_REG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['soil_moist_reg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.5'::text number,
       'nfl_all' target_table,
       'Ensure LAYER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['layer']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.6'::text number,
       'nfl_all' target_table,
       'Ensure LAYER_RANK is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['layer_rank']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.7'::text number,
       'nfl_all' target_table,
       'Ensure CROWN_CLOSURE_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['crown_closure_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.8'::text number,
       'nfl_all' target_table,
       'Ensure CROWN_CLOSURE_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['crown_closure_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.9'::text number,
       'nfl_all' target_table,
       'Ensure HEIGHT_UPPER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['height_upper']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.10'::text number,
       'nfl_all' target_table,
       'Ensure HEIGHT_LOWER is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['height_lower']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.11'::text number,
       'nfl_all' target_table,
       'Ensure NAT_NON_VEG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['nat_non_veg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.12'::text number,
       'nfl_all' target_table,
       'Ensure NON_FOR_ANTH is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['non_for_anth']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.13'::text number,
       'nfl_all' target_table,
       'Ensure NON_FOR_VEG is NOT NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'NOTNULL', ARRAY['non_for_veg']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.14'::text number,
       'nfl_all' target_table,
       'Ensure NFL table CAS_ID is 50 characters long. Cannot be TT_IsMissingOrInvalidText()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.15'::text number,
       'nfl_all' target_table,
       'Ensure NFL table SOIL_MOIST_REG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'FK', 
                        ARRAY['soil_moist_reg', 'casfri50_lookup', 'soil_moist_reg_codes', 'code']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.16'::text number,
       'nfl_all' target_table,
       'Ensure NFL table LAYER is greater than or equal to 0. Cannot be TT_IsMissingOrInvalidNumber()' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['layer_greater_than_zero', 'layer >= 0']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.17'::text number,
       'nfl_all' target_table,
       'Ensure NFL table LAYER_RANK is greater than 0 and smaller than 10' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['layer_rank_greater_than_zero', 
                              '(layer_rank > 0 AND layer_rank < 10) OR 
                                layer_rank = ANY(TT_IsMissingOrInvalidNumber())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.18'::text number,
       'nfl_all' target_table,
       'Ensure NFL table CROWN_CLOSURE_UPPER is greater than 0, smaller than or equal to 100 and greater than CROWN_CLOSURE_LOWER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['crown_closure_upper_between_0_and_100_and_greater_than_crown_closure_lower',
                              '(crown_closure_upper >= 0 AND crown_closure_upper <= 100 AND 
                                (crown_closure_lower <= crown_closure_upper OR
                                 crown_closure_lower = ANY(TT_IsMissingOrInvalidRange())
                                )
                               ) OR crown_closure_upper = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.19'::text number,
       'nfl_all' target_table,
       'Ensure NFL table CROWN_CLOSURE_LOWER is greater than 0, smaller than or equal to 100 and smaller than CROWN_CLOSURE_UPPER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['crown_closure_lower_between_0_and_100_and_smaller_than_crown_closure_upper',
                              '(crown_closure_lower >= 0 AND crown_closure_lower <= 100 AND 
                                (crown_closure_lower <= crown_closure_upper OR 
                                 crown_closure_upper = ANY(TT_IsMissingOrInvalidRange())
                                )
                              ) OR crown_closure_lower = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.20'::text number,
       'nfl_all' target_table,
       'Ensure NFL table HEIGHT_UPPER is greater than 0, smaller than or equal to 100 and greater than HEIGHT_LOWER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['height_upper_between_0_and_100_and_greater_than_height_lower',
                              '(height_upper >= 0 AND height_upper <= 100 AND 
                                (height_upper >= height_lower OR 
                                 height_lower = ANY(TT_IsMissingOrInvalidRange())
                                )
                              ) OR height_upper = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.21'::text number,
       'nfl_all' target_table,
       'Ensure NFL table HEIGHT_LOWER is greater than 0, smaller than or equal to 100 and smaller than HEIGHT_UPPER' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['height_lower_between_0_and_100_and_smaller_than_height_upper',
                              '(height_lower >= 0 AND height_lower <= 100 AND 
                                (height_upper >= height_lower OR 
                                 height_upper = ANY(TT_IsMissingOrInvalidRange())
                                )
                               ) OR height_lower = ANY(TT_IsMissingOrInvalidRange())
                              ']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.22'::text number,
       'nfl_all' target_table,
       'Ensure NFL table NAT_NON_VEG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'nat_non_veg'],
                        ARRAY['ALPINE', 'LAKE', 'RIVER', 'OCEAN', 'ROCK_RUBBLE', 'SAND', 'SNOW_ICE', 'SLIDE', 
                              'EXPOSED_LAND', 'BEACH', 'WATER_SEDIMENT', 'FLOOD', 'ISLAND', 'TIDAL_FLATS', 'OTHER', 'WATERBODY'] ||
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.23'::text number,
       'nfl_all' target_table,
       'Ensure NFL table NON_FOR_ANTH values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'non_for_anth'],
                        ARRAY['INDUSTRIAL', 'FACILITY_INFRASTRUCTURE', 'CULTIVATED', 'SETTLEMENT', 'LAGOON', 'BORROW_PIT', 'OTHER'] ||
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.24'::text number,
       'nfl_all' target_table,
       'Issue #347: Invalid or undocumented codes. Ensure NFL table NON_FOR_VEG values match the corresponding lookup table' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'LOOKUP', 
                        ARRAY['casfri50_lookup', 
                              'non_for_veg'],
                        ARRAY['OPEN_SHRUB', 'CLOSED_SHRUB', 'ALPINE_FOREST', 'TALL_SHRUB', 'LOW_SHRUB', 
						                  'FORBS', 'HERBS', 'GRAMINOIDS', 'BRYOID', 'OPEN_MUSKEG', 'TUNDRA', 'OTHER'] ||
                        TT_IsMissingOrNotInSetCode()) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '5.25'::text number,
       'nfl_all' target_table,
       'Issue #526 #365: Exactly one NFL record per row, except in AB03, AB10, AB25 and AB29 where multiple attributes per row are needed when structure is horizontal.' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'nfl_all', 'CHECK', 
                        ARRAY['one_nfl_per_row',
                              'LEFT(cas_id, 4) IN(''AB03'', ''AB25'', ''AB29'', ''AB10'') OR
							  (
							  ((non_for_veg=ANY(TT_IsMissingOrNotInSetCode()))::int + (nat_non_veg=ANY(TT_IsMissingOrNotInSetCode()))::int + (non_for_anth=ANY(TT_IsMissingOrNotInSetCode()))::int)=2
							  )
                              ']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
--) foo WHERE NOT passed;
