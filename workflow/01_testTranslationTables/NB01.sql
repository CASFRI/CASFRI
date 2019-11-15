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
-- Create a 200 random rows views on the source inventory
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Have a look at the source inventory table
SELECT * FROM rawfri.nb01 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.nb01;

-- Create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nb01_test_200;
CREATE OR REPLACE VIEW rawfri.nb01_test_200 AS
SELECT ogc_fid, wkb_geometry, water_code, shape_area, shape_len, src_filename, inventory_id, stdlab, datayr, 
       wc, wri, im, vt, fst, 
       l1trti, l1orig, l1estyr, l1trt, l1trtyr, 
       l1s1, l1ds1, l1pr1, l1s2, l1ds2, l1pr2, 
       l1s3, l1ds3, l1pr3, l1s4, l1ds4, l1pr4, 
       l1s5, l1ds5, l1pr5, l1ds, l1cci, l1cc, 
       l1stock, l1vs, l1ht, l1acs, l1dc, l1sc, l1funa, 
       l2trti, l2orig, l2estyr, l2trt, l2trtyr, 
       l2s1, l2ds1, l2pr1, l2s2, l2ds2, l2pr2, 
       l2s3, l2ds3, l2pr3, l2s4, l2ds4, l2pr4, 
       l2s5, l2ds5, l2pr5, l2ds, l2cci, l2cc, 
       l2stock, l2vs, l2ht, l2acs, l2dc, l2sc, l2funa
FROM rawfri.nb01 TABLESAMPLE SYSTEM (300.0*100/927177) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- Display
SELECT * FROM rawfri.nb01_test_200;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.nb01_nbi01_cas; 
SELECT * FROM translation.nb01_nbi01_dst; 
SELECT * FROM translation.nb01_nbi01_eco; 
SELECT * FROM translation.nb01_nbi01_lyr; 
SELECT * FROM translation.nb01_nbi01_nfl;
SELECT * FROM translation.nb01_nbi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nb01_nbi01_cas_test;
CREATE TABLE translation_test.nb01_nbi01_cas_test AS
SELECT * FROM translation.nb01_nbi01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.nb01_nbi01_dst_test;
CREATE TABLE translation_test.nb01_nbi01_dst_test AS
SELECT * FROM translation.nb01_nbi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_dst_test;
----------------------------
-- dst_layer2
DROP TABLE IF EXISTS translation_test.nb01_nbi01_dst_layer2_test;
CREATE TABLE translation_test.nb01_nbi01_dst_layer2_test AS
SELECT * FROM translation.nb01_nbi01_dst;

-- Update layer and layer_rank translation rules
UPDATE translation_test.nb01_nbi01_dst_layer2_test
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER';

-- Display
SELECT * FROM translation_test.nb01_nbi01_dst_layer2_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.nb01_nbi01_eco_test;
CREATE TABLE translation_test.nb01_nbi01_eco_test AS
SELECT * FROM translation.nb01_nbi01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.nb01_nbi01_lyr_test;
CREATE TABLE translation_test.nb01_nbi01_lyr_test AS
SELECT * FROM translation.nb01_nbi01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_lyr_test;
----------------------------
-- lyr_layer2
DROP TABLE IF EXISTS translation_test.nb01_nbi01_lyr_layer2_test;
CREATE TABLE translation_test.nb01_nbi01_lyr_layer2_test AS
SELECT * FROM translation.nb01_nbi01_lyr;

-- update layer and layer_rank translation rules
UPDATE translation_test.nb01_nbi01_lyr_layer2_test
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- Display
SELECT * FROM translation_test.nb01_nbi01_lyr_layer2_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.nb01_nbi01_nfl_test;
CREATE TABLE translation_test.nb01_nbi01_nfl_test AS
SELECT * FROM translation.nb01_nbi01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.nb01_nbi01_geo_test;
CREATE TABLE translation_test.nb01_nbi01_geo_test AS
SELECT * FROM translation.nb01_nbi01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- NB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_species_validation', '_nb_species_val');
SELECT * FROM TT_Translate_nb_species_val('translation', 'nb_nbi01_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-------------------------------------------------------
-- Create translation function
SELECT TT_Prepare('translation_test', 'nb01_nbi01_cas_test', '_nb01_cas_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_dst_test', '_nb01_dst_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_dst_layer2_test', '_nb01_dst_layer2_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_eco_test', '_nb01_eco_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_lyr_test', '_nb01_lyr_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_lyr_layer2_test', '_nb01_lyr_layer2_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_nfl_test', '_nb01_nfl_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_geo_test', '_nb01_geo_test');

-- Create a view mapping the layer 2 attributes to the layer 1 attributes
CREATE OR REPLACE VIEW rawfri.nb01_lyr_layer2_test_200 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid,
l2estyr l1estyr,
l2cc l1cc, l2ht l1ht,
l2s1 l1s1, l2pr1 l1pr1,
l2s2 l1s2, l2pr2 l1pr2,
l2s3 l1s3, l2pr3 l1pr3,
l2s4 l1s4, l2pr4 l1pr4,
l2s5 l1s5, l2pr5 l1pr5
FROM rawfri.nb01_test_200;

-- Create a view mapping the dst 2 attribute to the dst 1 attributes
CREATE OR REPLACE VIEW rawfri.nb01_dst_layer2_test_200 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid,
l2trt l1trt,	
l2trtyr l1trtyr
FROM rawfri.nb01_test_200;

-- translate the samples
SELECT * FROM TT_Translate_nb01_cas_test('rawfri', 'nb01_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_cas_test');

SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb01_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_test');

SELECT * FROM TT_Translate_nb01_dst_layer2_test('rawfri', 'nb01_dst_layer2_test_200', 'ogc_fid'); -- 3 s
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_layer2_test');

SELECT * FROM TT_Translate_nb01_eco_test('rawfri', 'nb01_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_eco_test');

SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_test');

SELECT * FROM TT_Translate_nb01_lyr_layer2_test('rawfri', 'nb01_lyr_layer2_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_layer2_test');

SELECT * FROM TT_Translate_nb01_nfl_test('rawfri', 'nb01_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_nfl_test');

SELECT * FROM TT_Translate_nb01_geo_test('rawfri', 'nb01_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_geo_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, inventory_id, stdlab, ogc_fid, cas_id, 
       l1cc, crown_closure_lower, crown_closure_upper, 
       l1ht, height_upper, height_lower, 
       l1s1, species_1,
       l1pr1, species_per_1
FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_test_200'), rawfri.nb01_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
