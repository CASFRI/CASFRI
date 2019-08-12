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


-- 1) In a PostgreSQL query window, install PostGIS in your database:
--    CREATE EXTENSION postgis;
--
-- 2) In a operating system command window, load the necessary inventories 
--    using the proper conversion scripts located in the conversion folder. You 
--    must copy and edit the configSample (.bat or .sh) file to match your 
--    system configuration.
--
-- 3) In a operating system command window, load the translation files using the 
--    load_tables (.bat or .sh) script located in the translation folder. You 
--    must copy and edit the configSample (.bat or .sh) file to match your 
--    system configuration.
--
-- 4) In a PostgreSQL query window, run, in this order:
--    a) the postTranslationEngine/engine.sql file,
--    b) the postTranslationEngine/helperFunctions.sql file,
--    c) the helperFunctionsTest.sql file. All test should pass.
--    c) the engineTest.sql file. All test should pass.
--
--    You can desinstall all the functions by running the 
--    helperFunctionsUninstall.sql and the engineUninstall.sql files.
--
-- 5) You are now ready to start translating the inventories following
--    the rest of this file instructions...
   
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-------------------------------------------------------
-------------------------------------------------------
-- Work on source inventory
-------------------------------------------------------
-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.ab06 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.ab06;

-- create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.ab06_test_200;
CREATE TABLE rawfri.ab06_test_200 AS
SELECT * FROM rawfri.ab06
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT src_filename, trm_1, poly_num, ogc_fid, density, height, sp1, sp1_per
FROM rawfri.ab06_test_200;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.ab16 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.ab16;

-- create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.ab16_test_200;
CREATE TABLE rawfri.ab16_test_200 AS
SELECT * FROM rawfri.ab16
--WHERE ogc_fid = 18317
LIMIT 200;

-- display
SELECT src_filename, forest_id, ogc_fid, crownclose, height, sp1, sp1_percnt
FROM rawfri.ab16_test_200;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- have a look at one of the source inventory table
SELECT * FROM rawfri.nb01 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.nb01;

-- create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.nb01_test_200;
CREATE TABLE rawfri.nb01_test_200 AS
SELECT * FROM rawfri.nb01 
WHERE stdlab > 0
--WHERE ogc_fid = 811451038
LIMIT 200;

-- display
SELECT src_filename, stdlab, ogc_fid, l1cc, l1ht, l1s1, l1pr1
FROM rawfri.nb01_test_200;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.bc08 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.bc08;

-- create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.bc08_test_200;
CREATE TABLE rawfri.bc08_test_200 AS
SELECT * FROM rawfri.bc08
WHERE crown_closure > 0
--WHERE ogc_fid = 424344
LIMIT 200;

-- display
SELECT src_filename, map_id, feature_id, ogc_fid, crown_closure, proj_height_1, species_cd_1, species_pct_1
FROM rawfri.bc08_test_200;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA translation_test;

