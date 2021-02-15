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
-- Translate all SK05. 4h15m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_cas', '_sk05_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'SK05';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk05_cas('rawfri', 'sk05_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk05_l1_to_sk_sfv_l1_map');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk05_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'SK05';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk05_dst('rawfri', 'sk05_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_dst', 'sk05_l1_to_sk_sfv_l1_map');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk05_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'SK05';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk05_eco('rawfri', 'sk05_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk05_l1_to_sk_sfv_l1_map');

------------------------
-- LYR
------------------------
-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_sk05_species_codes_idx 
ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk05_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'SK05';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk05_lyr('rawfri', 'sk05_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk05_l1_to_sk_sfv_l1_map');

-- Layer 2 using SFVI translation table
SELECT TT_CreateMappingView('rawfri', 'sk05', 2, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk05_lyr('rawfri', 'sk05_l2_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk05_l2_to_sk_sfv_l1_map');

-- Layer 3 using SFVI translation table
SELECT TT_CreateMappingView('rawfri', 'sk05', 3, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk05_lyr('rawfri', 'sk05_l3_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk05_l3_to_sk_sfv_l1_map');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk05_nfl', 'ab_avi01_nfl');

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'SK05';

-- Add translated ones
--layer 1 - non_for_veg: shrubs
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk05_nfl('rawfri', 'sk05_l4_to_sk_sfv_l1_map'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l4_to_sk_sfv_l1_map');

--layer 2 - non_for_veg: herbs
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk05_nfl('rawfri', 'sk05_l5_to_sk_sfv_l1_map'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l5_to_sk_sfv_l1_map');

--layer 2 - nat_non_veg and non_for_anth
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk05_nfl('rawfri', 'sk05_l6_to_sk_sfv_l1_map'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l6_to_sk_sfv_l1_map');
------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_geo', '_sk05_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'SK05';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_sk05_geo('rawfri', 'sk05_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_geo', 'sk05_l1_to_sk_sfv_l1_map');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'SK05'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'SK05'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'SK05'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'SK05'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'SK05'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK05';
--------------------------------------------------------------------------
