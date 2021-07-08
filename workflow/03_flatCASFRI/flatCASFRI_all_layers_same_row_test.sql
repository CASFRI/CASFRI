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
-- Have a look at a sample
SELECT * 
FROM casfri50_flat.cas_flat_all_layers_same_row
TABLESAMPLE SYSTEM ((100 * 100) / (SELECT count(*) FROM casfri50_flat.cas_flat_all_layers_same_row)::double precision) 
REPEATABLE (1.2)
ORDER BY cas_id;

-- Make sure cas_flat_all_layers_same_row has the right count (41091682, 41093124)
SELECT count(*) 
FROM casfri50.cas_all;

SELECT count(*) 
FROM casfri50_flat.cas_flat_all_layers_same_row;


-- Check the completeness of STAND_PHOTO_YEAR
SELECT left(cas_id, 4) inv, stand_photo_year, count(*) nb
FROM casfri50_flat.cas_flat_all_layers_same_row
GROUP BY inv, stand_photo_year
ORDER BY inv, stand_photo_year;

-- All inventories except AB06 and BC08 have holes in STAND_PHOTO_YEAR assignation.

