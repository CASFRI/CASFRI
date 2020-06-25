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
-- Translate all YT02. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'yt_yvi01_cas', '_yt_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'YT02';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_yt_cas('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'yt_yvi01_dst', '_yt_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'YT02';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_yt_dst('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'YT02';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_yt_eco('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_eco');

------------------------
-- LYR
------------------------
-- Check the uniqueness of YT species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (yt_species_codes)
WHERE TT_NotEmpty(yt_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_lyr', 'ab_avi01_lyr'); 

SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'YT02';

-- Add translated ones
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_yt_lyr('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_lyr');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'YT02';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt_nfl('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_nfl');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'yt_yvi01_geo', '_yt_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'YT02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_yt_geo('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'YT02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'YT02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'YT02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'YT02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'YT02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'YT02';
--------------------------------------------------------------------------
