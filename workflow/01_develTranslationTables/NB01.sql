------------------------------------------------------------------------------
-- CASFRI - NB01 translation development script for CASFRI v5
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
------------------------------------------------------
-- Display translation tables
SELECT * FROM translation.nb_nbi01_cas; 
SELECT * FROM translation.nb_nbi01_dst; 
SELECT * FROM translation.nb_nbi01_eco; 
SELECT * FROM translation.nb_nbi01_lyr; 
SELECT * FROM translation.nb_nbi01_nfl;
SELECT * FROM translation.nb_nbi01_geo;
----------------------------
-- Create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_devel.nb01_nbi01_cas_devel;
CREATE TABLE translation_devel.nb01_nbi01_cas_devel AS
SELECT * FROM translation.nb_nbi01_cas
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.nb01_nbi01_cas_devel;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_devel.nb01_nbi01_dst_devel;
CREATE TABLE translation_devel.nb01_nbi01_dst_devel AS
SELECT * FROM translation.nb_nbi01_dst
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.nb01_nbi01_dst_devel;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_devel.nb01_nbi01_eco_devel;
CREATE TABLE translation_devel.nb01_nbi01_eco_devel AS
SELECT * FROM translation.nb_nbi01_eco
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.nb01_nbi01_eco_devel;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_devel.nb01_nbi01_lyr_devel;
CREATE TABLE translation_devel.nb01_nbi01_lyr_devel AS
SELECT * FROM translation.nb_nbi01_lyr
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.nb01_nbi01_lyr_devel;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_devel.nb01_nbi01_nfl_devel;
CREATE TABLE translation_devel.nb01_nbi01_nfl_devel AS
SELECT * FROM translation.nb_nbi01_nfl
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.nb01_nbi01_nfl_devel;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_devel.nb01_nbi01_geo_devel;
CREATE TABLE translation_devel.nb01_nbi01_geo_devel AS
SELECT * FROM translation.nb_nbi01_geo
--WHERE rule_id::int = 1
;
-- Display
SELECT * FROM translation_devel.nb01_nbi01_geo_devel;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Check the uniqueness of NB species codes
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE UNIQUE INDEX ON translation.species_code_mapping (nb_species_codes)
WHERE TT_NotEmpty(nb_species_codes);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Prepare translation function
SELECT TT_Prepare('translation_devel', 'nb01_nbi01_cas_devel', '_nb01_cas_devel');
SELECT TT_Prepare('translation_devel', 'nb01_nbi01_dst_devel', '_nb01_dst_devel');
SELECT TT_Prepare('translation_devel', 'nb01_nbi01_eco_devel', '_nb01_eco_devel');
SELECT TT_Prepare('translation_devel', 'nb01_nbi01_lyr_devel', '_nb01_lyr_devel');
SELECT TT_Prepare('translation_devel', 'nb01_nbi01_nfl_devel', '_nb01_nfl_devel');
SELECT TT_Prepare('translation_devel', 'nb01_nbi01_geo_devel', '_nb01_geo_devel');

-- Create VIEW 'nb01_l2_to_nb01_l1_map_200' mapping the NB01 layer 2 
-- attributes to the NB01 layer 1 attributes

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'nb01', 1, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_cas_devel('rawfri', 'nb01_l1_to_nb_l1_map_200'); -- 5 s.

SELECT * FROM TT_Translate_nb01_dst_devel('rawfri', 'nb01_l1_to_nb_l1_map_200'); -- 4 s.

SELECT TT_CreateMappingView('rawfri', 'nb01', 2, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_dst_devel('rawfri', 'nb01_l2_to_nb_l1_map_200'); -- 3 s

SELECT * FROM TT_Translate_nb01_eco_devel('rawfri', 'nb01_l1_to_nb_l1_map_200'); -- 2 s.

SELECT * FROM TT_Translate_nb01_lyr_devel('rawfri', 'nb01_l1_to_nb_l1_map_200'); -- 7 s.

SELECT * FROM TT_Translate_nb01_lyr_devel('rawfri', 'nb01_l2_to_nb_l1_map_200');

SELECT TT_CreateMappingView('rawfri', 'nb01', 3, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_nfl_devel('rawfri', 'nb01_l3_to_nb_l1_map_200'); -- 3 s.

SELECT * FROM TT_Translate_nb01_geo_devel('rawfri', 'nb01_l1_to_nb_l1_map_200'); -- 2 s.

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_nb01_lyr_devel('rawfri', 'nb01_min_200') a, rawfri.nb01_min_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
