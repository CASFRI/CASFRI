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
-- Translate all NL01. 14h47m 
--------------------------------------------------------------------------
-- CAS 
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'nl_nli01_cas', '_nl01_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NL01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_nl01_cas('rawfri', 'nl01_l1_to_nl_nli_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'nl_nli01_dst', '_nl01_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NL01';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_nl01_dst('rawfri', 'nl01_l1_to_nl_nli_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'nl_nli01_eco', '_nl01_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NL01';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nl01_eco('rawfri', 'nl01_l1_to_nl_nli_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of YT species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_nl01_species_codes_idx
ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'nl_nli01_lyr', '_nl01_lyr', 'ab_avi01_lyr'); 

SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NL01';

-- Add translated ones
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nl01_lyr('rawfri', 'nl01_l1_to_nl_nli_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'nl_nli01_nfl', '_nl01_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NL01';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nl01_nfl('rawfri', 'nl01_l1_to_nl_nli_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'nl_nli01_geo', '_nl01_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NL01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_nl01_geo('rawfri', 'nl01_l1_to_nl_nli_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NL01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NL01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NL01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NL01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NL01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NL01';
*/
--------------------------------------------------------------------------
