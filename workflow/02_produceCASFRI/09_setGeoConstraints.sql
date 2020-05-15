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
-- Create a schema for lookup tables
-------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_lookup ;
-------------------------------------------------------
-- Add some constraints to the GEO_ALL table
-------------------------------------------------------
-- Add foreign key to CAS_ALL
SELECT TT_AddConstraint('casfri50', 'geo_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']);

-- Ensure attributes are NOT NULL
SELECT TT_AddConstraint('casfri50', 'geo_all', 'NOTNULL', ARRAY['cas_id']);
SELECT TT_AddConstraint('casfri50', 'geo_all', 'NOTNULL', ARRAY['geometry']);

-- Ensure GEO table CAS_ID is 50 characters long
SELECT TT_AddConstraint('casfri50', 'geo_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']);

-- Ensure GEO table GEOMETRY is valid
SELECT TT_AddConstraint('casfri50', 'geo_all', 'CHECK', 
                        ARRAY['geometry_isvalid', 'ST_IsValid(geometry)']);

-------------------------------------------------------

