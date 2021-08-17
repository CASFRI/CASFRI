------------------------------------------------------------------------------
-- CASFRI - Geo constraints script for CASFRI v5
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
-- Add some constraints to the GEO_ALL table
-------------------------------------------------------
-------------------------------------------------------
-- Begin test section
-------------------------------------------------------
-- Uncomment to display only failing tests (at the end also)
--SELECT * FROM (
-------------------------------------------------------
-- Add some constraints to the CAS_ALL table
-------------------------------------------------------
SELECT '6.1'::text number,
       'geo_all' target_table,
       'Add primary key to GEO_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'geo_all', 'PK', 
                        ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
-------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'geo_all' target_table,
       'Add foreign key from GEO_ALL to CAS_ALL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'geo_all', 'FK', 
                        ARRAY['cas_id', 'casfri50', 'cas_all', 'cas_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.3'::text number,
       'geo_all' target_table,
       'Ensure CAS_ID is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'geo_all', 'NOTNULL', ARRAY['cas_id']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.4'::text number,
       'geo_all' target_table,
       'Ensure GEOMETRY is not NULL' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'geo_all', 'NOTNULL', ARRAY['geometry']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.5'::text number,
       'cas_all' target_table,
       'Ensure GEO table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'geo_all', 'CHECK', 
                        ARRAY['cas_id_length', 'length(cas_id) = 50']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.6'::text number,
       'cas_all' target_table,
       'Ensure GEO table CAS_ID is 50 characters long' description, 
       passed, cstr_query
FROM (SELECT * 
      FROM TT_AddConstraint('casfri50', 'geo_all', 'CHECK', 
                        ARRAY['geometry_isvalid', 'ST_IsValid(geometry)']) AS (passed boolean, cstr_query text)) foo
---------------------------------------------------------
--) foo WHERE NOT passed;

