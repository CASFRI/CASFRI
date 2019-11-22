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

-- Create a 200 rows test view of the inventory table 
-- mapping the NT02 attributes on the NT01 attributes
-- in order to reuse the NT01 translation table
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt01', 200);

-- Display
SELECT * FROM rawfri.nt02_l1_to_nt01_l1_map_200;

-- Refine the view to test with one row if necessary
DROP VIEW IF EXISTS rawfri.nt02_l1_to_nt01_l1_map_200_test;
CREATE VIEW rawfri.nt02_l1_to_nt01_l1_map_200_test AS
SELECT * FROM rawfri.nt02_l1_to_nt01_l1_map_200
WHERE ogc_fid = 129;

-- Display
SELECT * FROM rawfri.nt02_l1_to_nt01_l1_map_200_test;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate NT species dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
SELECT TT_Prepare('translation', 'nt_fvi01_species_validation', '_nt_species_val');
SELECT * FROM TT_Translate_nt_species_val('translation', 'nt_fvi01_species');

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create VIEW 'nt02_l2_to_nt01_l1_map_200' mapping the NT02 layer 2 
-- attributes to the NT01 layer 1 attributes
SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt01', 1, 200);

-- Translate the samples (reusing NT01 translation functions prepared by NT01.sql)
SELECT * FROM TT_Translate_nt01_cas_test('rawfri', 'nt02_l1_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_cas_test');

SELECT * FROM TT_Translate_nt01_dst_test('rawfri', 'nt02_l1_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_dst_test');

SELECT * FROM TT_Translate_nt01_eco_test('rawfri', 'nt02_l1_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_eco_test');

SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt02_l1_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

SELECT * FROM TT_Translate_nt01_lyr_test('rawfri', 'nt02_l2_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_lyr_test');

SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt02_l1_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

SELECT * FROM TT_Translate_nt01_nfl_test('rawfri', 'nt02_l2_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_nfl_test');

SELECT * FROM TT_Translate_nt01_geo_test('rawfri', 'nt02_l1_to_nt01_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_test', 'nt01_fvi01_geo_test');

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');
