------------------------------------------------------------------------------
-- CASFRI - AB10 translation script for CASFRI v5
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
-- Translate all AB10. 5h19m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab10_cas'); 

SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB10';

-- Add translated ones
INSERT INTO casfri50.cas_all  -- xmxs
SELECT * FROM TT_Translate_ab10_cas('rawfri', 'ab10_l1_to_ab_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab10_dst');

SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB10';

-- Add translated ones
INSERT INTO casfri50.dst_all -- xs
SELECT * FROM TT_Translate_ab10_dst('rawfri', 'ab10_l1_to_ab_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab10_eco'); 

SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB10';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 36s
SELECT * FROM TT_Translate_ab10_eco('rawfri', 'ab10_l1_to_ab_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab10_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB10';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab10_lyr');

SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all -- xmxs
SELECT * FROM TT_Translate_ab10_lyr('rawfri', 'ab10_l1_to_ab_l1_map');


-- Layer 2 reusing AB10 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab10', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all -- xmxs
SELECT * FROM TT_Translate_ab10_lyr('rawfri', 'ab10_l2_to_ab_l1_map');


------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab10_nfl'); 

SELECT TT_CreateMappingView('rawfri', 'ab10', 3, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB10';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all -- xmxs
SELECT * FROM TT_Translate_ab10_nfl('rawfri', 'ab10_l3_to_ab_l1_map');


-- Layer 2 reusing AB10 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab10', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all -- xmxs
SELECT * FROM TT_Translate_ab10_nfl('rawfri', 'ab10_l4_to_ab_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab10_geo'); 

SELECT TT_CreateMappingView('rawfri', 'ab10', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB10';

-- Add translated ones
INSERT INTO casfri50.geo_all -- xs
SELECT * FROM TT_Translate_ab10_geo('rawfri', 'ab10_l1_to_ab_l1_map'); 

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB10'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB10'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB10'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB10'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB10'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB10';
*/
--------------------------------------------------------------------------
