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
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--------------------------------------------------------------------------
-- Translate all BC10. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc10_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'BC10';

-- Add translated ones
INSERT INTO casfri50.cas_all -- **h**m
SELECT * FROM TT_Translate_bc10_cas('rawfri', 'bc10_l1_to_bc_l1_map');

COMMIT;

------------------------
-- DST
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc10_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'BC10';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc10_dst('rawfri', 'bc10_l1_to_bc_l1_map');

COMMIT;

------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc10_eco', 'ab_avi01_eco'); -- used for both BC08 and BC10

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'BC10';

-- Add translated ones
INSERT INTO casfri50.eco_all -- *h**m
SELECT * FROM TT_Translate_bc10_eco('rawfri', 'bc10_l1_to_bc_l1_map');

COMMIT;

------------------------
-- LYR
------------------------
-- Check the uniqueness of BC species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_bc10_species_codes_idx
ON translation.species_code_mapping (bc_species_codes)
WHERE TT_NotEmpty(bc_species_codes);

BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc10_lyr', 'ab_avi01_lyr'); -- used for both BC08 and BC10, layer 1 and 2

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'BC10';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1);

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc10_lyr('rawfri', 'bc10_l1_to_bc_l1_map');


-- Layer 2 reusing BC10 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1);

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc10_lyr('rawfri', 'bc10_l2_to_bc_l1_map');

COMMIT;

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc10_nfl', 'ab_avi01_nfl'); -- used for both BC08 and BC10

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'BC10';

-- layer 1
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc10_nfl('rawfri', 'bc10_l3_to_bc_l1_map');


-- layer 2
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc10_nfl('rawfri', 'bc10_l4_to_bc_l1_map');


-- layer 3
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc10_nfl('rawfri', 'bc10_l5_to_bc_l1_map');

COMMIT;

------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_geo', '_bc10_geo', 'ab_avi01_geo'); -- used for both BC08 and BC10

SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc');

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'BC10';

-- Add translated ones
INSERT INTO casfri50.geo_all --*h**m
SELECT * FROM TT_Translate_bc10_geo('rawfri', 'bc10_l1_to_bc_l1_map');

COMMIT;
--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'BC10'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'BC10'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'BC10'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'BC10'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'BC10'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC10';
*/
--------------------------------------------------------------------------