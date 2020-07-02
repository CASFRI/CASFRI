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
-- Translate all NT01. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt01_cas', 'ab_avi01_cas'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NT01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 43m
SELECT * FROM TT_Translate_nt01_cas('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt01_dst', 'ab_avi01_dst'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NT01';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 36m
SELECT * FROM TT_Translate_nt01_dst('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt01_eco', 'ab_avi01_eco'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NT01';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt01_eco('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco');

------------------------
-- LYR
------------------------
-- Check the uniqueness of NT species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt01_lyr', 'ab_avi01_lyr'); -- used for both NT01 and NT02, layer 1 and 2

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NT01';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h49m
SELECT * FROM TT_Translate_nt01_lyr('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');

-- Layer 2 using NT layer 1 generic translation table

SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h24m
SELECT * FROM TT_Translate_nt01_lyr('rawfri', 'nt01_l2_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt01_nfl', 'ab_avi01_nfl'); -- used for both NT01 and NT02, layer 1 and 2

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NT01';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1); 

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt01_nfl('rawfri', 'nt01_l3_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');

-- Layer 2 using NT layer 1 generic translation table

SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt01_nfl('rawfri', 'nt01_l4_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_geo', '_nt01_geo', 'ab_avi01_geo'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NT01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 20m
SELECT * FROM TT_Translate_nt01_geo('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NT01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NT01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NT01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NT01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NT01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT01';
--------------------------------------------------------------------------