-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.ab06_avi01_cas; 
SELECT * FROM translation.ab06_avi01_dst; 
SELECT * FROM translation.ab06_avi01_eco; 
SELECT * FROM translation.ab06_avi01_hdr; 
SELECT * FROM translation.ab06_avi01_lyr; 
SELECT * FROM translation.ab06_avi01_nfl; 
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab06_avi01_cas_test;
CREATE TABLE translation_test.ab06_avi01_cas_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_cas
WHERE rule_id::int = 10
;
-- display
SELECT * FROM translation_test.ab06_avi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.ab06_avi01_dst_test;
CREATE TABLE translation_test.ab06_avi01_dst_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.ab06_avi01_eco_test;
CREATE TABLE translation_test.ab06_avi01_eco_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_eco_test;
----------------------------
-- hdr
DROP TABLE IF EXISTS translation_test.ab06_avi01_hdr_test;
CREATE TABLE translation_test.ab06_avi01_hdr_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_hdr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_hdr_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.ab06_avi01_lyr_test;
CREATE TABLE translation_test.ab06_avi01_lyr_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.ab06_avi01_nfl_test;
CREATE TABLE translation_test.ab06_avi01_nfl_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_nfl_test;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.ab16_avi01_cas; 
SELECT * FROM translation.ab16_avi01_dst; 
SELECT * FROM translation.ab16_avi01_eco; 
SELECT * FROM translation.ab16_avi01_hdr; 
SELECT * FROM translation.ab16_avi01_lyr; 
SELECT * FROM translation.ab16_avi01_nfl; 
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab16_avi01_cas_test;
CREATE TABLE translation_test.ab16_avi01_cas_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.ab16_avi01_dst_test;
CREATE TABLE translation_test.ab16_avi01_dst_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.ab16_avi01_eco_test;
CREATE TABLE translation_test.ab16_avi01_eco_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_eco_test;
----------------------------
-- hdr
DROP TABLE IF EXISTS translation_test.ab16_avi01_hdr_test;
CREATE TABLE translation_test.ab16_avi01_hdr_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_hdr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_hdr_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.ab16_avi01_lyr_test;
CREATE TABLE translation_test.ab16_avi01_lyr_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.ab16_avi01_nfl_test;
CREATE TABLE translation_test.ab16_avi01_nfl_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_nfl_test;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.nb01_nbi01_cas; 
SELECT * FROM translation.nb01_nbi01_dst; 
SELECT * FROM translation.nb01_nbi01_eco; 
SELECT * FROM translation.nb01_nbi01_hdr; 
SELECT * FROM translation.nb01_nbi01_lyr; 
SELECT * FROM translation.nb01_nbi01_nfl; 
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nb01_nbi01_cas_test;
CREATE TABLE translation_test.nb01_nbi01_cas_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.nb01_nbi01_dst_test;
CREATE TABLE translation_test.nb01_nbi01_dst_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.nb01_nbi01_eco_test;
CREATE TABLE translation_test.nb01_nbi01_eco_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_eco_test;
----------------------------
-- hdr
DROP TABLE IF EXISTS translation_test.nb01_nbi01_hdr_test;
CREATE TABLE translation_test.nb01_nbi01_hdr_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_hdr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_hdr_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.nb01_nbi01_lyr_test;
CREATE TABLE translation_test.nb01_nbi01_lyr_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.nb01_nbi01_nfl_test;
CREATE TABLE translation_test.nb01_nbi01_nfl_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_nfl_test;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.bc08_vri01_cas; 
SELECT * FROM translation.bc08_vri01_dst; 
SELECT * FROM translation.bc08_vri01_eco; 
SELECT * FROM translation.bc08_vri01_hdr; 
SELECT * FROM translation.bc08_vri01_lyr; 
SELECT * FROM translation.bc08_vri01_nfl; 
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.bc08_vri01_cas_test;
CREATE TABLE translation_test.bc08_vri01_cas_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.bc08_vri01_dst_test;
CREATE TABLE translation_test.bc08_vri01_dst_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.bc08_vri01_eco_test;
CREATE TABLE translation_test.bc08_vri01_eco_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_eco_test;
----------------------------
-- hdr
DROP TABLE IF EXISTS translation_test.bc08_vri01_hdr_test;
CREATE TABLE translation_test.bc08_vri01_hdr_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_hdr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_hdr_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.bc08_vri01_lyr_test;
CREATE TABLE translation_test.bc08_vri01_lyr_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.bc08_vri01_nfl_test;
CREATE TABLE translation_test.bc08_vri01_nfl_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_nfl_test;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AB species table
-------------------------------------------------------
SELECT TT_Prepare('validation', 'ab_avi01_species_validation', '_ab_species_val');
SELECT * FROM TT_Translate_ab_species_val('translation', 'ab_avi01_species');

-------------------------------------------------------
-- BC species table
-------------------------------------------------------
SELECT TT_Prepare('validation', 'bc_vri01_species_validation', '_bc_species_val');
SELECT * FROM TT_Translate_bc_species_val('translation', 'bc_vri01_species');

-------------------------------------------------------
-- NB species table
-------------------------------------------------------
SELECT TT_Prepare('validation', 'nb_nbi01_species_validation', '_nb_species_val');
SELECT * FROM TT_Translate_nb_species_val('translation', 'nb_nbi01_species');

