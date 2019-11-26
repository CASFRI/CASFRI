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

-- Create a 200 rows test view on the inventory table
SELECT TT_CreateMappingView('rawfri', 'nb01', 200);

-- Display
SELECT * FROM rawfri.nb01_min_200;

-- Refine the view to test with one row if necessary
DROP VIEW IF EXISTS rawfri.nb01_min_200_test;
CREATE VIEW rawfri.nb01_min_200_test AS
SELECT * FROM rawfri.nb01_min_200
WHERE ogc_fid = 373;

-- Display
SELECT * FROM rawfri.nb01_min_200_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.nbi01_cas; 
SELECT * FROM translation.nbi01_dst; 
SELECT * FROM translation.nbi01_eco; 
SELECT * FROM translation.nbi01_lyr; 
SELECT * FROM translation.nbi01_nfl;
SELECT * FROM translation.nbi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nb01_nbi01_cas_test;
CREATE TABLE translation_test.nb01_nbi01_cas_test AS
SELECT * FROM translation.nbi01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.nb01_nbi01_dst_test;
CREATE TABLE translation_test.nb01_nbi01_dst_test AS
SELECT * FROM translation.nbi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.nb01_nbi01_eco_test;
CREATE TABLE translation_test.nb01_nbi01_eco_test AS
SELECT * FROM translation.nbi01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.nb01_nbi01_lyr_test;
CREATE TABLE translation_test.nb01_nbi01_lyr_test AS
SELECT * FROM translation.nbi01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.nb01_nbi01_nfl_test;
CREATE TABLE translation_test.nb01_nbi01_nfl_test AS
SELECT * FROM translation.nbi01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.nb01_nbi01_geo_test;
CREATE TABLE translation_test.nb01_nbi01_geo_test AS
SELECT * FROM translation.nbi01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_test.nb01_nbi01_geo_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate the NB species dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_species_validation', '_nb_species_val');
SELECT * FROM TT_Translate_nb_species_val('translation', 'nb_nbi01_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Prepare translation function
SELECT TT_Prepare('translation_test', 'nb01_nbi01_cas_test', '_nb01_cas_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_dst_test', '_nb01_dst_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_eco_test', '_nb01_eco_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_lyr_test', '_nb01_lyr_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_nfl_test', '_nb01_nfl_test');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_geo_test', '_nb01_geo_test');

-- Create VIEW 'nb01_l2_to_nb01_l1_map_200' mapping the NB01 layer 2 
-- attributes to the NB01 layer 1 attributes
SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb01', 1, 200);

-- Translate the samples
SELECT * FROM TT_Translate_nb01_cas_test('rawfri', 'nb01_min_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_cas_test');

SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb01_min_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_test');

SELECT * FROM TT_Translate_nb01_dst_test('rawfri', 'nb01_l2_to_nb01_l1_map_200', 'ogc_fid'); -- 3 s
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_test');

SELECT * FROM TT_Translate_nb01_eco_test('rawfri', 'nb01_min_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_eco_test');

SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_min_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_test');

SELECT * FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_l2_to_nb01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_test');

SELECT * FROM TT_Translate_nb01_nfl_test('rawfri', 'nb01_min_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_nfl_test');

SELECT * FROM TT_Translate_nb01_geo_test('rawfri', 'nb01_min_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_geo_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_nb01_lyr_test('rawfri', 'nb01_min_200') a, rawfri.nb01_min_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
