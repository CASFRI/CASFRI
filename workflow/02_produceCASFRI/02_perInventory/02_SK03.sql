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
-- Translate all SK03. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_cas', '_sk03_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'SK03';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 1min 57s
SELECT * FROM TT_Translate_sk03_cas('rawfri', 'sk03_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk03_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'SK03';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 5s
SELECT * FROM TT_Translate_sk03_dst('rawfri', 'sk03_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk03_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'SK03';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk03_eco('rawfri', 'sk03_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco');

------------------------
-- LYR
------------------------
-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'sk_sfv01_lyr', '_sk03_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'SK03';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 3mins
SELECT * FROM TT_Translate_sk03_lyr('rawfri', 'sk03_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr');

-- Layer 2 using SFVI translation table
SELECT TT_CreateMappingView('rawfri', 'sk03', 2, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 1min 21s
SELECT * FROM TT_Translate_sk03_lyr('rawfri', 'sk03_l2_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr');

-- Layer 3 using SFVI translation table
SELECT TT_CreateMappingView('rawfri', 'sk03', 3, 'sk_sfv', 1);

INSERT INTO casfri50.lyr_all -- 1s
SELECT * FROM TT_Translate_sk03_lyr('rawfri', 'sk03_l3_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_lyr');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk03_nfl', 'ab_avi01_nfl');

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'SK03';

-- Add translated ones
--layer 1 - non_for_veg: shrubs
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 49s
SELECT * FROM TT_Translate_sk03_nfl('rawfri', 'sk03_l4_to_sk_sfv_l1_map'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl');

--layer 2 - non_for_veg: herbs
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 29s
SELECT * FROM TT_Translate_sk03_nfl('rawfri', 'sk03_l5_to_sk_sfv_l1_map'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl');

--layer 2 - nat_non_veg and non_for_anth
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1);

INSERT INTO casfri50.nfl_all -- 9s
SELECT * FROM TT_Translate_sk03_nfl('rawfri', 'sk03_l6_to_sk_sfv_l1_map'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl');
------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'sk_sfv01_geo', '_sk03_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'SK03';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 42s
SELECT * FROM TT_Translate_sk03_geo('rawfri', 'sk03_l1_to_sk_sfv_l1_map');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'SK03'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'SK03'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'SK03'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'SK03'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'SK03'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK03';
--------------------------------------------------------------------------
