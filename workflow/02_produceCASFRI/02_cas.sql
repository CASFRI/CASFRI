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

--------------------------------------------------------------------------
-- Translate all CAS tables into a common table
--------------------------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'avi01_cas', '_ab_cas'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nbi01_cas', '_nb_cas', 'avi01_cas'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'vri01_cas', '_bc_cas', 'avi01_cas'); 
SELECT TT_Prepare('translation', 'fvi01_cas', '_nt_cas', 'avi01_cas'); -- used for both NT01 and NT02
------------------------
DROP TABLE IF EXISTS casfri50.cas_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

CREATE TABLE casfri50.cas_all AS -- 3m40s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab06_l1_to_ab_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'avi01_cas');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab');

INSERT INTO casfri50.cas_all -- 37m35s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab16_l1_to_ab_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'avi01_cas');
------------------------
-- Translate NB01 using the NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb');

INSERT INTO casfri50.cas_all -- 2h45m
SELECT * FROM TT_Translate_nb_cas('rawfri', 'nb01_l1_to_nb_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_cas');
------------------------
-- Translate NB02 using the NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_nb_cas('rawfri', 'nb02_l1_to_nb_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_cas');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc');

INSERT INTO casfri50.cas_all -- 12h16m
SELECT * FROM TT_Translate_bc_cas('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_cas');
------------------------
-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc');

INSERT INTO casfri50.cas_all -- **h**m
SELECT * FROM TT_Translate_bc_cas('rawfri', 'bc10_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_cas');
------------------------
-- Translate NT01 using the NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt');

INSERT INTO casfri50.cas_all -- 43m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_cas');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt02_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_cas');
------------------------
-- Translate ON02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'on02', 'on');

INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'on02_l1_to_on_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fim02_cas');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);

SELECT count(*) FROM casfri50.cas_all; -- 7462773

-- Add primary key constraint
ALTER TABLE casfri50.cas_all 
ADD PRIMARY KEY (cas_id);
--------------------------------------------------------------------------
