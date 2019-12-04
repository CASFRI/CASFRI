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
-- Translate all ECO tables into a common table
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_eco', '_ab06_eco');
SELECT TT_Prepare('translation', 'ab16_avi01_eco', '_ab16_eco', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'nbi01_eco', '_nb_eco',   'ab06_avi01_eco'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'vri01_eco', '_bc_eco', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'fvi01_eco', '_nt_eco',   'ab06_avi01_eco'); -- used for both NT01 and NT02
------------------------
DROP TABLE IF EXISTS casfri50.eco_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ECO'); -- only rows with eco attributes

CREATE TABLE casfri50.eco_all AS -- 36s
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06_min_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_eco');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ECO'); -- only rows with eco attributes

INSERT INTO casfri50.eco_all -- 6m2s
SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16_min_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_eco');
------------------------
-- Translate NB01
SELECT TT_CreateMappingView('rawfri', 'nb01', 'ECO'); -- only rows with eco attributes

INSERT INTO casfri50.eco_all -- 1h27m
SELECT * FROM TT_Translate_nb_eco('rawfri', 'nb01_min_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_eco');
------------------------
-- Translate NB02 using NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb01', 'ECO'); -- only rows with eco attributes

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nb_eco('rawfri', 'nb02_l1_to_nb01_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi02_eco');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'ECO'); -- only rows with eco attributes

INSERT INTO casfri50.eco_all -- 4h05m
SELECT * FROM TT_Translate_bc_eco('rawfri', 'bc08_min_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_eco');
------------------------
-- Translate TN01 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 'ECO'); -- only rows with eco attributes

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt01_l1_to_nt_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_eco');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 'ECO');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt02_l1_to_nt_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_eco');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.eco_all;

SELECT count(*) FROM casfri50.eco_all; -- 6860441

-- Add primary and foreign key constraints
ALTER TABLE casfri50.eco_all ADD PRIMARY KEY (cas_id);

ALTER TABLE casfri50.eco_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
--------------------------------------------------------------------------
