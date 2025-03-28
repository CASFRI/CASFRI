------------------------------------------------------------------------------
-- CASFRI - NL02 translation development script for CASFRI v5
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

-- Check the uniqueness of NL species codes
CREATE UNIQUE INDEX ON translation.species_code_mapping (nl_species_codes)
WHERE TT_NotEmpty(nl_species_codes);

-- DST ATTRIBUTES
SELECT * FROM translation.nl_nli02_dst;
DROP TABLE IF EXISTS translation_devel.nl02_nli02_dst_devel;
CREATE TABLE translation_devel.nl02_nli02_dst_devel AS SELECT * FROM translation.nl_nli02_dst; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl02_nli02_dst_devel;
SELECT TT_Prepare('translation_devel', 'nl02_nli02_dst_devel', '_nl02_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1, 20000);
SELECT * FROM TT_Translate_nl02_dst_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map_20000'); -- 4 s.

-- NFL ATTRIBUTES
SELECT * FROM translation.nl_nli02_nfl;
DROP TABLE IF EXISTS translation_devel.nl02_nli02_nfl_devel;
CREATE TABLE translation_devel.nl02_nli02_nfl_devel AS
SELECT * FROM translation.nl_nli02_nfl; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl02_nli02_nfl_devel;
SELECT TT_Prepare('translation_devel', 'nl02_nli02_nfl_devel', '_nl02_nfl_devel');
SELECT TT_CreateMappingView('rawfri', 'nl02', 2, 'nl_nli2', 1);
SELECT * FROM TT_Translate_nl02_nfl_devel('rawfri', 'nl02_l2_to_nl_nli2_l1_map'); -- 3 s.


-- CAS ATTRIBUTES
SELECT * FROM translation.nl_nli02_cas;
DROP TABLE IF EXISTS translation_devel.nl02_nli02_cas_devel;
CREATE TABLE translation_devel.nl02_nli02_cas_devel AS SELECT * FROM translation.nl_nli02_cas;
SELECT * FROM translation_devel.nl02_nli02_cas_devel;
SELECT TT_Prepare('translation_devel', 'nl02_nli02_cas_devel', '_nl02_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1, 200);
SELECT * FROM TT_Translate_nl02_cas_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map_200'); -- 5 s.
--SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1);
--DROP TABLE IF EXISTS public.trans_nl02_temp;
--CREATE table public.trans_nl02_temp as SELECT * FROM TT_Translate_nl02_cas_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map'); -- 5 s.


-- GEO ATTRIBUTES
SELECT * FROM translation.nl_nli02_geo;
DROP TABLE IF EXISTS translation_devel.nl02_nli02_geo_devel;
CREATE TABLE translation_devel.nl02_nli02_geo_devel AS
SELECT * FROM translation.nl_nli02_geo; --WHERE rule_id::int = 1
SELECT * FROM translation_devel.nl02_nli02_geo_devel;
SELECT TT_Prepare('translation_devel', 'nl02_nli02_geo_devel', '_nl02_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'nl02', 'nl_nli2', 200);
SELECT * FROM TT_Translate_nl02_geo_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map_200'); -- 2 s.


-- ECO ATTRIBUTES
SELECT * FROM translation.nl_nli02_eco;
DROP TABLE IF EXISTS translation_devel.nl02_nli02_eco_devel;
CREATE TABLE translation_devel.nl02_nli02_eco_devel AS
SELECT * FROM translation.nl_nli02_eco; -- WHERE rule_id::int < 2;
SELECT * FROM translation_devel.nl02_nli02_eco_devel;
SELECT TT_Prepare('translation_devel', 'nl02_nli02_eco_devel', '_nl02_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'nl02', 'nl_nli2');
SELECT * FROM TT_Translate_nl02_eco_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map');


-- LYR ATTRIBUTES
SELECT * FROM translation.nl_nli02_lyr;
DROP TABLE IF EXISTS translation_devel.nl02_nli02_lyr_devel;
CREATE TABLE translation_devel.nl02_nli02_lyr_devel 
AS SELECT * FROM translation.nl_nli02_lyr; -- WHERE rule_id::int = 0;
SELECT * FROM translation_devel.nl02_nli02_lyr_devel;
SELECT TT_Prepare('translation_devel', 'nl02_nli02_lyr_devel', '_nl02_lyr_devel');
SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1, 200);
SELECT * FROM TT_Translate_nl02_lyr_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map_200'); -- 7 s.

--SELECT TT_CreateMappingView('rawfri', 'nl02', 1, 'nl_nli2', 1);
--DROP TABLE IF EXISTS public.trans_nl02_temp_lyr;
--CREATE table public.trans_nl02_temp_lyr as SELECT * FROM TT_Translate_nl02_lyr_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map'); -- 5 s.


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.src_filename, b.inventory_id, b.orig_stand_id, b.ogc_fid, a.cas_id, b.soil_moisture_regime, a.soil_moist_reg,
       b.crown_closure_lower cc_class, a.crown_closure_lower, a.crown_closure_upper, 
       b.height_lower height, a.height_upper, a.height_lower, b.foresttype, a.productivity, b.site_class, a.site_class,
	   p.year photoyear, b.origin_upper age_class, a.origin_lower, a.origin_upper
       --b.sp1, a.species_1,
       --b.sp1_per, a.species_per_1
FROM TT_Translate_nl02_lyr_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map_200') a --, rawfri.nl02_l1_to_nl_nli2_l1_map_200 b
--WHERE b.ogc_fid::int = right(a.cas_id, 7)::int;
JOIN rawfri.nl02_l1_to_nl_nli2_l1_map_200 b 
ON b.ogc_fid::int = CAST(RIGHT(REGEXP_REPLACE(a.cas_id, '[^0-9]', '', 'g'), 7) AS INT)
JOIN rawfri.nl02_photoyear p 
ON ST_Intersects(b.wkb_geometry, p.wkb_geometry);

--NFL
SELECT b.src_filename, b.inventory_id, b.orig_stand_id, b.ogc_fid, a.cas_id, b.stand_id nfcode, a.nat_non_veg, 
       a.non_for_veg, a.non_for_anth
FROM TT_Translate_nl02_nfl_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map') a --, rawfri.nl02_l1_to_nl_nli2_l1_map_200 b
JOIN rawfri.nl02_l1_to_nl_nli2_l1_map b 
ON b.ogc_fid::int = CAST(RIGHT(REGEXP_REPLACE(a.cas_id, '[^0-9]', '', 'g'), 7) AS INT)
--AND b.orig_stand_id::int = CAST(NULLIF(REGEXP_REPLACE(SUBSTRING(a.cas_id FROM 33 FOR 10), '[^0-9]', '', 'g'), '') AS INT);

--ECO
SELECT b.src_filename, b.inventory_id, b.orig_stand_id, b.ogc_fid, a.cas_id, b.stand_id nfcode, 
       a.wetland_type, a.wet_veg_cover, a.wet_landform_mod, a.wet_local_mod
FROM TT_Translate_nl02_eco_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map') a --, rawfri.nl02_l1_to_nl_nli2_l1_map_200 b
JOIN rawfri.nl02_l1_to_nl_nli2_l1_map b 
ON b.ogc_fid::int = CAST(RIGHT(REGEXP_REPLACE(a.cas_id, '[^0-9]', '', 'g'), 7) AS INT) 
--AND b.orig_stand_id::int = CAST(NULLIF(REGEXP_REPLACE(SUBSTRING(a.cas_id FROM 33 FOR 10), '[^0-9]', '', 'g'), '') AS INT);

--DST
SELECT b.src_filename, b.inventory_id, b.orig_stand_id, b.ogc_fid, a.cas_id, b.type_dist dist,	
       a.dist_type_1, b.year_dist, a.dist_year_1
FROM TT_Translate_nl02_dst_devel('rawfri', 'nl02_l1_to_nl_nli2_l1_map_20000') a --, rawfri.nl02_l1_to_nl_nli2_l1_map_200 b
JOIN rawfri.nl02_l1_to_nl_nli2_l1_map_20000 b 
ON b.ogc_fid::int = CAST(RIGHT(REGEXP_REPLACE(a.cas_id, '[^0-9]', '', 'g'), 7) AS INT)  
AND b.orig_stand_id::int = CAST(NULLIF(REGEXP_REPLACE(SUBSTRING(a.cas_id FROM 33 FOR 10), '[^0-9]', '', 'g'), '') AS INT);

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
