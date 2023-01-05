------------------------------------------------------------------------------
-- CASFRI - NS04 translation script for CASFRI v5
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
-- Translate all NS04. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ns_nsi01_cas', '_ns04_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'ns04', 'ns_nsi');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'NS04';

-- Add translated ones
INSERT INTO casfri50.cas_all --
SELECT * FROM TT_Translate_ns03_cas('rawfri', 'ns04_l1_to_ns_nsi_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ns_nsi01_dst', '_ns04_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'ns04', 'ns_nsi');

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'NS04';

-- Add translated ones
INSERT INTO casfri50.dst_all --
SELECT * FROM TT_Translate_ns04_dst('rawfri', 'ns04_l1_to_ns_nsi_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'ns_nsi01_eco', '_ns04_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'ns04', 'ns_nsi');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'NS04';

-- Add translated ones
INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_ns04_eco('rawfri', 'ns04_l1_to_ns_nsi_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of NS species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_ns04_species_codes_idx
ON translation.species_code_mapping (ns_species_codes)
WHERE TT_NotEmpty(ns_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'ns_nsi01_lyr', '_ns04_lyr', 'ab_avi01_lyr');

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'NS04';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'ns04', 1, 'ns_nsi', 1);

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_ns04_lyr('rawfri', 'ns04_l1_to_ns_nsi_l1_map');


-- Layer 2

SELECT TT_CreateMappingView('rawfri', 'ns04', 2, 'ns_nsi', 1);

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_ns04_lyr('rawfri', 'ns04_l2_to_ns_nsi_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'ns_nsi01_nfl', '_ns04_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'NS04';

-- Add translated NFL
SELECT TT_CreateMappingView('rawfri', 'ns04', 3, 'ns_nsi', 1);

INSERT INTO casfri50.nfl_all --
SELECT * FROM TT_Translate_ns04_nfl('rawfri', 'ns04_l3_to_ns_nsi_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ns_nsi01_geo', '_ns04_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'ns04', 'ns_nsi');

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'NS04';

-- Add translated ones
INSERT INTO casfri50.geo_all --
SELECT * FROM TT_Translate_ns04_geo('rawfri', 'ns04_l1_to_ns_nsi_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'NS04'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'NS04'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'NS04'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'NS04'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'NS04'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'NS04';
*/
--------------------------------------------------------------------------
