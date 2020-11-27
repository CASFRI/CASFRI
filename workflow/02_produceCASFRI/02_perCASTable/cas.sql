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
-- Validate AB photo year table
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_photoyear_validation', '_ab_photo_val');
SELECT * FROM TT_Translate_ab_photo_val('rawfri', 'ab_photoyear');

-- make table valid and subset by rows with valid photo years
DROP TABLE IF EXISTS rawfri.new_photo_year;
CREATE TABLE rawfri.new_photo_year AS
SELECT TT_GeoMakeValid(wkb_geometry) as wkb_geometry, photo_yr
FROM rawfri.ab_photoyear
WHERE TT_IsInt(photo_yr);

CREATE INDEX IF NOT EXISTS ab_photoyear_idx 
 ON rawfri.new_photo_year
 USING GIST(wkb_geometry);

DROP TABLE rawfri.ab_photoyear;
ALTER TABLE rawfri.new_photo_year RENAME TO ab_photoyear;

--------------------------------------------------------------------------
-- Validate NL photo year table
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'nl_photoyear_validation', '_nl_photo_val');
SELECT * FROM TT_Translate_nl_photo_val('rawfri', 'nl_photoyear');

-- make table valid and subset by rows with valid photo years
DROP TABLE IF EXISTS rawfri.new_photo_year;
CREATE TABLE rawfri.new_photo_year AS
SELECT TT_GeoMakeValid(wkb_geometry) as wkb_geometry, photoyear
FROM rawfri.nl_photoyear
WHERE TT_IsInt(photoyear::text);

CREATE INDEX IF NOT EXISTS nl_photoyear_idx 
 ON rawfri.new_photo_year
 USING GIST(wkb_geometry);

DROP TABLE rawfri.nl_photoyear;
ALTER TABLE rawfri.new_photo_year RENAME TO nl_photoyear;

--------------------------------------------------------------------------
-- Translate all CAS tables into a common table. 43h09m
--------------------------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab_cas'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nb_nbi01_cas', '_nb_cas', 'ab_avi01_cas'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt_cas', 'ab_avi01_cas'); -- used for both NT01 and NT02
SELECT TT_Prepare('translation', 'on_fim02_cas', '_on_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'sk_utm01_cas', '_sk_utm_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'sk_sfv01_cas', '_sk_sfv_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'yt_yvi01_cas', '_yt_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'ns_nsi01_cas', '_ns_cas', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'pe_pei01_cas', '_pe_cas', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'mb_fri01_cas', '_mb05_cas', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'mb_fli01_cas', '_mb06_cas', 'ab_avi01_cas');
SELECT TT_Prepare('translation', 'nl_nli01_cas', '_nl01_cas', 'ab_avi01_cas');
------------------------
DROP TABLE IF EXISTS casfri50.cas_all CASCADE;
------------------------
-- Translate AB06
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', NULL, 'cas');

CREATE TABLE casfri50.cas_all AS -- 3m40s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab06_l1_to_ab_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas', 'ab06_l1_to_ab_l1_map_cas');
------------------------
-- Translate AB16
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 37m35s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab16_l1_to_ab_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas', 'ab16_l1_to_ab_l1_map_cas');
------------------------
-- Translate NB01 using the NB generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 2h45m
SELECT * FROM TT_Translate_nb_cas('rawfri', 'nb01_l1_to_nb_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_cas', 'nb01_l1_to_nb_l1_map_cas');
------------------------
-- Translate NB02 using the NB generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_nb_cas('rawfri', 'nb02_l1_to_nb_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_cas', 'nb02_l1_to_nb_l1_map_cas');
------------------------
-- Translate BC08
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 12h16m
SELECT * FROM TT_Translate_bc_cas('rawfri', 'bc08_l1_to_bc_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_cas', 'bc08_l1_to_bc_l1_map_cas');
------------------------
-- Translate BC10
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', NULL, 'cas');

