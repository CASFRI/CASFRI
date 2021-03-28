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
-- Translate all ON01. 39h00m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'on_fim02_cas', '_on01_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'on01', 'on');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'ON01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_on01_cas('rawfri', 'on01_l1_to_on_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on01_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'ON01';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_on01_dst('rawfri', 'on01_l1_to_on_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on01_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'on01', 'on');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'ON01';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_on01_eco('rawfri', 'on01_l1_to_on_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of ON species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_on01_species_codes_idx
ON translation.species_code_mapping (on_species_codes)
WHERE TT_NotEmpty(on_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on01_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'ON01';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on01_lyr('rawfri', 'on01_l1_to_on_l1_map');


-- Layer 2 using ON translation table

SELECT TT_CreateMappingView('rawfri', 'on01', 2, 'on', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on01_lyr('rawfri', 'on01_l2_to_on_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on01_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'on01', 3, 'on', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'ON01';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_on01_nfl('rawfri', 'on01_l3_to_on_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'on_fim02_geo', '_on01_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'on01', 1, 'on', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'ON01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_on01_geo('rawfri', 'on01_l1_to_on_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'ON01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'ON01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'ON01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'ON01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'ON01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'ON01';
*/
--------------------------------------------------------------------------
