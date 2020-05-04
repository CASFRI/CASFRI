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
-- Build a Flat (denormalized) version of CASFRI50
-------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_flat;
-------------------------------------------------------
-- Create samples of CASFRI50 for development purpose only
--DROP MATERIALIZED VIEW IF EXISTS casfri50_flat.cas_sample2 CASCADE;
--CREATE MATERIALIZED VIEW casfri50_flat.cas_sample2 AS
--SELECT * 
--FROM casfri50.cas_all cas
--TABLESAMPLE SYSTEM ((10000 * 100) / (SELECT count(*) FROM casfri50.cas_all)::double precision) REPEATABLE (1.2);

--DROP VIEW IF EXISTS casfri50_flat.dst_sample2;
--CREATE VIEW casfri50_flat.dst_sample2 AS
--SELECT dst.* 
--FROM casfri50.dst_all dst, casfri50_flat.cas_sample2 cas
--WHERE dst.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.eco_sample2;
--CREATE VIEW casfri50_flat.eco_sample2 AS
--SELECT eco.* 
--FROM casfri50.eco_all eco, casfri50_flat.cas_sample2 cas
WHERE eco.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.lyr_sample2;
--CREATE VIEW casfri50_flat.lyr_sample2 AS
--SELECT lyr.* 
--FROM casfri50.lyr_all lyr, casfri50_flat.cas_sample2 cas
--WHERE lyr.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.nfl_sample2;
--CREATE VIEW casfri50_flat.nfl_sample2 AS
--SELECT nfl.* 
--FROM casfri50.nfl_all nfl, casfri50_flat.cas_sample2 cas
--WHERE nfl.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.geo_sample2;
--CREATE VIEW casfri50_flat.geo_sample2 AS
--SELECT geo.* 
--FROM casfri50.geo_all geo, casfri50_flat.cas_sample2 cas
--WHERE geo.cas_id = cas.cas_id;
-------------------------------------------------------
-- Create a flat table
--
-- This version has only one row per CAS_ID. LYR layer 1, 
-- LYR layer 2, NFL layer 1 and NFL layer 2, DST and ECO 
-- data are all stored in the same row, in separate columns.
-- Third (and higher) NFL layers and layer 2 NB01 DST are 
-- left out.
--
-- The query is basically a big LEFT JOIN from the cas_all 
-- table to each of those layers.
-------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS casfri50_flat.cas_flat_all_layers_same_row;
CREATE MATERIALIZED VIEW casfri50_flat.cas_flat_all_layers_same_row AS
WITH cas_lyr1 AS (
  -- First LYR layer
  SELECT cas.*,
         coalesce(soil_moist_reg, 'NOT_APPLICABLE') lyr1_soil_moist_reg,
         coalesce(structure_per, -8887) lyr1_structure_per,
         --coalesce(layer, -8887) layer,
         --coalesce(layer_rank, -8887) layer_rank,
         coalesce(crown_closure_upper, -8887) lyr1_crown_closure_upper,
         coalesce(crown_closure_lower, -8887) lyr1_crown_closure_lower,
         coalesce(height_upper, -8887) lyr1_height_upper,
         coalesce(height_lower, -8887) lyr1_height_lower,
         coalesce(productive_for, 'NOT_APPLICABLE') lyr1_productive_for,
         coalesce(species_1, 'NOT_APPLICABLE') lyr1_species_1,
         coalesce(species_per_1, -8887) lyr1_species_per_1,
         coalesce(species_2, 'NOT_APPLICABLE') lyr1_species_2,
         coalesce(species_per_2, -8887) lyr1_species_per_2,
         coalesce(species_3, 'NOT_APPLICABLE') lyr1_species_3,
         coalesce(species_per_3, -8887) lyr1_species_per_3,
         coalesce(species_4, 'NOT_APPLICABLE') lyr1_species_4,
         coalesce(species_per_4, -8887) lyr1_species_per_4,
         coalesce(species_5, 'NOT_APPLICABLE') lyr1_species_5,
         coalesce(species_per_5, -8887) lyr1_species_per_5,
         coalesce(species_6, 'NOT_APPLICABLE') lyr1_species_6,
         coalesce(species_per_6, -8887) lyr1_species_per_6,
         coalesce(origin_upper, -8887) lyr1_origin_upper,
         coalesce(origin_lower, -8887) lyr1_origin_lower,
         coalesce(site_class, 'NOT_APPLICABLE') lyr1_site_class,
         coalesce(site_index, -8887) lyr1_site_index
  --FROM casfri50_flat.cas_sample2 cas
  FROM casfri50.cas_all cas
  --LEFT OUTER JOIN casfri50_flat.lyr_sample2 lyr 
  LEFT OUTER JOIN casfri50.lyr_all lyr 
  ON (cas.cas_id = lyr.cas_id AND lyr.layer = 1)
), cas_lyr1_lyr2 AS (
  -- Second LYR layer
  SELECT cas_lyr1.*,
         coalesce(soil_moist_reg, 'NOT_APPLICABLE') lyr2_soil_moist_reg,
         coalesce(structure_per, -8887) lyr2_structure_per,
         --coalesce(layer, -8887) layer,
         --coalesce(layer_rank, -8887) layer_rank,
         coalesce(crown_closure_upper, -8887) lyr2_crown_closure_upper,
         coalesce(crown_closure_lower, -8887) lyr2_crown_closure_lower,
         coalesce(height_upper, -8887) lyr2_height_upper,
         coalesce(height_lower, -8887) lyr2_height_lower,
         coalesce(productive_for, 'NOT_APPLICABLE') lyr2_productive_for,
         coalesce(species_1, 'NOT_APPLICABLE') lyr2_species_1,
         coalesce(species_per_1, -8887) lyr2_species_per_1,
         coalesce(species_2, 'NOT_APPLICABLE') lyr2_species_2,
         coalesce(species_per_2, -8887) lyr2_species_per_2,
         coalesce(species_3, 'NOT_APPLICABLE') lyr2_species_3,
         coalesce(species_per_3, -8887) lyr2_species_per_3,
         coalesce(species_4, 'NOT_APPLICABLE') lyr2_species_4,
         coalesce(species_per_4, -8887) lyr2_species_per_4,
         coalesce(species_5, 'NOT_APPLICABLE') lyr2_species_5,
         coalesce(species_per_5, -8887) lyr2_species_per_5,
         coalesce(species_6, 'NOT_APPLICABLE') lyr2_species_6,
         coalesce(species_per_6, -8887) lyr2_species_per_6,
         coalesce(origin_upper, -8887) lyr2_origin_upper,
         coalesce(origin_lower, -8887) lyr2_origin_lower,
         coalesce(site_class, 'NOT_APPLICABLE') lyr2_site_class,
         coalesce(site_index, -8887) lyr2_site_index
  FROM cas_lyr1
  --LEFT OUTER JOIN casfri50_flat.lyr_sample2 lyr 
  LEFT OUTER JOIN casfri50.lyr_all lyr 
  ON (cas_lyr1.cas_id = lyr.cas_id AND lyr.layer = 2)
), nfl1_nfl2 AS (
  -- Aggregate NFL components
--WITH nfl1_nfl2 AS (
  SELECT min(cas_id) cas_id,
         --array_agg(layer ORDER BY layer) layer,
         array_agg(soil_moist_reg ORDER BY layer) soil_moist_reg,
         array_agg(structure_per ORDER BY layer) structure_per,
         array_agg(crown_closure_upper ORDER BY layer) crown_closure_upper,
         array_agg(crown_closure_lower ORDER BY layer) crown_closure_lower,
         array_agg(height_upper ORDER BY layer) height_upper,
         array_agg(height_lower ORDER BY layer) height_lower,
         array_agg(nat_non_veg ORDER BY layer) nat_non_veg,
         array_agg(non_for_anth ORDER BY layer) non_for_anth,
         array_agg(non_for_veg ORDER BY layer) non_for_veg
  --FROM casfri50_flat.nfl_sample2
  FROM casfri50.nfl_all
  GROUP BY left(cas_id, 4), right(cas_id, 7) 
), cas_lyr1_lyr2_nfl1_nfl2 AS (
  -- Add first and second NFL components defaulting non-joining rows to NOT_APPLICABLE (-8887)
  SELECT cas_lyr1_lyr2.*,
         coalesce(nfl1_nfl2.soil_moist_reg[1], 'NOT_APPLICABLE') nfl1_soil_moist_reg,
         coalesce(nfl1_nfl2.structure_per[1], -8887) nfl1_structure_per,
         coalesce(nfl1_nfl2.crown_closure_upper[1], -8887) nfl1_crown_closure_upper,
         coalesce(nfl1_nfl2.crown_closure_lower[1], -8887) nfl1_crown_closure_lower,
         coalesce(nfl1_nfl2.height_upper[1], -8887) nfl1_height_upper,
         coalesce(nfl1_nfl2.height_lower[1], -8887) nfl1_height_lower,
         coalesce(nfl1_nfl2.nat_non_veg[1], 'NOT_APPLICABLE') nfl1_nat_non_veg,
         coalesce(nfl1_nfl2.non_for_anth[1], 'NOT_APPLICABLE') nfl1_non_for_anth,
         coalesce(nfl1_nfl2.non_for_veg[1], 'NOT_APPLICABLE') nfl1_non_for_veg,
         coalesce(nfl1_nfl2.soil_moist_reg[2], 'NOT_APPLICABLE') nfl2_soil_moist_reg,
         coalesce(nfl1_nfl2.structure_per[2], -8887) nfl2_structure_per,
         coalesce(nfl1_nfl2.crown_closure_upper[2], -8887) nfl2_crown_closure_upper,
         coalesce(nfl1_nfl2.crown_closure_lower[2], -8887) nfl2_crown_closure_lower,
         coalesce(nfl1_nfl2.height_upper[2], -8887) nfl2_height_upper,
         coalesce(nfl1_nfl2.height_lower[2], -8887) nfl2_height_lower,
         coalesce(nfl1_nfl2.nat_non_veg[2], 'NOT_APPLICABLE') nfl2_nat_non_veg,
         coalesce(nfl1_nfl2.non_for_anth[2], 'NOT_APPLICABLE') nfl2_non_for_anth,
         coalesce(nfl1_nfl2.non_for_veg[2], 'NOT_APPLICABLE') nfl2_non_for_veg
  FROM cas_lyr1_lyr2 
  LEFT OUTER JOIN nfl1_nfl2 
  USING (cas_id)
), cas_lyr1_lyr2_nfl1_nfl2_dst AS (
  -- Add dst rows defaulting non-joining rows to NOT_APPLICABLE (-8887)
  SELECT cas.*, 
         coalesce(dist_type_1, 'NOT_APPLICABLE') dist_type_1,
         coalesce(dist_year_1, -8887) dist_year_1,
         coalesce(dist_ext_upper_1, -8887) dist_ext_upper_1,
         coalesce(dist_ext_lower_1, -8887) dist_ext_lower_1, 
         coalesce(dist_type_2, 'NOT_APPLICABLE') dist_type_2,
         coalesce(dist_year_2, -8887) dist_year_2,
         coalesce(dist_ext_upper_2, -8887) dist_ext_upper_2,
         coalesce(dist_ext_lower_2, -8887) dist_ext_lower_2
  FROM cas_lyr1_lyr2_nfl1_nfl2 cas
  --LEFT JOIN casfri50_flat.dst_sample dst 
  LEFT JOIN casfri50.dst_all dst 
  ON (cas.cas_id = dst.cas_id AND dst.layer = 1)
), cas_lyr1_lyr2_nfl1_nfl2_dst_eco AS (
  -- Add eco rows defaulting non-joining rows to NOT_APPLICABLE (-8887)
  SELECT cas.*,
         coalesce(wetland_type, 'NOT_APPLICABLE') wetland_type,
         coalesce(wet_veg_cover, 'NOT_APPLICABLE') wet_veg_cover,
         coalesce(wet_landform_mod, 'NOT_APPLICABLE') wet_landform_mod,
         coalesce(wet_local_mod, 'NOT_APPLICABLE') wet_local_mod,
         coalesce(eco_site, 'NOT_APPLICABLE') eco_site
  FROM cas_lyr1_lyr2_nfl1_nfl2_dst cas
  --LEFT JOIN casfri50_flat.eco_sample eco 
  LEFT JOIN casfri50.eco_all eco 
  USING (cas_id)
)
-- Add geo rows
SELECT cas.*,
       geometry
FROM cas_lyr1_lyr2_nfl1_nfl2_dst_eco cas
--LEFT JOIN casfri50_flat.geo_sample geo 
LEFT JOIN casfri50.geo_all geo 
USING (cas_id);

-- Have a look at a sample
SELECT * 
FROM casfri50_flat.cas_flat_all_layers_same_row
TABLESAMPLE SYSTEM ((100 * 100) / (SELECT count(*) FROM casfri50_flat.cas_flat_all_layers_same_row)::double precision) 
REPEATABLE (1.2)
ORDER BY cas_id;

-- Make sure cas_flat_one_layer_per_row has the right count (XXXX, 17976421)
SELECT count(*) 
FROM casfri50.cas_all;

SELECT count(*) 
FROM casfri50_flat.cas_flat_all_layers_same_row;

--------------------------------------------------------------------------
-- Add some indexes
CREATE INDEX cas_flat_all_layers_same_row_casid_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING btree(cas_id);

CREATE INDEX cas_flat_all_layers_same_row_inventory_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING btree(left(cas_id, 4));
    
CREATE INDEX cas_flat_all_layers_same_row_province_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING btree(left(cas_id, 2));

CREATE INDEX cas_flat_all_layers_same_row_geom_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING gist(geometry);
--------------------------------------------------------------------------
-- Check the completeness of STAND_PHOTO_YEAR
SELECT DISTINCT left(cas_id, 4) inv, stand_photo_year
FROM casfri50_flat.cas_flat_all_layers_same_row
ORDER BY inv, stand_photo_year;

-- All inventories except AB06 and BC08 have holes in STAND_PHOTO_YEAR assignation.
