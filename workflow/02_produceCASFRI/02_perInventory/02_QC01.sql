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
-- Translate all QC01. XXhXXm
--------------------------------------------------------------------------
-- add index on standstructure lookup table
CREATE UNIQUE INDEX IF NOT EXISTS qc_stand_structure_lookup_idx
ON translation.qc_standstructure_lookup (source_val);
------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_cas', '_qc01_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'qc01', 'qc_ini03');

-- Delete existing entries
DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'QC01';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_qc01_cas('rawfri', 'qc01_l1_to_qc_ini03_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_dst', '_qc01_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1);

-- Delete existing entries
DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'QC01';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc01_dst('rawfri', 'qc01_l1_to_qc_ini03_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_eco', '_qc01_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'qc01', 'qc_ini03');

-- Delete existing entries
DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'QC01';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_qc01_eco('rawfri', 'qc01_l1_to_qc_ini03_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of QC species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc01_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'qc_ini03_lyr', '_qc01_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'QC01';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc01_lyr('rawfri', 'qc01_l1_to_qc_ini03_l1_map');


-- Layer 2 using translation table
SELECT TT_CreateMappingView('rawfri', 'qc01', 2, 'qc_ini03', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc01_lyr('rawfri', 'qc01_l2_to_qc_ini03_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_nfl', '_qc01_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'qc01', 3, 'qc_ini03', 1);

-- Delete existing entries
DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'QC01';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc01_nfl('rawfri', 'qc01_l3_to_qc_ini03_l1_map'); 


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_geo', '_qc01_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'qc01', 1, 'qc_ini03', 1);

-- Delete existing entries
DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'QC01';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_qc01_geo('rawfri', 'qc01_l1_to_qc_ini03_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'QC01'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'QC01'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'QC01'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'QC01'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'QC01'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'QC01';
*/
--------------------------------------------------------------------------
