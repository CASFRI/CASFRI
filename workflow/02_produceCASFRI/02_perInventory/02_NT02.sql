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
-- Translate all NT02. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt_cas', 'ab_avi01_cas'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NT02';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt02_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt_dst', 'ab_avi01_dst'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NT02';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 51m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt02_l1_to_nt_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt_eco', 'ab_avi01_eco'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NT02';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt02_l1_to_nt_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco');

------------------------
-- LYR
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr', 'ab_avi01_lyr'); -- used for both NT01 and NT02, layer 1 and 2

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NT02';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l1_to_nt_l1_map_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');

-- Translate NT02 layer 2 using NT layer 1 generic translation table

SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l2_to_nt_l1_map_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt_nfl', 'ab_avi01_nfl'); -- used for both NT01 and NT02, layer 1 and 2

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NT02';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_l1_to_nt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');

-- Layer 2 reusing NT01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_l2_to_nt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_geo', '_nt_geo', 'ab_avi01_geo'); -- used for both NT01 and NT02

SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, NULL, NULL, 'geo');

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NT02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 22m
SELECT * FROM TT_Translate_nt_geo('rawfri', 'nt02_l1_to_nt_l1_map_geo', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NT02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NT02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NT02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NT02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NT02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT02';
--------------------------------------------------------------------------