-------------------------------------------------------
-- AB photo year
-------------------------------------------------------
SELECT TT_Prepare('validation', 'ab_photoyear_validation', '_ab_photo_val');
SELECT * FROM TT_Translate_ab_photo_val('rawfri', 'ab_photoyear'); -- 5s
SELECT * FROM rawfri.ab_photoyear;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AB06
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'ab06_avi01_cas_test', '_ab06_cas');
SELECT TT_Prepare('translation_test', 'ab06_avi01_dst_test', '_ab06_dst');
SELECT TT_Prepare('translation_test', 'ab06_avi01_eco_test', '_ab06_eco');
SELECT TT_Prepare('translation_test', 'ab06_avi01_hdr_test', '_ab06_hdr');
SELECT TT_Prepare('translation_test', 'ab06_avi01_lyr_test', '_ab06_lyr');
SELECT TT_Prepare('translation_test', 'ab06_avi01_nfl_test', '_ab06_nfl');

-- translate the samples (5 sec.)
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06_test_200'); -- 29 s.
SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06_test_200'); -- 5 s.
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06_test_200'); -- 1 s.
SELECT * FROM TT_Translate_ab06_hdr('rawfri', 'ab06_test_200'); -- 4 s.
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06_test_200'); -- 7 s.
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06_test_200'); -- 2 s.

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, trm_1, poly_num, rule_id, cas_id, 
       density, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_per, species_per_1
FROM TT_Translate_ab06('rawfri', 'ab06_test_200'), rawfri.ab06_test_200
WHERE poly_num = substr(cas_id, 33, 10)::int;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'ab16_avi01_cas_test', '_ab16_cas');
SELECT TT_Prepare('translation_test', 'ab16_avi01_dst_test', '_ab16_dst');
SELECT TT_Prepare('translation_test', 'ab16_avi01_eco_test', '_ab16_eco');
SELECT TT_Prepare('translation_test', 'ab16_avi01_hdr_test', '_ab16_hdr');
SELECT TT_Prepare('translation_test', 'ab16_avi01_lyr_test', '_ab16_lyr');
SELECT TT_Prepare('translation_test', 'ab16_avi01_nfl_test', '_ab16_nfl');

-- translate the samples
SELECT * FROM TT_Translate_ab16_cas('rawfri', 'ab16_test_200'); -- 13 s.
SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16_test_200'); -- 5 s.
SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16_test_200'); -- 3 s.
SELECT * FROM TT_Translate_ab16_hdr('rawfri', 'ab16_test_200'); -- 4 s.
SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16_test_200'); -- 7 s.
SELECT * FROM TT_Translate_ab16_nfl('rawfri', 'ab16_test_200'); -- 5 s.

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, forest_id, rule_id, cas_id, 
       crownclose, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_percnt, species_per_1
FROM TT_Translate_ab16('rawfri', 'ab16_test_200'), rawfri.ab16_test_200
WHERE rule_id::int = right(cas_id, 7)::int;
-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- create translation function
SELECT TT_Prepare('translation_test', 'nb01_nbi01_cas_test', '_nb01_cas');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_dst_test', '_nb01_dst');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_eco_test', '_nb01_eco');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_hdr_test', '_nb01_hdr');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_lyr_test', '_nb01_lyr');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_nfl_test', '_nb01_nfl');

-- translate the samples
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01_test_200'); -- 5 s.
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01_test_200'); -- 4 s.
SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01_test_200'); -- 2 s.
SELECT * FROM TT_Translate_nb01_hdr('rawfri', 'nb01_test_200'); -- 4 s.
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01_test_200'); -- 7 s.
SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01_test_200'); -- 3 s.

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, stdlab, rule_id, cas_id, 
       l1cc, crown_closure_lower, crown_closure_upper, 
       l1ht, height_upper, height_lower, 
       l1s1, species_1,
       l1pr1, species_per_1
FROM TT_Translate_nb01('rawfri', 'nb01_test_200'), rawfri.nb01_test_200
WHERE rule_id::int = right(cas_id, 7)::int;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'bc08_vri01_cas_test', '_bc08_cas');
SELECT TT_Prepare('translation_test', 'bc08_vri01_dst_test', '_bc08_dst');
SELECT TT_Prepare('translation_test', 'bc08_vri01_eco_test', '_bc08_eco');
SELECT TT_Prepare('translation_test', 'bc08_vri01_hdr_test', '_bc08_hdr');
SELECT TT_Prepare('translation_test', 'bc08_vri01_lyr_test', '_bc08_lyr');
SELECT TT_Prepare('translation_test', 'bc08_vri01_nfl_test', '_bc08_nfl');

