------------------------------------------------------------------------------
-- CASFRI - SK01 translation development script for CASFRI v5
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
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Check the uniqueness of SK species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (sk_species_codes)
WHERE TT_NotEmpty(sk_species_codes);

-- CAS ATTRIBUTES
SELECT * FROM translation.sk_utm01_cas;
DROP TABLE IF EXISTS translation_devel.sk07_utm01_cas_devel;
CREATE TABLE translation_devel.sk07_utm01_cas_devel AS
SELECT * FROM translation.sk_utm01_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk07_utm01_cas_devel;
SELECT TT_Prepare('translation_devel', 'sk07_utm01_cas_devel', '_sk07_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'sk07', 'sk_utm', 200);
SELECT * FROM TT_Translate_sk07_cas_devel('rawfri', 'sk07_l1_to_sk_utm_l1_map_200'); -- 5 s.

-- LYR1 ATTRIBUTES
SELECT * FROM translation.sk_utm01_lyr;
DROP TABLE IF EXISTS translation_devel.sk07_utm01_lyr_devel;
CREATE TABLE translation_devel.sk07_utm01_lyr_devel AS
SELECT * FROM translation.sk_utm01_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk07_utm01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'sk07_utm01_lyr_devel', '_sk07_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'sk07', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk07_lyr_devel('rawfri', 'sk07_l1_to_sk_utm_l1_map_200'); -- 7 s.

-- LYR2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'sk07', 2, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk07_lyr_devel('rawfri', 'sk07_l2_to_sk_utm_l1_map_200'); -- 7 s.

-- DST ATTRIBUTES
SELECT * FROM translation.sk_utm01_dst;
DROP TABLE IF EXISTS translation_devel.sk07_utm01_dst_devel;
CREATE TABLE translation_devel.sk07_utm01_dst_devel AS
SELECT * FROM translation.sk_utm01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk07_utm01_dst_devel;
SELECT TT_Prepare('translation_devel', 'sk07_utm01_dst_devel', '_sk07_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'sk07', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk07_dst_devel('rawfri', 'sk07_l1_to_sk_utm_l1_map_200'); -- 4 s.

-- NFL ATTRIBUTES
SELECT * FROM translation.sk_utm01_nfl;
DROP TABLE IF EXISTS translation_devel.sk07_utm01_nfl_devel;
CREATE TABLE translation_devel.sk07_utm01_nfl_devel AS
SELECT * FROM translation.sk_utm01_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk07_utm01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'sk07_utm01_nfl_devel', '_sk07_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'sk07', 3, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk07_nfl_devel('rawfri', 'sk07_l3_to_sk_utm_l1_map_200'); -- 3 s.


-- ECO ATTRIBUTES
SELECT * FROM translation.sk_utm01_eco;
DROP TABLE IF EXISTS translation_devel.sk07_utm01_eco_devel;
CREATE TABLE translation_devel.sk07_utm01_eco_devel AS
SELECT * FROM translation.sk_utm01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk07_utm01_eco_devel;
SELECT TT_Prepare('translation_devel', 'sk07_utm01_eco_devel', '_sk07_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'sk07', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk07_eco_devel('rawfri', 'sk07_l1_to_sk_utm_l1_map_200');


-- GEO ATTRIBUTES
SELECT * FROM translation.sk_utm01_geo;
DROP TABLE IF EXISTS translation_devel.sk07_utm01_geo_devel;
CREATE TABLE translation_devel.sk07_utm01_geo_devel AS
SELECT * FROM translation.sk_utm01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.sk07_utm01_geo_devel;
SELECT TT_Prepare('translation_devel', 'sk07_utm01_geo_devel', '_sk07_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'sk07', 1, 'sk_utm', 1, 200);
SELECT * FROM TT_Translate_sk07_geo_devel('rawfri', 'sk07_l1_to_sk_utm_l1_map_200'); -- 2 s.


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.map_sheet_id, b.ogc_fid, a.cas_id, 
       b.d as crown_closure, a.crown_closure_lower, a.crown_closure_upper, 
       b.height_upper as height, a.height_upper, a.height_lower, 
       b.sp10, a.species_1,
       b.sp11, b.sp12, b.sp20, b.sp21, a.species_per_1
FROM TT_Translate_sk07_lyr_devel('rawfri', 'sk07_l1_to_sk_utm_l1_map_200') a, rawfri.sk07_l1_to_sk_utm_l1_map_200 b
WHERE b.ogc_fid::int = trim(right(a.cas_id, 7),'x')::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
