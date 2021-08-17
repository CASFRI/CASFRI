------------------------------------------------------------------------------
-- CASFRI - NT02 translation development script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Check the uniqueness of NT species codes
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping (nt_species_codes)
WHERE TT_NotEmpty(nt_species_codes);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the samples (reusing NT01 translation functions prepared by NT01.sql)
SELECT TT_CreateMappingView('rawfri', 'nt02', 1, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_cas_devel('rawfri', 'nt02_l1_to_nt_l1_map_200');

SELECT * FROM TT_Translate_nt01_dst_devel('rawfri', 'nt02_l1_to_nt_l1_map_200');

SELECT * FROM TT_Translate_nt01_eco_devel('rawfri', 'nt02_l1_to_nt_l1_map_200');

SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt02_l1_to_nt_l1_map_200');

SELECT TT_CreateMappingView('rawfri', 'nt02', 2, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt02_l2_to_nt_l1_map_200');

SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt02_l1_to_nt_l1_map_200');

SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt02_l2_to_nt_l1_map_200');

SELECT * FROM TT_Translate_nt01_geo_devel('rawfri', 'nt02_l1_to_nt_l1_map_200');

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
