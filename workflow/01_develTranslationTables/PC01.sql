------------------------------------------------------------------------------
-- CASFRI - PC01 translation development script for CASFRI v5
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

-- Check the uniqueness of PC species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (pc01_species_codes)
WHERE TT_NotEmpty(pc01_species_codes);

--SELECT TT_DeleteAllViews('rawfri');

-- CAS ATTRIBUTES
SELECT * FROM translation.pc_panp01_cas;
DROP TABLE IF EXISTS translation_devel.pc01_panp01_cas_devel;
CREATE TABLE translation_devel.pc01_panp01_cas_devel AS
SELECT * FROM translation.pc_panp01_cas
--WHERE rule_id::int < 2;

SELECT * FROM translation_devel.pc01_panp01_cas_devel;
SELECT TT_Prepare('translation_devel', 'pc01_panp01_cas_devel', '_pc01_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'pc01', 'pc_panp', 200);
SELECT * FROM TT_Translate_pc01_cas_devel('rawfri', 'pc01_l1_to_pc_panp_l1_map_200');

-- DST ATTRIBUTES 
-- No disturbance history found in PC01

-- LYR1 ATTRIBUTES
SELECT * FROM translation.pc_panp01_lyr;
DROP TABLE IF EXISTS translation_devel.pc01_panp01_lyr_devel;
CREATE TABLE translation_devel.pc01_panp01_lyr_devel AS
SELECT * FROM translation.pc_panp01_lyr;
--WHERE rule_id::int < 6;
SELECT * FROM translation_devel.pc01_panp01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'pc01_panp01_lyr_devel', '_pc01_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_lyr_devel('rawfri', 'pc01_l1_to_pc_panp_l1_map_200');

-- LYR2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'pc01', 2, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_lyr_devel('rawfri', 'pc01_l2_to_pc_panp_l1_map_200');
-- LYR3 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'pc01', 3, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_lyr_devel('rawfri', 'pc01_l3_to_pc_panp_l1_map_200');

-- NFL ATTRIBUTES
SELECT * FROM translation.pc_panp01_nfl;
DROP TABLE IF EXISTS translation_devel.pc01_panp01_nfl_devel; 
CREATE TABLE translation_devel.pc01_panp01_nfl_devel AS
SELECT * FROM translation.pc_panp01_nfl; --WHERE rule_id::int != 4; --IN (0,1,2,3);
SELECT * FROM translation_devel.pc01_panp01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'pc01_panp01_nfl_devel', '_pc01_nfl_devel');

SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_nfl_devel('rawfri', 'pc01_l4_to_pc_panp_l1_map_200');

SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_nfl_devel('rawfri', 'pc01_l5_to_pc_panp_l1_map_200');

SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, 200); 
SELECT * FROM TT_Translate_pc01_nfl_devel('rawfri', 'pc01_l6_to_pc_panp_l1_map_200');

-- ECO ATTRIBUTES
SELECT * FROM translation.pc_panp01_eco;
DROP TABLE IF EXISTS translation_devel.pc01_panp01_eco_devel;
CREATE TABLE translation_devel.pc01_panp01_eco_devel AS
SELECT * FROM translation.pc_panp01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc01_panp01_eco_devel;
SELECT TT_Prepare('translation_devel', 'pc01_panp01_eco_devel', '_pc01_eco_devel');
--Layer 4
SELECT TT_CreateMappingView('rawfri', 'pc01', 4, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_eco_devel('rawfri', 'pc01_l4_to_pc_panp_l1_map_200'); -- 4 s.
--Layer 5
SELECT TT_CreateMappingView('rawfri', 'pc01', 5, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_eco_devel('rawfri', 'pc01_l5_to_pc_panp_l1_map_200'); -- 4 s.
--Layer 6
SELECT TT_CreateMappingView('rawfri', 'pc01', 6, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_eco_devel('rawfri', 'pc01_l6_to_pc_panp_l1_map_200'); -- 4 s.

-- GEO ATTRIBUTES
SELECT * FROM translation.pc_panp01_geo;
DROP TABLE IF EXISTS translation_devel.pc01_panp01_geo_devel;
CREATE TABLE translation_devel.pc01_panp01_geo_devel AS
SELECT * FROM translation.pc_panp01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.pc01_panp01_geo_devel;
SELECT TT_Prepare('translation_devel', 'pc01_panp01_geo_devel', '_pc01_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'pc01', 1, 'pc_panp', 1, 200);
SELECT * FROM TT_Translate_pc01_geo_devel('rawfri', 'pc01_l1_to_pc_panp_l1_map_200'); -- 4 s.


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.fpoly_, b.ogc_fid, a.cas_id, 
       b.crown_closure_upper crown_source, a.crown_closure_lower, a.crown_closure_upper, 
       b.height_upper height_source, a.height_upper, a.height_lower, 
       b.species_1 source_species1, a.species_1,a.species_2,a.species_3,
       b.species_per_1 source_species_per, a.species_per_1, a.species_per_2, a.species_per_3
FROM TT_Translate_pc01_lyr_devel('rawfri', 'pc01_l1_to_pc_panp_l1_map_200') a, rawfri.pc01_l1_to_pc_panp_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

SELECT b.src_filename, b.inventory_id, b.fpoly_, b.ogc_fid, a.cas_id, 
       b.non_for source_non_for, a.non_for,
	   b.species_layer1, b.species_layer2, b.species_layer3, a.layer 
FROM TT_Translate_pc01_nfl_devel('rawfri', 'pc01_l4_to_pc_panp_l1_map_200') a, rawfri.pc01_l4_to_pc_panp_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;
--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
