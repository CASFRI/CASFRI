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

CREATE SCHEMA IF NOT EXISTS casfri50;

-------------------------------------------------------
-- Translate all GEO tables into a common table
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'avi01_geo', '_ab_geo'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nbi01_geo', '_nb_geo', 'avi01_geo'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'vri01_geo', '_bc_geo', 'avi01_geo'); -- used for both BC08 and BC10
SELECT TT_Prepare('translation', 'fvi01_geo', '_nt_geo', 'avi01_geo'); -- used for both NT01 and NT02
SELECT TT_Prepare('translation', 'fim02_geo', '_on_geo', 'avi01_geo'); 
SELECT TT_Prepare('translation', 'sk_utm01_geo', '_sk_geo', 'avi01_geo'); 
SELECT TT_Prepare('translation', 'yt_yvi01_geo', '_yt_geo', 'avi01_geo'); 
------------------------
DROP TABLE IF EXISTS casfri50.geo_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

CREATE TABLE casfri50.geo_all AS -- 54s
SELECT * FROM TT_Translate_ab_geo('rawfri', 'ab06_l1_to_ab_l1_map', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'avi01_geo');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab');

INSERT INTO casfri50.geo_all -- 7m30s
SELECT * FROM TT_Translate_ab_geo('rawfri', 'ab16_l1_to_ab_l1_map', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'avi01_geo');
------------------------
-- Translate NB01 using the NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb');

INSERT INTO casfri50.geo_all -- 48m52s
SELECT * FROM TT_Translate_nb_geo('rawfri', 'nb01_l1_to_nb_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_geo');
------------------------
-- Translate NB02 using the NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb');

INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_nb_geo('rawfri', 'nb02_l1_to_nb_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_geo');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc');

INSERT INTO casfri50.geo_all --4h59m
SELECT * FROM TT_Translate_bc_geo('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_geo');
------------------------
-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc');

INSERT INTO casfri50.geo_all --*h**m
SELECT * FROM TT_Translate_bc_geo('rawfri', 'bc10_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_geo');
------------------------
-- Translate NT01 using the NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt');

INSERT INTO casfri50.geo_all -- 20m
SELECT * FROM TT_Translate_nt_geo('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_geo');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

INSERT INTO casfri50.geo_all -- 22m
SELECT * FROM TT_Translate_nt_geo('rawfri', 'nt02_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_geo');
------------------------
-- Translate ON02 using ON generic translation table
SELECT TT_CreateMappingView('rawfri', 'on02', 'on');

INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_on_geo('rawfri', 'on02_l1_to_on_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fim02_geo');
------------------------
-- Translate SK01 using UTM translation table
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk');

INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_sk_geo('rawfri', 'sk01_l1_to_sk_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_geo');
------------------------
-- Translate YT02 using YVI translation table
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt');

INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_yt_geo('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_geo');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.geo_all
GROUP BY left(cas_id, 4);

SELECT count(*) FROM casfri50.geo_all; -- 7462773
SELECT count(*) FROM casfri50.geo_all WHERE geometry = '010300000000000000'; -- 0

-- Add primary key constraint
ALTER TABLE casfri50.geo_all ADD PRIMARY KEY (cas_id);

-- Set the geometry type to be able to display in some GIS
ALTER TABLE casfri50.geo_all
ALTER COLUMN geometry TYPE geometry(multipolygon, 900914);
--------------------------------------------------------------------------
