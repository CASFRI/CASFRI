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
SELECT TT_Prepare('translation', 'sk_utm01_eco', '_sk_utm_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'sk_sfv01_eco', '_sk_sfv_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'yt_yvi01_eco', '_yt_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'ns_nsi01_eco', '_ns_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pe_pei01_eco', '_pe_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fri01_eco', '_mb_fri_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'mb_fli01_eco', '_mb_fli_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'nl_nli01_eco', '_nl_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'qc_ini03_eco', '_qc03_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'qc_ini04_eco', '_qc04_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'qc_ipf05_eco', '_qc05_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pc_panp01_eco', '_pc01_eco', 'ab_avi01_eco');
SELECT TT_Prepare('translation', 'pc_wbnp01_eco', '_pc02_eco', 'ab_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50.eco_all CASCADE;
------------------------
-- Translate AB03
SELECT TT_CreateMappingView('rawfri', 'ab03', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab03_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab03_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab06_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab06_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB07
SELECT TT_CreateMappingView('rawfri', 'ab07', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab07_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab07_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB08
SELECT TT_CreateMappingView('rawfri', 'ab08', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab08_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab08_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB10
SELECT TT_CreateMappingView('rawfri', 'ab10', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab10_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab10_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB11
SELECT TT_CreateMappingView('rawfri', 'ab11', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab11_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab11_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', NULL, 'eco');
INSERT INTO casfri50.eco_all -- 6m2s
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab16_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab16_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB25
SELECT TT_CreateMappingView('rawfri', 'ab25', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab25_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab25_l1_to_ab_l1_map_eco');
------------------------
-- Translate AB29
SELECT TT_CreateMappingView('rawfri', 'ab29', 'ab', NULL, 'eco');

CREATE TABLE casfri50.eco_all AS
SELECT * FROM TT_Translate_ab_eco('rawfri', 'ab29_l1_to_ab_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_eco', 'ab29_l1_to_ab_l1_map_eco');
------------------------
-- Translate NB01
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 1h27m
SELECT * FROM TT_Translate_nb_eco('rawfri', 'nb01_l1_to_nb_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_eco', 'nb01_l1_to_nb_l1_map_eco');
------------------------
-- Translate NB02 using NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nb_eco('rawfri', 'nb02_l1_to_nb_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi02_eco', 'nb02_l1_to_nb_l1_map_eco');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 4h05m
SELECT * FROM TT_Translate_bc_eco('rawfri', 'bc08_l1_to_bc_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_eco', 'bc08_l1_to_bc_l1_map_eco');
------------------------
-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', NULL, 'eco');

INSERT INTO casfri50.eco_all -- *h**m
SELECT * FROM TT_Translate_bc_eco('rawfri', 'bc10_l1_to_bc_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_eco', 'bc10_l1_to_bc_l1_map_eco');
------------------------
-- Translate NT01 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt01_l1_to_nt_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco', 'nt01_l1_to_nt_l1_map_eco');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nt_eco('rawfri', 'nt02_l1_to_nt_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_eco', 'nt02_l1_to_nt_l1_map_eco');
------------------------
-- Translate ON02 using ON translation table
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_on_eco('rawfri', 'on02_l1_to_on_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_eco', 'on02_l1_to_on_l1_map_eco');
------------------------
-- Translate SK01 using SK UTM translation table
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_utm_eco('rawfri', 'sk01_l1_to_sk_utm_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_eco', 'sk01_l1_to_sk_utm_l1_map_eco');
------------------------
-- Translate SK02 using SK SFV translation table
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_sfv_eco('rawfri', 'sk02_l1_to_sk_sfv_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk02_l1_to_sk_sfv_l1_map_eco');
------------------------
-- Translate SK03 using SK SFV translation table
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_sfv_eco('rawfri', 'sk03_l1_to_sk_sfv_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk03_l1_to_sk_sfv_l1_map_eco');
------------------------
-- Translate SK04 using SK SFV translation table
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_sfv_eco('rawfri', 'sk04_l1_to_sk_sfv_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk04_l1_to_sk_sfv_l1_map_eco');
------------------------
-- Translate SK05 using SK SFV translation table
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_sfv_eco('rawfri', 'sk05_l1_to_sk_sfv_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk05_l1_to_sk_sfv_l1_map_eco');
------------------------
-- Translate SK06 using SK SFV translation table
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_sk_sfv_eco('rawfri', 'sk06_l1_to_sk_sfv_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_eco', 'sk06_l1_to_sk_sfv_l1_map_eco');
------------------------
-- Translate YT02 using YT translation table
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_yt_eco('rawfri', 'yt02_l1_to_yt_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_eco', 'yt02_l1_to_yt_l1_map_eco');
------------------------
-- Translate NS03 using NS_NSI translation table
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_ns_eco('rawfri', 'ns03_l1_to_ns_nsi_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_eco', 'ns03_l1_to_ns_nsi_l1_map_eco');
------------------------
-- Translate PE01 using PE_PEI translation table
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pe_eco('rawfri', 'pe01_l1_to_pe_pei_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'pe_pei01_eco', 'pe01_l1_to_pe_pei_l1_map_eco');
------------------------
-- Translate MB05 using MB_FRI translation table
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_mb_fri_eco('rawfri', 'mb05_l1_to_mb_fri_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'mb_fri01_eco', 'mb05_l1_to_mb_fri_l1_map_eco');
------------------------
-- Translate MB06 using MB_FLI translation table
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_mb_fli_eco('rawfri', 'mb06_l1_to_mb_fli_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_eco', 'mb06_l1_to_mb_fli_l1_map_eco');
------------------------
-- Translate NL01 using NL_FLI translation table
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nl_eco('rawfri', 'nl01_l1_to_nl_nli_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'nl_nli01_eco', 'nl01_l1_to_nl_nli_l1_map_eco');
------------------------
-- Translate QC03 using QC_INI03 translation table
SELECT TT_CreateMappingView('rawfri', 'qc03', 'qc_ini03', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_qc03_eco('rawfri', 'qc03_l1_to_qc_ini03_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini03_eco', 'qc03_l1_to_qc_ini03_l1_map_eco');
------------------------
-- Translate QC04 using QC_INI04 translation table
SELECT TT_CreateMappingView('rawfri', 'qc04', 'qc_ini04', NULL, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_qc04_eco('rawfri', 'qc04_l1_to_qc_ini04_l1_map_eco');

SELECT * FROM TT_ShowLastLog('translation', 'qc_ini04_eco', 'qc04_l1_to_qc_ini04_l1_map_eco');
------------------------
-- Translate PC01 using PC_PANP translation table
-- Add layer 4
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc01_eco('rawfri', 'pc01_l4_to_pc_panp_l1_map_eco', 'ogc_fid');

-- Add layer 5
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc01_eco('rawfri', 'pc01_l5_to_pc_panp_l1_map_eco', 'ogc_fid');

-- Add layer 6
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc01_eco('rawfri', 'pc01_l6_to_pc_panp_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'pc_panp_eco', 'pc01_l4_to_pc_panp_l1_map');

------------------------
-- Translate PC02 using PC_WBNP translation table
-- layer 1 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 1, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l1_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l1_to_pc_wbnp_l1_map_eco');

--layer 2 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 2, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l2_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l2_to_pc_wbnp_l1_map_eco');

--layer 3 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 3, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l3_to_pc_wbnp_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l3_to_pc_wbnp_l1_map_eco');

--layer 4 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 4, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l4_to_pc_wbnp_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l4_to_pc_wbnp_l1_map_eco');

--layer 5 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 5, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l5_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l5_to_pc_wbnp_l1_map_eco');

--layer 6 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 6, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l6_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l6_to_pc_wbnp_l1_map_eco');

--layer 7 - ECOxLYR
SELECT TT_CreateMappingView('rawfri', 'pc02', 7, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l7_to_pc_wbnp_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l7_to_pc_wbnp_l1_map_eco');

--layer 8 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 8, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l8_to_pc_wbnp_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l8_to_pc_wbnp_l1_map_eco');

--layer 9 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 9, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l9_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l9_to_pc_wbnp_l1_map_eco');

--layer 10 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 10, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l10_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l10_to_pc_wbnp_l1_map_eco');

--layer 11 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 11, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l11_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l11_to_pc_wbnp_l1_map_eco');

--layer 12 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 12, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l12_to_pc_wbnp_l1_map_eco', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l12_to_pc_wbnp_l1_map_eco');

--layer 13 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 13, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l13_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l13_to_pc_wbnp_l1_map_eco');

--layer 14 - ECOxNFL
SELECT TT_CreateMappingView('rawfri', 'pc02', 14, 'pc_wbnp', 1, 'eco');

INSERT INTO casfri50.eco_all --
SELECT * FROM TT_Translate_pc02_eco('rawfri', 'pc02_l14_to_pc_wbnp_l1_map_eco', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'pc_wbnp01_eco', 'pc02_l14_to_pc_wbnp_l1_map_eco');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.eco_all
GROUP BY left(cas_id, 4)
ORDER BY inv;
--inv   count
--AB06 	1174
--AB16 	5528
--BC08 	66837
--BC10 	70989
--NB01 	72978
--NB02	107264
--NL01	238785
--NS03	122782
--PE01	1488
--QC03	50600
--QC04	243352
--QC05	879228
--PC01  1767
--PC02  1947
SELECT count(*) FROM casfri50.eco_all; -- 1861005
--------------------------------------------------------------------------
