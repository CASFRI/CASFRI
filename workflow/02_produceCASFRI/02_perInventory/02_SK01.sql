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
-- Translate all SK01. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'sk_utm01_cas', '_sk_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'SK01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_cas('rawfri', 'sk01_l1_to_sk_utm_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'sk_utm01_dst', '_sk_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'SK01';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_dst('rawfri', 'sk01_l1_to_sk_utm_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'SK01';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_eco('rawfri', 'sk01_l1_to_sk_utm_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_eco');

------------------------
-- LYR
------------------------
-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'SK01';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_lyr('rawfri', 'sk01_l1_to_sk_utm_l1_map', 'ogc_fid');


SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_lyr');

-- Layer 2 using UTM translation table

SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_lyr('rawfri', 'sk01_l2_to_sk_utm_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_lyr');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'SK01';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_nfl('rawfri', 'sk01_l3_to_sk_utm_l1_map', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_nfl');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'sk_utm01_geo', '_sk_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'SK01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_sk_geo('rawfri', 'sk01_l1_to_sk_utm_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'SK01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'SK01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'SK01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'SK01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'SK01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'SK01';
--------------------------------------------------------------------------
