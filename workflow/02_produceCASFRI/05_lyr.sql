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
-- Validate all species lookup tables
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_species_validation', '_ab_species_val');
SELECT TT_Prepare('translation', 'bc_vri01_species_validation', '_bc_species_val');
SELECT TT_Prepare('translation', 'nb_nbi01_species_validation', '_nb_species_val');
SELECT TT_Prepare('translation', 'nt_fvi01_species_validation', '_nt_species_val');
SELECT TT_Prepare('translation', 'on_fim02_species_validation', '_on_species_val');
SELECT TT_Prepare('translation', 'sk_utm01_species_validation', '_sk_species_val');
SELECT TT_Prepare('translation', 'yt_yvi01_species_validation', '_yt_species_val');

SELECT * FROM TT_Translate_ab_species_val('translation', 'ab_avi01_species');
SELECT * FROM TT_Translate_bc_species_val('translation', 'bc_vri01_species');
SELECT * FROM TT_Translate_nb_species_val('translation', 'nb_nbi01_species');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_fvi01_species');
SELECT * FROM TT_Translate_on_species_val('translation', 'on_fim02_species');
SELECT * FROM TT_Translate_sk_species_val('translation', 'sk_utm01_species');
SELECT * FROM TT_Translate_yt_species_val('translation', 'yt_yvi01_species');

-------------------------------------------------------
-- Translate all LYR tables into a common table. 32h
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_lyr', '_ab_lyr'); -- used for both AB16 and NB02AB06 layer 1 and 2
SELECT TT_Prepare('translation', 'nb_nbi01_lyr', '_nb_lyr', 'ab_avi01_lyr'); -- used for both NB01 and NB02, layer 1 and 2
SELECT TT_Prepare('translation', 'bc_vri01_lyr', '_bc_lyr', 'ab_avi01_lyr'); -- used for both BC08 and BC10, layer 1 and 2
SELECT TT_Prepare('translation', 'nt_fvi01_lyr', '_nt_lyr', 'ab_avi01_lyr'); -- used for both NT01 and NT02, layer 1 and 2
SELECT TT_Prepare('translation', 'on_fim02_lyr', '_on_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'sk_utm01_lyr', '_sk_lyr', 'ab_avi01_lyr'); 
SELECT TT_Prepare('translation', 'yt_yvi01_lyr', '_yt_lyr', 'ab_avi01_lyr'); 
-------------------------
DROP TABLE IF EXISTS casfri50.lyr_all CASCADE;
------------------------
-- Translate AB06 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', 'LYR'); -- only rows with LYR attributes

CREATE TABLE casfri50.lyr_all AS -- 4m41s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l1_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr');
------------------------
-- Translate AB06 layer 2 reusing AB06 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 2, 'ab', 1, 'LYR'); -- only rows with LYR attributes

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab06_l2_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr');
------------------------
-- Translate AB16 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', 'LYR'); -- only rows with LYR attributes

INSERT INTO casfri50.lyr_all -- 46m20s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab16_l1_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr');
------------------------
-- Translate AB16 layer 2 reusing AB16 layer 1 translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 2, 'ab', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 3m56s
SELECT * FROM TT_Translate_ab_lyr('rawfri', 'ab16_l2_to_ab_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_lyr');
------------------------
-- Translate NB01 using NB generic translation table and only rows with LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', 'LYR');

INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l1_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr');
------------------------
-- Translate NB01 layer 2 using NB layer 1 generic translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01_l2_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr');
------------------------
-- Translate NB02 using NB generic translation table and only rows having LYR attributes
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l1_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr');
------------------------
-- Translate NB02 layer 2 reusing NB01 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 2, 'nb', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_l2_to_nb_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_lyr');
------------------------
-- Translate BC08
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', 'LYR');

INSERT INTO casfri50.lyr_all -- 30h19m
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc08_l1_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr');
------------------------
-- Translate BC10 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', 'LYR'); -- only rows with LYR attributes

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc10_l1_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr');
------------------------
-- Translate BC10 layer 2 reusing BC10 layer 1 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 2, 'bc', 1, 'LYR'); -- only rows with LYR attributes

INSERT INTO casfri50.lyr_all -- *m**s
SELECT * FROM TT_Translate_bc_lyr('rawfri', 'bc10_l2_to_bc_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_lyr');
------------------------
-- Translate NT01 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', 'LYR');

INSERT INTO casfri50.lyr_all -- 1h49m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l1_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');
------------------------
-- Translate NT01 layer 2 using NT layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 2, 'nt', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 1h24m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01_l2_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');
------------------------
-- Translate NT02 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 'LYR');

INSERT INTO casfri50.lyr_all -- 1h45m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l1_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');
------------------------
-- Translate NT02 layer 2 using NT layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 1h34m
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_l2_to_nt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_lyr');
------------------------
-- Translate ON02 using ON translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l1_to_on_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_lyr');
------------------------
-- Translate ON02 layer 2 using ON translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_on_lyr('rawfri', 'on02_l2_to_on_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_lyr');
------------------------
-- Translate SK01 using UTM translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk', 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_lyr('rawfri', 'sk01_l1_to_sk_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_lyr');
------------------------
-- Translate SK01 layer 2 using UTM translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk', 1, 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_sk_lyr('rawfri', 'sk01_l2_to_sk_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_lyr');
------------------------
-- Translate YT02 using YVI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', 'LYR');

INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_yt_lyr('rawfri', 'yt02_l1_to_yt_l1_map_lyr', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_lyr');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4);

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer;

SELECT count(*) FROM casfri50.lyr_all; -- 6754426

-- Add primary key constraint
ALTER TABLE casfri50.lyr_all ADD PRIMARY KEY (cas_id, layer);
--------------------------------------------------------------------------
