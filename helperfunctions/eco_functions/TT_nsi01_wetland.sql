-------------------------------------------------------------------------------
-- TT_nsi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nsi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nsi01_wetland_code(
  fornon text,
  species text,
  crncl text,
  height text
)
RETURNS text AS $$
    SELECT CASE
        -- Original cases
        WHEN fornon='70' THEN 'W---'
        WHEN fornon='71' THEN 'MONG'
        WHEN fornon='72' THEN 'BONN'
        WHEN fornon='73' THEN 'BTNN'
        WHEN fornon='74' THEN 'ECNN'
        WHEN fornon='75' THEN 'MONG'
        -- These were added on 2012-09-17
        WHEN fornon IN('33','38','39') AND species IN('BS10','TL10','EC10','WB10','YB10','AS10') THEN 'SONS'
		WHEN (fornon='0' AND (species='TL10' OR (species LIKE '%TL%' AND species LIKE '%WB%') AND crncl <='50' AND height <='12')) THEN 'FTNN'
		WHEN (fornon='0' AND (species='TL10' OR (species LIKE '%TL%' AND species LIKE '%WB%') AND crncl >'50')) THEN 'STNN'
		WHEN (fornon='0' AND (species='EC10' OR (species LIKE '%EC%' AND species LIKE '%TL%')  OR (species LIKE '%EC%' AND species LIKE '%BS%')  OR (species LIKE '%EC%' AND species LIKE '%WB%'))) THEN 'STNN'
		WHEN (fornon='0' AND (species='AS10' OR (species LIKE '%AS%' AND species LIKE '%BS%')  OR (species LIKE '%AS%' AND species LIKE '%TL%'))) THEN 'STNN'
		WHEN (fornon='0' AND (species LIKE '%BS%' AND species LIKE '%LT%' )) THEN 'STNN'
		ELSE NULL
    END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nsi01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nsi01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nsi01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nsi01_wetland_validation(
  fornon text,
  species text,
  crncl text,
  height text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_nsi01_wetland_code(fornon, species, crncl, height) IN('W---', 'MONG', 'BONN', 'BTNN', 'ECNN', 'SONS', 'FTNN', 'STNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nsi01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nsi01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nsi01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nsi01_wetland_translation(
  fornon text,
  species text,
  crncl text,
  height text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_nsi01_wetland_code(fornon, species, crncl, height);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
