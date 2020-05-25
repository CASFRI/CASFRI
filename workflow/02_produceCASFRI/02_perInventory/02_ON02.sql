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
-- Translate all ON02. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'on_fim02_cas', '_on_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'on02', 'on');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'ON02';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_on_cas('rawfri', 'on02_l1_to_on_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 'DST');

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'ON02';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_on_dst('rawfri', 'on02_l1_to_on_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 'ECO');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'ON02';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_on_eco('rawfri', 'on02_l1_to_on_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_eco');

------------------------
-- LYR
------------------------
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'ON02';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l1_to_on_l1_map_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_lyr');

-- Layer 2 using ON translation table

SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l2_to_on_l1_map_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_lyr');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 'NFL');

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'ON02';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_on_nfl('rawfri', 'on02_l1_to_on_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_nfl');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'on_fim02_geo', '_on_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, NULL, NULL, 'geo');

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'ON02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_on_geo('rawfri', 'on02_l1_to_on_l1_map_geo', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'ON02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'ON02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'ON02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'ON02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'ON02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'ON02';
--------------------------------------------------------------------------
