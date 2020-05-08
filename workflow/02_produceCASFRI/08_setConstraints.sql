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
-- Add different constraints to the CAS_ALL table
-------------------------------------------------------
-- Add foreign key to HDR_ALL
ALTER TABLE casfri50.hdr_all
ADD FOREIGN KEY (inventory_id) 
REFERENCES casfri50.hdr_all (inventory_id) MATCH FULL;

-- Ensure attributes are NOT NULL
ALTER TABLE casfri50.cas_all 
ALTER COLUMN cas_id SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN inventory_id SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN orig_stand_id SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN stand_structure SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN num_of_layers SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN map_sheet_id SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN casfri_area SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN casfri_perimeter SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN src_inv_area SET NOT NULL;

ALTER TABLE casfri50.cas_all 
ALTER COLUMN stand_photo_year SET NOT NULL;

-- Ensure CAS table CAS_ID is 50 characters long
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS cas_id_length;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure CAS table INVENTORY_ID is 4 characters long
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS inventory_id_length;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT inventory_id_length
CHECK (length(inventory_id) = 4);

-- Ensure CAS table NUM_OF_LAYERS is greater than 0
-- Issue on replacing 0 with UNKNOWN_VALUE
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS num_of_layers_greater_than_zero;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT num_of_layers_greater_than_zero
CHECK (num_of_layers > 0 OR 
       num_of_layers = -8886); -- UNKNOWN_VALUE

-- Ensure CAS table STAND_STRUCTURE values match the corresponding lookup table
DROP TABLE IF EXISTS casfri50_lookup.stand_structure_codes;
CREATE TABLE casfri50_lookup.stand_structure_codes AS
SELECT * FROM (VALUES ('S'), ('M'), ('H'), ('C'), 
                      ('NULL_VALUE'), ('EMPTY_STRING'), ('NOT_IN_SET')) AS t(code);

ALTER TABLE casfri50_lookup.stand_structure_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS cas_stand_structure_fk;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT cas_stand_structure_fk FOREIGN KEY (stand_structure) 
REFERENCES casfri50_lookup.stand_structure_codes (code);

-- Ensure CAS table STAND_STRUCTURE fits with NUM_OF_LAYERS
-- Issue on replacing 0 with UNKNOWN_VALUE
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS stand_structure_num_of_layers;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT stand_structure_num_of_layers 
CHECK (((stand_structure = 'M' OR stand_structure = 'H' OR stand_structure = 'C') AND num_of_layers > 1) OR 
       ((stand_structure = 'S' OR stand_structure = 'C') AND num_of_layers = 1) OR 
       num_of_layers = -8886 OR -- UNKNOWN_VALUE
       stand_structure = 'NULL_VALUE' OR
       stand_structure = 'EMPTY_STRING' OR
       stand_structure = 'NOT_IN_SET');

-- Ensure CAS table CASFRI_AREA is greater than 0
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS casfri_area_greater_than_zero;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT casfri_area_greater_than_zero
CHECK (casfri_area > 0);

-- Ensure CAS table CASFRI_PERIMETER is greater than 0
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS casfri_perimeter_greater_than_zero;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT casfri_perimeter_greater_than_zero
CHECK (casfri_perimeter > 0);

-- Ensure CAS table SRC_INV_AREA is greater than 0
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS src_inv_area_greater_than_zero;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT src_inv_area_greater_than_zero
CHECK (src_inv_area >= 0 OR 
       src_inv_area = -9997 OR -- INVALID_VALUE
       src_inv_area = -8888 OR -- NULL_VALUE
       src_inv_area = -8887);  -- NOT_APPLICABLE

-- Ensure CAS table STAND_PHOTO_YEAR is greater than 0
-- Issue #248
ALTER TABLE casfri50.cas_all DROP CONSTRAINT IF EXISTS stand_photo_year_greater_than_zero;
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT stand_photo_year_greater_than_zero
CHECK (stand_photo_year > 0);

