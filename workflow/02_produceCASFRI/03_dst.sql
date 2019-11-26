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
SELECT TT_Prepare('translation', 'ab06_avi01_dst', '_ab06_dst');
SELECT TT_Prepare('translation', 'ab16_avi01_dst', '_ab16_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nbi01_dst', '_nb_dst', 'ab06_avi01_dst'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'vri01_dst', '_bc_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'fvi01_dst', '_nt_dst',   'ab06_avi01_dst'); -- used for both NT01 and NT02
------------------------
DROP TABLE IF EXISTS casfri50.dst_all CASCADE;
------------------------
-- Translate AB06
CREATE TABLE casfri50.dst_all AS -- 2m12s
SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_dst');
------------------------
-- Translate AB16
INSERT INTO casfri50.dst_all -- 24m46s
SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_dst');
------------------------
-- Translate NB01
SELECT TT_CreateMappingView('rawfri', 'nb01'); -- needed to assign layer and layer_rank

INSERT INTO casfri50.dst_all -- 1h32m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb01_min', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_dst');
------------------------
-- Translate NB01 layer 2 reusing NB01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb01', 1);

INSERT INTO casfri50.dst_all -- 1h11m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb01_l2_to_nb01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_dst');
------------------------
-- Translate NB02 reusing NB01 translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb01');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb02_l1_to_nb01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nbi01_dst');
------------------------
-- Translate BC08
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc_dst('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'vri01_dst');
------------------------
-- Translate NT01
SELECT TT_CreateMappingView('rawfri', 'nt01'); -- needed to assign layer and layer_rank

INSERT INTO casfri50.dst_all -- 36m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt01_min', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_dst');
------------------------
-- Translate NT02 reusing NT01 translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt01');

INSERT INTO casfri50.dst_all -- 51m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt02_l1_to_nt01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'fvi01_dst');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.dst_all;

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.dst_all
GROUP BY left(cas_id, 4), layer;

SELECT count(*) FROM casfri50.dst_all; -- 7787618

-- Add primary and foreign key constraints
ALTER TABLE casfri50.dst_all 
ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.dst_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
--------------------------------------------------------------------------
