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
-- Translate all AB06. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab_cas'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.cas_all  -- 3m40s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab06_l1_to_ab_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas');

------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab_dst'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab'); -- Only rows with a disturbance

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 26s
SELECT * FROM TT_Translate_ab_dst('rawfri', 'ab06_l1_to_ab_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_dst');

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab_eco'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab'); -- only rows with eco attributes

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 36s
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab06_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco');

------------------------
-- LYR
------------------------
-- Validate species lookup tables
SELECT TT_Prepare('translation', 'ab_avi01_species_validation', '_ab_species_val');

SELECT * FROM TT_Translate_ab_species_val('translation', 'ab_avi01_species');

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
-- Layer 1

SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr'); -- used for both AB06 and AB16 layer 1 and 2

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab'); -- only rows with LYR attributes

INSERT INTO casfri50.lyr_all -- 4m41s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l1_to_ab_l1_map_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr');

-- Layer 2 reusing AB06 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1); -- only rows with LYR attributes

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l2_to_ab_l1_map_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr');

------------------------
-- NFL
------------------------

SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab_nfl'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
-- Layer 1

INSERT INTO casfri50.nfl_all -- 2m24s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l1_to_ab_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl');

-- Layer 2 reusing AB06 layer 1 translation table

SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1);

INSERT INTO casfri50.nfl_all -- 2m1s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l2_to_ab_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab_geo'); -- used for both AB06 and AB16

SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, NULL, NULL, 'geo');

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB06';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 54s
SELECT * FROM TT_Translate_ab_geo('rawfri', 'ab06_l1_to_ab_l1_map_geo', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_geo');
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'AB06'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB06';
--------------------------------------------------------------------------
