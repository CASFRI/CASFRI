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

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the tables by appending all translated 
-- table to the same big table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA casfri50;
-------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_cas', '_ab06_cas');
SELECT TT_Prepare('translation', 'ab16_avi01_cas', '_ab16_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nb01_nbi01_cas', '_nb01_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc08_vri01_cas', '_bc08_cas', 'ab06_avi01_cas');
------------------------
--DROP TABLE IF EXISTS casfri50.cas_all;
CREATE TABLE casfri50.cas_all AS -- 3m40s
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 37m35s
SELECT * FROM TT_Translate_ab16_cas('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 2h45m
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 12h16m
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_cas');
------------------------
SELECT count(*) FROM casfri50.cas_all; -- 5736548
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
-- make table edits and copies as needed for use with VIEWs
-- NB01_dst2 translations table
DROP TABLE IF EXISTS translation.nb01_nbi01_dst2;
CREATE TABLE translation.nb01_nbi01_dst2 WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_dst;
UPDATE translation.nb01_nbi01_dst2
SET translation_rules = 'copyInt(''2'')'
WHERE rule_id = '14';

-- Make VIEWs
CREATE OR REPLACE VIEW rawfri.nb01_dst2 AS
SELECT src_filename, stdlab, ogc_fid,
l2trt l1trt,	
l2trtyr l1trtyr
FROM rawfri.nb01;

SELECT TT_Prepare('translation', 'ab06_avi01_dst', '_ab06_dst');
SELECT TT_Prepare('translation', 'ab16_avi01_dst', '_ab16_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst', '_nb01_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst2', '_nb01_dst2', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc08_vri01_dst', '_bc08_dst', 'ab06_avi01_dst');
------------------------
--DROP TABLE IF EXISTS casfri50.dst_all;
CREATE TABLE casfri50.dst_all AS -- 2m12s
SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 24m46s
SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 1h32m
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 1h11m
SELECT * FROM TT_Translate_nb01_dst2('rawfri', 'nb01_dst2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_dst2');
------------------------
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_dst');
------------------------
SELECT count(*) FROM casfri50.dst_all; -- 5736548
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_eco', '_ab06_eco');
SELECT TT_Prepare('translation', 'ab16_avi01_eco', '_ab16_eco', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'nb01_nbi01_eco', '_nb01_eco', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'bc08_vri01_eco', '_bc08_eco', 'ab06_avi01_eco');
------------------------
--DROP TABLE IF EXISTS casfri50.eco_all;
CREATE TABLE casfri50.eco_all AS -- 36s
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_eco');
------------------------
INSERT INTO casfri50.eco_all -- 6m2s
SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_eco');
------------------------
INSERT INTO casfri50.eco_all -- 1h27m
SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_eco');
------------------------
INSERT INTO casfri50.eco_all -- 4h05m
SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_eco');
------------------------
SELECT count(*) FROM casfri50.eco_all; -- 5736548
-------------------------------------------------------
-- Translate all HDR tables into a common table
-- HDR tables only need one row per inventory, they
-- do not need to be made using translation, we can just
-- select the required row and columns from the
-- inventory_list_cas05 table.
-------------------------------------------------------
--DROP TABLE IF EXISTS casfri50.hdr_all;
CREATE TABLE casfri50.hdr_all AS -- <1 sec
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id IN ('AB06', 'AB16', 'BC08', 'NB01');
------------------------
SELECT count(*) FROM casfri50.hdr_all; -- 4
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
-- make table edits and copies as needed for use with VIEWs
-- NB01_lyr2 translations table
DROP TABLE IF EXISTS translation.nb01_nbi01_lyr2;
CREATE TABLE translation.nb01_nbi01_lyr2 WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_lyr;
UPDATE translation.nb01_nbi01_lyr2
SET translation_rules = 'copyInt(''2'')'
WHERE rule_id = '4' OR rule_id = '5';

-- Make VIEWs
CREATE OR REPLACE VIEW rawfri.nb01_lyr2 AS
SELECT src_filename, stdlab, ogc_fid,
l2estyr l1estyr,	
l2cc l1cc, l2ht l1ht,
l2s1 l1s1, l2pr1 l1pr1,
l2s2 l1s2, l2pr2 l1pr2,
l2s3 l1s3, l2pr3 l1pr3,
l2s4 l1s4, l2pr4 l1pr4,
l2s5 l1s5, l2pr5 l1pr5
FROM rawfri.nb01;

SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb01_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr2', '_nb01_lyr2', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr', 'ab06_avi01_lyr');
-------------------------
--DROP TABLE IF EXISTS casfri50.lyr_all;
CREATE TABLE casfri50.lyr_all AS -- 4m41s
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 46m20s
SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb01_lyr2('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr2');
------------------------
INSERT INTO casfri50.lyr_all -- 30h19m
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_lyr');
------------------------
SELECT count(*) FROM casfri50.lyr_all; -- 5736548
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_nfl', '_ab06_nfl');
SELECT TT_Prepare('translation', 'ab16_avi01_nfl', '_ab16_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nb01_nbi01_nfl', '_nb01_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc08_vri01_nfl', '_bc08_nfl', 'ab06_avi01_nfl');
------------------------
--DROP TABLE IF EXISTS casfri50.nfl_all;
CREATE TABLE casfri50.nfl_all AS -- 2m24s
SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 23m43s
SELECT * FROM TT_Translate_ab16_nfl('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 1h4m
SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_nfl');
------------------------
SELECT count(*) FROM casfri50.nfl_all; -- 5736548

-------------------------------------------------------
-- Translate all GEO tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_geo', '_ab06_geo');
SELECT TT_Prepare('translation', 'ab16_avi01_geo', '_ab16_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'nb01_nbi01_geo', '_nb01_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'bc08_vri01_geo', '_bc08_geo', 'ab06_avi01_geo');
------------------------
--DROP TABLE IF EXISTS casfri50.geo_all;
CREATE TABLE casfri50.geo_all AS -- 54s
SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_geo');
------------------------
INSERT INTO casfri50.geo_all -- 7m30s
SELECT * FROM TT_Translate_ab16_geo('rawfri', 'ab16', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_geo');
------------------------
INSERT INTO casfri50.geo_all -- 48m52s
SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_geo');
------------------------
INSERT INTO casfri50.geo_all --4h59m
SELECT * FROM TT_Translate_bc08_geo('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_geo');
------------------------
SELECT count(*) FROM casfri50.geo_all; --5736548
SELECT count(*) FROM casfri50.geo_all WHERE geometry = '010300000000000000'; -- 0
------------------------