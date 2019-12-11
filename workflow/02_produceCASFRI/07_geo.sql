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
SELECT TT_Prepare('translation', 'ab06_avi01_geo', '_ab06_geo');
SELECT TT_Prepare('translation', 'ab16_avi01_geo', '_ab16_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'nbi01_geo', '_nb_geo',   'ab06_avi01_geo'); -- reused for both NB01 and NB02
SELECT TT_Prepare('translation', 'vri01_geo', '_bc_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'fvi01_geo', '_nt_geo',   'ab06_avi01_geo'); -- reused for both NT01 and NT02
------------------------
DROP TABLE IF EXISTS casfri50.geo_all CASCADE;
------------------------
-- Translate AB06
CREATE TABLE casfri50.geo_all AS -- 54s
SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_geo');
------------------------
-- Translate AB16
INSERT INTO casfri50.geo_all -- 7m30s
SELECT * FROM TT_Translate_ab16_geo('rawfri', 'ab16', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_geo');
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
INSERT INTO casfri50.geo_all --4h59m
SELECT * FROM TT_Translate_bc_geo('rawfri', 'bc08', 'ogc_fid');

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
