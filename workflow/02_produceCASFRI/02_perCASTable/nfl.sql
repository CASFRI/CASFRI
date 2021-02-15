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
-- Create index for qc stand structure
--------------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS qc_stand_structure_lookup_idx
ON translation.qc_standstructure_lookup (source_val)

-------------------------------------------------------
-- Translate all NFL tables into a common table. 33h32m
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_nfl', '_ab_nfl');
SELECT TT_Prepare('translation', 'nb_nbi01_nfl', '_nb_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'bc_vri01_nfl', '_bc_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'nt_fvi01_nfl', '_nt_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'on_fim02_nfl', '_on_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_utm_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk_sfv_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'ns_nsi01_nfl', '_ns_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pe_pei01_nfl', '_pe_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'mb_fri01_nfl', '_mb_fri_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'mb_fli01_nfl', '_mb_fli_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'nl_nli01_nfl', '_nl_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ini03_nfl', '_qc03_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ini04_nfl', '_qc04_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ipf05_nfl', '_qc05_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pc_panp01_nfl', '_pc01_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pc_wbnp01_nfl', '_pc02_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ini03_nfl', '_qc02_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ini04_nfl', '_qc06_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'qc_ipf05_nfl', '_qc07_nfl', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50.nfl_all CASCADE;
------------------------
-- Translate AB03 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab03', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab03_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab03_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB03 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab03', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab03_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab03_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB06 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS -- 2m24s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab06_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB06 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 2m1s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab06_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB07 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab07', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab07_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab07_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB07 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab07', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab07_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab07_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB08 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab08', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab08_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab08_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB08 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab08', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab08_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab08_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB10 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab10', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab10_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab10_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB10 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab10', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab10_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab10_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB11 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab11', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab11_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab11_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB11 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab11', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab11_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab11_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB16 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 3, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 23m43s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab16_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab16_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB16 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab16_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab16_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB25 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab25', 3, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab25_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab25_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB25 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab25', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab25_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab25_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB29 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab29', 3, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab29_l3_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab29_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB29 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab29', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab29_l4_to_ab_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab29_l4_to_ab_l1_map_nfl');
------------------------
-- Translate NB01 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 1h4m
SELECT * FROM TT_Translate_nb_nfl('rawfri', 'nb01_l3_to_nb_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_nfl', 'nb01_l3_to_nb_l1_map_nfl');
------------------------
-- Translate NB02 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 3, 'nb', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nb_nfl('rawfri', 'nb02_l3_to_nb_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_nfl', 'nb02_l3_to_nb_l1_map_nfl');
------------------------
-- Translate BC08 NFL layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l3_to_bc_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc08_l3_to_bc_l1_map_nfl');
------------------------
-- Translate BC08 layer NFL 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l4_to_bc_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc08_l4_to_bc_l1_map_nfl');
------------------------
-- Translate BC08 layer NFL 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 5, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l5_to_bc_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc08_l5_to_bc_l1_map_nfl');
------------------------
-- Translate BC10 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l3_to_bc_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc10_l3_to_bc_l1_map_nfl');
------------------------
-- Translate BC10 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l4_to_bc_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc10_l4_to_bc_l1_map_nfl');
------------------------
-- Translate BC10 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l5_to_bc_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc10_l5_to_bc_l1_map_nfl');
------------------------
-- Translate NT01 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1, NULL, 'nfl'); 

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01_l3_to_nt_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt01_l3_to_nt_l1_map_nfl');
------------------------
-- Translate NT01 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01_l4_to_nt_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt01_l4_to_nt_l1_map_nfl');
------------------------
-- Translate NT03 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt03', 3, 'nt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt03_l3_to_nt_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt03_l3_to_nt_l1_map_nfl');
------------------------
-- Translate NT03 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt03', 4, 'nt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt03_l4_to_nt_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt03_l4_to_nt_l1_map_nfl');
------------------------
-- Translate ON02 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 3, 'on', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_on_nfl('rawfri', 'on02_l3_to_on_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_nfl', 'on02_l3_to_on_l1_map_nfl');
------------------------
-- Translate SK01 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_utm_nfl('rawfri', 'sk01_l3_to_sk_utm_l1_map_nfl'); 
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_nfl', 'sk01_l3_to_sk_utm_l1_map_nfl');
------------------------
-- Translate SK02 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk02_l4_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK02 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk02_l5_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK02 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk02_l6_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK03 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk03_l4_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk03_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK03 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk03_l5_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk03_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK03 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk03_l6_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk03_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK04 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk04_l4_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk04_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK04 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk04_l5_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk04_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK04 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk04_l6_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk04_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK05 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk05_l4_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK05 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk05_l5_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK05 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk05_l6_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK06 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk06_l4_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk06_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK06 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk06_l5_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk06_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK06 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk06_l6_to_sk_sfv_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk06_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate YT02 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 2, 'yt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt_nfl('rawfri', 'yt02_l2_to_yt_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_nfl', 'yt02_l2_to_yt_l1_map_nfl');
------------------------
-- Translate NS03 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 3, 'ns_nsi', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ns_nfl('rawfri', 'ns03_l3_to_ns_nsi_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_nfl', 'ns03_l3_to_ns_nsi_l1_map_nfl');
------------------------
-- Translate PE01 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pe01', 2, 'pe_pei', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pe_nfl('rawfri', 'pe01_l2_to_pe_pei_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pe_pei01_nfl', 'pe01_l2_to_pe_pei_l1_map_nfl');
------------------------
-- Translate MB05 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb05', 2, 'mb_fri', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_mb_fri_nfl('rawfri', 'mb05_l2_to_mb_fri_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fri01_nfl', 'mb05_l2_to_mb_fri_l1_map_nfl');
------------------------
-- Translate MB06 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 6, 'mb_fli', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_mb_fli_nfl('rawfri', 'mb06_l6_to_mb_fli_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_nfl', 'mb06_l6_to_mb_fli_l1_map_nfl');
------------------------
-- Translate NL01 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nl01', 2, 'nl_nli', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nl_nfl('rawfri', 'nl01_l2_to_nl_nli_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nl_nli01_nfl', 'nl01_l2_to_nl_nli_l1_map_nfl');
------------------------
-- Translate QC03 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc03', 3, 'qc_ini03', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc03_nfl('rawfri', 'qc03_l3_to_qc_ini03_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini03_nfl', 'qc03_l3_to_qc_ini03_l1_map_nfl');
------------------------
-- Translate QC04 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc04', 3, 'qc_ini04', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc04_nfl('rawfri', 'qc04_l3_to_qc_ini04_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini04_nfl', 'qc04_l3_to_qc_ini04_l1_map_nfl');
------------------------
-- Translate QC05 layer 1
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc05', 3, 'qc_ipf', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc05_nfl('rawfri', 'qc05_l3_to_qc_ipf_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ipf05_nfl', 'qc05_l3_to_qc_ipf_l1_map_nfl');
------------------------
-- Translate PC01 from PANP
--layer 4 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc01_nfl('rawfri', 'pc01_l4_to_pc_panp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_panp_nfl', 'pc01_l1_to_pc_panp_l1_map_nfl');

