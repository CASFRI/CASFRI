------------------------------------------------------------------------------
-- CASFRI - AB30 translation script for CASFRI v5
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
-- Translate all AB30. 3m
-- This is post inventory cutblock file. It only contains disturbances data
-- We use the aquisition year as photo_year for use in the temporalisation
-- process. See issue #473
-- Only translate the GEO, CAS and DST tables
--------------------------------------------------------------------------
-- CAS
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab30_cas'); 

SELECT TT_CreateMappingView('rawfri', 'ab30', 'ab');

-- Delete existing entries
-- DELETE FROM casfri50.cas_all WHERE left(cas_id, 4) = 'AB30';

-- Add translated ones
INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_ab30_cas('rawfri', 'ab30_l1_to_ab_l1_map');


------------------------
-- DST
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab30_dst');

SELECT TT_CreateMappingView('rawfri', 'ab30', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.dst_all WHERE left(cas_id, 4) = 'AB30';

-- Add translated ones
INSERT INTO casfri50.dst_all
SELECT * FROM TT_Translate_ab30_dst('rawfri', 'ab30_l1_to_ab_l1_map');


------------------------
-- GEO
------------------------
SELECT TT_Prepare('translation', 'ab_avi01_geo', '_ab30_geo'); 

SELECT TT_CreateMappingView('rawfri', 'ab30', 1, 'ab', 1);

-- Delete existing entries
-- DELETE FROM casfri50.geo_all WHERE left(cas_id, 4) = 'AB30';

-- Add translated ones
INSERT INTO casfri50.geo_all
SELECT * FROM TT_Translate_ab30_geo('rawfri', 'ab30_l1_to_ab_l1_map'); 

--------------------------------------------------------------------------
-- Check
/*
SELECT 'cas_all' AS table, count(*) nb
FROM casfri50.cas_all
WHERE left(cas_id, 4) = 'AB30'
UNION ALL
SELECT 'dst_all', count(*) nb
FROM casfri50.dst_all
WHERE left(cas_id, 4) = 'AB30'
UNION ALL
SELECT 'geo_all', count(*) nb
FROM casfri50.geo_all
WHERE left(cas_id, 4) = 'AB30';
*/
--------------------------------------------------------------------------
