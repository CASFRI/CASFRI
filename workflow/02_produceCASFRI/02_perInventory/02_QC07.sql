------------------------------------------------------------------------------
-- CASFRI - QC07 translation script for CASFRI v5
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
-- Translate all QC07. 117h
--------------------------------------------------------------------------
-- add index on standstructure lookup table
CREATE UNIQUE INDEX IF NOT EXISTS qc_stand_structure_lookup_idx
ON translation.qc_standstructure_lookup (source_val);
------------------------
-- CAS
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'qc_ipf05_cas', '_qc07_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'qc07', 'qc_ipf');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'QC07';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_qc07_cas('rawfri', 'qc07_l1_to_qc_ipf_l1_map');

COMMIT;

------------------------
-- DST
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'qc_ipf05_dst', '_qc07_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'QC07';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc07_dst('rawfri', 'qc07_l1_to_qc_ipf_l1_map');

COMMIT;

------------------------
-- ECO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'qc_ipf05_eco', '_qc07_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'qc07', 'qc_ipf');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'QC07';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_qc07_eco('rawfri', 'qc07_l1_to_qc_ipf_l1_map');

COMMIT;

------------------------
-- LYR
------------------------
-- Check the uniqueness of QC species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc07_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

BEGIN;
-- Prepare the translation function
SELECT TT_Prepare('translation', 'qc_ipf05_lyr', '_qc07_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'QC07';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc07_lyr('rawfri', 'qc07_l1_to_qc_ipf_l1_map');


-- Layer 2 using translation table
SELECT TT_CreateMappingView('rawfri', 'qc07', 2, 'qc_ipf', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc07_lyr('rawfri', 'qc07_l2_to_qc_ipf_l1_map');

COMMIT;

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'qc_ipf05_nfl', '_qc07_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'qc07', 3, 'qc_ipf', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'QC07';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc07_nfl('rawfri', 'qc07_l3_to_qc_ipf_l1_map'); 

COMMIT;

------------------------
-- GEO
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'qc_ipf05_geo', '_qc07_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'qc07', 1, 'qc_ipf', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'QC07';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_qc07_geo('rawfri', 'qc07_l1_to_qc_ipf_l1_map');

COMMIT;

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'QC07'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'QC07'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'QC07'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'QC07'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'QC07'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'QC07';
*/
--------------------------------------------------------------------------
