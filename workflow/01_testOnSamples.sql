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
SELECT * FROM translation.ab06_avi01_lyr; 
SELECT * FROM translation.ab06_avi01_nfl;
SELECT * FROM translation.ab06_avi01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab06_avi01_cas_test;
CREATE TABLE translation_test.ab06_avi01_cas_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_cas
--WHERE rule_id::int = 10
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
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.ab06_avi01_geo_test;
CREATE TABLE translation_test.ab06_avi01_geo_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_test.ab06_avi01_geo_test;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.ab16_avi01_cas; 
SELECT * FROM translation.ab16_avi01_dst; 
SELECT * FROM translation.ab16_avi01_eco; 
SELECT * FROM translation.ab16_avi01_lyr; 
SELECT * FROM translation.ab16_avi01_nfl;
SELECT * FROM translation.ab16_avi01_geo;
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
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.ab16_avi01_geo_test;
CREATE TABLE translation_test.ab16_avi01_geo_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_geo_test;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.nb01_nbi01_cas; 
SELECT * FROM translation.nb01_nbi01_dst; 
SELECT * FROM translation.nb01_nbi01_eco; 
SELECT * FROM translation.nb01_nbi01_lyr; 
SELECT * FROM translation.nb01_nbi01_nfl;
SELECT * FROM translation.nb01_nbi01_geo;
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
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.nb01_nbi01_geo_test;
CREATE TABLE translation_test.nb01_nbi01_geo_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_geo_test;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.bc08_vri01_cas; 
SELECT * FROM translation.bc08_vri01_dst; 
SELECT * FROM translation.bc08_vri01_eco; 
SELECT * FROM translation.bc08_vri01_lyr; 
SELECT * FROM translation.bc08_vri01_nfl;
SELECT * FROM translation.bc08_vri01_geo;
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
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.bc08_vri01_geo_test;
CREATE TABLE translation_test.bc08_vri01_geo_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_species_validation', '_ab_species_val');
SELECT * FROM TT_Translate_ab_species_val('translation', 'ab_avi01_species');

-------------------------------------------------------
-- BC species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'bc_vri01_species_validation', '_bc_species_val');
SELECT * FROM TT_Translate_bc_species_val('translation', 'bc_vri01_species');

-------------------------------------------------------
-- NB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_species_validation', '_nb_species_val');
SELECT * FROM TT_Translate_nb_species_val('translation', 'nb_nbi01_species');

-------------------------------------------------------
-- AB photo year
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_photoyear_validation', '_ab_photo_val');
SELECT * FROM TT_Translate_ab_photo_val('rawfri', 'ab_photoyear'); -- 5s

-- make table valid and subset by rows with valid photo years
CREATE TABLE rawfri.new_photo_year AS
SELECT TT_GeoMakeValid(wkb_geometry) as wkb_geometry, photo_yr
FROM rawfri.ab_photoyear
WHERE TT_IsInt(photo_yr);

CREATE INDEX ab_photoyear_idx 
 ON rawfri.new_photo_year
 USING GIST(wkb_geometry);

DROP TABLE rawfri.ab_photoyear;
ALTER TABLE rawfri.new_photo_year RENAME TO ab_photoyear;
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
SELECT TT_Prepare('translation_test', 'ab06_avi01_lyr_test', '_ab06_lyr');
SELECT TT_Prepare('translation_test', 'ab06_avi01_nfl_test', '_ab06_nfl');
SELECT TT_Prepare('translation_test', 'ab06_avi01_geo_test', '_ab06_geo');

-- translate the samples (5 sec.)
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06_test_200', 'ogc_fid'); -- 29 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_cas_test');

SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_dst_test');

SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06_test_200', 'ogc_fid'); -- 1 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_eco_test');

SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_lyr_test');

SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_nfl_test');

SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, trm_1, poly_num, cas_id, 
       density, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_per, species_per_1
FROM TT_Translate_ab06_lyr('rawfri', 'ab06_test_200'), rawfri.ab06_test_200
WHERE poly_num = substr(cas_id, 33, 10)::int;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'ab16_avi01_cas_test', '_ab16_cas');
SELECT TT_Prepare('translation_test', 'ab16_avi01_dst_test', '_ab16_dst');
SELECT TT_Prepare('translation_test', 'ab16_avi01_eco_test', '_ab16_eco');
SELECT TT_Prepare('translation_test', 'ab16_avi01_lyr_test', '_ab16_lyr');
SELECT TT_Prepare('translation_test', 'ab16_avi01_nfl_test', '_ab16_nfl');
SELECT TT_Prepare('translation_test', 'ab16_avi01_geo_test', '_ab16_geo');

-- translate the samples
SELECT * FROM TT_Translate_ab16_cas('rawfri', 'ab16_test_200', 'ogc_fid'); -- 13 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_cas_test');

SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_dst_test');

SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_eco_test');

SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_lyr_test');

SELECT * FROM TT_Translate_ab16_nfl('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_nfl_test');

SELECT * FROM TT_Translate_ab16_geo('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, forest_id, ogc_fid, cas_id, 
       crownclose, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_percnt, species_per_1
FROM TT_Translate_ab16_lyr('rawfri', 'ab16_test_200'), rawfri.ab16_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;
-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- create translation function
SELECT TT_Prepare('translation_test', 'nb01_nbi01_cas_test', '_nb01_cas');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_dst_test', '_nb01_dst');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_eco_test', '_nb01_eco');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_lyr_test', '_nb01_lyr');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_nfl_test', '_nb01_nfl');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_geo_test', '_nb01_geo');

-- translate the samples
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_cas_test');

SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_test');

SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_eco_test');

SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_test');

SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_nfl_test');

SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb01_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, stdlab, ogc_fid, cas_id, 
       l1cc, crown_closure_lower, crown_closure_upper, 
       l1ht, height_upper, height_lower, 
       l1s1, species_1,
       l1pr1, species_per_1
FROM TT_Translate_nb01_lyr('rawfri', 'nb01_test_200'), rawfri.nb01_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'bc08_vri01_cas_test', '_bc08_cas');
SELECT TT_Prepare('translation_test', 'bc08_vri01_dst_test', '_bc08_dst');
SELECT TT_Prepare('translation_test', 'bc08_vri01_eco_test', '_bc08_eco');
SELECT TT_Prepare('translation_test', 'bc08_vri01_lyr_test', '_bc08_lyr');
SELECT TT_Prepare('translation_test', 'bc08_vri01_nfl_test', '_bc08_nfl');
SELECT TT_Prepare('translation_test', 'bc08_vri01_geo_test', '_bc08_geo');

-- translate the samples
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_cas_test');

SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_dst_test');

SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_eco_test');

SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_lyr_test');

SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_nfl_test');

SELECT * FROM TT_Translate_bc08_geo('rawfri', 'bc08_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, map_id, ogc_fid, cas_id, 
       crown_closure, crown_closure_lower, crown_closure_upper, 
       proj_height_1, height_upper, height_lower,
       species_cd_1, species_1,
       species_pct_1, species_per_1
FROM TT_Translate_bc08_lyr('rawfri', 'bc08_test_200'), rawfri.bc08_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');


