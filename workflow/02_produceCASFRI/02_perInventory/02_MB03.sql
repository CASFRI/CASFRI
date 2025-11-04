------------------------------------------------------------------------------
-- CASFRI - MB03 translation script for CASFRI v5
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
-- Translate all MB03. *h**m
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'mb_fri03_cas', '_mb03_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'mb03', 'mb_fri3');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'MB03';

-- Add translated ones
INSERT INTO casfri50.cas_all --
SELECT * FROM TT_Translate_mb03_cas('rawfri', 'mb03_l1_to_mb_fri3_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'mb_fri03_dst', '_mb03_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'mb03', 'mb_fri3');

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'MB03';

-- Add translated ones
INSERT INTO casfri50.dst_all --
SELECT * FROM TT_Translate_mb03_dst('rawfri', 'mb03_l1_to_mb_fri3_l1_map');


------------------------
-- ECO
------------------------
SELECT TT_Prepare('translation', 'mb_fri03_eco', '_mb03_eco', 'ab_avi01_eco');

SELECT TT_CreateMappingView('rawfri', 'mb03', 'mb_fri3');

-- Delete existing entries
-- DELETE FROM casfri50.eco_all WHERE left(cas_id, 4) = 'MB03';

-- Add translated ones
INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_mb03_eco('rawfri', 'mb03_l1_to_mb_fri3_l1_map');


------------------------
-- LYR
------------------------
-- Check the uniqueness of MB species codes
CREATE UNIQUE INDEX IF NOT EXISTS species_code_mapping_mb03_species_codes_idx
ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

-- Prepare the translation function
SELECT TT_Prepare('translation', 'mb_fri03_lyr', '_mb03_lyr', 'ab_avi01_lyr');

-- Delete existing entries
-- DELETE FROM casfri50.lyr_all WHERE left(cas_id, 4) = 'MB03';

-- Add translated ones
-- Layer 1
SELECT TT_CreateMappingView('rawfri', 'mb03', 1, 'mb_fri3', 1);

INSERT INTO casfri50.lyr_all --
SELECT * FROM TT_Translate_mb03_lyr('rawfri', 'mb03_l1_to_mb_fri3_l1_map');


------------------------
-- NFL
------------------------
SELECT TT_Prepare('translation', 'mb_fri03_nfl', '_mb03_nfl', 'ab_avi01_nfl');

-- Delete existing entries
-- DELETE FROM casfri50.nfl_all WHERE left(cas_id, 4) = 'MB03';

-- Add translated NFL
SELECT TT_CreateMappingView('rawfri', 'mb03', 2, 'mb_fri3', 1);

INSERT INTO casfri50.nfl_all --
SELECT * FROM TT_Translate_mb03_nfl('rawfri', 'mb03_l2_to_mb_fri3_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'mb_fri03_geo', '_mb03_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'mb03', 'mb_fri3');

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'MB03';

-- Add translated ones
INSERT INTO casfri50.geo_all --
SELECT * FROM TT_Translate_mb03_geo('rawfri', 'mb03_l1_to_mb_fri3_l1_map');

--------------------------------------------------------------------------
-- Check

SELECT 'cas_all', count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'MB03'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'MB03'
UNION ALL
SELECT 'eco_all', count(*) nb
FROM casfri50.eco_all
WHERE left(cas_id, 4) = 'MB03'
UNION ALL
SELECT 'lyr_all', count(*) nb
FROM casfri50.lyr_all
WHERE left(cas_id, 4) = 'MB03'
UNION ALL
SELECT 'nfl_all', count(*) nb
FROM casfri50.nfl_all
WHERE left(cas_id, 4) = 'MB03'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'MB03';

--------------------------------------------------------------------------
