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
--
--
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Validation Function Definitions...
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- TT_vri1_origin_validation(text)
--
--  proj_date text
--
-- Return TRUE if the first 4 characters of val represent an integer. 
-- This is a year value used for translation.
-- 
-- e.g. TT_vri1_origin_validation('2001-01-01')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri1_origin_validation(text);
CREATE OR REPLACE FUNCTION TT_vri1_origin_validation(
  proj_date text
)
RETURNS boolean AS $$
  DECLARE
    _proj_date double precision;
  BEGIN
    _proj_date = substring(proj_date from 1 for 4)::double precision; -- get year
    RETURN _proj_date - _proj_date::int = 0; -- check its an integer
  EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IsNotEqualToInt(text)
--
--  val text
--
-- Return TRUE if the integer val1 is not equal to val2. 
-- This is needed for VRI ORIGIN to check the proj_age_1 is not zero
-- 
-- e.g. TT_IsNotEqualToInt(1, 0)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_IsNotEqualToInt(text, text);
CREATE OR REPLACE FUNCTION TT_IsNotEqualToInt(
  val1 text,
  val2 text
)
RETURNS boolean AS $$
  BEGIN
    IF NOT val1::int = val2::int THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri1_site_class_validation(text, text)
--
--  site_index text
--  site_index_est text
--
-- Return TRUE one of the vals is not null. If both are null return FALSE.
-- Translation rule will return site_class if present, if not returns site_class_est.
-- If both null returns error code during validation. 
-- 
-- e.g. TT_vri1_site_class_validation(1,1)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri1_site_class_validation(text, text);
CREATE OR REPLACE FUNCTION TT_vri1_site_class_validation(
  site_index text,
  site_index_est text
)
RETURNS boolean AS $$
  DECLARE
    _site_index text;
    _site_index_est text;
  BEGIN
    IF site_index IS NULL OR replace(site_index, ' ', '') = ''::text THEN
      _site_index = 'empty';
    ELSE
      _site_index = 'not_empty';
    END IF;    
    IF site_index_est IS NULL OR replace(site_index_est, ' ', '') = ''::text THEN
      _site_index_est = 'empty';
    ELSE
      _site_index_est = 'not_empty';
    END IF;
    
    IF _site_index = 'not_empty' OR _site_index_est = 'not_empty' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Translation Function Definitions...
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- TT_vri1_origin_translation(text)
--
-- proj_date text
-- proj_age text
--
-- get projected year as first 4 characters of proj_date  
-- return projected year minus projected age
-- Validation should ensure projected year substring is an integer using TT_vri1_origin_validation,
-- and that projected age is not zero using TT_IsNotEqualToInt()
-- 
-- e.g. TT_vri1_origin_translation(proj_date, proj_age)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri1_origin_translation(text,text);
CREATE OR REPLACE FUNCTION TT_vri1_origin_translation(
  proj_date text,
  proj_age text
)
RETURNS integer AS $$
  BEGIN
    RETURN substring(proj_date from 1 for 4)::int - proj_age::int;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TRANSLATION_ERROR';
    RETURN '-3333';
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri1_site_class_translation(text, text)
--
--  site_index text
--  site_index_est text
--
-- If site_index not null, return it.
-- Otherwise return site_index_est.
-- If both are null, TT_vri1_site_class_validation should return error.
-- 
-- e.g. TT_vri1_site_class_translation(site_index, site_index_est)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri1_site_class_translation(text, text);
CREATE OR REPLACE FUNCTION TT_vri1_site_class_translation(
  site_index text,
  site_index_est text
)
RETURNS double precision AS $$
  DECLARE
    _site_index text;
    _site_index_est text;
  BEGIN
    IF site_index IS NULL OR replace(site_index, ' ', '') = ''::text THEN
      _site_index = 'empty';
    ELSE
      _site_index = 'not_empty';
    END IF;    
    IF site_index_est IS NULL OR replace(site_index_est, ' ', '') = ''::text THEN
      _site_index_est = 'empty';
    ELSE
      _site_index_est = 'not_empty';
    END IF;
    
    IF _site_index = 'not_empty' THEN
      RETURN site_index::double precision;
    ELSIF _site_index = 'empty' AND _site_index_est = 'not_empty' THEN
      RETURN site_index_est::double precision;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;