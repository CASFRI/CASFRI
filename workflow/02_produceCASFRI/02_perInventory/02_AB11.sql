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
-- Translate all AB11. hm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab11_cas'); 

SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB11';

-- Add translated ones
INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_ab11_cas('rawfri', 'ab11_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas', 'ab11_l1_to_ab_l1_map');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab11_dst');

SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB11';

-- Add translated ones
INSERT INTO casfri50.dst_all
SELECT * FROM TT_Translate_ab11_dst('rawfri', 'ab11_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_dst', 'ab11_l1_to_ab_l1_map');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab11_eco'); 

SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB11';

-- Add translated ones
INSERT INTO casfri50.eco_all
SELECT * FROM TT_Translate_ab11_eco('rawfri', 'ab11_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab11_l1_to_ab_l1_map');

------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab11_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB11';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab11_lyr');

SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab11_lyr('rawfri', 'ab11_l1_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab11_l1_to_ab_l1_map');

-- Layer 2 reusing AB11 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab11', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab11_lyr('rawfri', 'ab11_l2_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr', 'ab11_l2_to_ab_l1_map');

------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab11_nfl'); 

SELECT TT_CreateMappingView('rawfri', 'ab11', 3, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB11';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all
SELECT * FROM TT_Translate_ab11_nfl('rawfri', 'ab11_l3_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab11_l3_to_ab_l1_map');

-- Layer 2 reusing AB11 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab11', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all
SELECT * FROM TT_Translate_ab11_nfl('rawfri', 'ab11_l4_to_ab_l1_map', 'ogc_fid');

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab11_l4_to_ab_l1_map');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab11_geo'); 

SELECT TT_CreateMappingView('rawfri', 'ab11', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB11';

-- Add translated ones
INSERT INTO casfri50.geo_all
SELECT * FROM TT_Translate_ab11_geo('rawfri', 'ab11_l1_to_ab_l1_map', 'ogc_fid'); 

--SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_geo', 'ab11_l1_to_ab_l1_map');
--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB11'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB11'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB11'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB11'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB11'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB11';
*/
--------------------------------------------------------------------------
