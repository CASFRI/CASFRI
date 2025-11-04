------------------------------------------------------------------------------
-- CASFRI - QC09 translation script for CASFRI v5
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
-- Translate all QC09. 43h56m
--------------------------------------------------------------------------
-- add index on standstructure lookup table
CREATE UNIQUE INDEX IF NOT EXISTS qc_stand_structure_lookup_idx
ON translation.qc_standstructure_lookup (source_val);
------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'qc_ini04_cas', '_qc09_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'qc09', 'qc_ini04');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'QC09';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_qc09_cas('rawfri', 'qc09_l1_to_qc_ini04_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'qc_ini04_dst', '_qc09_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'qc09', 1, 'qc_ini04', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'QC09';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc09_dst('rawfri', 'qc09_l1_to_qc_ini04_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'qc_ini04_eco', '_qc09_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'qc09', 'qc_ini04');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'QC09';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_qc09_eco('rawfri', 'qc09_l1_to_qc_ini04_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of QC species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc04_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'qc_ini04_lyr', '_qc09_lyr', 'ab_avi01_lyr');

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'QC09';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'qc09', 1, 'qc_ini04', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc09_lyr('rawfri', 'qc09_l1_to_qc_ini04_l1_map');


-- Layer 2 using translation table
SELECT TT_CreateMappingView('rawfri', 'qc09', 2, 'qc_ini04', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc09_lyr('rawfri', 'qc09_l2_to_qc_ini04_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'qc_ini04_nfl', '_qc09_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'qc09', 3, 'qc_ini04', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'QC09';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc09_nfl('rawfri', 'qc09_l3_to_qc_ini04_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'qc_ini04_geo', '_qc09_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'qc09', 1, 'qc_ini04', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'QC09';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_qc09_geo('rawfri', 'qc09_l1_to_qc_ini04_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'QC09'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'QC09'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'QC09'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'QC09'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'QC09'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'QC09';
*/
--------------------------------------------------------------------------
