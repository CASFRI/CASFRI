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
SELECT TT_Prepare('translation', 'sk_utm01_nfl', '_sk_utm_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'sk_sfv01_nfl', '_sk_sfv_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'yt_yvi01_nfl', '_yt_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'ns_nsi01_nfl', '_ns_nfl', 'ab_avi01_nfl');
SELECT TT_Prepare('translation', 'pe_pei01_nfl', '_pe_nfl', 'ab_avi01_nfl');
------------------------
DROP TABLE IF EXISTS casfri50.nfl_all CASCADE;
------------------------
-- Translate AB06 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 3, 'ab', 1, NULL, 'nfl');

CREATE TABLE casfri50.nfl_all AS -- 2m24s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l3_to_ab_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab06_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB06 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 2m1s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab06_l4_to_ab_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab06_l4_to_ab_l1_map_nfl');
------------------------
-- Translate AB16 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 3, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 23m43s
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab16_l3_to_ab_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab16_l3_to_ab_l1_map_nfl');
------------------------
-- Translate AB16 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 4, 'ab', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ab_nfl('rawfri', 'ab16_l4_to_ab_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_nfl', 'ab16_l4_to_ab_l1_map_nfl');
------------------------
-- Translate NB01 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 1h4m
SELECT * FROM TT_Translate_nb_nfl('rawfri', 'nb01_l3_to_nb_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_nfl', 'nb01_l3_to_nb_l1_map_nfl');
------------------------
-- Translate NB02 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 3, 'nb', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nb_nfl('rawfri', 'nb02_l3_to_nb_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_nfl', 'nb02_l3_to_nb_l1_map_nfl');
------------------------
-- Translate BC08 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l2_to_bc_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc08_l2_to_bc_l1_map_nfl');
------------------------
-- Translate BC08 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l3_to_bc_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc08_l3_to_bc_l1_map_nfl');
------------------------
-- Translate BC08 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc08_l4_to_bc_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc08_l4_to_bc_l1_map_nfl');
------------------------
-- Translate BC10 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 3, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l3_to_bc_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc10_l3_to_bc_l1_map_nfl');
------------------------
-- Translate BC10 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 4, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l4_to_bc_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc10_l4_to_bc_l1_map_nfl');
------------------------
-- Translate BC10 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 5, 'bc', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- **h**m
SELECT * FROM TT_Translate_bc_nfl('rawfri', 'bc10_l5_to_bc_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_nfl', 'bc10_l5_to_bc_l1_map_nfl');
------------------------
-- Translate NT01 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 3, 'nt', 1, NULL, 'nfl'); 

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01_l3_to_nt_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt01_l3_to_nt_l1_map_nfl');
------------------------
-- Translate NT01 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 4, 'nt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01_l4_to_nt_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt01_l4_to_nt_l1_map_nfl');
------------------------
-- Translate NT02 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 3, 'nt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_l3_to_nt_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt02_l3_to_nt_l1_map_nfl');
------------------------
-- Translate NT02 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 4, 'nt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_l4_to_nt_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_nfl', 'nt02_l4_to_nt_l1_map_nfl');
------------------------
-- Translate ON02 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 3, 'on', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_on_nfl('rawfri', 'on02_l3_to_on_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_nfl', 'on02_l3_to_on_l1_map_nfl');
------------------------
-- Translate SK01 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_utm_nfl('rawfri', 'sk01_l3_to_sk_utm_l1_map_nfl', 'ogc_fid'); 
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
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk02_l5_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK02 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk02_l6_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk02_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK03 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk03_l4_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk03_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK03 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk03_l5_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk03_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK03 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk03_l6_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk03_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK04 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk04_l4_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk04_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK04 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk04_l5_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk04_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK04 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk04_l6_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk04_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK05 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk05_l4_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK05 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk05_l5_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK05 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk05_l6_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk05_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK06 layer 4
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 4, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk06_l4_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk06_l4_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK06 layer 5
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 5, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk06_l5_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk06_l5_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate SK06 layer 6
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 6, 'sk_sfv', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_sk_sfv_nfl('rawfri', 'sk06_l6_to_sk_sfv_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_nfl', 'sk06_l6_to_sk_sfv_l1_map_nfl');
------------------------
-- Translate YT02 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 2, 'yt', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_yt_nfl('rawfri', 'yt02_l2_to_yt_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_nfl', 'yt02_l2_to_yt_l1_map_nfl');
------------------------
-- Translate NS03 layer 3
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 3, 'ns_nsi', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_ns_nfl('rawfri', 'ns03_l3_to_ns_nsi_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_nfl', 'ns03_l3_to_ns_nsi_l1_map_nfl');
------------------------
-- Translate PE01 layer 2
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pe01', 2, 'pe_pei', 1, NULL, 'nfl');

INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_pe_nfl('rawfri', 'pe01_l2_to_pe_pei_l1_map_nfl', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pe_pei01_nfl', 'pe01_l2_to_pe_pei_l1_map_nfl');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.nfl_all
GROUP BY left(cas_id, 4);
--inv   nb
--AB06	3515
--AB16	26858
--BC08	1998885
--BC10	2276213
--NB01	78227
--NB02	139930
--NS03	212453
--NT01	65299
--NT02	258582
--ON02	1562183
--PE01	22223
--SK01	340357
--SK02	17530
--SK03 	6845
--SK04 	311133
--SK05 	184184
--SK06 	78506
--YT02	76344

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.nfl_all
GROUP BY left(cas_id, 4), layer
ORDER BY inv, layer;
-- inv lyr nb
--AB06	1	2081
--AB06	2	1434
--AB16	1	15434
--AB16	2	11424
--BC08	1	554538
--BC08	2	1265774
--BC08	3	178334
--BC08	4	239
--BC10	0	225219
--BC10	1	1082425
--BC10	2	740803
--BC10	3	224091
--BC10	4	3673
--BC10	5	2
--NB01	1	78227
--NB02	1	139930
--NS03	1	201114
--NS03	2	11339
--NT01	1	42512
--NT01	2	22769
--NT01	3	18
--NT02	1	105150
--NT02	2	152264
--NT02	3	1168
--ON02	1	1562183
--PE01	1	22223
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

SELECT count(*) FROM casfri50.nfl_all; -- 7659266
--------------------------------------------------------------------------
-- Add some indexes
CREATE INDEX nfl_all_casid_idx
ON casfri50.nfl_all USING btree(cas_id);

CREATE INDEX nfl_all_inventory_idx
ON casfri50.nfl_all USING btree(left(cas_id, 4));
    
CREATE INDEX nfl_all_province_idx
ON casfri50.nfl_all USING btree(left(cas_id, 2));
--------------------------------------------------------------------------

