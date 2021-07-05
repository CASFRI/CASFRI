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
-- Add indexes to CAS_ALL
DROP INDEX IF EXISTS cas_all_casid_idx;
CREATE INDEX cas_all_casid_idx
ON casfri50.cas_all USING btree(cas_id);

DROP INDEX IF EXISTS cas_all_inventoryid_idx;
CREATE INDEX cas_all_inventoryid_idx
ON casfri50.cas_all USING btree(inventory_id);

DROP INDEX IF EXISTS cas_all_casidinv_idx;
CREATE INDEX cas_all_casidinv_idx
ON casfri50.cas_all USING btree(left(cas_id, 4));
    
DROP INDEX IF EXISTS cas_all_province_idx;
CREATE INDEX cas_all_province_idx
ON casfri50.cas_all USING btree(left(cas_id, 2));

--------------------------------------------------------------------------
-- Add indexes to DST_ALL
DROP INDEX IF EXISTS dst_all_casid_idx;
CREATE INDEX dst_all_casid_idx
ON casfri50.dst_all USING btree(cas_id);

DROP INDEX IF EXISTS dst_all_inventory_idx;
CREATE INDEX dst_all_inventory_idx
ON casfri50.dst_all USING btree(left(cas_id, 4));
    
DROP INDEX IF EXISTS dst_all_province_idx;
CREATE INDEX dst_all_province_idx
ON casfri50.dst_all USING btree(left(cas_id, 2));

--------------------------------------------------------------------------
-- Add indexes to ECO_ALL
DROP INDEX IF EXISTS eco_all_casid_idx;
CREATE INDEX eco_all_casid_idx
ON casfri50.eco_all USING btree(cas_id);

DROP INDEX IF EXISTS eco_all_inventory_idx;
CREATE INDEX eco_all_inventory_idx
ON casfri50.eco_all USING btree(left(cas_id, 4));
    
DROP INDEX IF EXISTS eco_all_province_idx;
CREATE INDEX eco_all_province_idx
ON casfri50.eco_all USING btree(left(cas_id, 2));

--------------------------------------------------------------------------
-- Add indexes to LYR_ALL
DROP INDEX IF EXISTS lyr_all_casid_idx;
CREATE INDEX lyr_all_casid_idx
ON casfri50.lyr_all USING btree(cas_id);

DROP INDEX IF EXISTS lyr_all_inventory_idx;
CREATE INDEX lyr_all_inventory_idx
ON casfri50.lyr_all USING btree(left(cas_id, 4));
    
DROP INDEX IF EXISTS lyr_all_province_idx;
CREATE INDEX lyr_all_province_idx
ON casfri50.lyr_all USING btree(left(cas_id, 2));

--------------------------------------------------------------------------
-- Add indexes to NFL_ALL
DROP INDEX IF EXISTS nfl_all_casid_idx;
CREATE INDEX nfl_all_casid_idx
ON casfri50.nfl_all USING btree(cas_id);

DROP INDEX IF EXISTS nfl_all_inventory_idx;
CREATE INDEX nfl_all_inventory_idx
ON casfri50.nfl_all USING btree(left(cas_id, 4));
    
DROP INDEX IF EXISTS nfl_all_province_idx;
CREATE INDEX nfl_all_province_idx
ON casfri50.nfl_all USING btree(left(cas_id, 2));

--------------------------------------------------------------------------
-- Add indexes to GEO_ALL
DROP INDEX IF EXISTS geo_all_casid_idx;
CREATE INDEX geo_all_casid_idx
ON casfri50.geo_all USING btree(cas_id);

DROP INDEX IF EXISTS geo_all_inventory_idx;
CREATE INDEX geo_all_inventory_idx
ON casfri50.geo_all USING btree(left(cas_id, 4));
    
DROP INDEX IF EXISTS geo_all_province_idx;
CREATE INDEX geo_all_province_idx
ON casfri50.geo_all USING btree(left(cas_id, 2));

DROP INDEX IF EXISTS geo_all_geom_idx;
CREATE INDEX geo_all_geom_idx
ON casfri50.geo_all USING gist(geometry);
--------------------------------------------------------------------------