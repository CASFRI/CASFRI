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
-- Validate AB photo year table
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_photoyear_validation', '_ab_photo_val');
SELECT * FROM TT_Translate_ab_photo_val('rawfri', 'ab_photoyear');

-- Make table valid and subset by rows with valid photo years
DROP TABLE IF EXISTS rawfri.new_photo_year;
CREATE TABLE rawfri.new_photo_year AS
SELECT TT_GeoMakeValid(wkb_geometry) as wkb_geometry, photo_yr
FROM rawfri.ab_photoyear
WHERE TT_IsInt(photo_yr);

CREATE INDEX IF NOT EXISTS ab_photoyear_idx 
 ON rawfri.new_photo_year
 USING GIST(wkb_geometry);

DROP TABLE rawfri.ab_photoyear;
ALTER TABLE rawfri.new_photo_year RENAME TO ab_photoyear;

--------------------------------------------------------------------------
-- Translate all AB03. 1h9m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab03_cas'); 

SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB03';

-- Add translated ones
INSERT INTO casfri50.cas_all  -- xmxs
SELECT * FROM TT_Translate_ab03_cas('rawfri', 'ab03_l1_to_ab_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab03_dst');

SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB03';

-- Add translated ones
INSERT INTO casfri50.dst_all
SELECT * FROM TT_Translate_ab03_dst('rawfri', 'ab03_l1_to_ab_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab03_eco'); 

SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB03';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 36s
SELECT * FROM TT_Translate_ab03_eco('rawfri', 'ab03_l1_to_ab_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of AB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ab03_species_codes_idx
ON translation.species_code_mapping (ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB03';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab03_lyr');

SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1);

INSERT INTO casfri50.lyr_all -- xmxs
SELECT * FROM TT_Translate_ab03_lyr('rawfri', 'ab03_l1_to_ab_l1_map');


-- Layer 2 reusing AB03 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab03', 2, 'ab', 1);

INSERT INTO casfri50.lyr_all -- xmxs
SELECT * FROM TT_Translate_ab03_lyr('rawfri', 'ab03_l2_to_ab_l1_map');


------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab03_nfl'); 

SELECT TT_CreateMappingView('rawfri', 'ab03', 3, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB03';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all -- xmxs
SELECT * FROM TT_Translate_ab03_nfl('rawfri', 'ab03_l3_to_ab_l1_map');


-- Layer 2 reusing AB03 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab03', 4, 'ab', 1);

INSERT INTO casfri50.nfl_all -- xmxs
SELECT * FROM TT_Translate_ab03_nfl('rawfri', 'ab03_l4_to_ab_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab03_geo'); 

SELECT TT_CreateMappingView('rawfri', 'ab03', 1, 'ab', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB03';

-- Add translated ones
INSERT INTO casfri50.geo_all -- xs
SELECT * FROM TT_Translate_ab03_geo('rawfri', 'ab03_l1_to_ab_l1_map'); 

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB03'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB03'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB03'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB03'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB03'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB03';
*/
--------------------------------------------------------------------------
