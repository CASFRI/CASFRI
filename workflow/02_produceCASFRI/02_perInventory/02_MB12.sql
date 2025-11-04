------------------------------------------------------------------------------
-- CASFRI - MB12 translation script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--------------------------------------------------------------------------
-- Translate all MB12. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_cas', '_mb12_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'mb12', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'MB12';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_mb12_cas('rawfri', 'mb12_l1_to_mb_fli_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_dst', '_mb12_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'mb12', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'MB12';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_mb12_dst('rawfri', 'mb12_l1_to_mb_fli_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_eco', '_mb12_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'mb12', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'MB12';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_mb12_eco('rawfri', 'mb12_l1_to_mb_fli_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of MB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_mb06_species_codes_idx
ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'mb_fli01_lyr', '_mb12_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'MB12';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'mb12', 1, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb12_lyr('rawfri', 'mb12_l1_to_mb_fli_l1_map');


-- Layer 2
SELECT TT_CreateMappingView('rawfri', 'mb12', 2, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb12_lyr('rawfri', 'mb12_l2_to_mb_fli_l1_map');


-- Layer 3
SELECT TT_CreateMappingView('rawfri', 'mb12', 3, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb12_lyr('rawfri', 'mb12_l3_to_mb_fli_l1_map');


-- Layer 4
SELECT TT_CreateMappingView('rawfri', 'mb12', 4, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb12_lyr('rawfri', 'mb12_l4_to_mb_fli_l1_map');


-- Layer 5
SELECT TT_CreateMappingView('rawfri', 'mb12', 5, 'mb_fli', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_mb12_lyr('rawfri', 'mb12_l5_to_mb_fli_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_nfl', '_mb12_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'MB12';

-- Add translated NFL
SELECT TT_CreateMappingView('rawfri', 'mb12', 6, 'mb_fli', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_mb12_nfl('rawfri', 'mb12_l6_to_mb_fli_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'mb_fli01_geo', '_mb12_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'mb12', 'mb_fli');

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'MB12';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_mb12_geo('rawfri', 'mb12_l1_to_mb_fli_l1_map');

--------------------------------------------------------------------------
-- Check

SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'MB12'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'MB12'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'MB12'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'MB12'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'MB12'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB12';

--------------------------------------------------------------------------
