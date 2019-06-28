------------------------------------------------------------------------------
-- CASFRI Helper functions uninstall file for CASFR v5 beta
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
--
--
--
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_vri1_origin_validation(text);
DROP FUNCTION IF EXISTS TT_IsNotEqualToInt(text, text)
DROP FUNCTION IF EXISTS TT_vri1_site_class_validation(text, text)

DROP FUNCTION IF EXISTS TT_vri1_origin_translation(text,text)
DROP FUNCTION IF EXISTS TT_vri1_site_class_translation(text, text)
