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
SELECT TT_Prepare('translation', 'ab_avi01_eco', '_ab_eco'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nb_nbi01_eco', '_nb_eco', 'ab_avi01_eco'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'bc_vri01_eco', '_bc_eco', 'ab_avi01_eco'); -- used for both BC08 and BC10
SELECT TT_Prepare('translation', 'nt_fvi01_eco', '_nt_eco', 'ab_avi01_eco'); -- used for both NT01 and NT02
SELECT TT_Prepare('translation', 'on_fim02_eco', '_on_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_eco', 'ab_avi01_eco');

------------------------
DROP TABLE IF EXISTS casfri50.eco_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab');

CREATE TABLE casfri50.eco_all AS -- 36s
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab06_l1_to_ab_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab');


INSERT INTO casfri50.eco_all -- 6m2s
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab16_l1_to_ab_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco');
------------------------
-- Translate NB01
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb');

INSERT INTO casfri50.eco_all -- 1h27m
SELECT * FROM TT_Translate_nb_eco('rawfri', 'nb01_l1_to_nb_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_eco');
------------------------
-- Translate NB02 using NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nb_eco('rawfri', 'nb02_l1_to_nb_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi02_eco');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc');

INSERT INTO casfri50.eco_all -- 4h05m
SELECT * FROM TT_Translate_bc_eco('rawfri', 'bc08_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_eco');
------------------------
-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc');

INSERT INTO casfri50.eco_all -- *h**m
SELECT * FROM TT_Translate_bc_eco('rawfri', 'bc10_l1_to_bc_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_eco');
------------------------
-- Translate NT01 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt01_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt02_l1_to_nt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco');
------------------------
-- Translate ON02 using ON translation table
SELECT TT_CreateMappingView('rawfri', 'on02', 'on');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_on_eco('rawfri', 'on02_l1_to_on_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_eco');
------------------------
-- Translate SK01 using SK translation table
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_eco('rawfri', 'sk01_l1_to_sk_utm_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_eco');
------------------------
-- Translate YT02 using YT translation table
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_yt_eco('rawfri', 'yt02_l1_to_yt_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_eco');

--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.eco_all
GROUP BY left(cas_id, 4);
--inv   count
--NB01	72978
--NB02	111135

SELECT count(*) FROM casfri50.eco_all; -- 184113
--------------------------------------------------------------------------
-- Add some indexes
CREATE INDEX eco_all_casid_idx
ON casfri50.eco_all USING btree(cas_id);

CREATE INDEX eco_all_inventory_idx
ON casfri50.eco_all USING btree(left(cas_id, 4));
    
CREATE INDEX eco_all_province_idx
ON casfri50.eco_all USING btree(left(cas_id, 2));
--------------------------------------------------------------------------