-- translate the samples
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08_test_200'); -- 4 s.
SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08_test_200'); -- 4 s.
SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08_test_200'); -- 2 s.
SELECT * FROM TT_Translate_bc08_hdr('rawfri', 'bc08_test_200'); -- 5 s.
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08_test_200'); -- 7 s.
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08_test_200'); -- 4 s.

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, map_id, rule_id, cas_id, 
       crown_closure, crown_closure_lower, crown_closure_upper, 
       proj_height_1, height_upper, height_lower,
       species_cd_1, species_1,
       species_pct_1, species_per_1
FROM TT_Translate_bc08('rawfri', 'bc08_test_200'), rawfri.bc08_test_200
WHERE rule_id::int = right(cas_id, 7)::int;
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
CREATE TABLE casfri50.cas_all AS -- 25m28s
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06');
------------------------
INSERT INTO casfri50.cas_all -- 2h11m
SELECT * FROM TT_Translate_ab16_cas('rawfri', 'ab16');
------------------------
INSERT INTO casfri50.cas_all -- 2h9m
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01');
------------------------
INSERT INTO casfri50.cas_all -- 9h13m -- 8h37
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08');

SELECT count(*) FROM casfri50.cas_all; -- 5736548
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_dst', '_ab06_dst');
SELECT TT_Prepare('translation', 'ab16_avi01_dst', '_ab16_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst', '_nb01_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc08_vri01_dst', '_bc08_dst', 'ab06_avi01_dst');
------------------------
--DROP TABLE IF EXISTS casfri50.dst_all;
CREATE TABLE casfri50.dst_all AS -- 2m -- 1m35s
SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06');
------------------------
INSERT INTO casfri50.dst_all -- 21m54s -- 15m51s
SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16');
------------------------
INSERT INTO casfri50.dst_all -- 1h49m -- 1h12m
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01');
------------------------
INSERT INTO casfri50.dst_all -- 8h43m - 5h44m
SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08');

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
CREATE TABLE casfri50.eco_all AS -- 44s -- 29s
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06');
------------------------
INSERT INTO casfri50.eco_all -- 7m13s -- 4m17s
SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16');
------------------------
INSERT INTO casfri50.eco_all -- 51m31s
SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01');
------------------------
INSERT INTO casfri50.eco_all -- 4h37m - 3h14m
SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08');

SELECT count(*) FROM casfri50.eco_all; -- 5736548
-------------------------------------------------------
-- Translate all HDR tables into a common table
-------------------------------------------------------
--DROP TABLE IF EXISTS casfri50.hdr_all;
CREATE TABLE casfri50.hdr_all AS -- <1 sec
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end	, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id IN ('AB06', 'AB16', 'BC08', 'NB01');
------------------------

SELECT count(*) FROM casfri50.hdr_all; -- 4
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb01_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr', 'ab06_avi01_lyr');
-------------------------
--DROP TABLE IF EXISTS casfri50.lyr_all;
CREATE TABLE casfri50.lyr_all AS -- 4m9s -- 3m42s
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06');
------------------------
INSERT INTO casfri50.lyr_all -- 45m34s -- 38m51s
SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16');
------------------------
INSERT INTO casfri50.lyr_all -- 4h50m -- 4h44m
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01');
------------------------
INSERT INTO casfri50.lyr_all -- 26h31m
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08');

SELECT count(*) FROM casfri50.lyr_all; -- xx
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab06_avi01_nfl', '_ab06_nfl');
SELECT TT_Prepare('translation', 'ab16_avi01_nfl', '_ab16_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nb01_nbi01_nfl', '_nb01_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc08_vri01_nfl', '_bc08_nfl', 'ab06_avi01_nfl');
------------------------
--DROP TABLE IF EXISTS casfri50.nfl_all;
CREATE TABLE casfri50.nfl_all AS -- 2m14s -- 1m53s
SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06');
------------------------
INSERT INTO casfri50.nfl_all -- 23m3s -- 18m21s
SELECT * FROM TT_Translate_ab16_nfl('rawfri', 'ab16');
------------------------
INSERT INTO casfri50.nfl_all -- 1h21m -- 45m45s
SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01');
------------------------
INSERT INTO casfri50.nfl_all -- 13h43m --12h36m
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08');

SELECT count(*) FROM casfri50.nfl_all; -- 5736548