-------------------------------------------------------
-- Add different constraints to the DST_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
ALTER TABLE casfri50.dst_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;

-- Ensure attributes are NOT NULL
ALTER TABLE casfri50.dst_all 
ALTER COLUMN cas_id SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_type_1 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_year_1 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_ext_upper_1 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_ext_lower_1 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_type_2 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_year_2 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_ext_upper_2 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_ext_lower_2 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_type_3 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_year_3 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_ext_upper_3 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN dist_ext_lower_3 SET NOT NULL;

ALTER TABLE casfri50.dst_all 
ALTER COLUMN layer SET NOT NULL;

-- Ensure DST table CAS_ID is 50 characters long
ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS cas_id_length;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure DST table LAYER is greater than 0
ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS layer_greater_than_zero;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT layer_greater_than_zero
CHECK (layer > 0 OR 
       layer = -8886); -- UNKNOWN_VALUE

-- Ensure DST table DIST_TYPE_1 values match the corresponding lookup table
DROP TABLE IF EXISTS casfri50_lookup.dist_type_1_codes CASCADE;
CREATE TABLE casfri50_lookup.dist_type_1_codes AS
SELECT * FROM (VALUES ('CO'), ('PC'), ('BU'), ('WF'), ('DI'), ('IK'), ('FL'), 
                      ('WE'), ('SL'), ('OT'), ('DT'), ('SI'), ('CL'), ('UK'),
                      ('NULL_VALUE'), ('EMPTY_STRING'), ('NOT_IN_SET')) AS t(code);

ALTER TABLE casfri50_lookup.dist_type_1_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dst_dist_type_1_fk;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dst_dist_type_1_fk FOREIGN KEY (dist_type_1) 
REFERENCES casfri50_lookup.dist_type_1_codes (code);

