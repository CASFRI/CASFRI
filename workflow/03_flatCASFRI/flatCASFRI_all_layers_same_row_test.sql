------------------------------------------------------------------------------
-- CASFRI - Flat table test script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
-------------------------------------------------------------------------------
-- Have a look at a sample
SELECT * 
FROM casfri50_flat.cas_flat_all_layers_same_row
TABLESAMPLE SYSTEM ((100 * 100) / (SELECT count(*) FROM casfri50_flat.cas_flat_all_layers_same_row)::double precision) 
REPEATABLE (1.2)
ORDER BY cas_id;

-- Make sure cas_flat_all_layers_same_row has the right count (66007533, 66008963)
SELECT count(*) 
FROM casfri50.cas_all;

SELECT count(*) 
FROM casfri50_flat.cas_flat_all_layers_same_row;


-- Check the completeness of STAND_PHOTO_YEAR
SELECT inventory_id, stand_photo_year, count(*) nb
FROM casfri50_flat.cas_flat_all_layers_same_row
GROUP BY inventory_id, stand_photo_year
ORDER BY inventory_id, stand_photo_year;

-- All inventories except AB06 and BC08 have holes in STAND_PHOTO_YEAR assignation.

