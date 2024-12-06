------------------------------------------------------------------------------
-- CASFRI - NT04 translation script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2022 Morgan Thompson <Morgan.Thompson@nrcan-rncan.gc.ca>
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--------------------------------------------------------------------------
-- Translate all NT04. 3h35m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt04_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'nt04', 'nt');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NT04';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt04_cas('rawfri', 'nt04_l1_to_nt_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt04_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'nt04', 1, 'nt', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NT04';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 51m
SELECT * FROM TT_Translate_nt04_dst('rawfri', 'nt04_l1_to_nt_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt04_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'nt04', 'nt');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NT04';

-- Add translated ones
INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_nt04_eco('rawfri', 'nt04_l1_to_nt_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of NT species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nt03_species_codes_idx
ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt04_lyr', 'ab_avi01_lyr');

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NT04';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'nt04', 1, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt04_lyr('rawfri', 'nt04_l1_to_nt_l1_map');


-- Translate NT03 layer 2 using NT layer 1 generic translation table

SELECT TT_CreateMappingView('rawfri', 'nt04', 2, 'nt', 1);

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt04_lyr('rawfri', 'nt04_l2_to_nt_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt04_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NT04';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'nt04', 3, 'nt', 1);

INSERT INTO casfri50.nfl_all --
SELECT * FROM TT_Translate_nt04_nfl('rawfri', 'nt04_l3_to_nt_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_geo', '_nt04_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'nt04', 1, 'nt', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NT04';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 22m
SELECT * FROM TT_Translate_nt04_geo('rawfri', 'nt04_l1_to_nt_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NT04'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NT04'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NT04'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NT04'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NT04'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NT04';
*/
--------------------------------------------------------------------------
