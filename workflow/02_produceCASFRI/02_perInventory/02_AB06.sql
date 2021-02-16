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
-- Translate all AB06. 0h12m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab06_cas'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.cas_all  -- 3m40s
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06_l1_to_ab_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab06_dst'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 26s
SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06_l1_to_ab_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab06_eco'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 36s
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06_l1_to_ab_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab06_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab06_lyr'); -- used for both AB06 and AB16 layer 1 and 2

SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all -- 4m41s
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06_l1_to_ab_l1_map');


-- Layer 2 reusing AB06 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06_l2_to_ab_l1_map');


------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab06_nfl'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 3, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all -- 2m24s
SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06_l3_to_ab_l1_map');


-- Layer 2 reusing AB06 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab06', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all -- 2m1s
SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06_l4_to_ab_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab06_geo'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 54s
SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06_l1_to_ab_l1_map'); 

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB06';
*/
--------------------------------------------------------------------------
