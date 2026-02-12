------------------------------------------------------------------------------
-- CASFRI - Table creation script for CASFRI v5
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
CREATE SCHEMA IF NOT EXISTS casfri50;
--------------------------------------------------------------------------
-------------------------------------------------------
-- Translate all HDR tables into a common table
-- HDR tables only need one row per inventory, they
-- do not need to be made using translation, we can just
-- select the required row and columns from the
-- inventory_metadata table.
-------------------------------------------------------
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.hdr_all CASCADE;

CREATE TABLE casfri50.hdr_all AS -- 1 s
SELECT inventory_id, jurisdiction, owner_type, owner_name, standard_type, standard_version, 
       standard_id, standard_revision, documentation_titles, src_data_format, 
       production_years, publication_date, acquisition_date, acquisition_type, acquisition_links, contact_info, 
       data_availability, redistribution, permission, license_agreement, 
       photo_year_start, photo_year_end, photo_year_src
FROM public.inventory_metadata;
------------------------
SELECT count(*) FROM casfri50.hdr_all; -- 63

-- Add primary key constraint
ALTER TABLE casfri50.hdr_all ADD PRIMARY KEY (inventory_id);
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.cas_all CASCADE;
CREATE TABLE casfri50.cas_all
(
    cas_id text,
    inventory_id text,
    orig_stand_id text,
    stand_structure text,
    num_of_layers integer,
    map_sheet_id text,
    casfri_area double precision,
    casfri_perimeter double precision,
    src_inv_area double precision,
    stand_photo_year integer
);
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.dst_all CASCADE;
CREATE TABLE casfri50.dst_all
(
    cas_id text,
    dist_type_1 text,
    dist_year_1 integer,
    dist_ext_upper_1 integer,
    dist_ext_lower_1 integer,
    dist_type_2 text,
    dist_year_2 integer,
    dist_ext_upper_2 integer,
    dist_ext_lower_2 integer,
    dist_type_3 text,
    dist_year_3 integer,
    dist_ext_upper_3 integer,
    dist_ext_lower_3 integer,
    layer integer
);
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.eco_all CASCADE;
CREATE TABLE casfri50.eco_all
(
    cas_id text,
    wetland_type text,
    wet_veg_cover text,
    wet_landform_mod text,
    wet_local_mod text,
    eco_site text,
	layer integer
);
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.lyr_all CASCADE;
CREATE TABLE casfri50.lyr_all
(
    cas_id text,
    soil_moist_reg text,
    structure_per integer,
    structure_range double precision,
    layer integer,
    layer_rank integer,
    crown_closure_upper integer,
    crown_closure_lower integer,
    height_upper double precision,
    height_lower double precision,
    productivity text,
    productivity_type text,
    species_1 text,
    species_per_1 integer,
    species_2 text,
    species_per_2 integer,
    species_3 text,
    species_per_3 integer,
    species_4 text,
    species_per_4 integer,
    species_5 text,
    species_per_5 integer,
    species_6 text,
    species_per_6 integer,
    species_7 text,
    species_per_7 integer,
    species_8 text,
    species_per_8 integer,
    species_9 text,
    species_per_9 integer,
    species_10 text,
    species_per_10 integer,
    origin_upper integer,
    origin_lower integer,
    site_class text,
    site_index double precision
);
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.nfl_all CASCADE;
CREATE TABLE casfri50.nfl_all
(
    cas_id text,
    soil_moist_reg text,
    structure_per integer,
    layer integer,
    layer_rank integer,
    crown_closure_upper integer,
    crown_closure_lower integer,
    height_upper double precision,
    height_lower double precision,
    nat_non_veg text,
    non_for_anth text,
    non_for_veg text
);
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.geo_all CASCADE;
CREATE TABLE casfri50.geo_all
(
    cas_id text,
    geometry geometry(MultiPolygon, 102001)
);