INSERT INTO casfri50.cas_all -- **h**m
SELECT * FROM TT_Translate_bc_cas('rawfri', 'bc10_l1_to_bc_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_cas', 'bc10_l1_to_bc_l1_map_cas');
------------------------
-- Translate NT01 using the NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 43m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt01_l1_to_nt_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas', 'nt01_l1_to_nt_l1_map_cas');
------------------------
-- Translate NT02 using NT generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt02_l1_to_nt_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas', 'nt02_l1_to_nt_l1_map_cas');
------------------------
-- Translate ON02 using ON generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_on_cas('rawfri', 'on02_l1_to_on_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_cas', 'on02_l1_to_on_l1_map_cas');
------------------------
-- Translate SK01 using UTM generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_utm_cas('rawfri', 'sk01_l1_to_sk_utm_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_cas', 'sk01_l1_to_sk_utm_l1_map_cas');
------------------------
-- Translate SK02 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk02', 'sk_sfv', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_sfv_cas('rawfri', 'sk02_l1_to_sk_sfv_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk02_l1_to_sk_sfv_l1_map_cas');
------------------------
-- Translate SK03 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk03', 'sk_sfv', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_sfv_cas('rawfri', 'sk03_l1_to_sk_sfv_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk03_l1_to_sk_sfv_l1_map_cas');
------------------------
-- Translate SK04 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk04', 'sk_sfv', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_sfv_cas('rawfri', 'sk04_l1_to_sk_sfv_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk04_l1_to_sk_sfv_l1_map_cas');
------------------------
-- Translate SK05 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk05', 'sk_sfv', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_sfv_cas('rawfri', 'sk05_l1_to_sk_sfv_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk05_l1_to_sk_sfv_l1_map_cas');
------------------------
-- Translate SK06 using SFV generic translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'sk06', 'sk_sfv', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_sfv_cas('rawfri', 'sk06_l1_to_sk_sfv_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_sfv01_cas', 'sk06_l1_to_sk_sfv_l1_map_cas');
------------------------
-- Translate YT02 using YVI01 translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', NULL, 'cas');

INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_yt_cas('rawfri', 'yt02_l1_to_yt_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_cas', 'yt02_l1_to_yt_l1_map_cas');
------------------------
-- Translate NS03 using NS_NSI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', NULL, 'cas');

INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_ns_cas('rawfri', 'ns03_l1_to_ns_nsi_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ns_nsi01_cas', 'ns03_l1_to_ns_nsi_l1_map_cas');
------------------------
-- Translate PE01 using PE_PEI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'pe01', 'pe_pei', NULL, 'cas');

INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_pe_cas('rawfri', 'pe01_l1_to_pe_pei_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'pe_pei01_cas', 'pe01_l1_to_pe_pei_l1_map_cas');
------------------------
-- Translate MB05 using MB_FRI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb05', 'mb_fri', NULL, 'cas');

INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_mb05_cas('rawfri', 'mb05_l1_to_mb_fri_l1_map', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fri01_cas', 'mb05_l1_to_mb_fri_l1_map_cas');
------------------------
-- Translate MB06 using MB_FLI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb_fli', NULL, 'cas');

INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_mb06_cas('rawfri', 'mb06_l1_to_mb_fli_l1_map', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'mb_fli01_cas', 'mb06_l1_to_mb_fli_l1_map_cas');
------------------------
-- Translate NL01 using NL_FLI translation table
BEGIN;
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', NULL, 'cas');

INSERT INTO casfri50.cas_all
SELECT * FROM TT_Translate_nl01_cas('rawfri', 'nl01_l1_to_nl_nli_l1_map', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nl_nli01_cas', 'nl01_l1_to_nl_nli_l1_map_cas');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.cas_all
GROUP BY left(cas_id, 4)
ORDER BY inv;
--inv   nb
--AB06	11484
--AB16	120476
--BC08	4677411
--BC10	5151772
--NB01	927177
--NB02	1123893
--NS03	995886
--NT01	281388
--NT02	320944
--ON02	3629072
--PE01  107220
--SK01	1501667
--SK02	27314
--SK03	8964
--SK04	633522
--SK05	421977
--SK06	211482
--YT02	231137

SELECT count(*) FROM casfri50.cas_all; -- 20382784
--------------------------------------------------------------------------

