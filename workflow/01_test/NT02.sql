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
SELECT * FROM rawfri.nt02 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.nt02;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nt02_test_200;
CREATE OR REPLACE VIEW rawfri.nt02_test_200 AS
SELECT invproj_id, fc_id, ogc_fid, wkb_geometry, areaha, 
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
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_test;
-------------------------------------------------------
-- NT02 reuse most of NT01 translation tables 
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nt02_fvi01_cas_test;
CREATE TABLE translation_test.nt02_fvi01_cas_test WITH OIDS AS
SELECT * FROM translation.nt01_fvi01_cas;

-- Update cas_id translation rules
--UPDATE translation_test.nt02_fvi01_cas_test
--SET translation_rules = 'copyInt(''2'')'
--WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- Update cas_id
UPDATE translation_test.nt02_fvi01_cas_test
SET translation_rules = regexp_replace(translation_rules, 'nt01', 'nt02')
WHERE rule_id = '1';

-- change 'fc_id_1' to 'fc_id' in validation rules
--UPDATE translation_test.nt02_fvi01_cas_test
--SET validation_rules = regexp_replace(validation_rules, 'fc_id_1', 'fc_id', 'g')
--WHERE rule_id IN ('1','2');

-- Display
SELECT * FROM translation_test.nt02_fvi01_cas_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- NB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_species_validation', '_nt_species_val');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_fvi01_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation function
--SELECT TT_Prepare('translation_test', 'nt02_fvi02_cas_test', '_nt02_cas_test');

-- Create a view mapping the nb02 dst attributes to the nb01 dst attributes
CREATE OR REPLACE VIEW rawfri.nt02_cas_test_200 AS
SELECT invproj_id, ogc_fid, wkb_geometry, areaha, ref_year, 
fc_id fc_id_1 
FROM rawfri.nt02_test_200;
--SELECT * FROM rawfri.nt02_test_200;

-- Translate the samples (reuse most of NT01 translation functions)
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt02_test_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_cas_test');

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
