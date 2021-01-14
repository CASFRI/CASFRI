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
-- Translate all SK02. 18m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_cas', '_sk02_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'SK02';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 6min 23s
SELECT * FROM TT_Translate_sk02_cas('rawfri', 'sk02_l1_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk02_l1_to_sk_sfv_l1_map');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk02_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'SK02';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 2min 23s
SELECT * FROM TT_Translate_sk02_dst('rawfri', 'sk02_l1_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_dst', 'sk02_l1_to_sk_sfv_l1_map');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk02_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'SK02';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk02_eco('rawfri', 'sk02_l1_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk02_l1_to_sk_sfv_l1_map');

------------------------
-- LYR
------------------------
-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_sk02_species_codes_idx
ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk02_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'SK02';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 9min 11s
SELECT * FROM TT_Translate_sk02_lyr('rawfri', 'sk02_l1_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk02_l1_to_sk_sfv_l1_map');

-- Layer 2 using SFVI translation table
SELECT TT_CreateMappingView('rawfri', 'sk02', 2, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 1min 56s
SELECT * FROM TT_Translate_sk02_lyr('rawfri', 'sk02_l2_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk02_l2_to_sk_sfv_l1_map');

-- Layer 3 using SFVI translation table
SELECT TT_CreateMappingView('rawfri', 'sk02', 3, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 6s
SELECT * FROM TT_Translate_sk02_lyr('rawfri', 'sk02_l3_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr', 'sk02_l3_to_sk_sfv_l1_map');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk02_nfl', 'ab_avi01_nfl');

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'SK02';

-- Add translated ones
--layer 1 - non_for_veg: shrubs
SELECT TT_CreateMappingView('rawfri', 'sk02', 4, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 2min 8s
SELECT * FROM TT_Translate_sk02_nfl('rawfri', 'sk02_l4_to_sk_sfv_l1_map', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l4_to_sk_sfv_l1_map');

--layer 2 - non_for_veg: herbs
SELECT TT_CreateMappingView('rawfri', 'sk02', 5, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 1min 18s
SELECT * FROM TT_Translate_sk02_nfl('rawfri', 'sk02_l5_to_sk_sfv_l1_map', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l5_to_sk_sfv_l1_map');

--layer 3 - nat_non_veg and non_for_anth
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 9s
SELECT * FROM TT_Translate_sk02_nfl('rawfri', 'sk02_l6_to_sk_sfv_l1_map', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l6_to_sk_sfv_l1_map');
------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_geo', '_sk02_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'SK02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 1min 56s
SELECT * FROM TT_Translate_sk02_geo('rawfri', 'sk02_l1_to_sk_sfv_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_geo', 'sk02_l1_to_sk_sfv_l1_map');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'SK02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'SK02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'SK02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'SK02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'SK02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK02';
--------------------------------------------------------------------------