-- Ensure DST table DIST_TYPE_2 and DIST_TYPE_3 values match the corresponding lookup table
DROP TABLE IF EXISTS casfri50_lookup.dist_type_2_3_codes CASCADE;
CREATE TABLE casfri50_lookup.dist_type_2_3_codes AS
SELECT * FROM (VALUES ('CO'), ('PC'), ('BU'), ('WF'), ('DI'), ('IK'), ('FL'), 
                      ('WE'), ('SL'), ('OT'), ('DT'), ('SI'), ('CL'), ('UK'),
                      ('NULL_VALUE'), ('EMPTY_STRING'), ('NOT_IN_SET'), ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.dist_type_2_3_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dst_dist_type_2_fk;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dst_dist_type_2_fk FOREIGN KEY (dist_type_2) 
REFERENCES casfri50_lookup.dist_type_2_3_codes (code);

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dst_dist_type_3_fk;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dst_dist_type_3_fk FOREIGN KEY (dist_type_3) 
REFERENCES casfri50_lookup.dist_type_2_3_codes (code);

-- Ensure DST table DIST_YEAR_1, DIST_YEAR_2 and DIST_YEAR_2 are greater than 1900 and below 2020
-- Issue #337
ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_year_1_greater_than_1900;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_year_1_greater_than_1900
CHECK ((1900 <= dist_year_1 AND dist_year_1 <= 2020) OR 
       dist_year_1 = -9999 OR -- OUT_OF_RANGE
       dist_year_1 = -9997 OR -- INVALID_VALUE
       dist_year_1 = -8888);  -- NULL_VALUE

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_year_2_greater_than_1900;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_year_2_greater_than_1900
CHECK ((1900 <= dist_year_2 AND dist_year_2 <= 2020) OR 
       dist_year_2 = -9999 OR -- OUT_OF_RANGE
       dist_year_2 = -9997 OR -- INVALID_VALUE
       dist_year_2 = -8888 OR -- NULL_VALUE
       dist_year_2 = -8887);  -- NOT_APPLICABLE

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_year_3_greater_than_1900;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_year_3_greater_than_1900
CHECK ((1900 <= dist_year_3 AND dist_year_3 <= 2020) OR 
       dist_year_3 = -9999 OR -- OUT_OF_RANGE
       dist_year_3 = -9997 OR -- INVALID_VALUE
       dist_year_3 = -8888 OR -- NULL_VALUE
       dist_year_3 = -8887);  -- NOT_APPLICABLE

-- Ensure DST table DIST_EXT_UPPER_1, DIST_EXT_UPPER_2 and DIST_EXT_UPPER_3 
-- are greater than 10 and below 100
-- Issue #338
ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_ext_upper_1_betweeen_10_and_100;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_ext_upper_1_betweeen_10_and_100
CHECK ((10 <= dist_ext_upper_1 AND dist_ext_upper_1 <= 100) OR 
       dist_ext_upper_1 = -9999 OR -- OUT_OF_RANGE
       dist_ext_upper_1 = -9997 OR -- INVALID_VALUE
       dist_ext_upper_1 = -8888 OR -- NULL_VALUE
       dist_ext_upper_1 = -8887);  -- NOT_APPLICABLE

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_ext_upper_2_betweeen_10_and_100;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_ext_upper_2_betweeen_10_and_100
CHECK ((10 <= dist_ext_upper_2 AND dist_ext_upper_2 <= 100) OR 
       dist_ext_upper_2 = -9999 OR -- OUT_OF_RANGE
       dist_ext_upper_2 = -9997 OR -- INVALID_VALUE
       dist_ext_upper_2 = -8888 OR -- NULL_VALUE
       dist_ext_upper_2 = -8887);  -- NOT_APPLICABLE

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_ext_upper_3_betweeen_10_and_100;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_ext_upper_3_betweeen_10_and_100
CHECK ((10 <= dist_ext_upper_3 AND dist_ext_upper_3 <= 100) OR 
       dist_ext_upper_3 = -9999 OR -- OUT_OF_RANGE
       dist_ext_upper_3 = -9997 OR -- INVALID_VALUE
       dist_ext_upper_3 = -8888 OR -- NULL_VALUE
       dist_ext_upper_3 = -8887);  -- NOT_APPLICABLE

-- Ensure DST table DIST_EXT_LOWER_1, DIST_EXT_LOWER_2 and DIST_EXT_LOWER_3 
-- are greater than 10 and below 100
-- Issue #338
ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_ext_lower_1_betweeen_10_and_100;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_ext_lower_1_betweeen_10_and_100
CHECK ((10 <= dist_ext_lower_1 AND dist_ext_lower_1 <= 100) OR 
       dist_ext_lower_1 = -9999 OR -- OUT_OF_RANGE
       dist_ext_lower_1 = -9997 OR -- INVALID_VALUE
       dist_ext_lower_1 = -8888 OR -- NULL_VALUE
       dist_ext_lower_1 = -8887);  -- NOT_APPLICABLE

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_ext_lower_2_betweeen_10_and_100;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_ext_lower_2_betweeen_10_and_100
CHECK ((10 <= dist_ext_lower_2 AND dist_ext_lower_2 <= 100) OR 
       dist_ext_lower_2 = -9999 OR -- OUT_OF_RANGE
       dist_ext_lower_2 = -9997 OR -- INVALID_VALUE
       dist_ext_lower_2 = -8888 OR -- NULL_VALUE
       dist_ext_lower_2 = -8887);  -- NOT_APPLICABLE

ALTER TABLE casfri50.dst_all DROP CONSTRAINT IF EXISTS dist_ext_lower_3_betweeen_10_and_100;
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT dist_ext_lower_3_betweeen_10_and_100
CHECK ((10 <= dist_ext_lower_3 AND dist_ext_lower_3 <= 100) OR 
       dist_ext_lower_3 = -9999 OR -- OUT_OF_RANGE
       dist_ext_lower_3 = -9997 OR -- INVALID_VALUE
       dist_ext_lower_3 = -8888 OR -- NULL_VALUE
       dist_ext_lower_3 = -8887);  -- NOT_APPLICABLE

-------------------------------------------------------
-- Add different constraints to the ECO_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
ALTER TABLE casfri50.eco_all
ADD FOREIGN KEY (cas_id) 
REFERENCES casfri50.cas_all (cas_id) MATCH FULL;

-- Ensure attributes are NOT NULL
ALTER TABLE casfri50.eco_all 
ALTER COLUMN cas_id SET NOT NULL;

ALTER TABLE casfri50.eco_all 
ALTER COLUMN wetland_type SET NOT NULL;

ALTER TABLE casfri50.eco_all 
ALTER COLUMN wet_veg_cover SET NOT NULL;

ALTER TABLE casfri50.eco_all 
ALTER COLUMN wet_landform_mod SET NOT NULL;

ALTER TABLE casfri50.eco_all 
ALTER COLUMN wet_local_mod SET NOT NULL;

ALTER TABLE casfri50.eco_all 
ALTER COLUMN eco_site SET NOT NULL;

-- Ensure ECO table CAS_ID is 50 characters long
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure ECO table WETLAND_TYPE values match the corresponding lookup table
-- Issue 'S' is in the database and not in the specs
-- 'NA', 'E' and 'Z' are in the specs but not in the database.
DROP TABLE IF EXISTS casfri50_lookup.wetland_type_codes CASCADE;
CREATE TABLE casfri50_lookup.wetland_type_codes AS
SELECT * FROM (VALUES ('B'), ('F'), ('M'), ('O'), ('T'), ('W'),
                      ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.wetland_type_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.eco_all DROP CONSTRAINT IF EXISTS eco_wetland_type_fk;
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT eco_wetland_type_fk FOREIGN KEY (wetland_type) 
REFERENCES casfri50_lookup.wetland_type_codes (code);

-- Ensure ECO table WET_VEG_COVER values match the corresponding lookup table
-- Issue 'P' is in the database and not in the specs
DROP TABLE IF EXISTS casfri50_lookup.wet_veg_cover_codes CASCADE;
CREATE TABLE casfri50_lookup.wet_veg_cover_codes AS
SELECT * FROM (VALUES ('F'), ('T'), ('O'), ('C'), ('M'),
                      ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.wet_veg_cover_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.eco_all DROP CONSTRAINT IF EXISTS eco_wet_veg_cover_fk;
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT eco_wet_veg_cover_fk FOREIGN KEY (wet_veg_cover) 
REFERENCES casfri50_lookup.wet_veg_cover_codes (code);

-- Ensure ECO table WET_LANDFORM_MOD values match the corresponding lookup table
-- Issue 'P' is in the database and not in the specs
DROP TABLE IF EXISTS casfri50_lookup.wet_landform_mod_codes CASCADE;
CREATE TABLE casfri50_lookup.wet_landform_mod_codes AS
SELECT * FROM (VALUES ('X'), ('P'), ('N'), ('A'),
                      ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.wet_landform_mod_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.eco_all DROP CONSTRAINT IF EXISTS eco_wet_landform_mod_fk;
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT eco_wet_landform_mod_fk FOREIGN KEY (wet_landform_mod) 
REFERENCES casfri50_lookup.wet_landform_mod_codes (code);

-- Ensure ECO table WET_LOCAL_MOD values match the corresponding lookup table
-- Issue 'B' is found in the database but in the specs.
DROP TABLE IF EXISTS casfri50_lookup.wet_local_mod_codes CASCADE;
CREATE TABLE casfri50_lookup.wet_local_mod_codes AS
SELECT * FROM (VALUES ('C'), ('R'), ('I'), ('N'), ('S'), ('G'),
                      ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.wet_local_mod_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.eco_all DROP CONSTRAINT IF EXISTS eco_wet_local_mod_fk;
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT eco_wet_local_mod_fk FOREIGN KEY (wet_local_mod) 
REFERENCES casfri50_lookup.wet_local_mod_codes (code);

-- Ensure ECO table ECO_SITE values match the corresponding lookup table
DROP TABLE IF EXISTS casfri50_lookup.eco_site_codes CASCADE;
CREATE TABLE casfri50_lookup.eco_site_codes AS
SELECT * FROM (VALUES ('C'), ('R'), ('I'), ('N'), ('S'), ('G'),
                      ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.eco_site_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.eco_all DROP CONSTRAINT IF EXISTS eco_wet_local_mod_fk;
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT eco_wet_local_mod_fk FOREIGN KEY (wet_local_mod) 
REFERENCES casfri50_lookup.eco_site_codes (code);

-- Ensure ECO table ECO_SITE values match the corresponding lookup table
-- Issue eco_site does not seems to be translated
ALTER TABLE casfri50.eco_all DROP CONSTRAINT IF EXISTS eco_site_not_applicable;
ALTER TABLE casfri50.eco_all
ADD CONSTRAINT eco_site_not_applicable
CHECK (eco_site = 'NOT_APPLICABLE');

-------------------------------------------------------
-- Add different constraints to the LYR_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
ALTER TABLE casfri50.lyr_all
ADD FOREIGN KEY (cas_id) 
REFERENCES casfri50.cas_all (cas_id) MATCH FULL;

-- Ensure all attributes are NOT NULL
ALTER TABLE casfri50.lyr_all 
ALTER COLUMN cas_id SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN soil_moist_reg SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN layer SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN layer_rank SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN crown_closure_upper SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN crown_closure_lower SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN height_upper SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN height_lower SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN productive_for SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_1 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_1 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_2 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_2 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_3 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_3 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_4 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_4 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_5 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_5 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_6 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_6 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_7 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_7 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_8 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_8 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_9 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_9 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_10 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN species_per_10 SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN origin_upper SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN origin_lower SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN site_class SET NOT NULL;

ALTER TABLE casfri50.lyr_all 
ALTER COLUMN site_index SET NOT NULL;

-- Ensure LYR table CAS_ID is 50 characters long
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure LYR table STRUCTURE_PER is greater than 0 and smaller or equal to 100
-- Issue 338
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT structure_per_between_0_and_100 -- or NULL_VALUE (-8888) or INVALID_VALUE(-9997) or OUT_OF_RANGE(-9999) 
CHECK ((structure_per > 0 AND structure_per <= 100) OR 
       structure_per = -9999 OR -- OUT_OF_RANGE
       structure_per = -9997 OR -- INVALID_VALUE
       structure_per = -8888 OR -- NULL_VALUE
       structure_per = -8887);  -- NOT_APPLICABLE

-- Ensure LYR table SOIL_MOIST_REG values match the corresponding lookup table
DROP TABLE IF EXISTS casfri50_lookup.soil_moist_reg_codes CASCADE;
CREATE TABLE casfri50_lookup.soil_moist_reg_codes AS
SELECT * FROM (VALUES ('D'), ('F'), ('M'), ('W'), ('A'),
                      ('NULL_VALUE'), ('NOT_IN_SET'), ('NOT_APPLICABLE')) AS t(code);

ALTER TABLE casfri50_lookup.soil_moist_reg_codes
ADD PRIMARY KEY (code);

ALTER TABLE casfri50.lyr_all DROP CONSTRAINT IF EXISTS lyr_soil_moist_reg_fk;
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT lyr_soil_moist_reg_fk FOREIGN KEY (soil_moist_reg) 
REFERENCES casfri50_lookup.soil_moist_reg_codes (code);

-- Ensure LYR table LAYER is greater than 0
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT layer_greater_than_zero
CHECK (layer > 0);

-- Ensure LYR table LAYER_RANK is greater than 0 and smaller than 10
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT layer_rank_greater_than_zero
CHECK ((layer_rank > 0 AND layer_rank < 10) OR 
       layer_rank = -8888 OR -- NULL_VALUE
       layer_rank = -8887);  -- NOT_APPLICABLE

-- Ensure LYR table CROWN_CLOSURE_UPPER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT crown_closure_upper_between_0_and_100 
CHECK ((crown_closure_upper >= 0 AND crown_closure_upper <= 100) OR 
       crown_closure_upper = -9999 OR -- OUT_OF_RANGE
       crown_closure_upper = -9997 OR -- INVALID_VALUE
       crown_closure_upper = -8888 OR -- NULL_VALUE
       crown_closure_upper = -8887);  -- NOT_APPLICABLE

-- Ensure LYR table CROWN_CLOSURE_LOWER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT crown_closure_lower_between_0_and_100 
CHECK ((crown_closure_lower >= 0 AND crown_closure_lower <= 100) OR 
       crown_closure_lower = -9999 OR -- OUT_OF_RANGE
       crown_closure_lower = -9997 OR -- INVALID_VALUE
       crown_closure_lower = -8888 OR -- NULL_VALUE
       crown_closure_lower = -8887);  -- NOT_APPLICABLE

-- Ensure LYR table HEIGHT_UPPER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT height_upper_between_0_and_100 
CHECK ((height_upper >= 0 AND height_upper <= 100) OR 
       height_upper = -9999 OR -- OUT_OF_RANGE
       height_upper = -9997 OR -- INVALID_VALUE
       height_upper = -8888 OR -- NULL_VALUE
       height_upper = -8887);  -- NOT_APPLICABLE

-- Ensure LYR table HEIGHT_LOWER is greater than 0 and smaller or equal to 100
-- Issue 338 -9998 (NOT_IN_SET) should not be accepted for an integer
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT height_lower_between_0_and_100 
CHECK ((height_lower >= 0 AND height_lower <= 100) OR 
       height_lower = -9999 OR -- OUT_OF_RANGE
       height_lower = -9997 OR -- INVALID_VALUE
       height_lower = -8888 OR -- NULL_VALUE
       height_lower = -8887);  -- NOT_APPLICABLE

SELECT DISTINCT height_lower
FROM casfri50.lyr_all
ORDER BY height_lower;

-------------------------------------------------------
-- Add different constraints to the NFL_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
ALTER TABLE casfri50.nfl_all
ADD FOREIGN KEY (cas_id) 
REFERENCES casfri50.cas_all (cas_id) MATCH FULL;

-- Ensure all attributes are NOT NULL
ALTER TABLE casfri50.nfl_all 
ALTER COLUMN cas_id SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN soil_moist_reg SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN layer SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN layer_rank SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN crown_closure_upper SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN crown_closure_lower SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN height_upper SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN height_lower SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN nat_non_veg SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN non_for_anth SET NOT NULL;

ALTER TABLE casfri50.nfl_all 
ALTER COLUMN non_for_veg SET NOT NULL;

-- Ensure NFL table CAS_ID is 50 characters long
ALTER TABLE casfri50.nfl_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure NFL table LAYER is greater than 0
ALTER TABLE casfri50.nfl_all
ADD CONSTRAINT layer_greater_than_zero
CHECK (layer > 0);

-------------------------------------------------------
-- Add different constraints to the GEO_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
ALTER TABLE casfri50.geo_all
ADD FOREIGN KEY (cas_id) 
REFERENCES casfri50.cas_all (cas_id) MATCH FULL;

-- Ensure all attributes are NOT NULL
ALTER TABLE casfri50.geo_all 
ALTER COLUMN cas_id SET NOT NULL;

ALTER TABLE casfri50.geo_all 
ALTER COLUMN geometry SET NOT NULL;

-- Ensure NFL table CAS_ID is 50 characters long
ALTER TABLE casfri50.geo_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);
-------------------------------------------------------

