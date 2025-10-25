------------------------------------------------------------------------------
-- CASFRI - YT02 translation development script for CASFRI v5
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

-- Check the uniqueness of YT species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (yt_species_codes)
WHERE TT_NotEmpty(yt_species_codes);

-- CAS ATTRIBUTES
SELECT * FROM translation.yt_yvi02_cas;
DROP TABLE IF EXISTS translation_devel.yt03_yvi02_cas_devel;
CREATE TABLE translation_devel.yt03_yvi02_cas_devel AS SELECT * FROM translation.yt_yvi02_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.yt03_yvi02_cas_devel;
SELECT TT_Prepare('translation_devel', 'yt03_yvi02_cas_devel', '_yt03_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt', 200);
SELECT * FROM TT_Translate_yt03_cas_devel('rawfri', 'yt03_l1_to_yt_l1_map_200'); -- 5 s.


-- LYR ATTRIBUTES
SELECT * FROM translation.yt_yvi02_lyr;
DROP TABLE IF EXISTS translation_devel.yt03_yvi02_lyr_devel;
CREATE TABLE translation_devel.yt03_yvi02_lyr_devel AS SELECT * FROM translation.yt_yvi02_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.yt03_yvi02_lyr_devel;
SELECT TT_Prepare('translation_devel', 'yt03_yvi02_lyr_devel', '_yt03_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt', 1, 200);
SELECT * FROM TT_Translate_yt03_lyr_devel('rawfri', 'yt03_l1_to_yt_l1_map_200'); -- 7 s.


-- DST ATTRIBUTES
SELECT * FROM translation.yt_yvi02_dst;
DROP TABLE IF EXISTS translation_devel.yt03_yvi02_dst_devel;
CREATE TABLE translation_devel.yt03_yvi02_dst_devel AS SELECT * FROM translation.yt_yvi02_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.yt03_yvi02_dst_devel;
SELECT TT_Prepare('translation_devel', 'yt03_yvi02_dst_devel', '_yt03_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'yt03', 1, 'yt', 1, 200);
SELECT * FROM TT_Translate_yt03_dst_devel('rawfri', 'yt03_l1_to_yt_l1_map_200'); -- 4 s.


-- NFL ATTRIBUTES
SELECT * FROM translation.yt_yvi02_nfl;
DROP TABLE IF EXISTS translation_devel.yt03_yvi02_nfl_devel;
CREATE TABLE translation_devel.yt03_yvi02_nfl_devel AS
SELECT * FROM translation.yt_yvi02_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.yt03_yvi02_nfl_devel;
SELECT TT_Prepare('translation_devel', 'yt03_yvi02_nfl_devel', '_yt03_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'yt03', 2, 'yt', 1, 200);
SELECT * FROM TT_Translate_yt03_nfl_devel('rawfri', 'yt03_l2_to_yt_l1_map_200'); -- 3 s.


-- ECO ATTRIBUTES
SELECT * FROM translation.yt_yvi02_eco;
DROP TABLE IF EXISTS translation_devel.yt03_yvi02_eco_devel;
CREATE TABLE translation_devel.yt03_yvi02_eco_devel AS
SELECT * FROM translation.yt_yvi02_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.yt03_yvi02_eco_devel;
SELECT TT_Prepare('translation_devel', 'yt03_yvi02_eco_devel', '_yt03_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt', 200);
SELECT * FROM TT_Translate_yt03_eco_devel('rawfri', 'yt03_l1_to_yt_l1_map_200');


-- GEO ATTRIBUTES
SELECT * FROM translation.yt_yvi02_geo;
DROP TABLE IF EXISTS translation_devel.yt03_yvi02_geo_devel;
CREATE TABLE translation_devel.yt03_yvi02_geo_devel AS
SELECT * FROM translation.yt_yvi02_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.yt03_yvi02_geo_devel;
SELECT TT_Prepare('translation_devel', 'yt03_yvi02_geo_devel', '_yt03_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'yt03', 'yt', 200);
SELECT * FROM TT_Translate_yt03_geo_devel('rawfri', 'yt03_l1_to_yt_l1_map_200'); -- 2 s.


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_no, b.ogc_fid, a.cas_id,
       b.cc, a.crown_closure_lower, a.crown_closure_upper,
       b.avg_ht, a.height_upper, a.height_lower,
       b.sp1, a.species_1,
       b.sp1_per, a.species_per_1
FROM TT_Translate_yt03_lyr_devel('rawfri', 'yt03_l1_to_yt_l1_map_200') a, rawfri.yt03_l1_to_yt_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
