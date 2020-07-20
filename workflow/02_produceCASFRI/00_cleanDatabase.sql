------------------------------------------------------------------------------
-- CASFRI Helper functions installation file for CASFR v5 beta
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
------------------------------------------------------------------------------
SELECT TT_DropAllTranslateFct();
SELECT TT_DeleteAllViews('rawfri');
DROP SCHEMA IF EXISTS translation CASCADE;
DROP SCHEMA IF EXISTS casfri50_test CASCADE;
DROP SCHEMA IF EXISTS casfri50 CASCADE;
DROP EXTENSION IF EXISTS table_translation_framework CASCADE;


