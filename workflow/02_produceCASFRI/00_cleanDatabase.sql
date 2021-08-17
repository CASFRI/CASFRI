------------------------------------------------------------------------------
-- CASFRI - Cleaning script for CASFRI v5
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
------------------------------------------------------------------------------
SELECT TT_DropAllTranslateFct();
SELECT TT_DeleteAllViews('rawfri');
DROP SCHEMA IF EXISTS translation CASCADE;
DROP SCHEMA IF EXISTS casfri50_test CASCADE;
DROP SCHEMA IF EXISTS casfri50 CASCADE;
DROP EXTENSION IF EXISTS table_translation_framework CASCADE;


