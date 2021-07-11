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
-- Make sure cas_flat_one_layer_per_row has the right count (76534476) 
SELECT count(*) 
FROM casfri50_flat.cas_flat_one_layer_per_row;

-- Make sure no two row per cas_id have the same layer number
SELECT DISTINCT string_agg(layer::text, '_' ORDER BY layer) layers
FROM casfri50_flat.cas_flat_one_layer_per_row
GROUP BY cas_id;

SELECT *, max(layer) OVER (PARTITION BY cas_id) max_lyr
FROM casfri50_flat.cas_flat_one_layer_per_row;
--------------------------------------------------------------------------
-- Make sure the number of layer matches cas.num_of_layers
SELECT DISTINCT max(layer) layer, max(num_of_layers) num_of_layers
FROM casfri50_flat.cas_flat_one_layer_per_row
GROUP BY cas_id;

SELECT cas_id, max(layer) layer, max(num_of_layers) num_of_layers
FROM casfri50_flat.cas_flat_one_layer_per_row
GROUP BY cas_id
HAVING max(layer) != max(num_of_layers);
