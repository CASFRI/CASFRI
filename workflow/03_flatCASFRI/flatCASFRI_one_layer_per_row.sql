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
--DROP MATERIALIZED VIEW IF EXISTS casfri50_flat.cas_sample CASCADE;
--CREATE MATERIALIZED VIEW casfri50_flat.cas_sample AS
--SELECT * 
--FROM casfri50.cas_all cas
--TABLESAMPLE SYSTEM ((4000 * 100) / (SELECT count(*) FROM casfri50.cas_all)::double precision) REPEATABLE (1.2);

--DROP VIEW IF EXISTS casfri50_flat.dst_sample;
--CREATE VIEW casfri50_flat.dst_sample AS
--SELECT dst.* 
--FROM casfri50.dst_all dst, casfri50_flat.cas_sample cas
--WHERE dst.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.eco_sample;
--CREATE VIEW casfri50_flat.eco_sample AS
--SELECT eco.* 
--FROM casfri50.eco_all eco, casfri50_flat.cas_sample cas
--WHERE eco.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.lyr_sample;
--CREATE VIEW casfri50_flat.lyr_sample AS
--SELECT lyr.* 
--FROM casfri50.lyr_all lyr, casfri50_flat.cas_sample cas
--WHERE lyr.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.nfl_sample;
--CREATE VIEW casfri50_flat.nfl_sample AS
--SELECT nfl.* 
--FROM casfri50.nfl_all nfl, casfri50_flat.cas_sample cas
--WHERE nfl.cas_id = cas.cas_id;

--DROP VIEW IF EXISTS casfri50_flat.geo_sample;
--CREATE VIEW casfri50_flat.geo_sample AS
--SELECT geo.* 
--FROM casfri50.geo_all geo, casfri50_flat.cas_sample cas
--WHERE geo.cas_id = cas.cas_id;
-------------------------------------------------------
-- Create a flat table
--
-- This version has one row per LYR and NFL layers, 
-- so many rows per CAS_ID.
-- DST info is always joined to row with layer = 1.
-- NB01 dst on layer 2 are left out.
-------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS casfri50_flat.cas_flat_one_layer_per_row;
CREATE MATERIALIZED VIEW casfri50_flat.cas_flat_one_layer_per_row AS
WITH lyr_nfl AS (
  -- Create a LYR_NFL table containing only LYR (707) and NFL (846) rows
  -- SELECT count(*) FROM casfri50_flat.lyr_sample;
  SELECT cas_id,
         soil_moist_reg, structure_per, layer, layer_rank,
         crown_closure_upper, crown_closure_lower, height_upper, height_lower, productive_for,
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, 
         species_4, species_per_4, species_5, species_per_5, species_6, species_per_6,
         origin_upper, origin_lower, site_class, site_index,
         'NOT_APPLICABLE' nat_non_veg,
         'NOT_APPLICABLE' non_for_anth,
         'NOT_APPLICABLE' non_for_veg
  --FROM casfri50_flat.lyr_sample
  FROM casfri50.lyr_all
  UNION ALL
  -- SELECT count(*) FROM casfri50_flat.nfl_sample;
  SELECT cas_id, 
         soil_moist_reg, structure_per, layer, layer_rank,
         crown_closure_upper, crown_closure_lower, height_upper, height_lower,
         'NOT_APPLICABLE' productive_for,
         'NOT_APPLICABLE' species_1,
         -8887 species_per_1,
         'NOT_APPLICABLE' species_2,
          -8887 species_per_2,
         'NOT_APPLICABLE' species_3,
         -8887 species_per_3,
         'NOT_APPLICABLE' species_4,
         -8887 species_per_4,
         'NOT_APPLICABLE' species_5,
         -8887 species_per_5,
         'NOT_APPLICABLE' species_6,
         -8887 species_per_6,
         -8887 origin_upper,
         -8887 origin_lower,
         'NOT_APPLICABLE' site_class,
         -8887 site_index,
         nat_non_veg,
         non_for_anth,
         non_for_veg
  --FROM casfri50_flat.nfl_sample
  FROM casfri50.nfl_all
), cas_lyr_nfl AS (
  -- LEFT JOIN the cas table (1010 rows) with the lyr_nfl 
  -- table in order to get all cas rows.
  -- Defaulting non-joining rows to NOT_APPLICABLE (-8887).
  SELECT cas.*,
         coalesce(soil_moist_reg, 'NOT_APPLICABLE') soil_moist_reg,
         coalesce(structure_per, -8887) structure_per,
         coalesce(layer, 1) layer,
         coalesce(layer_rank, -8887) layer_rank,
         coalesce(crown_closure_upper, -8887) crown_closure_upper,
         coalesce(crown_closure_lower, -8887) crown_closure_lower,
         coalesce(height_upper, -8887) height_upper,
         coalesce(height_lower, -8887) height_lower,
         coalesce(productive_for, 'NOT_APPLICABLE') productive_for,
         coalesce(species_1, 'NOT_APPLICABLE') species_1,
         coalesce(species_per_1, -8887) species_per_1,
         coalesce(species_2, 'NOT_APPLICABLE') species_2,
         coalesce(species_per_2, -8887) species_per_2,
         coalesce(species_3, 'NOT_APPLICABLE') species_3,
         coalesce(species_per_3, -8887) species_per_3,
         coalesce(species_4, 'NOT_APPLICABLE') species_4,
         coalesce(species_per_4, -8887) species_per_4,
         coalesce(species_5, 'NOT_APPLICABLE') species_5,
         coalesce(species_per_5, -8887) species_per_5,
         coalesce(species_6, 'NOT_APPLICABLE') species_6,
         coalesce(species_per_6, -8887) species_per_6,
         coalesce(origin_upper, -8887) origin_upper,
         coalesce(origin_lower, -8887) origin_lower,
         coalesce(site_class, 'NOT_APPLICABLE') site_class,
         coalesce(site_index, -8887) site_index,
         coalesce(nat_non_veg, 'NOT_APPLICABLE') nat_non_veg,
         coalesce(non_for_anth, 'NOT_APPLICABLE') non_for_anth,
         coalesce(non_for_veg, 'NOT_APPLICABLE') non_for_veg
  --FROM casfri50_flat.cas_sample cas 
  FROM casfri50.cas_all cas 
  LEFT OUTER JOIN lyr_nfl
  USING (cas_id)
  --ORDER BY cas.cas_id, layer
), cas_lyr_nfl_dst AS (
  -- Add dst rows defaulting non-joining rows to NOT_APPLICABLE (-8887)
  SELECT cas_lyr_nfl.*, 
         coalesce(dist_type_1, 'NOT_APPLICABLE') dist_type_1,
         coalesce(dist_year_1, -8887) dist_year_1,
         coalesce(dist_ext_upper_1, -8887) dist_ext_upper_1,
         coalesce(dist_ext_lower_1, -8887) dist_ext_lower_1, 
         coalesce(dist_type_2, 'NOT_APPLICABLE') dist_type_2,
         coalesce(dist_year_2, -8887) dist_year_2,
         coalesce(dist_ext_upper_2, -8887) dist_ext_upper_2,
         coalesce(dist_ext_lower_2, -8887) dist_ext_lower_2
  FROM cas_lyr_nfl
  --LEFT JOIN casfri50_flat.dst_sample dst 
  LEFT JOIN casfri50.dst_all dst 
  ON (cas_lyr_nfl.cas_id = dst.cas_id AND dst.layer = 1)
), cas_lyr_nfl_dst_eco AS (
  -- Add eco rows defaulting non-joining rows to NOT_APPLICABLE (-8887)
  SELECT cas_lyr_nfl_dst.*,
         coalesce(wetland_type, 'NOT_APPLICABLE') wetland_type,
         coalesce(wet_veg_cover, 'NOT_APPLICABLE') wet_veg_cover,
         coalesce(wet_landform_mod, 'NOT_APPLICABLE') wet_landform_mod,
         coalesce(wet_local_mod, 'NOT_APPLICABLE') wet_local_mod,
         coalesce(eco_site, 'NOT_APPLICABLE') eco_site
  FROM cas_lyr_nfl_dst
  --LEFT JOIN casfri50_flat.eco_sample eco 
  LEFT JOIN casfri50.eco_all eco 
  USING (cas_id)
)
-- Add geo rows
SELECT cas_lyr_nfl_dst_eco.*,
       geometry
