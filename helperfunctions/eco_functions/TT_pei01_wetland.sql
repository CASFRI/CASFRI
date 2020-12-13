-------------------------------------------------------------------------------
-- TT_pei01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_pei01_wetland_code(text, int);
CREATE OR REPLACE FUNCTION TT_pei01_wetland_code(
  landtype text,
  per1 text
)
RETURNS text AS $$
  SELECT CASE
           WHEN landtype='BO' AND NOT per1='0' THEN 'BFX-'
		   WHEN landtype='BO' AND per1='0' THEN 'BOX-'
           WHEN landtype='SO' THEN 'SOX-'
           WHEN landtype='SW' AND NOT per1='0' THEN 'STX-'
           WHEN landtype='SW' AND per1='0' THEN 'SOX-'
           ELSE NULL
         END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_pei01_wetland_validation(text, text, text, text)
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
-- e.g. TT_pei01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_pei01_wetland_validation(text, int, text);
CREATE OR REPLACE FUNCTION TT_pei01_wetland_validation(
  landtype text,
  per1 text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_pei01_wetland_code(landtype, per1) IN('BFX-', 'BOX-', 'SOX-', 'STX-', 'SOX-') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_pei01_wetland_translation(text, int, text)
-- Assign 4 letter wetland character code, then return the requested character (1-4)
-- e.g. TT_pei01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_pei01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_pei01_wetland_translation(
  landtype text,
  per1 text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
  BEGIN
    _wetland_code = TT_pei01_wetland_code(landtype, per1);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
