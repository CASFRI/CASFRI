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
-- Translate the samples (reusing NT01 translation functions prepared by NT01.sql)
SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 200);
SELECT * FROM TT_Translate_nt01_cas_devel('rawfri', 'nt02_l1_to_nt_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_cas_devel');

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 200);
SELECT * FROM TT_Translate_nt01_dst_devel('rawfri', 'nt02_l1_to_nt_l1_map_200_dst', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_dst_devel');

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 200);
SELECT * FROM TT_Translate_nt01_eco_devel('rawfri', 'nt02_l1_to_nt_l1_map_200_eco', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_eco_devel');

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 200);
SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt02_l1_to_nt_l1_map_200_lyr', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt02_l2_to_nt_l1_map_200_lyr', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'nt02', 'nt', 200);
SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt02_l1_to_nt_l1_map_200_nfl', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_nfl_devel');

SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt02_l2_to_nt_l1_map_200_nfl', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_nfl_devel');

SELECT * FROM TT_Translate_nt01_geo_devel('rawfri', 'nt02_l1_to_nt_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nt01_fvi01_geo_devel');

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
