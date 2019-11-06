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
SELECT * FROM rawfri.nb02 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.nb02;

-- Create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nb02_test_200;
CREATE OR REPLACE VIEW rawfri.nb02_test_200 AS
SELECT ogc_fid, wkb_geometry, water_code, shape_area, shape_leng, src_filename, inventory_id, stdlab, datayr, 
       lc, wc, wri, im, vt, fst, sitei, voli, origin, trt, trtyr, 
       h1, h1yr, h2, h2yr, h3, h3yr, h4, h4yr, rf, rfyr, 
       si, siyr, untreati, lpriority, 
       l1datasrc, l1datayr, l1funa, l1estabyr, l1aryr, 
       l1s1, l1ds1, l1pr1, l1s2, l1ds2, l1pr2, l1s3, l1ds3, l1pr3, 
       l1s4, l1ds4, l1pr4, l1s5, l1ds5, l1pr5, 
       l1ds, l1cci, l1cc, l1vol, l1ba, l1pstock, 
       l1vs, l1ht, l1dc, l1sc, l2datasrc, l2datayr, l2funa, l2estabyr, l2aryr, 
       l2s1, l2ds1, l2pr1, l2s2, l2ds2, l2pr2, l2s3, l2ds3, l2pr3, 
       l2s4, l2ds4, l2pr4, l2s5, l2ds5, l2pr5, 
       l2ds, l2cci, l2cc, l2pstock, l2nstock, l2vs, l2ht, l2dc 
FROM rawfri.nb02 TABLESAMPLE SYSTEM (300.0*100/1123893) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- Display
SELECT * FROM rawfri.nb02_test_200;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- NB02 reuse most of NB01 translation tables 
----------------------------
-- lyr_layer2
DROP TABLE IF EXISTS translation_test.nb02_nbi01_lyr_layer2_test;
CREATE TABLE translation_test.nb02_nbi01_lyr_layer2_test WITH OIDS AS
SELECT * FROM translation_test.nb01_nbi01_lyr_test;

-- Update layer and layer_rank translation rules
UPDATE translation_test.nb02_nbi01_lyr_layer2_test
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- Display
SELECT * FROM translation_test.nb02_nbi01_lyr_layer2_test;

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
-- Create translation function
SELECT TT_Prepare('translation_test', 'nb02_nbi01_lyr_layer2_test', '_nb02_lyr_layer2_test');

-- Create a view mapping the nb02 layer 1 attributes to the nb01 layer 1 attributes
CREATE OR REPLACE VIEW rawfri.nb02_lyr_layer1_test_200 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid, l1cc, l1ht, l1s1, l1pr1, l1s2, l1pr2, 
l1s3, l1pr3, l1s4, l1pr4, l1s5, l1pr5,
l1estabyr l1estyr
FROM rawfri.nb02_test_200;

-- Create a view mapping the nb02 layer 2 attributes to the nb01 layer 1 attributes
CREATE OR REPLACE VIEW rawfri.nb02_lyr_layer2_test_200 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid, 
l2cc l1cc, l2ht l1ht, 
l2s1 l1s1, l2pr1 l1pr1, 
l2s2 l1s2, l2pr2 l1pr2, 
l2s3 l1s3, l2pr3 l1pr3, 
l2s4 l1s4, l2pr4 l1pr4, 
l2s5 l1s5, l2pr5 l1pr5,
l2estabyr l1estyr
FROM rawfri.nb02_test_200;

-- Create a view mapping the nb02 dst attributes to the nb01 dst attributes
CREATE OR REPLACE VIEW rawfri.nb02_dst_test_200 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid, 
trt l1trt,
trtyr l1trtyr
FROM rawfri.nb02_test_200;

-- Translate the samples (reuse most of NB01 translation functions)
SELECT * FROM TT_Translate_nb01_cas_test('rawfri', 'nb02_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_cas_test');

SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb02_dst_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_test');

SELECT * FROM TT_Translate_nb01_eco_test('rawfri', 'nb02_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_eco_test');

SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb02_lyr_layer1_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_test');

SELECT * FROM TT_Translate_nb02_lyr_layer2_test('rawfri', 'nb02_lyr_layer2_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb02_nbi01_lyr_layer2_test');

SELECT * FROM TT_Translate_nb01_nfl_test('rawfri', 'nb02_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_nfl_test');

SELECT * FROM TT_Translate_nb01_geo_test('rawfri', 'nb02_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_geo_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, inventory_id, stdlab, ogc_fid, cas_id, 
       l1cc, crown_closure_lower, crown_closure_upper, 
       l1ht, height_upper, height_lower, 
       l1s1, species_1,
       l1pr1, species_per_1
FROM TT_Translate_nb01_lyr_test('rawfri', 'nb02_lyr_layer1_test_200'), rawfri.nb02_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
