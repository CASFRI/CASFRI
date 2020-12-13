-------------------------------------------------------------------------------
-- TT_nli01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nli01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nli01_wetland_code(
  stand_id text,
  site text,
  species_comp text
)
RETURNS text AS $$
	SELECT CASE
	    WHEN stand_id='920' THEN 'BONS'
	    WHEN stand_id='925' THEN 'BTNN'
	    WHEN stand_id='930' THEN 'MONG'
	    WHEN stand_id='900' AND site='W' THEN 'STNN'
	    WHEN stand_id='910' AND site='W' THEN 'STNN'
	    WHEN species_comp IN('BSTL', 'BSTLBF', 'BSTLWB' ) THEN 'STNN'
	    WHEN species_comp IN('TL', 'TLBF','TLWB', 'TLBS', 'TLBSBF', 'TLBSWB') THEN 'STNN'
	    WHEN species_comp IN('WBTL', 'WBTLBS', 'WBBSTL') THEN 'STNN'
    END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nli01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nli01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nli01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nli01_wetland_validation(
  stand_id text,
  site text,
  species_comp text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_nli01_wetland_code(stand_id, site, species_comp) IN('BONS', 'BTNN', 'MONG', 'STNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nli01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nli01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nli01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nli01_wetland_translation(
  stand_id text,
  site text,
  species_comp text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_nli01_wetland_code(stand_id, site, species_comp);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
