------------------------------------------------------------------------------
-- CASFRI - PC02 translation script for CASFRI v5
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
-- Translate all PC02. 00h05m
--------------------------------------------------------------------------
-- CAS
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_wbnp01_cas', '_pc02_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'pc02', 'pc_wbnp');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'PC02';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_pc02_cas('rawfri', 'pc02_l1_to_pc_wbnp_l1_map');

COMMIT;

------------------------
-- DST 
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_wbnp01_dst', '_pc02_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'PC02';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_pc02_dst('rawfri', 'pc02_l1_to_pc_wbnp_l1_map');

COMMIT;

------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_wbnp01_eco', '_pc02_eco', 'ab_avi01_eco');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'PC02';

-- Add translated ECOxLYR layer 1  
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l1_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxLYR layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l2_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxLYR layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l3_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxLYR layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l4_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxLYR layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l5_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxLYR layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l6_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxLYR layer 7
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l7_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 8
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l8_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 9
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l9_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 10
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l10_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 11
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l11_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 12
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l12_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 13
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l13_to_pc_wbnp_l1_map');
COMMIT;

-- Add translated ECOxNFL layer 14
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1);

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l14_to_pc_wbnp_l1_map');
COMMIT;

------------------------
-- LYR
------------------------
-- Check the uniqueness of pc02 species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pc02_species_codes_idx
ON translation.species_code_mapping (pc02_species_codes)
WHERE TT_NotEmpty(pc02_species_codes);

BEGIN;
-- Prepare the translation function
SELECT TT_Prepare('translation', 'pc_wbnp01_lyr', '_pc02_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'PC02';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l1_to_pc_wbnp_l1_map');
COMMIT;

-- Layer 2 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l2_to_pc_wbnp_l1_map');
COMMIT;

-- Layer 3 
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l3_to_pc_wbnp_l1_map');
COMMIT;

-- Layer 4
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l4_to_pc_wbnp_l1_map');
COMMIT;

-- Layer 5
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l5_to_pc_wbnp_l1_map');
COMMIT;

-- Layer 6
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l6_to_pc_wbnp_l1_map');
COMMIT;

-- Layer 7 
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_pc02_lyr('rawfri', 'pc02_l7_to_pc_wbnp_l1_map');
COMMIT;

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_wbnp01_nfl', '_pc02_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'PC02';

-- Add translated ones
-- Layer 8
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l8_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 9 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l9_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 10
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l10_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 11
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l11_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 12
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l12_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 13
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l13_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 14
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l14_to_pc_wbnp_l1_map'); 
COMMIT;

-- Layer 15
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 15, 'pc_wbnp', 1);

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l15_to_pc_wbnp_l1_map'); 
COMMIT;

------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pc_wbnp01_geo', '_pc02_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'PC02';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_pc02_geo('rawfri', 'pc02_l1_to_pc_wbnp_l1_map');

COMMIT;

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'PC02'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'PC02'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'PC02'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'PC02'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'PC02'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'PC02';
*/
--------------------------------------------------------------------------
