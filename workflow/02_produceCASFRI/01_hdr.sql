------------------------------------------------------------------------------
-- CASFRI - HDR table translation script for CASFRI v5
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
--------------------------------------------------------------------------
-- Translate the tables by appending all translated 
-- table to the same big table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all HDR tables into a common table
-- HDR tables only need one row per inventory, they
-- do not need to be made using translation, we can just
-- select the required row and columns from the
-- inventory_list_cas05 table.
-------------------------------------------------------
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.hdr_all CASCADE;

CREATE TABLE casfri50.hdr_all AS -- 1 s
SELECT inventory_id, jurisdiction, owner_type, owner_name, standard_type, standard_version, 
       standard_id, standard_revision, documentation_titles, src_data_format, 
       production_years, publication_date, acquisition_date, acquisition_type, acquisition_links, contact_info, 
       data_availability, redistribution, permission, license_agreement, 
       photo_year_start, photo_year_end, photo_year_src
FROM translation.inventory_list_cas05
WHERE inventory_id IN ('AB03', 'AB06', 'AB07', 'AB08', 'AB10', 'AB11', 'AB16', 'AB25', 'AB27','AB29', 'AB30', 
                       'AB31', 'AB32', 'AB33', 'BC08', 'BC10', 'BC11', 'BC12',
                       'MB01', 'MB02', 'MB04', 'MB05', 'MB06', 'MB07', 
                       'NB01', 'NB02', 'NL01', 'NS01', 'NS02', 'NS03', 'NT01', 'NT03', 'NT04',
                       'ON01', 'ON02', 'PC01', 'PC02', 'PE01', 
                       'QC01', 'QC02', 'QC03', 'QC04', 'QC05', 'QC06', 'QC07', 
                       'SK01', 'SK02', 'SK03', 'SK04', 'SK05', 'SK06', 
                       'YT01', 'YT02', 'YT03');
------------------------
SELECT count(*) FROM casfri50.hdr_all; -- 5

-- Add primary key constraint
ALTER TABLE casfri50.hdr_all ADD PRIMARY KEY (inventory_id);
-------------------------------------------------------