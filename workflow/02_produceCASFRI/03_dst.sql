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
-- Translate all DST tables into a common table
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'avi01_dst', '_ab_dst'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nbi01_dst', '_nb_dst', 'avi01_dst'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'vri01_dst', '_bc_dst', 'avi01_dst');
SELECT TT_Prepare('translation', 'fvi01_dst', '_nt_dst', 'avi01_dst'); -- used for both NT01 and NT02
------------------------
DROP TABLE IF EXISTS casfri50.dst_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 'DST'); -- Only rows with a disturbance

CREATE TABLE casfri50.dst_all AS -- 26s
SELECT * FROM TT_Translate_ab_dst('rawfri', 'ab06_l1_to_ab_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'avi01_dst');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 'DST'); -- Only rows with a disturbance

INSERT INTO casfri50.dst_all -- 1m50s
SELECT * FROM TT_Translate_ab_dst('rawfri', 'ab16_l1_to_ab_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'avi01_dst');
------------------------
-- Translate NB01 using NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 'DST'); -- Only rows with a disturbance

INSERT INTO casfri50.dst_all -- 38m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb01_l1_to_nb_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_dst');
------------------------
-- Translate NB01 layer 2 using NB layer 1 generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 'DST'); 

INSERT INTO casfri50.dst_all -- 44m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb01_l2_to_nb_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_dst');
------------------------
-- Translate NB02 using NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 'DST');

INSERT INTO casfri50.dst_all -- 34m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb02_l1_to_nb_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_dst');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 'DST');

INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc_dst('rawfri', 'bc08_l1_to_bc_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_dst');
------------------------
-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 'DST');

INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc_dst('rawfri', 'bc10_l1_to_bc_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_dst');
------------------------
-- Translate NT01 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 'DST');

INSERT INTO casfri50.dst_all -- 36m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt01_l1_to_nt_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_dst');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 'DST');

INSERT INTO casfri50.dst_all -- 51m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt02_l1_to_nt_l1_map_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_dst');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.dst_all
GROUP BY left(cas_id, 4);

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.dst_all
GROUP BY left(cas_id, 4), layer;

SELECT count(*) FROM casfri50.dst_all; -- 2432342

-- Add primary key constraint
ALTER TABLE casfri50.dst_all 
ADD PRIMARY KEY (cas_id, layer);
--------------------------------------------------------------------------