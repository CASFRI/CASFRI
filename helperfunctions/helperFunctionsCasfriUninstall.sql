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
DROP FUNCTION IF EXISTS TT_vri01_site_index_validation(text, text);
DROP FUNCTION IF EXISTS TT_avi01_non_for_anth_validation(text, text, text, text);

DROP FUNCTION IF EXISTS TT_vri01_origin_translation(text,text);
DROP FUNCTION IF EXISTS TT_vri01_site_index_translation(text, text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_translation(text, text, text, text,text);
DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_translation(text, text, text, text);
DROP FUNCTION IF EXISTS TT_avi01_non_for_anth_translation(text, text, text, text, text);