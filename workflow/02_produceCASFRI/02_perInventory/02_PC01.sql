------------------------------------------------------------------------------
-- CASFRI - PC01 translation script for CASFRI v5
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
-- Translate all PC01. 00h05m
--------------------------------------------------------------------------
-- CAS
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_panp01_cas', '_pc01_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'pc01', 'pc_panp');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'PC01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_pc01_cas('rawfri', 'pc01_l1_to_pc_panp_l1_map');

COMMIT;

------------------------
-- DST (No DST in PC01)
------------------------
--BEGIN;
--SELECT TT_Prepare('translation', 'pc_panp01_dst', '_pc01_dst', 'ab_avi01_dst');

--SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1);

-- Delete existing entries
---- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'PC01';

-- Add translated ones
--INSERT INTO casfri50.dst_all -- 
--SELECT * FROM TT_Translate_pc01_dst('rawfri', 'pc01_l1_to_pc_panp_l1_map');

----COMMIT;

------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_panp01_eco', '_pc01_eco', 'ab_avi01_eco');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'PC01';

-- Add translated ones layer 4
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc01_eco('rawfri', 'pc01_l4_to_pc_panp_l1_map');

-- Add translated ones layer 5
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc01_eco('rawfri', 'pc01_l5_to_pc_panp_l1_map');

-- Add translated ones layer 6
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc01_eco('rawfri', 'pc01_l6_to_pc_panp_l1_map');

COMMIT;

------------------------
-- LYR
------------------------
-- Check the uniqueness of PC01 species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc01_species_codes_idx
ON translation.species_code_mapping (pc01_species_codes)
WHERE TT_NotEmpty(pc01_species_codes);

BEGIN;
-- Prepare the translation function
SELECT TT_Prepare('translation', 'pc_panp01_lyr', '_pc01_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'PC01';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc01_lyr('rawfri', 'pc01_l1_to_pc_panp_l1_map');


-- Layer 2 using translation table
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc01_lyr('rawfri', 'pc01_l2_to_pc_panp_l1_map');

COMMIT;

-- Layer 3 using translation table
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc01_lyr('rawfri', 'pc01_l3_to_pc_panp_l1_map');

COMMIT;

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_panp01_nfl', '_pc01_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'PC01';

-- Add translated ones
-- Layer 4
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc01_nfl('rawfri', 'pc01_l4_to_pc_panp_l1_map'); 

COMMIT;

-- Layer 5 using translation table
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc01_nfl('rawfri', 'pc01_l5_to_pc_panp_l1_map'); 

COMMIT;

-- Layer 6 using translation table
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc01_nfl('rawfri', 'pc01_l6_to_pc_panp_l1_map'); 

COMMIT;

------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_panp01_geo', '_pc01_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'PC01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_pc01_geo('rawfri', 'pc01_l1_to_pc_panp_l1_map');

COMMIT;

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'PC01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'PC01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'PC01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'PC01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'PC01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'PC01';
*/
--------------------------------------------------------------------------
