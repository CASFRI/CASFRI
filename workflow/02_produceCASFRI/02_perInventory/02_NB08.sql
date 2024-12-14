------------------------------------------------------------------------------
-- CASFRI - NB08 translation script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--------------------------------------------------------------------------
-- Translate all NB08
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_cas', '_nb08_cas', 'ab_avi01_cas'); -- used for both NB01, NB03, and NB08

SELECT TT_CreateMappingView('rawfri', 'nb08', 'nb');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NB08';

-- Add translated ones
INSERT INTO casfri50.cas_all --
SELECT * FROM TT_Translate_nb08_cas('rawfri', 'nb08_l1_to_nb_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb08_dst', 'ab_avi01_dst'); -- used for both NB01, NB03, NB08

SELECT TT_CreateMappingView('rawfri', 'nb08', 1, 'nb', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NB08';

-- Add translated ones
INSERT INTO casfri50.dst_all 
SELECT * FROM TT_Translate_nb08_dst('rawfri', 'nb08_l1_to_nb_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb08_eco', 'ab_avi01_eco'); -- used for both NB01, NB03, NB08

SELECT TT_CreateMappingView('rawfri', 'nb08', 'nb');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NB08';

-- Add translated ones
INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_nb08_eco('rawfri', 'nb08_l1_to_nb_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of NB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nb02_species_codes_idx
ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb08_lyr', 'ab_avi01_lyr'); -- used for both NB01, NB03, NB08, layer 1 and 2

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NB08';

-- Add translated ones
-- Layer 1 reusing NB01 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'nb08', 1, 'nb', 1);

INSERT INTO casfri50.lyr_all --
SELECT * FROM TT_Translate_nb08_lyr('rawfri', 'nb08_l1_to_nb_l1_map');



-- Layer 2 reusing NB01 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'nb08', 2, 'nb', 1);

INSERT INTO casfri50.lyr_all --
SELECT * FROM TT_Translate_nb08_lyr('rawfri', 'nb08_l2_to_nb_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb08_nfl', 'ab_avi01_nfl'); -- used for both NB01, NB03, NB08

SELECT TT_CreateMappingView('rawfri', 'nb08', 3, 'nb', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NB08';

-- Add translated ones
INSERT INTO casfri50.nfl_all --
SELECT * FROM TT_Translate_nb08_nfl('rawfri', 'nb08_l3_to_nb_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_geo', '_nb08_geo', 'ab_avi01_geo'); -- used for both NB01, NB03, NB08

SELECT TT_CreateMappingView('rawfri', 'nb08', 1, 'nb', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NB08';

-- Add translated ones
INSERT INTO casfri50.geo_all --
SELECT * FROM TT_Translate_nb08_geo('rawfri', 'nb08_l1_to_nb_l1_map');

--------------------------------------------------------------------------
-- Check

SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NB08'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NB08'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NB08'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NB08'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NB08'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NB08';

--------------------------------------------------------------------------
