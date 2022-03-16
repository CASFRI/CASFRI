------------------------------------------------------------------------------
-- CASFRI - NT01 translation development script for CASFRI v5
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
-- Create devel translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS translation_devel;
-------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.nt_fvi02_cas;
SELECT * FROM translation.nt_fvi02_dst;
SELECT * FROM translation.nt_fvi02_eco;
SELECT * FROM translation.nt_fvi02_lyr;
SELECT * FROM translation.nt_fvi02_nfl;
SELECT * FROM translation.nt_fvi02_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.nt04_fvi02_cas_devel;
CREATE TABLE translation_devel.nt04_fvi02_cas_devel AS
SELECT * FROM translation.nt_fvi02_cas
--WHERE rule_id::int < 1
;
-- display
SELECT * FROM translation_devel.nt04_fvi02_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.nt04_fvi02_dst_devel;
CREATE TABLE translation_devel.nt04_fvi02_dst_devel AS
SELECT * FROM translation.nt_fvi02_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt04_fvi02_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.nt04_fvi02_eco_devel;
CREATE TABLE translation_devel.nt04_fvi02_eco_devel AS
SELECT * FROM translation.nt_fvi02_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt04_fvi02_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.nt04_fvi02_lyr_devel;
CREATE TABLE translation_devel.nt04_fvi02_lyr_devel AS
SELECT * FROM translation.nt_fvi02_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt04_fvi02_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.nt04_fvi02_nfl_devel;
CREATE TABLE translation_devel.nt04_fvi02_nfl_devel AS
SELECT * FROM translation.nt_fvi02_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_devel.nt04_fvi02_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.nt04_fvi02_geo_devel;
CREATE TABLE translation_devel.nt04_fvi02_geo_devel AS
SELECT * FROM translation.nt_fvi02_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_devel.nt04_fvi02_geo_devel;

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
-- Create translation functions
SELECT TT_Prepare('translation_devel', 'nt04_fvi02_cas_devel', '_nt04_cas_devel');
SELECT TT_Prepare('translation_devel', 'nt04_fvi02_dst_devel', '_nt04_dst_devel');
SELECT TT_Prepare('translation_devel', 'nt04_fvi02_eco_devel', '_nt04_eco_devel');
SELECT TT_Prepare('translation_devel', 'nt04_fvi02_lyr_devel', '_nt04_lyr_devel');
SELECT TT_Prepare('translation_devel', 'nt04_fvi02_nfl_devel', '_nt04_nfl_devel');
SELECT TT_Prepare('translation_devel', 'nt04_fvi02_geo_devel', '_nt04_geo_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'nt04', 1, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_cas_devel('rawfri', 'nt04_l1_to_nt_l1_map_200'); -- 6 s.

SELECT * FROM TT_Translate_nt01_dst_devel('rawfri', 'nt04_l1_to_nt_l1_map_200'); -- 7 s.

SELECT * FROM TT_Translate_nt01_eco_devel('rawfri', 'nt04_l1_to_nt_l1_map_200'); -- 7 s.

SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt04_l1_to_nt_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'nt04', 2, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_lyr_devel('rawfri', 'nt04_l2_to_nt_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'nt04', 3, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt04_l3_to_nt_l1_map_200'); -- 7 s.

SELECT TT_CreateMappingView('rawfri', 'nt04', 4, 'nt', 1, 200);
SELECT * FROM TT_Translate_nt01_nfl_devel('rawfri', 'nt04_l4_to_nt_l1_map_200'); -- 7 s.

SELECT * FROM TT_Translate_nt01_geo_devel('rawfri', 'nt04_l1_to_nt_l1_map_200'); -- 7 s.

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
