------------------------------------------------------------------------------
-- CASFRI - ds01 translation development script for CASFRI v5
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

--SELECT TT_DeleteAllViews('rawfri');

-- CAS ATTRIBUTES
SELECT * FROM translation.ds_cfs01_cas;

DROP TABLE IF EXISTS translation_devel.ds_cfs01_cas_devel;
CREATE TABLE translation_devel.ds_cfs01_cas_devel AS
SELECT * FROM translation.ds_cfs01_cas; --WHERE rule_id::int <> 5;

SELECT * FROM translation_devel.ds_cfs01_cas_devel;
SELECT TT_Prepare('translation_devel', 'ds_cfs01_cas_devel', '_ds01_cas_devel');
SELECT TT_CreateMappingView('rawfri', 'ds01', 'ds', 200);
SELECT * FROM TT_Translate_ds01_cas_devel('rawfri', 'ds01_l1_to_ds_l1_map_200');


-- DST ATTRIBUTES
SELECT * FROM translation.ds_cfs01_dst;

DROP TABLE IF EXISTS translation_devel.ds_cfs01_dst_devel;
CREATE TABLE translation_devel.ds_cfs01_dst_devel AS
SELECT * FROM translation.ds_cfs01_dst; --WHERE rule_id::int = 1;

SELECT * FROM translation_devel.ds_cfs01_dst_devel;
SELECT TT_Prepare('translation_devel', 'ds_cfs01_dst_devel', '_ds01_dst_devel');
SELECT TT_CreateMappingView('rawfri', 'ds01', 'ds', 200);
SELECT * FROM TT_Translate_ds01_dst_devel('rawfri', 'ds01_l1_to_ds_l1_map_200'); -- 4 s.


-- GEO ATTRIBUTES
SELECT * FROM translation.ds_cfs01_geo;
DROP TABLE IF EXISTS translation_devel.ds_cfs01_geo_devel;
CREATE TABLE translation_devel.ds_cfs01_geo_devel AS
SELECT * FROM translation.ds_cfs01_geo; --WHERE rule_id::int = 1

SELECT * FROM translation_devel.ds_cfs01_geo_devel;
SELECT TT_Prepare('translation_devel', 'ds_cfs01_geo_devel', '_ds01_geo_devel');
SELECT TT_CreateMappingView('rawfri', 'ds01', 'ds', 200);
SELECT * FROM TT_Translate_ds01_geo_devel('rawfri', 'ds01_l1_to_ds_l1_map_200'); -- 4 s.


-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT b.inventory_id, b.src_filename, b.map_sheet_id, b.orig_stand_id, b.ogc_fid, a.cas_id,
       b.stand_photo_year, a.dist_year_1,
	   b.dist_type_1, a.dist_type_1
FROM TT_Translate_ds01_dst_devel('rawfri', 'ds01_l1_to_ds_l1_map_200') a, 
     rawfri.ds01_l1_to_ds_l1_map_200 b
WHERE b.ogc_fid::int = trim(leading 'x' from right(a.cas_id, 7))::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_devel');
