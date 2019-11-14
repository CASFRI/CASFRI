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
-- NFL - nt01_fvi01_nfl.csv
----------------------------------------
-- Mappings for VIEWs
----------------------------------------
-- All tables require a VIEW that maps:
  -- fc_id to fc_id_1
    -- used in cas_id
-- LYR 2 table requires VIEW mapping:
  -- minmoist to moisture
  -- mincrownclos to crownclos
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
  -- minsiteclass to siteclass
-- NFL 2 table requires VIEW mapping:
  -- mintypeclas to typeclas
  

-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create a 200 random rows views on the source inventory
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Have a look at the source inventory table
SELECT * FROM rawfri.nt02 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.nt02;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nt02_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_test_200 AS
SELECT invproj_id, fc_id, ogc_fid, wkb_geometry, areaha, inventory_id, 
       moisture, crownclos, height, siteclass, si_50, 
       sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, 
       structur, strc_per, origin, typeclas, 
       dis1code, dis1year, dis1ext, ref_year
FROM rawfri.nt02 TABLESAMPLE SYSTEM (300.0*100/11484) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.nt02_test_200;

--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS translation_test;

-- NB species table
SELECT TT_Prepare('translation', 'nt_fvi01_species_validation', '_nt_species_val');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_fvi01_species');

-- NT02 CAS 

--reuse most of NT01 translation tables 
DROP TABLE IF EXISTS translation_test.nt02_fvi01_cas_test;
CREATE TABLE translation_test.nt02_fvi01_cas_test AS
SELECT * FROM translation.nt01_fvi01_cas;
SELECT * FROM translation_test.nt02_fvi01_cas_test;

-- Create a view mapping the nb02 cas attributes to the nb01 cas attributes
DROP VIEW IF EXISTS rawfri.nt02_cas_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_cas_test_200 AS
SELECT invproj_id, inventory_id, ogc_fid, wkb_geometry, areaha, ref_year, structur, 
fc_id fc_id_1 
FROM rawfri.nt02_test_200;
SELECT * FROM rawfri.nt02_cas_test_200;

-- Translate the samples (reuse most of NT01 translation functions)
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt02_cas_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_cas_test');

-- NT02 LYR

-- Reuse most of NT01 translation tables 
DROP TABLE IF EXISTS translation_test.nt02_fvi01_lyr_test;
CREATE TABLE translation_test.nt02_fvi01_lyr_test AS
SELECT * FROM translation.nt01_fvi01_lyr;
SELECT * FROM translation_test.nt02_fvi01_lyr_test;

-- Create a view mapping the nb02 lyr attributes to the nb01 lyr attributes
DROP VIEW IF EXISTS rawfri.nt02_lyr_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_lyr_test_200 AS
SELECT invproj_id, inventory_id, ogc_fid, wkb_geometry, 
moisture, strc_per, crownclos, height, 
sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per,
origin, siteclass, si_50,
fc_id fc_id_1 
FROM rawfri.nt02_test_200;
SELECT * FROM rawfri.nt02_lyr_test_200;

-- Translate the samples (reuse most of NT01 translation functions)
SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt02_lyr_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

-- NT02 NFL

-- Reuse most of NT01 translation tables 
DROP TABLE IF EXISTS translation_test.nt02_fvi01_nfl_test;
CREATE TABLE translation_test.nt02_fvi01_nfl_test AS
SELECT * FROM translation.nt01_fvi01_nfl;
SELECT * FROM translation_test.nt02_fvi01_nfl_test;

-- Create a view mapping the nb02 nfl attributes to the nb01 nfl attributes
DROP VIEW IF EXISTS rawfri.nt02_nfl_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_nfl_test_200 AS
SELECT invproj_id, inventory_id, ogc_fid, wkb_geometry, 
moisture, strc_per, crownclos, height, typeclas, 
sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per,
origin, siteclass, si_50,
fc_id fc_id_1 
FROM rawfri.nt02_test_200;
SELECT * FROM rawfri.nt02_nfl_test_200;

-- Translate the samples (reuse most of NT01 translation functions)
SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt02_nfl_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

-- NT02 DST

-- Reuse most of NT01 translation tables 
DROP TABLE IF EXISTS translation_test.nt02_fvi01_dst_test;
CREATE TABLE translation_test.nt02_fvi01_dst_test AS
SELECT * FROM translation.nt01_fvi01_dst;
SELECT * FROM translation_test.nt02_fvi01_dst_test;

-- Create a view mapping the nb02 dst attributes to the nb01 dst attributes
DROP VIEW IF EXISTS rawfri.nt02_dst_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_dst_test_200 AS
SELECT invproj_id, inventory_id, ogc_fid, wkb_geometry, 
dis1code, dis1year, dis1ext,
fc_id fc_id_1 
FROM rawfri.nt02_test_200;
SELECT * FROM rawfri.nt02_dst_test_200;

-- Translate the samples (reuse most of NT01 translation functions)
SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt02_dst_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_dst_test');

-- NT02 GEO

-- Reuse most of NT01 translation tables 
DROP TABLE IF EXISTS translation_test.nt02_fvi01_geo_test;
CREATE TABLE translation_test.nt02_fvi01_geo_test AS
SELECT * FROM translation.nt01_fvi01_geo;
SELECT * FROM translation_test.nt02_fvi01_geo_test;

-- Create a view mapping the nb02 geo attributes to the nb01 geo attributes
DROP VIEW IF EXISTS rawfri.nt02_geo_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_geo_test_200 AS
SELECT invproj_id, inventory_id, ogc_fid, wkb_geometry, 
fc_id fc_id_1 
FROM rawfri.nt02_test_200;
SELECT * FROM rawfri.nt02_geo_test_200;

-- Translate the samples (reuse most of NT01 translation functions)
SELECT * FROM TT_Translate_nt01_geo_test('rawfri', 'nt02_geo_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_geo_test');

-- CHECK FULL TEST RESULTS
-- Display original values and translated values side-by-side to compare and debug the translation table
--SELECT src_filename, inventory_id, stdlab, ogc_fid, cas_id, 
--       l1cc, crown_closure_lower, crown_closure_upper, 
--       l1ht, height_upper, height_lower, 
--       l1s1, species_1,
--       l1pr1, species_per_1
--FROM TT_Translate_nb01_lyr_test('rawfri', 'nb02_lyr_layer1_test_200'), rawfri.nb02_test_200
--WHERE ogc_fid::int = right(cas_id, 7)::int;

--------------------------------------------------------------------------
--SELECT TT_DeleteAllLogs('translation_test');


-- change 'fc_id_1' to 'fc_id' in validation rules
--UPDATE translation_test.nt02_fvi01_cas_test
--SET validation_rules = regexp_replace(validation_rules, 'fc_id_1', 'fc_id', 'g')
--WHERE rule_id IN ('1','2');

