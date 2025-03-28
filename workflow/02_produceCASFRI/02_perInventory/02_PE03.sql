------------------------------------------------------------------------------
-- CASFRI - PE03 translation script for CASFRI v5
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
-- Translate all PE03. XXh10m
--------------------------------------------------------------------------
-- CAS
------------------------

SELECT TT_Prepare('translation', 'pe_pei01_cas', '_pe03_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'pe03', 'pe_pei');

-- Delete existing entries
--DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'PE03';

-- Add translated ones
INSERT INTO casfri50.cas_all --
SELECT * FROM TT_Translate_pe02_cas('rawfri', 'pe03_l1_to_pe_pei_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'pe_pei01_dst', '_pe03_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'pe03', 'pe_pei');

-- Delete existing entries
--DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'PE03';

-- Add translated ones
INSERT INTO casfri50.dst_all --
SELECT * FROM TT_Translate_pe03_dst('rawfri', 'pe03_l1_to_pe_pei_l1_map');
--

------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'pe_pei01_eco', '_pe03_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'pe03', 'pe_pei');

-- Delete existing entries
--DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'PE03';

-- Add translated ones
INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pe03_eco('rawfri', 'pe03_l1_to_pe_pei_l1_map');

------------------------
-- LYR
------------------------

-- Check the uniqueness of NS species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_pe01_species_codes_idx
ON translation.species_code_mapping (pe_species_codes)
WHERE TT_NotEmpty(pe_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'pe_pei01_lyr', '_pe03_lyr', 'ab_avi01_lyr');

-- Delete existing entries
--DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'PE03';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'pe03', 1, 'pe_pei', 1);

INSERT INTO casfri50.lyr_all --
SELECT * FROM TT_Translate_pe03_lyr('rawfri', 'pe03_l1_to_pe_pei_l1_map');

------------------------
-- NFL
------------------------
BEGIN;
SELECT TT_Prepare('translation', 'pe_pei01_nfl', '_pe03_nfl', 'ab_avi01_nfl');

-- Delete existing entries
--DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'PE03';

-- Add translated NFL
SELECT TT_CreateMappingView('rawfri', 'pe03', 2, 'pe_pei', 1);

INSERT INTO casfri50.nfl_all --
SELECT * FROM TT_Translate_pe03_nfl('rawfri', 'pe03_l2_to_pe_pei_l1_map');

COMMIT;
------------------------
-- GEO
------------------------

SELECT TT_Prepare('translation', 'pe_pei01_geo', '_pe03_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'pe03', 'pe_pei');

-- Delete existing entries
--DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'PE03';

-- Add translated ones
INSERT INTO casfri50.geo_all --
SELECT * FROM TT_Translate_pe03_geo('rawfri', 'pe03_l1_to_pe_pei_l1_map');

--------------------------------------------------------------------------
-- Check

SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'PE03'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'PE03'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'PE03'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'PE03'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'PE03'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'PE03';
--------------------------------------------------------------------------
