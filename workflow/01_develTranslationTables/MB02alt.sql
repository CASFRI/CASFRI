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
-- Check the uniqueness of MB species codes
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the samples (reusing mb06 translation functions prepared by mb06.sql)
SELECT TT_CreateMappingView('rawfri', 'mb02', 1, 'mb_fli', 1, 200);
SELECT * FROM TT_Translate_mb06_cas_devel('rawfri', 'mb02_l1_to_mb_l1_map_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_cas_devel');

SELECT * FROM TT_Translate_mb06_dst_devel('rawfri', 'mb02_l1_to_mb_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_dst_devel');

SELECT * FROM TT_Translate_mb06_eco_devel('rawfri', 'mb02_l1_to_mb_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_eco_devel');

SELECT * FROM TT_Translate_mb06_lyr_devel('rawfri', 'mb02_l1_to_mb_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'mb02', 2, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_lyr_devel('rawfri', 'mb02_l2_to_mb_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_lyr_devel');

SELECT TT_CreateMappingView('rawfri', 'mb02', 3, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_nfl_devel('rawfri', 'mb02_l3_to_mb_l1_map_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_nfl_devel');

SELECT * FROM TT_Translate_mb06_geo_devel('rawfri', 'mb02_l1_to_mb_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_geo_devel');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_mb06_lyr_devel('rawfri', 'mb02_l1_to_mb_l1_map_200') a, rawfri.mb02_l1_to_mb_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
