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
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure CAS table INVENTORY_ID is 4 characters long
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT inventory_id_length
CHECK (length(inventory_id) = 4);

-- Ensure CAS table NUM_OF_LAYERS is greater than 0
-- BUG!
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT num_of_layers_greater_than_zero
CHECK (num_of_layers > 0);

-- Ensure CAS table STAND_STRUCTURE fits with NUM_OF_LAYERS
-- BUG!
ALTER TABLE casfri50.cas_all
ADD CONSTRAINT stand_structure_num_of_layers 
CHECK (stand_structure = 'M' AND num_of_layers > 1);

-- Ensure CAS table STAND_PHOTO_YEAR is greater than 0
-- BUG!
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
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT cas_id_length
CHECK (length(cas_id) = 50);

-- Ensure DST table LAYER is greater than 0
ALTER TABLE casfri50.dst_all
ADD CONSTRAINT layer_greater_than_zero
CHECK (layer > 0);

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

-- Ensure LYR table LAYER is greater than 0
ALTER TABLE casfri50.lyr_all
ADD CONSTRAINT layer_greater_than_zero
CHECK (layer > 0);

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

