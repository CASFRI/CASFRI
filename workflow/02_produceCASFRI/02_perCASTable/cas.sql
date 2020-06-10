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
-- Translate all CAS tables into a common table. 43h09m
--------------------------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab_avi01_cas', '_ab_cas'); -- used for both AB06 and AB16
SELECT TT_Prepare('translation', 'nb_nbi01_cas', '_nb_cas', 'ab_avi01_cas'); -- used for both NB01 and NB02
SELECT TT_Prepare('translation', 'bc_vri01_cas', '_bc_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'nt_fvi01_cas', '_nt_cas', 'ab_avi01_cas'); -- used for both NT01 and NT02
SELECT TT_Prepare('translation', 'on_fim02_cas', '_on_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'sk_utm01_cas', '_sk_cas', 'ab_avi01_cas'); 
SELECT TT_Prepare('translation', 'yt_yvi01_cas', '_yt_cas', 'ab_avi01_cas'); 
------------------------
DROP TABLE IF EXISTS casfri50.cas_all CASCADE;
------------------------
-- Translate AB06
SELECT TT_CreateMappingView('rawfri', 'ab06', 'ab', NULL, 'cas');

BEGIN;
CREATE TABLE casfri50.cas_all AS -- 3m40s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab06_l1_to_ab_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas');
------------------------
-- Translate AB16
SELECT TT_CreateMappingView('rawfri', 'ab16', 'ab', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 37m35s
SELECT * FROM TT_Translate_ab_cas('rawfri', 'ab16_l1_to_ab_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'ab_avi01_cas');
------------------------
-- Translate NB01 using the NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb01', 'nb', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 2h45m
SELECT * FROM TT_Translate_nb_cas('rawfri', 'nb01_l1_to_nb_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_cas');
------------------------
-- Translate NB02 using the NB generic translation table
SELECT TT_CreateMappingView('rawfri', 'nb02', 'nb', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_nb_cas('rawfri', 'nb02_l1_to_nb_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nb_nbi01_cas');
------------------------
-- Translate BC08
SELECT TT_CreateMappingView('rawfri', 'bc08', 'bc', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 12h16m
SELECT * FROM TT_Translate_bc_cas('rawfri', 'bc08_l1_to_bc_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_cas');
------------------------
-- Translate BC10
SELECT TT_CreateMappingView('rawfri', 'bc10', 'bc', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- **h**m
SELECT * FROM TT_Translate_bc_cas('rawfri', 'bc10_l1_to_bc_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'bc_vri01_cas');
------------------------
-- Translate NT01 using the NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt01', 'nt', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 43m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt01_l1_to_nt_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas');
------------------------
-- Translate NT02 using NT generic translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt02_l1_to_nt_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'nt_fvi01_cas');
------------------------
-- Translate ON02 using ON generic translation table
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_on_cas('rawfri', 'on02_l1_to_on_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'on_fim02_cas');
------------------------
-- Translate SK01 using UTM translation table
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_sk_cas('rawfri', 'sk01_l1_to_sk_utm_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'sk_utm01_cas');
------------------------
-- Translate YT02 using YVI01 translation table
SELECT TT_CreateMappingView('rawfri', 'yt02', 'yt', NULL, 'cas');

BEGIN;
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_yt_cas('rawfri', 'yt02_l1_to_yt_l1_map_cas', 'ogc_fid');
COMMIT;

SELECT * FROM TT_ShowLastLog('translation', 'yt_yvi01_cas');
--------------------------------------------------------------------------
-- Check processed inventories and count
--------------------------------------------------------------------------
SELECT left(cas_id, 4) inv, count(*) nb 
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);
--inv   nb
--AB06	11484
--AB16	120476
--BC08	4677411
--BC10	5151772
--NB01	927177
--NB02	1123893
--NT01	281388
--NT02	320944
--ON02	3629072
--SK01	1501667
--YT02	231137

SELECT count(*) FROM casfri50.cas_all; -- 17976422
--------------------------------------------------------------------------
-- Add some indexes
CREATE INDEX cas_all_casid_idx
ON casfri50.cas_all USING btree(cas_id);

CREATE INDEX cas_all_inventory_idx
ON casfri50.cas_all USING btree(left(cas_id, 4));
    
CREATE INDEX cas_all_province_idx
ON casfri50.cas_all USING btree(left(cas_id, 2));
--------------------------------------------------------------------------

