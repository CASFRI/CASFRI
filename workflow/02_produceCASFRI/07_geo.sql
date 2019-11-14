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
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the tables by appending all translated 
-- table to the same big table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all GEO tables into a common table
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_geo', '_ab06_geo');
SELECT TT_Prepare('translation', 'ab16_avi01_geo', '_ab16_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'nb01_nbi01_geo', '_nb01_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'bc08_vri01_geo', '_bc08_geo', 'ab06_avi01_geo');
------------------------
DROP TABLE IF EXISTS casfri50.geo_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.geo_all AS -- 54s
SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_geo');
------------------------
INSERT INTO casfri50.geo_all -- 7m30s
SELECT * FROM TT_Translate_ab16_geo('rawfri', 'ab16', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_geo');
------------------------
INSERT INTO casfri50.geo_all -- 48m52s
SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_geo');
------------------------
-- Reuse TT_Translate_nb01_geo() for NB02
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb02', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_geo');
------------------------
INSERT INTO casfri50.geo_all --4h59m
SELECT * FROM TT_Translate_bc08_geo('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_geo');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.geo_all; 

SELECT count(*) FROM casfri50.geo_all; -- 6860441
SELECT count(*) FROM casfri50.geo_all WHERE geometry = '010300000000000000'; -- 0

-- Add primary and foreign key constraints
ALTER TABLE casfri50.geo_all ADD PRIMARY KEY (cas_id);

ALTER TABLE casfri50.geo_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
------------------------