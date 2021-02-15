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

-- Check the uniqueness of NS species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (ns_species_codes)
WHERE TT_NotEmpty(ns_species_codes);

CREATE UNIQUE INDEX ON translation.species_code_mapping (ns2_species_codes)
WHERE TT_NotEmpty(ns2_species_codes);

-- CAS ATTRIBUTES
SELECT * FROM translation.ns_nsi01_cas;
DROP TABLE IF EXISTS translation_devel.ns_nsi01_cas_devel;
CREATE TABLE translation_devel.ns_nsi01_cas_devel AS
SELECT * FROM translation.ns_nsi01_cas; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.ns_nsi01_cas_devel;
SELECT TT_Prepare('translation_devel', 'ns_nsi01_cas_devel', '_ns03_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'ns03', 'ns_nsi', 200);
SELECT * FROM TT_Translate_ns03_cas_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns03_nsi01_cas_devel');

-- LYR1 ATTRIBUTES
SELECT * FROM translation.ns_nsi01_lyr;
DROP TABLE IF EXISTS translation_devel.ns_nsi01_lyr_devel;
CREATE TABLE translation_devel.ns_nsi01_lyr_devel AS
SELECT * FROM translation.ns_nsi01_lyr; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.ns_nsi01_lyr_devel;
SELECT TT_Prepare('translation_devel', 'ns_nsi01_lyr_devel', '_ns03_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_lyr_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns_nsi01_lyr_devel');

-- LYR2 ATTRIBUTES
SELECT TT_CreateMappingView('rawfri', 'ns03', 2, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_lyr_devel('rawfri', 'ns03_l2_to_ns_nsi_l1_map_200'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns_nsi01_lyr_devel');

-- DST ATTRIBUTES
SELECT * FROM translation.ns_nsi01_dst;
DROP TABLE IF EXISTS translation_devel.ns_nsi01_dst_devel;
CREATE TABLE translation_devel.ns_nsi01_dst_devel AS
SELECT * FROM translation.ns_nsi01_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.ns_nsi01_dst_devel;
SELECT TT_Prepare('translation_devel', 'ns_nsi01_dst_devel', '_ns03_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_dst_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns_nsi01_dst_devel');

-- NFL ATTRIBUTES
SELECT * FROM translation.ns_nsi01_nfl;
DROP TABLE IF EXISTS translation_devel.ns_nsi01_nfl_devel;
CREATE TABLE translation_devel.ns_nsi01_nfl_devel AS
SELECT * FROM translation.ns_nsi01_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.ns_nsi01_nfl_devel;
SELECT TT_Prepare('translation_devel', 'ns_nsi01_nfl_devel', '_ns03_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'ns03', 3, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_nfl_devel('rawfri', 'ns03_l3_to_ns_nsi_l1_map_200'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns_nsi01_nfl_devel');

-- ECO ATTRIBUTES
SELECT * FROM translation.ns_nsi01_eco;
DROP TABLE IF EXISTS translation_devel.ns_nsi01_eco_devel;
CREATE TABLE translation_devel.ns_nsi01_eco_devel AS
SELECT * FROM translation.ns_nsi01_eco; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.ns_nsi01_eco_devel;
SELECT TT_Prepare('translation_devel', 'ns_nsi01_eco_devel', '_ns03_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_eco_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns_nsi01_eco_devel');

-- GEO ATTRIBUTES
SELECT * FROM translation.ns_nsi01_geo;
DROP TABLE IF EXISTS translation_devel.ns_nsi01_geo_devel;
CREATE TABLE translation_devel.ns_nsi01_geo_devel AS
SELECT * FROM translation.ns_nsi01_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.ns_nsi01_geo_devel;
SELECT TT_Prepare('translation_devel', 'ns_nsi01_geo_devel', '_ns03_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_geo_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns_nsi01_geo_devel');


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.poly_id, b.ogc_fid, a.cas_id, 
       b.l1cc, a.crown_closure_lower, a.crown_closure_upper, 
       b.l1ht, a.height_upper, a.height_lower, 
       b.l1s1, a.species_1,
       b.l1pr1, a.species_per_1
FROM TT_Translate_ns03_lyr_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200') a, rawfri.ns03_l1_to_ns_nsi_l1_map_200 b
WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