-- Translate layer 5 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc01_nfl('rawfri', 'pc01_l5_to_pc_panp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_panp_nfl', 'pc01_l5_to_pc_panp_l1_map_nfl');

-- Translate layer 6 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc01_nfl('rawfri', 'pc01_l6_to_pc_panp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_panp_nfl', 'pc01_l6_to_pc_panp_l1_map_nfl');

------------------------
-- Translate PC02 from WBNP
--layer 8 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l8_to_pc_wbnp_l1_map_nfl');

--layer 9 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l9_to_pc_wbnp_l1_map_nfl');

--layer 10 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l10_to_pc_wbnp_l1_map_nfl');

--layer 11 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l11_to_pc_wbnp_l1_map_nfl');

--layer 12 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l12_to_pc_wbnp_l1_map_nfl');

--layer 13 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l13_to_pc_wbnp_l1_map_nfl');

--layer 14 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l14_to_pc_wbnp_l1_map_nfl');

--layer 15 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pc02', 15, 'pc_wbnp', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pc02_nfl('rawfri', 'pc02_l15_to_pc_wbnp_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_nfl', 'pc02_l15_to_pc_wbnp_l1_map_nfl');

------------------------
-- Translate QC02 USING QC_INI03 translation table 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc02', 3, 'qc_ini03', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc02_nfl('rawfri', 'qc02_l3_to_qc_ini03_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini03_nfl', 'qc02_l3_to_qc_ini03_l1_map_nfl');
------------------------
-- Translate QC06 USING QC_INI04 translation table 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc06', 3, 'qc_ini04', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc06_nfl('rawfri', 'qc06_l3_to_qc_ini04_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini04_nfl', 'qc06_l3_to_qc_ini04_l1_map_nfl');
------------------------
-- Translate QC07 USING QC_IPF05 translation table 
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc07', 3, 'qc_ipf', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_qc07_nfl('rawfri', 'qc07_l3_to_qc_ipf_l1_map_nfl');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ipf05_nfl', 'qc07_l3_to_qc_ipf_l1_map_nfl');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.nfl_all
GROUP BY left(cas_id, 4)
ORDER BY inv;
--inv   nb
--AB06	3515
--AB16	26858
--BC08	1998885
--BC10	2276213
--MB05	340124
--MB06	9826
--NB01	78227
--NB02	139930
--NL01	664096
--NS03	212453
--NT01	65299
--NT03	?????
--ON02	1318495
--PE01	22223
--QC03  197876
--QC04  328940
--QC05  1016269
--SK01	340357
--SK02	17529
--SK03 	6845
--SK04 	311133
--SK05 	184184
--SK06 	78506
--YT02	76344
--PC01  3593
--PC02  1614

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.nfl_all
GROUP BY left(cas_id, 4), layer
ORDER BY inv, layer;
-- inv lyr nb
--AB06	1	2081
--AB06	2	1434
--AB16	1	15434
--AB16	2	11424
--BC08	1	549593
--BC08	2	1234648
--BC08	3	212966
--BC08	4	1676
--BC08	5	2
--BC10	1	569834
--BC10	2	1440564
--BC10	3	262135
--BC10	4	3678
--BC10	5	2
--MB05  1 340124
--MB06  1 9802
--MB06  2 24
--NB01	1	78227
--NB02	1	139930
--NL01	1	664096
--NS03	1	201114
--NS03	2	11339
--NT01	1	42836
--NT01	2	22463
--NT03	1	?????
--NT03	2	?????
--ON02	1	1318495
--PE01	1	22223
--QC03  1 197876
--QC04  1 328940
--QC05  1 1016269
--SK01	1	340356
--SK01	2	1
--SK02	1	3337
--SK02	2	10143
--SK02	3	3707
--SK02	4	336
--SK02	5	6
--SK03	1	1524
--SK03	2	3094
--SK03	3	1977
--SK03	4	245
--SK03	5	5
--SK04	1	80905
--SK04	2	178021
--SK04	3	50036
--SK04	4	2129
--SK04	5	42
--SK05	1	41657
--SK05	2	114488
--SK05	3	27285
--SK05	4	744
--SK05	5	10
--SK06	1	21714
--SK06	2	38317
--SK06	3	18194
--SK06	4	275
--SK06	5	6
--YT02	1	76344
--PC01	1	2380
--PC01	2	933
--PC01	3	274
--PC01	4	6
--PC02  1  163
--PC02  2  166
--PC02  3  504
--PC02  4  555
--PC02  5  151
--PC02  6  64
--PC02  7  11

SELECT count(*) FROM casfri50.nfl_all; -- 9843418
--------------------------------------------------------------------------


