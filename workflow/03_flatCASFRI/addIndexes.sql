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
-- Add a unique index on cas_flat_all_layers_same_row
CREATE UNIQUE INDEX ON casfri50_flat.cas_flat_one_layer_per_row (cas_id, layer);

-- Add more indexes
CREATE INDEX cas_flat_all_layers_same_row_casid_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING btree(cas_id);

CREATE INDEX cas_flat_all_layers_same_row_inventory_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING btree(left(cas_id, 4));
    
CREATE INDEX cas_flat_all_layers_same_row_province_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING btree(left(cas_id, 2));

CREATE INDEX cas_flat_all_layers_same_row_geom_idx
ON casfri50_flat.cas_flat_all_layers_same_row USING gist(geometry);
--------------------------------------------------------------------------
-- Add a unique index on cas_flat_one_layer_per_row
CREATE UNIQUE INDEX ON casfri50_flat.cas_flat_one_layer_per_row (cas_id, layer);

-- bug
--SELECT * FROM casfri50_flat.cas_flat_one_layer_per_row
--WHERE cas_id = 'YT02-xYTVEGINVENTORY-xxxxxxxxxx-0000014069-0014069'

-- Add more indexes
CREATE INDEX cas_flat_one_layer_per_row_casid_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING btree(cas_id);

CREATE INDEX cas_flat_one_layer_per_row_inventory_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING btree(left(cas_id, 4));
    
CREATE INDEX cas_flat_one_layer_per_row_province_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING btree(left(cas_id, 2));

CREATE INDEX cas_flat_one_layer_per_row_geom_idx
ON casfri50_flat.cas_flat_one_layer_per_row USING gist(geometry);
