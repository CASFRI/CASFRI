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
SELECT invproj_id, fc_id_1, ogc_fid, wkb_geometry, areaha, 
       moisture, crownclos, height, siteclass, si_50, 
       sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, 
       structur, strc_per, origin, typeclas, 
       dis1code, dis1year, dis1ext, ref_year, inventory_id
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
-- lyr
DROP TABLE IF EXISTS translation_test.nt01_fvi01_lyr_test;
CREATE TABLE translation_test.nt01_fvi01_lyr_test AS
SELECT * FROM translation.nt01_fvi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_lyr_test;

-- nfl
DROP TABLE IF EXISTS translation_test.nt01_fvi01_nfl_test;
CREATE TABLE translation_test.nt01_fvi01_nfl_test AS
SELECT * FROM translation.nt01_fvi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nt01_fvi01_nfl_test;
----------------------------
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
SELECT TT_Prepare('translation_test', 'nt01_fvi01_nfl_test', '_nt01_nfl_test');
SELECT TT_Prepare('translation_test', 'nt01_fvi01_geo_test', '_nt01_geo_test');

-- translate the samples (5 sec.)
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_cas_test');

SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_dst_test');

--SELECT * FROM TT_Translate_nt01_eco('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
--SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_eco_test');

SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

SELECT * FROM TT_Translate_nt01_geo_test('rawfri', 'nt01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_geo_test');
