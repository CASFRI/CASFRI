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
-- Translate all MB02. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_cas', '_mb02_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'MB02';

-- Add translated ones
INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_mb02_cas('rawfri', 'mb02_l1_to_mb_fli_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_dst', '_mb02_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'MB02';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_mb02_dst('rawfri', 'mb02_l1_to_mb_fli_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_eco', '_mb02_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'MB02';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_mb02_eco('rawfri', 'mb02_l1_to_mb_fli_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of MB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_mb02_species_codes_idx
ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'mb_fli01_lyr', '_mb02_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'MB02';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb02_lyr('rawfri', 'mb02_l1_to_mb_fli_l1_map');


-- Layer 2
SELECT TT_CreateMappingView('rawfri', 'mb02', 2, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb02_lyr('rawfri', 'mb02_l2_to_mb_fli_l1_map');


-- Layer 3
SELECT TT_CreateMappingView('rawfri', 'mb02', 3, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb02_lyr('rawfri', 'mb02_l3_to_mb_fli_l1_map');


-- Layer 4
SELECT TT_CreateMappingView('rawfri', 'mb02', 4, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb02_lyr('rawfri', 'mb02_l4_to_mb_fli_l1_map');


-- Layer 5
SELECT TT_CreateMappingView('rawfri', 'mb02', 5, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb02_lyr('rawfri', 'mb02_l5_to_mb_fli_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_nfl', '_mb02_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'MB02';

-- Add translated NFL
SELECT TT_CreateMappingView('rawfri', 'mb02', 6, 'mb_fli', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_mb02_nfl('rawfri', 'mb02_l6_to_mb_fli_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_geo', '_mb02_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'mb02', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'MB02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_mb02_geo('rawfri', 'mb02_l1_to_mb_fli_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'MB02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'MB02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'MB02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'MB02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'MB02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB02';
*/
--------------------------------------------------------------------------
