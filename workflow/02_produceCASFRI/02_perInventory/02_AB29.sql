------------------------------------------------------------------------------
-- CASFRI - AB29 translation script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

--------------------------------------------------------------------------
-- Translate all AB29. 6h20m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab29_cas'); 

SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB29';

-- Add translated ones
INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_ab29_cas('rawfri', 'ab29_l1_to_ab_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab29_dst');

SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB29';

-- Add translated ones
INSERT INTO casfri50.dst_all
SELECT * FROM TT_Translate_ab29_dst('rawfri', 'ab29_l1_to_ab_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab29_eco'); 

SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB29';

-- Add translated ones
INSERT INTO casfri50.eco_all
SELECT * FROM TT_Translate_ab29_eco('rawfri', 'ab29_l1_to_ab_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab29_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB29';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab29_lyr');

SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab29_lyr('rawfri', 'ab29_l1_to_ab_l1_map');


-- Layer 2 reusing AB29 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab29', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all
SELECT * FROM TT_Translate_ab29_lyr('rawfri', 'ab29_l2_to_ab_l1_map');


------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab29_nfl'); 

SELECT TT_CreateMappingView('rawfri', 'ab29', 3, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB29';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all
SELECT * FROM TT_Translate_ab29_nfl('rawfri', 'ab29_l3_to_ab_l1_map');


-- Layer 2 reusing AB29 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab29', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all
SELECT * FROM TT_Translate_ab29_nfl('rawfri', 'ab29_l4_to_ab_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab29_geo'); 

SELECT TT_CreateMappingView('rawfri', 'ab29', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB29';

-- Add translated ones
INSERT INTO casfri50.geo_all
SELECT * FROM TT_Translate_ab29_geo('rawfri', 'ab29_l1_to_ab_l1_map'); 

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB29'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB29'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB29'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB29'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB29'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB29';
*/
--------------------------------------------------------------------------
