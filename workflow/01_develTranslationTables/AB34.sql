------------------------------------------------------------------------------
-- CASFRI - AB34 translation development script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2024 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
-------------------------------------------------------------------------------
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_devel; --added
-------------------------------------------------------
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.ab_avi01_cas; 
SELECT * FROM translation.ab_avi01_dst; 
SELECT * FROM translation.ab_avi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.ab34_avi01_cas_devel;
CREATE TABLE translation_devel.ab34_avi01_cas_devel AS
SELECT * FROM translation.ab_avi01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab34_avi01_cas_devel;
----------------------------
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.ab34_avi01_dst_devel;
CREATE TABLE translation_devel.ab34_avi01_dst_devel AS
SELECT * FROM translation.ab_avi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.ab34_avi01_dst_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.ab34_avi01_geo_devel;
CREATE TABLE translation_devel.ab34_avi01_geo_devel AS
SELECT * FROM translation.ab_avi01_geo
--WHERE rule_id::int = 2
;
-- Display
SELECT * FROM translation_devel.ab34_avi01_geo_devel;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Check the uniqueness of AB species codes
-------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping(ab_species_codes)
WHERE TT_NotEmpty(ab_species_codes);
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_devel', 'ab34_avi01_cas_devel', '_ab34_cas_devel');
SELECT TT_Prepare('translation_devel', 'ab34_avi01_dst_devel', '_ab34_dst_devel');
SELECT TT_Prepare('translation_devel', 'ab34_avi01_geo_devel', '_ab34_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'ab34', 1, 'ab', 1, 200);

SELECT * FROM TT_Translate_ab34_cas_devel('rawfri', 'ab34_l1_to_ab_l1_map_200');

SELECT * FROM TT_Translate_ab34_dst_devel('rawfri', 'ab34_l1_to_ab_l1_map_200');

SELECT * FROM TT_Translate_ab34_geo_devel('rawfri', 'ab34_l1_to_ab_l1_map_200');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.poly_num, a.cas_id, 
       b.density, a.crown_closure_lower, a.crown_closure_upper, 
       b.height, a.height_upper, a.height_lower,
       b.sp1, a.species_1,
       b.sp1_per, a.species_per_1
FROM TT_Translate_ab34_lyr_devel('rawfri', 'ab34_l1_to_ab_l1_map_200') a, rawfri.ab34 b
WHERE b.poly_num = substr(a.cas_id, 34, 9)::int;

SELECT b.src_filename, b.poly_num, a.cas_id, 
       b.data_yr, a.stand_photo_year
FROM TT_Translate_ab34_cas_devel('rawfri', 'ab34_l1_to_ab_l1_map_200') a, rawfri.ab34 b
WHERE b.poly_num = substr(a.cas_id, 34, 9)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');