FROM cas_lyr_nfl_dst_eco
--LEFT JOIN casfri50_flat.geo_sample geo 
LEFT JOIN casfri50.geo_all geo 
USING (cas_id);

-- Make sure cas_flat_one_layer_per_row has the right count (5806, 30199600) 
SELECT count(*) 
FROM casfri50_flat.cas_flat_one_layer_per_row;

--------------------------------------------------------------------------
-- Add some indexes
CREATE INDEX cas_flat_one_layer_per_row_casid_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING btree(cas_id);

-- Add a unique index 
CREATE UNIQUE INDEX ON casfri50_flat.cas_flat_one_layer_per_row (cas_id, layer);

-- bug
--SELECT * FROM casfri50_flat.cas_flat_one_layer_per_row
--WHERE cas_id = 'YT02-xYTVEGINVENTORY-xxxxxxxxxx-0000014069-0014069'

CREATE INDEX cas_flat_one_layer_per_row_inventory_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING btree(left(cas_id, 4));
    
CREATE INDEX cas_flat_one_layer_per_row_province_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING btree(left(cas_id, 2));

CREATE INDEX cas_flat_one_layer_per_row_geom_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING gist(geometry);
--------------------------------------------------------------------------
-- Make sure no two row per cas_id have the same layer number
SELECT DISTINCT string_agg(layer::text, '_' ORDER BY layer) layers
FROM casfri50_flat.cas_flat_one_layer_per_row
GROUP BY cas_id;

SELECT *, max(layer) OVER (PARTITION BY cas_id) max_lyr
FROM casfri50_flat.cas_flat_one_layer_per_row;
-------------------------------------------------------
