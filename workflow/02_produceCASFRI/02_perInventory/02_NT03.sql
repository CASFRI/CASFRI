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
-- Translate all NT03. 3h35m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt03_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'nt03', 'nt');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NT03';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt03_cas('rawfri', 'nt03_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas', 'nt03_l1_to_nt_l1_map');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt03_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NT03';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 51m
SELECT * FROM TT_Translate_nt03_dst('rawfri', 'nt03_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_dst', 'nt03_l1_to_nt_l1_map');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt03_eco', 'ab_avi01_eco'); 

SELECT TT_CreateMappingView('rawfri', 'nt03', 'nt');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NT03';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt03_eco('rawfri', 'nt03_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco', 'nt03_l1_to_nt_l1_map');

------------------------
-- LYR
------------------------
-- Check the uniqueness of NT species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nt03_species_codes_idx
ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt03_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NT03';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt03_lyr('rawfri', 'nt03_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr', 'nt03_l1_to_nt_l1_map');

-- Translate NT03 layer 2 using NT layer 1 generic translation table

SELECT TT_CreateMappingView('rawfri', 'nt03', 2, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt03_lyr('rawfri', 'nt03_l2_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr', 'nt03_l2_to_nt_l1_map');

------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt03_nfl', 'ab_avi01_nfl'); 

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NT03';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'nt03', 3, 'nt', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt03_nfl('rawfri', 'nt03_l3_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt03_l3_to_nt_l1_map');

-- Layer 2 reusing NT01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nt03', 4, 'nt', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt03_nfl('rawfri', 'nt03_l4_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt03_l4_to_nt_l1_map');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_geo', '_nt03_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'nt03', 1, 'nt', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NT03';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 22m
SELECT * FROM TT_Translate_nt03_geo('rawfri', 'nt03_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_geo', 'nt03_l1_to_nt_l1_map');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NT03'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NT03'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NT03'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NT03'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NT03'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT03';
--------------------------------------------------------------------------
