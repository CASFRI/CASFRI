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
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Check the uniqueness of MB species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (mb_species_codes)
WHERE TT_NotEmpty(mb_species_codes);

--SELECT TT_DeleteAllViews('rawfri');

-- CAS ATTRIBUTES
SELECT * FROM translation.mb_fli01_cas;
DROP TABLE IF EXISTS translation_devel.mb06_fli01_cas_devel;
CREATE TABLE translation_devel.mb06_fli01_cas_devel AS
SELECT * FROM translation.mb_fli01_cas;
--WHERE rule_id::int <> 5;
SELECT * FROM translation_devel.mb06_fli01_cas_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_cas_devel', '_mb06_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 'mb', 200);
SELECT * FROM TT_Translate_mb06_cas_devel('rawfri', 'mb06_l1_to_mb_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_cas_devel');

-- LYR1 ATTRIBUTES
SELECT * FROM translation.mb_fli01_lyr;
DROP TABLE IF EXISTS translation_devel.mb06_fli01_lyr_devel;
CREATE TABLE translation_devel.mb06_fli01_lyr_devel AS
SELECT * FROM translation.mb_fli01_lyr; 
--WHERE rule_id::int != 4;
SELECT * FROM translation_devel.mb06_fli01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_lyr_devel', '_mb06_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_lyr_devel('rawfri', 'mb06_l1_to_mb_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_lyr_devel');

-- DST ATTRIBUTES
SELECT * FROM translation.mb_fli01_dst;
DROP TABLE IF EXISTS translation_devel.mb06_fli01_dst_devel;
CREATE TABLE translation_devel.mb06_fli01_dst_devel AS
SELECT * FROM translation.mb_fli01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.mb06_fli01_dst_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_dst_devel', '_mb06_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_dst_devel('rawfri', 'mb06_l1_to_mb_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_dst_devel');

SELECT a.cas_id, b.dist_type_1, a.dist_type_1, a.dist_type_2 
FROM TT_Translate_mb06_dst_devel('rawfri', 'mb06_l1_to_mb_l1_map_200') a, rawfri.mb06_l1_to_mb_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

-- NFL ATTRIBUTES
SELECT * FROM translation.mb_fli01_nfl;
DROP TABLE IF EXISTS translation_devel.mb06_fli01_nfl_devel;
CREATE TABLE translation_devel.mb06_fli01_nfl_devel AS
SELECT * FROM translation.mb_fli01_nfl;
--WHERE rule_id::int != 4; --IN (0,1,2,3);
SELECT * FROM translation_devel.mb06_fli01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_nfl_devel', '_mb06_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 2, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_nfl_devel('rawfri', 'mb06_l2_to_mb_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_nfl_devel');

-- ECO ATTRIBUTES
SELECT * FROM translation.mb_fli01_eco;
DROP TABLE IF EXISTS translation_devel.mb06_fli01_eco_devel;
CREATE TABLE translation_devel.mb06_fli01_eco_devel AS
SELECT * FROM translation.mb_fli01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.mb06_fli01_eco_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_eco_devel', '_mb06_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_eco_devel('rawfri', 'mb06_l1_to_mb_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_nfl_devel');

-- GEO ATTRIBUTES
SELECT * FROM translation.mb_fli01_geo;
DROP TABLE IF EXISTS translation_devel.mb06_fli01_geo_devel;
CREATE TABLE translation_devel.mb06_fli01_geo_devel AS
SELECT * FROM translation.mb_fli01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.mb06_fli01_geo_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_geo_devel', '_mb06_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb', 1, 200);
SELECT * FROM TT_Translate_mb06_geo_devel('rawfri', 'mb06_l1_to_mb_l1_map_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'mb06_fli01_geo_devel');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_mb06_lyr_devel('rawfri', 'mb06_l1_to_mb_l1_map_200') a, rawfri.mb06_l1_to_mb_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
