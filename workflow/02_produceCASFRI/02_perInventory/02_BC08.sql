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
-- Translate all BC08. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc08_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'BC08';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 12h16m
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_cas');
COMMIT;

------------------------
-- DST
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc08_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'BC08';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_dst');
COMMIT;

------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc08_eco', 'ab_avi01_eco'); -- used for both BC08 and BC10

SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'BC08';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 4h05m
SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_eco');
COMMIT;

------------------------
-- LYR
------------------------
-- Check the uniqueness of BC species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (bc_species_codes)
WHERE TT_NotEmpty(bc_species_codes);

BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc08_lyr', 'ab_avi01_lyr'); -- used for both BC08 and BC10, layer 1 and 2

SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1);

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'BC08';

-- Add translated ones
INSERT INTO casfri50.lyr_all -- 30h19m
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr');
COMMIT;

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc08_nfl', 'ab_avi01_nfl'); -- used for both BC08 and BC10

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'BC08';

-- layer 1
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08_l2_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl');

-- layer 2
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08_l3_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl');

-- layer 4
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1);

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08_l4_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl');
COMMIT;

------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'bc_vri01_geo', '_bc08_geo', 'ab_avi01_geo'); -- used for both BC08 and BC10

SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'BC08';

-- Add translated ones
INSERT INTO casfri50.geo_all --4h59m
SELECT * FROM TT_Translate_bc08_geo('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_geo');
COMMIT;
--------------------------------------------------------------------------
-- Check
SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'BC08'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'BC08'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'BC08'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'BC08'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'BC08'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'BC08';
--------------------------------------------------------------------------