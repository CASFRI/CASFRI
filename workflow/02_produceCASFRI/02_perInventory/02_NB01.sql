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
-- Translate all NB01. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_cas', '_nb01_cas', 'ab_avi01_cas'); -- used for both NB01 and NB02

SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NB01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 2h45m
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01_l1_to_nb_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb01_dst', 'ab_avi01_dst'); -- used for both NB01 and NB02

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NB01';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1);

INSERT INTO casfri50.dst_all -- 38m
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01_l1_to_nb_l1_map');



-- Layer 2 using NB layer 1 generic translation table

SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1); 

INSERT INTO casfri50.dst_all -- 44m
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01_l2_to_nb_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb01_eco', 'ab_avi01_eco'); -- used for both NB01 and NB02

SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NB01';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 1h27m
SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01_l1_to_nb_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of NB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nb01_species_codes_idx
ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb01_lyr', 'ab_avi01_lyr'); -- used for both NB01 and NB02, layer 1 and 2

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NB01';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1);

INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01_l1_to_nb_l1_map');


-- Layer 2 using NB layer 1 generic translation table and only rows having LYR attributes

SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01_l2_to_nb_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb01_nfl', 'ab_avi01_nfl'); -- used for both NB01 and NB02

SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NB01';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 1h4m
SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01_l3_to_nb_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_geo', '_nb01_geo', 'ab_avi01_geo'); -- used for both NB01 and NB02

SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NB01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 48m52s
SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb01_l1_to_nb_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NB01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NB01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NB01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NB01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NB01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB01';
*/
--------------------------------------------------------------------------
