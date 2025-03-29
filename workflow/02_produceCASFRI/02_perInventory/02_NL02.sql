------------------------------------------------------------------------------
-- CASFRI - NL02 translation script for CASFRI v5
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
-- Translate all NL02. 14h47m 
--------------------------------------------------------------------------
-- CAS 
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'nl_nli02_cas', '_nl02_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'nl02', 'nl_nli2');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NL02';

-- Add translated ones
INSERT INTO casfri50.cas_all --6h4min
SELECT * FROM TT_Translate_nl02_cas('rawfri', 'nl02_l1_to_nl_nli2_l1_map');
COMMIT;


------------------------
-- DST 
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'nl_nli02_dst', '_nl02_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NL02';

-- Add translated ones
INSERT INTO casfri50.dst_all --4min1sec 
SELECT * FROM TT_Translate_nl02_dst('rawfri', 'nl02_l1_to_nl_nli2_l1_map');
COMMIT;


------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'nl_nli02_eco', '_nl02_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'nl02', 'nl_nli2');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NL02';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 2min26sec
SELECT * FROM TT_Translate_nl02_eco('rawfri', 'nl02_l1_to_nl_nli2_l1_map');
COMMIT;


------------------------
-- LYR
------------------------
-- Check the uniqueness of YT species codes
BEGIN;
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nl02_species_codes_idx
ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nl_nli02_lyr', '_nl02_lyr', 'ab_avi01_lyr'); 

SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1);

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NL02';

-- Add translated ones
INSERT INTO casfri50.lyr_all -- 3hr24min
SELECT * FROM TT_Translate_nl02_lyr('rawfri', 'nl02_l1_to_nl_nli2_l1_map');
COMMIT;


------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'nl_nli02_nfl', '_nl02_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'nl02', 2, 'nl_nli2', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NL02';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 6min1sec
SELECT * FROM TT_Translate_nl02_nfl('rawfri', 'nl02_l2_to_nl_nli2_l1_map');
COMMIT;


------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'nl_nli02_geo', '_nl02_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NL02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 27min25sec
SELECT * FROM TT_Translate_nl02_geo('rawfri', 'nl02_l1_to_nl_nli2_l1_map');
COMMIT;

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all --2612451
WHERE left(cas_id, 4) = 'NL02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all --30956
WHERE left(cas_id, 4) = 'NL02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all --264026
WHERE left(cas_id, 4) = 'NL02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all --1421015
WHERE left(cas_id, 4) = 'NL02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all --487879
WHERE left(cas_id, 4) = 'NL02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all --2612451
WHERE left(cas_id, 4) = 'NL02';
*/
--------------------------------------------------------------------------
