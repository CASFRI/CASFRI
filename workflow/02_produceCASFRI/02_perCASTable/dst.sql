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
-- Translate all DST tables into a common table (no DST in PC01). 23h
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_dst', '_ab_dst'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nb_nbi01_dst', '_nb_dst', 'ab_avi01_dst'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'bc_vri01_dst', '_bc_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nt_fvi01_dst', '_nt_dst', 'ab_avi01_dst'); -- used for both NT01 and NT02
SELECT TT_Prepare('translation', 'on_fim02_dst', '_on_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_utm01_dst', '_sk_utm_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'sk_sfv01_dst', '_sk_sfv_dst', 'ab_avi01_dst'); 
SELECT TT_Prepare('translation', 'yt_yvi01_dst', '_yt_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'ns_nsi01_dst', '_ns_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'pe_pei01_dst', '_pe_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fri01_dst', '_mb05_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'mb_fli01_dst', '_mb06_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'nl_nli01_dst', '_nl_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'qc_ini03_dst', '_qc03_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'qc_ini04_dst', '_qc04_dst', 'ab_avi01_dst');
SELECT TT_Prepare('translation', 'qc_ipf05_dst', '_qc05_dst', 'ab_avi01_dst');
--SELECT TT_Prepare('translation', 'pc_wbnp01_dst', '_pc02_dst', 'ab_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50.dst_all CASCADE;
------------------------
-- Translate AB06
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 1, 'ab', 1, NULL, 'dst');

CREATE TABLE casfri50.dst_all AS -- 26s
SELECT * FROM TT_Translate_ab_dst('rawfri', 'ab06_l1_to_ab_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_dst', 'ab06_l1_to_ab_l1_map_dst');
------------------------
-- Translate AB16
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 1m50s
SELECT * FROM TT_Translate_ab_dst('rawfri', 'ab16_l1_to_ab_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_dst', 'ab16_l1_to_ab_l1_map_dst');
------------------------
-- Translate NB01 using NB generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 38m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb01_l1_to_nb_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_dst', 'nb01_l1_to_nb_l1_map_dst');
------------------------
-- Translate NB01 layer 2 using NB layer 1 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, NULL, 'dst'); 

