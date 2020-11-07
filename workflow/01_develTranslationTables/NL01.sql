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

-- Check the uniqueness of NL species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);

-- CAS ATTRIBUTES
SELECT * FROM translation.nl_nli01_cas;
DROP TABLE IF EXISTS translation_devel.nl01_nli01_cas_devel;
CREATE TABLE translation_devel.nl01_nli01_cas_devel AS SELECT * FROM translation.nl_nli01_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl01_nli01_cas_devel;
SELECT TT_Prepare('translation_devel', 'nl01_nli01_cas_devel', '_nl01_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 200);
SELECT * FROM TT_Translate_nl01_cas_devel('rawfri', 'nl01_l1_to_nl_nli_l1_map_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_nli01_cas_devel', 'nl01_l1_to_nl_nli_l1_map_200')


-- LYR ATTRIBUTES
SELECT * FROM translation.nl_nli01_lyr;
DROP TABLE IF EXISTS translation_devel.nl01_nli01_lyr_devel;
CREATE TABLE translation_devel.nl01_nli01_lyr_devel AS SELECT * FROM translation.nl_nli01_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl01_nli01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'nl01_nli01_lyr_devel', '_nl01_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 200);
SELECT * FROM TT_Translate_nl01_lyr_devel('rawfri', 'nl01_l1_to_nl_nli_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_nli01_lyr_devel', 'nl01_l1_to_nl_nli_l1_map_200') ORDER BY message;


-- DST ATTRIBUTES
SELECT * FROM translation.nl_nli01_dst;
DROP TABLE IF EXISTS translation_devel.nl01_nli01_dst_devel;
CREATE TABLE translation_devel.nl01_nli01_dst_devel AS SELECT * FROM translation.nl_nli01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl01_nli01_dst_devel;
SELECT TT_Prepare('translation_devel', 'nl01_nli01_dst_devel', '_nl01_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 2000);
SELECT * FROM TT_Translate_nl01_dst_devel('rawfri', 'nl01_l1_to_nl_nli_l1_map_2000', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_nli01_dst_devel', 'nl01_l1_to_nl_nli_l1_map_2000');


-- NFL ATTRIBUTES
SELECT * FROM translation.nl_nli01_nfl;
DROP TABLE IF EXISTS translation_devel.nl01_nli01_nfl_devel;
CREATE TABLE translation_devel.nl01_nli01_nfl_devel AS
SELECT * FROM translation.nl_nli01_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl01_nli01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'nl01_nli01_nfl_devel', '_nl01_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'nl01', 2, 'nl_nli', 1, 200);
SELECT * FROM TT_Translate_nl01_nfl_devel('rawfri', 'nl01_l2_to_nl_nli_l1_map_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_nli01_nfl_devel', 'nl01_l2_to_nl_nli_l1_map_200');


-- ECO ATTRIBUTES
SELECT * FROM translation.nl_nli01_eco;
DROP TABLE IF EXISTS translation_devel.nl01_nli01_eco_devel;
CREATE TABLE translation_devel.nl01_nli01_eco_devel AS
SELECT * FROM translation.nl_nli01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl01_nli01_eco_devel;
SELECT TT_Prepare('translation_devel', 'nl01_nli01_eco_devel', '_nl01_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 200);
SELECT * FROM TT_Translate_nl01_eco_devel('rawfri', 'nl01_l1_to_nl_nli_l1_map_200', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_nli01_eco_devel', 'nl01_l1_to_nl_nli_l1_map_200');


-- GEO ATTRIBUTES
SELECT * FROM translation.nl_nli01_geo;
DROP TABLE IF EXISTS translation_devel.nl01_nli01_geo_devel;
CREATE TABLE translation_devel.nl01_nli01_geo_devel AS
SELECT * FROM translation.nl_nli01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl01_nli01_geo_devel;
SELECT TT_Prepare('translation_devel', 'nl01_nli01_geo_devel', '_nl01_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'nl01', 'nl_nli', 200);
SELECT * FROM TT_Translate_nl01_geo_devel('rawfri', 'nl01_l1_to_nl_nli_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_nli01_geo_devel', 'nl01_l1_to_nl_nli_l1_map_200');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_no, b.ogc_fid, a.cas_id, 
       b.cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.avg_ht, a.height_upper, a.height_lower, 
       b.sp1, a.species_1,
       b.sp1_per, a.species_per_1
FROM TT_Translate_yt02_lyr_devel('rawfri', 'yt02_l1_to_yt_l1_map_200') a, rawfri.yt02_l1_to_yt_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
