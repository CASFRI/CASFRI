------------------------------------------------------------------------------
-- CASFRI - QC08 translation script for CASFRI v5
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
-- Translate all QC08. XXhXXm
--------------------------------------------------------------------------
-- add index on standstructure lookup table
CREATE UNIQUE INDEX IF NOT EXISTS qc_stand_structure_lookup_idx
ON translation.qc_standstructure_lookup (source_val);
------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_cas', '_qc08_cas', 'ab_avi01_cas'); 

SELECT TT_CreateMappingView('rawfri', 'qc08', 'qc_ini03');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'QC08';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_qc08_cas('rawfri', 'qc08_l1_to_qc_ini03_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_dst', '_qc08_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'qc08', 1, 'qc_ini03', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'QC08';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc08_dst('rawfri', 'qc08_l1_to_qc_ini03_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_eco', '_qc08_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'qc08', 'qc_ini03');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'QC08';

-- Add translated ones
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_qc08_eco('rawfri', 'qc08_l1_to_qc_ini03_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of QC species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_qc03_species_codes_idx
ON translation.species_code_mapping (qc_species_codes)
WHERE TT_NotEmpty(qc_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'qc_ini03_lyr', '_qc08_lyr', 'ab_avi01_lyr'); 

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'QC08';

-- Add translated ones
-- Layer 1

SELECT TT_CreateMappingView('rawfri', 'qc08', 1, 'qc_ini03', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc08_lyr('rawfri', 'qc08_l1_to_qc_ini03_l1_map');


-- Layer 2 using translation table
SELECT TT_CreateMappingView('rawfri', 'qc08', 2, 'qc_ini03', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_qc08_lyr('rawfri', 'qc08_l2_to_qc_ini03_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_nfl', '_qc08_nfl', 'ab_avi01_nfl');

SELECT TT_CreateMappingView('rawfri', 'qc08', 3, 'qc_ini03', 1);

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'QC08';

-- Add translated ones
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc08_nfl('rawfri', 'qc08_l3_to_qc_ini03_l1_map'); 


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'qc_ini03_geo', '_qc08_geo', 'ab_avi01_geo'); 

SELECT TT_CreateMappingView('rawfri', 'qc08', 1, 'qc_ini03', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'QC08';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_qc08_geo('rawfri', 'qc08_l1_to_qc_ini03_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'QC08'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'QC08'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'QC08'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'QC08'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'QC08'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'QC08';
*/
--------------------------------------------------------------------------