INSERT INTO casfri50.dst_all -- 44m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb01_l2_to_nb_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_dst', 'nb01_l2_to_nb_l1_map_dst');
------------------------
-- Translate NB02 using NB generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 34m
SELECT * FROM TT_Translate_nb_dst('rawfri', 'nb02_l1_to_nb_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_dst', 'nb02_l1_to_nb_l1_map_dst');
------------------------
-- Translate BC08
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc_dst('rawfri', 'bc08_l1_to_bc_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_dst', 'bc08_l1_to_bc_l1_map_dst');
------------------------
-- Translate BC10
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 1, 'bc', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc_dst('rawfri', 'bc10_l1_to_bc_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_dst', 'bc10_l1_to_bc_l1_map_dst');
------------------------
-- Translate NT01 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 1, 'nt', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 36m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt01_l1_to_nt_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_dst', 'nt01_l1_to_nt_l1_map_dst');
------------------------
-- Translate NT02 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 51m
SELECT * FROM TT_Translate_nt_dst('rawfri', 'nt02_l1_to_nt_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_dst', 'nt02_l1_to_nt_l1_map_dst');
------------------------
-- Translate ON02 using FIM generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 1, 'on', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_on_dst('rawfri', 'on02_l1_to_on_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_dst', 'on02_l1_to_on_l1_map_dst');
------------------------
-- Translate SK01 using UTM generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_utm_dst('rawfri', 'sk01_l1_to_sk_utm_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst', 'sk01_l1_to_sk_utm_l1_map_dst');
------------------------
-- Translate SK02 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 1, 'sk_sfv', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_sfv_dst('rawfri', 'sk02_l1_to_sk_sfv_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst', 'sk02_l1_to_sk_utm_l1_map_dst');
------------------------
-- Translate SK03 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_sfv_dst('rawfri', 'sk03_l1_to_sk_sfv_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst', 'sk03_l1_to_sk_utm_l1_map_dst');
------------------------
-- Translate SK04 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 1, 'sk_sfv', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_sfv_dst('rawfri', 'sk04_l1_to_sk_sfv_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst', 'sk04_l1_to_sk_utm_l1_map_dst');
------------------------
-- Translate SK05 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 1, 'sk_sfv', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_sfv_dst('rawfri', 'sk05_l1_to_sk_sfv_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst', 'sk05_l1_to_sk_utm_l1_map_dst');
------------------------
-- Translate SK06 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 1, 'sk_sfv', 1, NULL, 'dst'); 

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_sk_sfv_dst('rawfri', 'sk06_l1_to_sk_sfv_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_dst', 'sk06_l1_to_sk_utm_l1_map_dst');
------------------------
-- Translate YT02 using YVI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 1, 'yt', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_yt_dst('rawfri', 'yt02_l1_to_yt_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_dst', 'yt02_l1_to_yt_l1_map_dst');
------------------------
-- Translate NS03 using NS_NSI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_ns_dst('rawfri', 'ns03_l1_to_ns_nsi_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_dst', 'ns03_l1_to_ns_nsi_l1_map_dst');
------------------------
-- Translate PE01 using PE_PEI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pe01', 1, 'pe_pei', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_pe_dst('rawfri', 'pe01_l1_to_pe_pei_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pe_pei01_dst', 'pe01_l1_to_pe_pei_l1_map_dst');
------------------------
-- Translate MB05 using MB_FRI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_mb05_dst('rawfri', 'mb05_l1_to_mb_fri_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fri01_dst', 'mb05_l1_to_mb_fri_l1_map_dst');
------------------------
-- Translate MB06 using MB_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_mb06_dst('rawfri', 'mb06_l1_to_mb_fli_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_dst', 'mb06_l1_to_mb_fli_l1_map_dst');
------------------------
-- Translate NL01 using NL_FLI generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_nl_dst('rawfri', 'nl01_l1_to_nl_nli_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nl_nli01_dst', 'nl01_l1_to_nl_nli_l1_map_dst');
------------------------
-- Translate QC03 using QC_INI03 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc03_dst('rawfri', 'qc03_l1_to_qc_ini03_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini03_dst', 'qc03_l1_to_qc_ini03_l1_map_dst');
------------------------
-- Translate QC04 using QC_INI04 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc04', 1, 'qc_ini04', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc04_dst('rawfri', 'qc04_l1_to_qc_ini04_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini04_dst', 'qc04_l1_to_qc_ini04_l1_map_dst');
------------------------
-- Translate QC05 using QC_IPF05 generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'qc05', 1, 'qc_ipf', 1, NULL, 'dst');

INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_qc05_dst('rawfri', 'qc05_l1_to_qc_ipf_l1_map_dst', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'qc_ipf05_dst', 'qc05_l1_to_qc_ipf_l1_map_dst');
------------------------
-- Translate PC02 using PC_WBNP generic translation table
--BEGIN;
--SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, NULL, 'dst');

--INSERT INTO casfri50.dst_all -- 
--SELECT * FROM TT_Translate_pc02_dst('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_dst', 'ogc_fid');
--COMMIT;

--SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp_dst', 'pc02_l1_to_pc_wbnp_l1_map_dst');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.dst_all
GROUP BY left(cas_id, 4)
ORDER BY inv;

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.dst_all
GROUP BY left(cas_id, 4), layer
ORDER BY inv, layer;
--inv lyr nb
--AB06 -8886	1875
--AB16 -8886	8873
--BC08 -8886	1142604
--BC10 -8886	1421223
--NB01     1	250366
--NB01     2	2198
--NB02 -8886	333114
--NS03 -8886	69446
--NT01 -8886	77270
--NT02 -8886	129867
--ON02 -8886	1970285
--PE01 -8886	29517
--SK01 -8886	64052
--SK02 -8886	9020
--SK03 -8886	236
--SK04 -8886	93980
--SK05 -8886	58248
--SK06 -8886	45081
--YT02 -8886	19173

SELECT count(*) FROM casfri50.dst_all; -- 10907114
--------------------------------------------------------------------------
