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
-- Translate all AB25. 5h15m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab25_cas'); 

SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB25';

-- Add translated ones
INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_ab25_cas('rawfri', 'ab25_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas', 'ab25_l1_to_ab_l1_map');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab25_dst');

SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB25';

-- Add translated ones
INSERT INTO casfri50.dst_all
SELECT * FROM TT_Translate_ab25_dst('rawfri', 'ab25_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_dst', 'ab25_l1_to_ab_l1_map');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab25_eco'); 

SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB25';

-- Add translated ones
INSERT INTO casfri50.eco_all
SELECT * FROM TT_Translate_ab25_eco('rawfri', 'ab25_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab25_l1_to_ab_l1_map');

------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab25_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB25';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab25_lyr');

SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab25_lyr('rawfri', 'ab25_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab25_l1_to_ab_l1_map');

-- Layer 2 reusing AB25 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab25', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab25_lyr('rawfri', 'ab25_l2_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab25_l2_to_ab_l1_map');

------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab25_nfl'); 

SELECT TT_CreateMappingView('rawfri', 'ab25', 3, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB25';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all
SELECT * FROM TT_Translate_ab25_nfl('rawfri', 'ab25_l3_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab25_l3_to_ab_l1_map');

-- Layer 2 reusing AB25 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab25', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all
SELECT * FROM TT_Translate_ab25_nfl('rawfri', 'ab25_l4_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab25_l4_to_ab_l1_map');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab25_geo'); 

SELECT TT_CreateMappingView('rawfri', 'ab25', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB25';

-- Add translated ones
INSERT INTO casfri50.geo_all
SELECT * FROM TT_Translate_ab25_geo('rawfri', 'ab25_l1_to_ab_l1_map', 'ogc_fid'); 

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_geo', 'ab25_l1_to_ab_l1_map');
--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB25'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB25'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB25'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB25'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB25'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB25';
*/
--------------------------------------------------------------------------
