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

-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- CAS ATTRIBUTES
SELECT * FROM translation.sk_utm01_cas;
DROP TABLE IF EXISTS translation_devel.sk01_utm01_cas_devel;
CREATE TABLE translation_devel.sk01_utm01_cas_devel AS
SELECT * FROM translation.sk_utm01_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk01_utm01_cas_devel;
SELECT TT_Prepare('translation_devel', 'sk01_utm01_cas_devel', '_sk01_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'sk01', 'sk_utm', 200);
SELECT * FROM TT_Translate_sk01_cas_devel('rawfri', 'sk01_l1_to_sk_utm_l1_map_200'); -- 5 s.

-- LYR1 ATTRIBUTES
SELECT * FROM translation.sk_utm01_lyr;
DROP TABLE IF EXISTS translation_devel.sk01_utm01_lyr_devel;
CREATE TABLE translation_devel.sk01_utm01_lyr_devel AS
SELECT * FROM translation.sk_utm01_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk01_utm01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'sk01_utm01_lyr_devel', '_sk01_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk01_lyr_devel('rawfri', 'sk01_l1_to_sk_utm_l1_map_200'); -- 7 s.

-- LYR2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'sk01', 2, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk01_lyr_devel('rawfri', 'sk01_l2_to_sk_utm_l1_map_200'); -- 7 s.

-- DST ATTRIBUTES
SELECT * FROM translation.sk_utm01_dst;
DROP TABLE IF EXISTS translation_devel.sk01_utm01_dst_devel;
CREATE TABLE translation_devel.sk01_utm01_dst_devel AS
SELECT * FROM translation.sk_utm01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk01_utm01_dst_devel;
SELECT TT_Prepare('translation_devel', 'sk01_utm01_dst_devel', '_sk01_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk01_dst_devel('rawfri', 'sk01_l1_to_sk_utm_l1_map_200'); -- 4 s.

-- NFL ATTRIBUTES
SELECT * FROM translation.sk_utm01_nfl;
DROP TABLE IF EXISTS translation_devel.sk01_utm01_nfl_devel;
CREATE TABLE translation_devel.sk01_utm01_nfl_devel AS
SELECT * FROM translation.sk_utm01_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk01_utm01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'sk01_utm01_nfl_devel', '_sk01_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'sk01', 3, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk01_nfl_devel('rawfri', 'sk01_l3_to_sk_utm_l1_map_200'); -- 3 s.


-- ECO ATTRIBUTES
SELECT * FROM translation.sk_utm01_eco;
DROP TABLE IF EXISTS translation_devel.sk01_utm01_eco_devel;
CREATE TABLE translation_devel.sk01_utm01_eco_devel AS
SELECT * FROM translation.sk_utm01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk01_utm01_eco_devel;
SELECT TT_Prepare('translation_devel', 'sk01_utm01_eco_devel', '_sk01_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk01_eco_devel('rawfri', 'sk01_l1_to_sk_utm_l1_map_200');


-- GEO ATTRIBUTES
SELECT * FROM translation.sk_utm01_geo;
DROP TABLE IF EXISTS translation_devel.sk01_utm01_geo_devel;
CREATE TABLE translation_devel.sk01_utm01_geo_devel AS
SELECT * FROM translation.sk_utm01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk01_utm01_geo_devel;
SELECT TT_Prepare('translation_devel', 'sk01_utm01_geo_devel', '_sk01_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk01_geo_devel('rawfri', 'sk01_l1_to_sk_utm_l1_map_200'); -- 2 s.


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_on01_lyr_devel('rawfri', 'sk01_l1_to_sk_l1_map_200') a, rawfri.sk01_l1_to_sk_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
