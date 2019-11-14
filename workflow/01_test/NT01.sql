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
----------------------------------------
-- Which translation tables to use?
----------------------------------------
-- CAS - nt01_fvi01_cas.csv
-- DST - nt01_fvi01_dst.csv
-- GEO - nt01_fvi01_geo.csv
-- LYR1 - nt01_fvi01_lyr.csv
-- LYR2 - nt01_fvi01_lyr.csv
   -- copyInt('1') should be changed to copyInt('2') for LAYER attribute
-- NFL1 - nt01_fvi01_nfl.csv
-- NFL2 - nt01_fvi01_nfl.csv
  -- copyInt('1') should be changed to copyInt('2') for LAYER attribute
----------------------------------------
-- Mappings for VIEWs
----------------------------------------
-- LYR 2 table requires VIEW mapping:
  -- minmoist to moisture
  -- mincrowncl to crownclos
  -- minheight to height
  -- minsp1 to sp1
  -- minsp1per to sp1_per
  -- minsp2 to sp2
  -- minsp2per to sp2per
  -- minsp3 to sp3
  -- minsp3per to sp3per
  -- minsp4 to sp4
  -- minsp4per to sp4per
  -- minorigin to origin
  -- minsitecla to siteclass
-- NFL 2 table requires VIEW mapping:
  -- minmoist to moisture
  -- mincrowncl to crownclos
  -- minheight to height
  -- mintypecla to typeclas
  
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-------------------------------------------------------
-------------------------------------------------------
-- Create 200 random rows views on each source inventory
-------------------------------------------------------
-------------------------------------------------------
-- NT01
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.nt01 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.nt01;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nt01_test_200;
CREATE OR REPLACE VIEW rawfri.nt01_test_200 AS
SELECT src_filename, invproj_id, fc_id_1, ogc_fid, wkb_geometry, areaha, 
       moisture, crownclos, height, siteclass, si_50, 
       sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, 
       structur, strc_per, origin, typeclas, 
       dis1code, dis1year, dis1ext, ref_year, inventory_id,
	   minmoist, mincrowncl, minheight, 
	   minsp1, minsp1per, minsp2, minsp2per, minsp3, minsp3per, minsp4, minsp4per, 
	   minorigin, minsitecla, mintypecla
FROM rawfri.nt01 TABLESAMPLE SYSTEM (300.0*100/11484) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;



-- display
SELECT * FROM rawfri.nt01_test_200;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--CREATE SCHEMA translation_test;

-------------------------------------------------------
-- NT01
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.nt01_fvi01_cas; 
SELECT * FROM translation.nt01_fvi01_dst; 
--SELECT * FROM translation.nt01_fvi01_eco; 
SELECT * FROM translation.nt01_fvi01_lyr; 
SELECT * FROM translation.nt01_fvi01_nfl;
SELECT * FROM translation.nt01_fvi01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nt01_fvi01_cas_test;
CREATE TABLE translation_test.nt01_fvi01_cas_test AS
SELECT * FROM translation.nt01_fvi01_cas
--WHERE rule_id::int < 10
;
-- display
SELECT * FROM translation_test.nt01_fvi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.nt01_fvi01_dst_test;
CREATE TABLE translation_test.nt01_fvi01_dst_test AS
SELECT * FROM translation.nt01_fvi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_dst_test;
----------------------------
-- eco
--DROP TABLE IF EXISTS translation_test.nt01_fvi01_eco_test;
--CREATE TABLE translation_test.nt01_fvi01_eco_test AS
--SELECT * FROM translation.nt01_fvi01_eco
--WHERE rule_id::int = 1
--;
-- display
--SELECT * FROM translation_test.nt01_fvi01_eco_test;
----------------------------
-- lyr1
DROP TABLE IF EXISTS translation_test.nt01_fvi01_lyr_test;
CREATE TABLE translation_test.nt01_fvi01_lyr_test AS
SELECT * FROM translation.nt01_fvi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_lyr_test;

-- lyr2
DROP TABLE IF EXISTS translation_test.nt01_fvi01_lyr_layer2_test;
CREATE TABLE translation_test.nt01_fvi01_lyr_layer2_test AS
SELECT * FROM translation.nt01_fvi01_lyr;
-- Update layer and layer_rank translation rules
UPDATE translation_test.nt01_fvi01_lyr_layer2_test
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- nfl
DROP TABLE IF EXISTS translation_test.nt01_fvi01_nfl_test;
CREATE TABLE translation_test.nt01_fvi01_nfl_test AS
SELECT * FROM translation.nt01_fvi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_nfl_test;

-- nfl2
DROP TABLE IF EXISTS translation_test.nt01_fvi01_nfl_layer2_test;
CREATE TABLE translation_test.nt01_fvi01_nfl_layer2_test AS
SELECT * FROM translation.nt01_fvi01_nfl;
-- Update layer and layer_rank translation rules
UPDATE translation_test.nt01_fvi01_nfl_layer2_test
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- geo
DROP TABLE IF EXISTS translation_test.nt01_fvi01_geo_test;
CREATE TABLE translation_test.nt01_fvi01_geo_test AS
SELECT * FROM translation.nt01_fvi01_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_test.nt01_fvi01_geo_test;
----------------------------

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- NT species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_species_validation', '_nt_species_val');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_fvi01_species');
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- NT01
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'nt01_fvi01_cas_test', '_nt01_cas_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_dst_test', '_nt01_dst_test');
--SELECT TT_Prepare('translation_test', 'nt01_fvi01_eco_test', '_nt01_eco_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_lyr_test', '_nt01_lyr_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_lyr_layer2_test', '_nt01_lyr_layer2_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_nfl_test', '_nt01_nfl_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_nfl_layer2_test', '_nt01_nfl_layer2_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_geo_test', '_nt01_geo_test');

-- Create a view mapping the layer 2 attributes to the layer 1 attributes
CREATE OR REPLACE VIEW rawfri.nt01_lyr_layer2_test_200 AS
SELECT src_filename, inventory_id, invproj_id, fc_id_1, ogc_fid, strc_per, si_50,
minmoist moisture, mincrowncl crownclos, minheight height,
minsp1 sp1, minsp1per sp1_per,
minsp2 sp2, minsp2per sp2per,
minsp3 sp3, minsp3per sp3per,
minsp4 sp4, minsp4per sp4per,
minorigin origin, minsitecla siteclass
FROM rawfri.nt01_test_200;

-- Create a view mapping the nfl 2 attributes to the nfl 1 attributes
CREATE OR REPLACE VIEW rawfri.nt01_nfl_layer2_test_200 AS
SELECT src_filename, inventory_id, invproj_id, fc_id_1, ogc_fid, strc_per,
minmoist moisture, mincrowncl crownclos, minheight height,
mintypecla typeclas
FROM rawfri.nt01_test_200;

-- translate the samples (5 sec.)
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_cas_test');

SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_dst_test');

--SELECT * FROM TT_Translate_nt01_eco('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
--SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_eco_test');

SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

SELECT * FROM TT_Translate_nt01_lyr_layer2_test('rawfri', 'nt01_lyr_layer2_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_layer2_test');

SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

SELECT * FROM TT_Translate_nt01_nfl_layer2_test('rawfri', 'nt01_nfl_layer2_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_layer2_test');

SELECT * FROM TT_Translate_nt01_geo_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_geo_test');
