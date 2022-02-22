------------------------------------------------------------------------------
-- CASFRI - AB27 translation script for CASFRI v5
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
-- Translate all AB27. 0h12m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab27_cas'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab27', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB27';

-- Add translated ones
INSERT INTO casfri50.cas_all  -- 1h17m43s
SELECT * FROM TT_Translate_ab27_cas('rawfri', 'ab27_l1_to_ab_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab27_dst'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB27';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 4m43s 
SELECT * FROM TT_Translate_ab27_dst('rawfri', 'ab27_l1_to_ab_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab27_eco'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab27', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB27';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 33s
SELECT * FROM TT_Translate_ab27_eco('rawfri', 'ab27_l1_to_ab_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab27_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB27';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab27_lyr'); -- used for both AB06 and AB16 layer 1 and 2

SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all -- 20m13s 
SELECT * FROM TT_Translate_ab27_lyr('rawfri', 'ab27_l1_to_ab_l1_map');


-- Layer 2 reusing ab27 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab27', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all -- 4m3s 
SELECT * FROM TT_Translate_ab27_lyr('rawfri', 'ab27_l2_to_ab_l1_map');


------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab27_nfl'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab27', 3, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB27';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all -- 3m5s 
SELECT * FROM TT_Translate_ab27_nfl('rawfri', 'ab27_l3_to_ab_l1_map');


-- Layer 2 reusing ab27 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab27', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all -- 2m42s 
SELECT * FROM TT_Translate_ab27_nfl('rawfri', 'ab27_l4_to_ab_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab27_geo'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab27', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB27';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 10m42s 840448
SELECT * FROM TT_Translate_ab27_geo('rawfri', 'ab27_l1_to_ab_l1_map'); 

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB27'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB27'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB27'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB27'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB27'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB27';
*/
--------------------------------------------------------------------------
