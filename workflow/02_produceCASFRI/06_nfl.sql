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
-- Translate all NFL tables into a common table. 33h32m
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab_nfl'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb_nfl', 'ab_avi01_nfl'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc_nfl', 'ab_avi01_nfl'); -- used for both BC08 and BC10
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt_nfl', 'ab_avi01_nfl'); -- used for both NT01 and NT02, layer 1 and 2
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_nfl', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50.nfl_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 'NFL');

CREATE TABLE casfri50.nfl_all AS -- 2m24s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l1_to_ab_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl');
------------------------
-- Translate AB06 layer 2 reusing AB06 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 'NFL');

INSERT INTO casfri50.nfl_all -- 2m1s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l2_to_ab_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl');
------------------------

-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 'NFL');

INSERT INTO casfri50.nfl_all -- 23m43s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab16_l1_to_ab_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl');
------------------------
-- Translate AB16 layer 2 reusing AB16 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab16_l2_to_ab_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl');
------------------------

-- Translate NB01
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 'NFL');

INSERT INTO casfri50.nfl_all -- 1h4m
SELECT * FROM TT_Translate_nb_nfl('rawfri', 'nb01_l1_to_nb_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_nfl');
------------------------

-- Translate NB02 using NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nb_nfl('rawfri', 'nb02_l1_to_nb_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_nfl');
------------------------

-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 'NFL');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l1_to_bc_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl');
------------------------

-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 'NFL');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l1_to_bc_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl');
------------------------

-- Translate NT01 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 'NFL'); 

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01_l1_to_nt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');
------------------------
-- Translate NT01 layer 2 using NT layer 1 generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01_l2_to_nt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');
------------------------

-- Translate NT02 reusing NT translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_l1_to_nt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');
------------------------
-- Translate NT02 layer 2 reusing NT01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_l2_to_nt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl');
------------------------

-- Translate ON02 using FIM translation table
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_on_nfl('rawfri', 'on02_l1_to_on_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_nfl');
------------------------

-- Translate SK01 using UTM translation table
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_nfl('rawfri', 'sk01_l1_to_sk_utm_l1_map_nfl', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_nfl');
------------------------

-- Translate YT02 using YVI translation table
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 'NFL');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt_nfl('rawfri', 'yt02_l1_to_yt_l1_map_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_nfl');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.nfl_all
GROUP BY left(cas_id, 4);
--inv   nb
--AB06	3515
--AB16	26858
--BC08	4669156
--BC10	5141801
--NB01	87371
--NB02	141747
--NT01	312384
--NT02	480283
--ON02	3629071
--SK01	574487
--YT02	169016

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.nfl_all
GROUP BY left(cas_id, 4), layer;
-- inv lyr nb
--AB06	1	2081
--AB06	2	1434
--AB16	1	15434
--AB16	2	11424
--BC08	1	558779
--BC08	2	4110377
--BC10	1	574975
--BC10	2	4392244
--BC10	3	174582
--NB01	1	87371
--NB02	1	141747
--NT01	1	43765
--NT01	2	229699
--NT01	3	29682
--NT01	4	9238
--NT02	1	53674
--NT02	2	195061
--NT02	3	146864
--NT02	4	84684
--ON02	1	1562183
--ON02	2	1892961
--ON02	3	173927
--SK01	1	574481
--SK01	2	6
--YT02	1	169016

SELECT count(*) FROM casfri50.nfl_all; -- 15235689
--------------------------------------------------------------------------
-- Add some indexes
CREATE INDEX nfl_all_casid_idx
ON casfri50.nfl_all USING btree(cas_id);

CREATE INDEX nfl_all_inventory_idx
ON casfri50.nfl_all USING btree(left(cas_id, 4));
    
CREATE INDEX nfl_all_province_idx
ON casfri50.nfl_all USING btree(left(cas_id, 2));
--------------------------------------------------------------------------

