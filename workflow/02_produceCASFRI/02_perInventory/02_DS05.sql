------------------------------------------------------------------------------
-- CASFRI - DS05 translation script for CASFRI v5
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
-- Translate all DS05. XXhXXm
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ds_cfs02_cas', '_ds05_cas', 'ab_avi01_cas');

SELECT TT_CreateMappingView('rawfri', 'ds05', 'ds');

-- Delete existing edsries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'DS05';

-- Add translated ones
INSERT INTO casfri50.cas_all -- 1 hr 32 min
SELECT * FROM TT_Translate_ds05_cas('rawfri', 'ds05_l1_to_ds_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ds_cfs02_dst', '_ds05_dst', 'ab_avi01_dst');

SELECT TT_CreateMappingView('rawfri', 'ds05', 1, 'ds', 1);

-- Delete existing edsries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'DS05';

-- Add translated ones
INSERT INTO casfri50.dst_all -- 1 hr 48 min.
SELECT * FROM TT_Translate_ds05_dst('rawfri', 'ds05_l1_to_ds_l1_map');

------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ds_cfs02_geo', '_ds05_geo', 'ab_avi01_geo');

SELECT TT_CreateMappingView('rawfri', 'ds05', 1, 'ds', 1);

-- Delete existing edsries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'DS05';

-- Add translated ones
INSERT INTO casfri50.geo_all -- 1 hr 44 min.
SELECT * FROM TT_Translate_ds05_geo('rawfri', 'ds05_l1_to_ds_l1_map');

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'DS05'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'DS05'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'DS05';
*/
--------------------------------------------------------------------------
