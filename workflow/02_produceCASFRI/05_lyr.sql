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
-- Translate all LYR tables into a common table
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb_lyr',   'ab06_avi01_lyr'); -- reused for both NB01 and NB02, layer 1 and 2
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nt01_fvi01_lyr', '_nt_lyr',   'ab06_avi01_lyr'); -- reused for both NT01 and NT02, layer 1 and 2
-------------------------
DROP TABLE IF EXISTS casfri50.lyr_all CASCADE;
------------------------
-- Translate AB06
CREATE TABLE casfri50.lyr_all AS -- 4m41s
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_lyr');
------------------------
-- Translate AB16
INSERT INTO casfri50.lyr_all -- 46m20s
SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_lyr');
------------------------
-- Translate NB01
SELECT TT_CreateMappingView('rawfri', 'nb01'); -- needed to assign layer and layer_rank

INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_min', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
-- Translate NB01 layer 2 reusing NB01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb01', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l2_to_nb01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr_layer2');
------------------------
-- Translate NB02 reusing NB01 translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb01');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l1_to_nb01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
-- Translate NB02 layer 2 reusing NB01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb01', 1);

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l2_to_nb01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
-- Translate BC08
INSERT INTO casfri50.lyr_all -- 30h19m
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_lyr');
------------------------
-- Translate NT01
SELECT TT_CreateMappingView('rawfri', 'nt01'); -- needed to assign layer and layer_rank

INSERT INTO casfri50.lyr_all -- 1h49m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_min', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr');
------------------------
-- Translate NT01 layer 2 reusing NT01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt01', 1);

INSERT INTO casfri50.lyr_all -- 1h24m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l2_to_nt01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr');
------------------------
-- Translate NT02 reusing NT01 translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt01');

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l1_to_nt01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr');
------------------------
-- Translate NT02 layer 2 reusing NT01 layer 1 translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt01', 1);

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l2_to_nt01_l1_map', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.lyr_all;

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer;

SELECT count(*) FROM casfri50.lyr_all; -- 8911511

-- Add primary and foreign key constraints
ALTER TABLE casfri50.lyr_all ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.lyr_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
--------------------------------------------------------------------------
