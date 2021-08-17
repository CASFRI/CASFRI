------------------------------------------------------------------------------
-- CASFRI - BC08 translation development script for CASFRI v5
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
SELECT * FROM translation.bc_vri01_cas; 
SELECT * FROM translation.bc_vri01_dst; 
SELECT * FROM translation.bc_vri01_eco; 
SELECT * FROM translation.bc_vri01_lyr; 
SELECT * FROM translation.bc_vri01_nfl;
SELECT * FROM translation.bc_vri01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.bc08_vri01_cas_devel;
CREATE TABLE translation_devel.bc08_vri01_cas_devel AS
SELECT * FROM translation.bc_vri01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc08_vri01_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.bc08_vri01_dst_devel;
CREATE TABLE translation_devel.bc08_vri01_dst_devel AS
SELECT * FROM translation.bc_vri01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc08_vri01_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.bc08_vri01_eco_devel;
CREATE TABLE translation_devel.bc08_vri01_eco_devel AS
SELECT * FROM translation.bc_vri01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc08_vri01_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.bc08_vri01_lyr_devel;
CREATE TABLE translation_devel.bc08_vri01_lyr_devel AS
SELECT * FROM translation.bc_vri01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc08_vri01_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.bc08_vri01_nfl_devel;
CREATE TABLE translation_devel.bc08_vri01_nfl_devel AS
SELECT * FROM translation.bc_vri01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc08_vri01_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.bc08_vri01_geo_devel;
CREATE TABLE translation_devel.bc08_vri01_geo_devel AS
SELECT * FROM translation.bc_vri01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.bc08_vri01_geo_devel;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create translation functions
SELECT TT_Prepare('translation_devel', 'bc08_vri01_cas_devel', '_bc08_cas_devel');
SELECT TT_Prepare('translation_devel', 'bc08_vri01_dst_devel', '_bc08_dst_devel');
SELECT TT_Prepare('translation_devel', 'bc08_vri01_eco_devel', '_bc08_eco_devel');
SELECT TT_Prepare('translation_devel', 'bc08_vri01_lyr_devel', '_bc08_lyr_devel');
SELECT TT_Prepare('translation_devel', 'bc08_vri01_nfl_devel', '_bc08_nfl_devel');
SELECT TT_Prepare('translation_devel', 'bc08_vri01_geo_devel', '_bc08_geo_devel');

-- translate the samples
-- here we use dummy column names representing the layer 2 species attributes in 
-- the generic bc row of the dependency table and in the translation table.
-- These are set to null in the bc08 workflow because there is no layer 2. In the
-- bc10 workflow they are mapped to the layer 2 species attributes.
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 200);
SELECT * FROM TT_Translate_bc08_cas_devel('rawfri', 'bc08_l1_to_bc_l1_map_200'); -- 4 s.

SELECT * FROM TT_Translate_bc08_dst_devel('rawfri', 'bc08_l1_to_bc_l1_map_200'); -- 4 s.

SELECT * FROM TT_Translate_bc08_eco_devel('rawfri', 'bc08_l1_to_bc_l1_map_200'); -- 2 s.

SELECT * FROM TT_Translate_bc08_lyr_devel('rawfri', 'bc08_l1_to_bc_l1_map_200'); -- 7 s.

-- NFL needs one translation for each attribute
SELECT TT_CreateMappingView('rawfri', 'bc08', 2, 'bc', 1, 200);
SELECT * FROM TT_Translate_bc08_nfl_devel('rawfri', 'bc08_l2_to_bc_l1_map_200'); -- 4 s.

SELECT TT_CreateMappingView('rawfri', 'bc08', 3, 'bc', 1, 200);
SELECT * FROM TT_Translate_bc08_nfl_devel('rawfri', 'bc08_l3_to_bc_l1_map_200'); -- 4 s.

SELECT TT_CreateMappingView('rawfri', 'bc08', 4, 'bc', 1, 200);
SELECT * FROM TT_Translate_bc08_nfl_devel('rawfri', 'bc08_l4_to_bc_l1_map_200'); -- 4 s.

SELECT * FROM TT_Translate_bc08_geo_devel('rawfri', 'bc08_l1_to_bc_l1_map_200'); -- 2 s.

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.map_id, b.ogc_fid, a.cas_id, 
       b.crown_closure, a.crown_closure_lower, a.crown_closure_upper, 
       b.proj_height_1, a.height_upper, a.height_lower,
       b.species_cd_1, a.species_1,
       b.species_pct_1, a.species_per_1
FROM TT_Translate_bc08_lyr_devel('rawfri', 'bc08_min_200') a, rawfri.bc08_min_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
