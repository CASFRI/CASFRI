------------------------------------------------------------------------------
-- CASFRI - BC12 translation script for CASFRI v5
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
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--------------------------------------------------------------------------
-- Translate all bc12. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc12_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'bc12', 'bc');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'BC12';

-- Add translated ones
INSERT INTO casfri50.cas_all -- **h**m
SELECT * FROM TT_Translate_bc12_cas('rawfri', 'bc12_l1_to_bc_l1_map');

COMMIT;

------------------------
-- DST
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc12_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'BC12';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc12_dst('rawfri', 'bc12_l1_to_bc_l1_map');

COMMIT;

------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc12_eco', 'ab_avi01_eco'); -- used for both BC08 and bc12

SELECT TT_CreateMappingView('rawfri', 'bc12', 'bc');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'BC12';

-- Add translated ones
INSERT INTO casfri50.eco_all -- *h**m
SELECT * FROM TT_Translate_bc12_eco('rawfri', 'bc12_l1_to_bc_l1_map');

COMMIT;

------------------------
-- LYR
------------------------
-- Check the uniqueness of BC species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_bc12_species_codes_idx
ON translation.species_code_mapping (bc_species_codes)
WHERE TT_NotEmpty(bc_species_codes);

BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc12_lyr', 'ab_avi01_lyr'); -- used for both BC08 and bc12, layer 1 and 2

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'BC12';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'bc12', 1, 'bc', 1);

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc12_lyr('rawfri', 'bc12_l1_to_bc_l1_map');


-- Layer 2 reusing bc12 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'bc12', 2, 'bc', 1);

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc12_lyr('rawfri', 'bc12_l2_to_bc_l1_map');

COMMIT;

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc12_nfl', 'ab_avi01_nfl'); -- used for both BC08 and bc12

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'BC12';

-- layer 1
SELECT TT_CreateMappingView('rawfri', 'bc12', 3, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc12_nfl('rawfri', 'bc12_l3_to_bc_l1_map');


-- layer 2
SELECT TT_CreateMappingView('rawfri', 'bc12', 4, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc12_nfl('rawfri', 'bc12_l4_to_bc_l1_map');


-- layer 3
SELECT TT_CreateMappingView('rawfri', 'bc12', 5, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc12_nfl('rawfri', 'bc12_l5_to_bc_l1_map');

COMMIT;

------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_geo', '_bc12_geo', 'ab_avi01_geo'); -- used for both BC08 and bc12

SELECT TT_CreateMappingView('rawfri', 'bc12', 'bc');

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'BC12';

-- Add translated ones
INSERT INTO casfri50.geo_all --*h**m
SELECT * FROM TT_Translate_bc12_geo('rawfri', 'bc12_l1_to_bc_l1_map');

COMMIT;
--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'BC12'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'BC12'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'BC12'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'BC12'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'BC12'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC12';
*/
--------------------------------------------------------------------------