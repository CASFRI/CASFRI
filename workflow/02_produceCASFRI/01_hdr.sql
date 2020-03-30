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
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, 
       standard_id, standard_revision, inventory_manual, src_data_format, 
       acquisition_date, data_transfer, received_from, contact_info, 
       data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id IN ('AB06', 'AB16', 'BC08', 'BC10', 'NB01', 'NB02', 'NT01', 'NT02', 'ON02', 'SK01', 'YT02');
------------------------
SELECT count(*) FROM casfri50.hdr_all; -- 5

-- Add primary key constraint
ALTER TABLE casfri50.hdr_all ADD PRIMARY KEY (inventory_id);
-------------------------------------------------------