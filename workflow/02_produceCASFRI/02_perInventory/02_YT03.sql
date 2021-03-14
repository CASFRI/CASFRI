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
-- Translate all YT03. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'yt_yvi02_cas', '_yt03_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt_yvi02');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'YT03';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_yt03_cas('rawfri', 'yt03_l1_to_yt_yvi02_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'yt_yvi02_dst', '_yt03_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'YT03';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_yt03_dst('rawfri', 'yt03_l1_to_yt_yvi02_l1_map');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_yt03_dst('rawfri', 'yt03_l2_to_yt_yvi02_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'yt_yvi02_eco', '_yt03_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt_yvi02');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'YT03';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_yt03_eco('rawfri', 'yt03_l1_to_yt_yvi02_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of YT species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_yt02_species_codes_idx
ON translation.species_code_mapping (yt_species_codes)
WHERE TT_NotEmpty(yt_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'yt_yvi02_lyr', '_yt03_lyr', 'ab_avi01_lyr'); 

SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt_yvi02', 1);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'YT03';

-- Add translated ones
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_yt03_lyr('rawfri', 'yt03_l1_to_yt_yvi02_l1_map');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_yt03_lyr('rawfri', 'yt03_l2_to_yt_yvi02_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'yt_yvi02_nfl', '_yt03_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'yt03', 3, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 4, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 5, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 6, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 7, 'yt_yvi02', 1);
SELECT TT_CreateMappingView('rawfri', 'yt03', 8, 'yt_yvi02', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'YT03';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt03_nfl('rawfri', 'yt03_l3_to_yt_yvi02_l1_map');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt03_nfl('rawfri', 'yt03_l4_to_yt_yvi02_l1_map');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt03_nfl('rawfri', 'yt03_l5_to_yt_yvi02_l1_map');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt03_nfl('rawfri', 'yt03_l6_to_yt_yvi02_l1_map');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt03_nfl('rawfri', 'yt03_l7_to_yt_yvi02_l1_map');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt03_nfl('rawfri', 'yt03_l8_to_yt_yvi02_l1_map');
------------------------

-- GEO
------------------------
SELECT TT_Prepare('translation', 'yt_yvi02_geo', '_yt03_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt_yvi02', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'YT03';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_yt03_geo('rawfri', 'yt03_l1_to_yt_yvi02_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'YT03'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'YT03'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'YT03'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'YT03'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'YT03'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'YT03';
*/
--------------------------------------------------------------------------
