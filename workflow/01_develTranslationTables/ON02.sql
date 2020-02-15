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


-- Validate species dependency tables
SELECT TT_Prepare('translation', 'on_fim02_species_validation', '_on_species_val');
SELECT * FROM TT_Translate_on_species_val('translation', 'on_fim02_species');


-- CAS ATTRIBUTES
SELECT * FROM translation.fim02_cas;
DROP TABLE IF EXISTS translation_devel.on02_fim02_cas_devel;
CREATE TABLE translation_devel.on02_fim02_cas_devel AS
SELECT * FROM translation.fim02_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_cas_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_cas_devel', '_on02_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 200);
SELECT * FROM TT_Translate_on02_cas_devel('rawfri', 'on02_l1_to_on_l1_map_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'on02_fim02_cas_devel');


-- LYR1 ATTRIBUTES
SELECT * FROM translation.fim02_lyr;
DROP TABLE IF EXISTS translation_devel.on02_fim02_lyr_devel;
CREATE TABLE translation_devel.on02_fim02_lyr_devel AS
SELECT * FROM translation.fim02_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_lyr_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_lyr_devel', '_on02_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 200, 'lyr');
SELECT * FROM TT_Translate_on02_lyr_devel('rawfri', 'on02_l1_to_on_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'on02_fim02_lyr_devel');


-- LYR2 ATTRIBUTES
DROP TABLE IF EXISTS translation_devel.on02_fim02_lyr_devel;
CREATE TABLE translation_devel.on02_fim02_lyr_devel AS
SELECT * FROM translation.fim02_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_lyr_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_lyr_devel', '_on02_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 2, 'on', 1, 200, 'lyr');
SELECT * FROM TT_Translate_on02_lyr_devel('rawfri', 'on02_l2_to_on_l1_map_200_lyr', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'on02_fim02_lyr_devel');


-- DST ATTRIBUTES
SELECT * FROM translation.fim02_dst;
DROP TABLE IF EXISTS translation_devel.on02_fim02_dst_devel;
CREATE TABLE translation_devel.on02_fim02_dst_devel AS
SELECT * FROM translation.fim02_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_dst_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_dst_devel', '_on02_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 200, 'dst');
SELECT * FROM TT_Translate_on02_dst_devel('rawfri', 'on02_l1_to_on_l1_map_200_dst', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'on01_oni01_dst_devel');


-- NFL ATTRIBUTES
SELECT * FROM translation.fim02_nfl;
DROP TABLE IF EXISTS translation_devel.on02_fim02_nfl_devel;
CREATE TABLE translation_devel.on02_fim02_nfl_devel AS
SELECT * FROM translation.fim02_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_nfl_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_nfl_devel', '_on02_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 200, 'nfl');
SELECT * FROM TT_Translate_on01_nfl_devel('rawfri', 'on02_l1_to_on_l1_map_200_nfl', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'on01_oni01_nfl_devel');


-- ECO ATTRIBUTES
SELECT * FROM translation.fim02_eco;
DROP TABLE IF EXISTS translation_devel.on02_fim02_eco_devel;
CREATE TABLE translation_devel.on02_fim02_eco_devel AS
SELECT * FROM translation.fim02_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_eco_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_eco_devel', '_on02_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 200, 'eco');
SELECT * FROM TT_Translate_on02_eco_devel('rawfri', 'on02_l1_to_on_l1_map_200_eco', 'ogc_fid');
SELECT * FROM TT_ShowLastLog('translation_devel', 'on01_oni01_eco_devel');


-- GEO ATTRIBUTES
SELECT * FROM translation.fim02_geo;
DROP TABLE IF EXISTS translation_devel.on02_fim02_geo_devel;
CREATE TABLE translation_devel.on02_fim02_geo_devel AS
SELECT * FROM translation.fim02_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.on02_fim02_geo_devel;
SELECT TT_Prepare('translation_devel', 'on02_fim02_geo_devel', '_on02_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'on02', 'on', 200, 'geo');
SELECT * FROM TT_Translate_on02_geo_devel('rawfri', 'on02_l1_to_on_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'on02_fim02_geo_devel');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_on01_lyr_devel('rawfri', 'on02_l1_to_on_l1_map_200') a, rawfri.on02_l1_to_on_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
