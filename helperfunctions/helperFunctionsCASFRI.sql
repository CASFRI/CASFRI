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

-------------------------------------------------------------------------------
-- TT_vri01_non_for_veg_validation(text, text, text, text)
--  
-- inventory_standard_cd text
-- land_cover_class_cd_1 text
-- bclcs_level_4 text
-- non_productive_descriptor_cd text
--
-- Check the correct combination of values exists based on the translation rules.
-- If not return FALSE
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_veg_validation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text
)
RETURNS boolean AS $$
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('AF', 'M', 'NPBR', 'OR') THEN
        RETURN TRUE;
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        RETURN TRUE;
      END IF;
    END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_nat_non_veg_validation(text, text, text, text, text)
--  
-- inventory_standard_cd text
-- land_cover_class_cd_1 text
-- bclcs_level_4 text
-- non_productive_descriptor_cd text
-- non_veg_cover_type_1
--
-- Check the correct combination of values exists based on the translation rules.
-- If not return FALSE
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_validation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_nat_non_veg_validation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS boolean AS $$
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'DW', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RS', 'TA') THEN
        RETURN TRUE;
      END IF;
    END IF;

    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'EL', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RO', 'RS', 'SI', 'TA') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        RETURN TRUE;
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('A', 'CL', 'G', 'ICE', 'L', 'MUD', 'R', 'RIV', 'S', 'SAND', 'TIDE') THEN
        RETURN TRUE;
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        RETURN TRUE;
      END IF;
    END IF;
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_anth_validation(text, text, text, text)
--  
-- inventory_standard_cd text
-- land_cover_class_cd_1 text
-- non_productive_descriptor_cd text
-- non_veg_cover_type_1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_anth_validation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS boolean AS $$
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        RETURN TRUE;
      END IF;
    END IF;
        
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        RETURN TRUE;
      END IF;
    END IF;
        
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('C', 'GR', 'P', 'U') THEN
        RETURN TRUE;
      END IF;
    END IF;    
    RETURN FALSE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_code(
  wc text,
  vt text,
  im text
)
RETURNS text AS $$
  SELECT CASE
           WHEN wc='BO' AND vt='EV' AND im='BP' THEN 'BO-B'
           WHEN wc='FE' AND vt='EV' AND im='BP' THEN 'FO-B'
           WHEN wc='BO' AND vt='EV' AND im='DI' THEN 'BO--'
           WHEN wc='BO' AND vt='AW' AND im='BP' THEN 'BT-B'
           WHEN wc='BO' AND vt='OV' AND im='BP' THEN 'OO-B'
           WHEN wc='FE' AND vt='EV' AND im IN ('MI', 'DI') THEN 'FO--'
           WHEN wc='FE' AND vt='OV' AND im='MI' THEN 'OO--'
           WHEN wc='BO' AND vt='FS' THEN 'BTNN'
           WHEN wc='BO' AND vt='SV' THEN 'BONS'
           WHEN wc='FE' AND vt IN ('FH', 'FS') THEN 'FTNN'
           WHEN wc='FE' AND vt IN ('AW', 'SV') THEN 'FONS'
           WHEN wc='FW' AND im='BP' THEN 'OF-B'
           WHEN wc='FE' AND vt='EV' THEN 'FO--'
           WHEN wc IN ('FE', 'BO') AND vt='OV' THEN 'OO--'
           WHEN wc IN ('FE', 'BO') AND vt='OW' THEN 'O---'
           WHEN wc='BO' AND vt='EV' THEN 'BP--'
           WHEN wc='BO' AND vt='AW' THEN 'BT--'
           WHEN wc='AB' THEN 'OONN'
           WHEN wc='FM' THEN 'MONG'
           WHEN wc='FW' THEN 'STNN'
           WHEN wc='SB' THEN 'SONS'
           WHEN wc='CM' THEN 'MCNG'
           WHEN wc='TF' THEN 'TMNN'
           WHEN wc IN ('NP', 'WL') THEN 'W---'
           ELSE NULL
         END;
$$ LANGUAGE sql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_validation(text, text, text, text)
--
--  wc text
--  vt text
--  im text
--  ret_char_pos text
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nbi01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_validation(
  wc text,
  vt text,
  im text,
	ret_char_pos text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_wetland_validation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	wetland_code = TT_nbi01_wetland_code(wc, vt, im);

    -- return true or false
    IF wetland_code IS NULL OR substring(wetland_code from ret_char_pos::int for 1) = '-' THEN
      RETURN FALSE;
		END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Translation Function Definitions...
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- TT_vri01_origin_translation(text, text)
--
-- proj_date text
-- proj_age text
--
-- get projected year as first 4 characters of proj_date  
-- return projected year minus projected age
-- Validation should ensure projected year substring is an integer using TT_vri01_origin_validation,
-- and that projected age is not zero using TT_IsNotEqualToInt()
-- 
-- e.g. TT_vri01_origin_translation(proj_date, proj_age)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_origin_translation(text, text);
CREATE OR REPLACE FUNCTION TT_vri01_origin_translation(
  proj_date text,
  proj_age text
)
RETURNS integer AS $$
  BEGIN
    RETURN substring(proj_date from 1 for 4)::int - proj_age::int;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_site_index_translation(text, text)
--
--  site_index text
--  site_index_est text
--
-- If site_index not null, return it.
-- Otherwise return site_index_est.
-- If both are null, TT_vri01_site_index_validation should return error.
-- 
-- e.g. TT_vri01_site_index_translation(site_index, site_index_est)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_site_index_translation(text, text);
CREATE OR REPLACE FUNCTION TT_vri01_site_index_translation(
  site_index text,
  site_index_est text
)
RETURNS double precision AS $$
  BEGIN
    IF TT_NotEmpty(site_index) THEN
      RETURN site_index::double precision;
    ELSIF NOT TT_NotEmpty(site_index) AND TT_NotEmpty(site_index_est) THEN
      RETURN site_index_est::double precision;
	  END IF;
		RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_veg_translation(text, text, text, text)
--  
-- inventory_standard_cd text
-- land_cover_class_cd_1 text
-- bclcs_level_4 text
-- non_productive_descriptor_cd text
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_veg_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_veg_translation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text
)
RETURNS text AS $$
  DECLARE
    result text = NULL;
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL THEN
      IF land_cover_class_cd_1 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        result = TT_MapText(land_cover_class_cd_1, '{''BL'', ''BM'', ''BY'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}', '{''BR'', ''BR'', ''BR'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        result = TT_MapText(bclcs_level_4, '{''BL'', ''BM'', ''BY'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}', '{''BR'', ''BR'', ''BR'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('AF', 'M', 'NPBR', 'OR') THEN
        result = TT_MapText(non_productive_descriptor_cd, '{''AF'', ''M'', ''NPBR'', ''OR''}', '{''AF'', ''HG'', ''ST'', ''HG''}');
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('BL', 'BM', 'BY', 'HE', 'HF', 'HG', 'SL', 'ST') THEN
        result = TT_MapText(bclcs_level_4, '{''BL'', ''BM'', ''BY'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}', '{''BR'', ''BR'', ''BR'', ''HE'', ''HF'', ''HG'', ''SL'', ''ST''}');
      END IF;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_nat_non_veg_translation(text, text, text, text, text)
--  
-- inventory_standard_cd text
-- land_cover_class_cd_1 text
-- bclcs_level_4 text
-- non_productive_descriptor_cd text
-- non_veg_cover_type_1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_nat_non_veg_translation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_nat_non_veg_translation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  bclcs_level_4 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS text AS $$
  DECLARE
    result text = NULL;
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'DW', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RS', 'TA') THEN
        result = TT_MapText(non_veg_cover_type_1, '{''BE'', ''BI'', ''BR'', ''BU'', ''CB'', ''DW'', ''ES'', ''GL'', ''LA'', ''LB'', ''LL'', ''LS'', ''MN'', ''MU'', ''OC'', ''PN'', ''RE'', ''RI'', ''RM'', ''RS'', ''TA''}', '{''BE'', ''RK'', ''RK'', ''EX'', ''EX'', ''DW'', ''EX'', ''SI'', ''LA'', ''RK'', ''EX'', ''WS'', ''EX'', ''WS'', ''OC'', ''SI'', ''LA'', ''RI'', ''EX'', ''WS'', ''RK''}');
      END IF;
    END IF;

    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL AND result IS NULL THEN
      IF land_cover_class_cd_1 IN ('BE', 'BI', 'BR', 'BU', 'CB', 'EL', 'ES', 'GL', 'LA', 'LB', 'LL', 'LS', 'MN', 'MU', 'OC', 'PN', 'RE', 'RI', 'RM', 'RO', 'RS', 'SI', 'TA') THEN
        result = TT_MapText(land_cover_class_cd_1, '{''BE'', ''BI'', ''BR'', ''BU'', ''CB'', ''EL'', ''ES'', ''GL'', ''LA'', ''LB'', ''LL'', ''LS'', ''MN'', ''MU'', ''OC'', ''PN'', ''RE'', ''RI'', ''RM'', ''RO'', ''RS'', ''SI'', ''TA''}', '{''BE'', ''RK'', ''RK'', ''EX'', ''EX'', ''EX'', ''EX'', ''SI'', ''LA'', ''RK'', ''EX'', ''WS'', ''EX'', ''WS'', ''OC'', ''SI'', ''LA'', ''RI'', ''EX'', ''RK'', ''WS'', ''SI'', ''RK''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V', 'I') AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        result = TT_MapText(bclcs_level_4, '{''EL'', ''RO'', ''SI''}', '{''EX'', ''RK'', ''SI''}');
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('A', 'CL', 'G', 'ICE', 'L', 'MUD', 'R', 'RIV', 'S', 'SAND', 'TIDE') THEN
        result = TT_MapText(non_productive_descriptor_cd, '{''A'', ''CL'', ''G'', ''ICE'', ''L'', ''MUD'', ''R'', ''RIV'', ''S'', ''SAND'', ''TIDE''}', '{''AP'', ''EX'', ''WS'', ''SI'', ''LA'', ''EX'', ''RK'', ''RI'', ''SL'', ''SA'', ''TF''}');
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND bclcs_level_4 IS NOT NULL AND result IS NULL THEN
      IF bclcs_level_4 IN ('EL', 'RO', 'SI') THEN
        result = TT_MapText(bclcs_level_4, '{''EL'', ''RO'', ''SI''}', '{''EX'', ''RK'', ''SI''}');
      END IF;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_anth_translation(text, text, text, text)
--  
-- inventory_standard_cd text
-- land_cover_class_cd_1 text
-- non_productive_descriptor_cd text
-- non_veg_cover_type_1
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_non_for_anth_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_non_for_anth_translation(
  inventory_standard_cd text,
  land_cover_class_cd_1 text,
  non_productive_descriptor_cd text,
  non_veg_cover_type_1 text
)
RETURNS text AS $$
  DECLARE
    result text = NULL;
  BEGIN
    -- run if statements
    IF inventory_standard_cd IN ('V', 'I') AND non_veg_cover_type_1 IS NOT NULL THEN
      IF non_veg_cover_type_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        result = TT_MapText(non_veg_cover_type_1, '{''AP'', ''GP'', ''MI'', ''MZ'', ''OT'', ''RN'', ''RZ'', ''TZ'', ''UR''}', '{''FA'', ''IN'', ''IN'', ''IN'', ''OT'', ''FA'', ''FA'', ''IN'', ''FA''}');
      END IF;
    END IF;
        
    IF inventory_standard_cd IN ('V', 'I') AND land_cover_class_cd_1 IS NOT NULL AND result IS NULL THEN
      IF land_cover_class_cd_1 IN ('AP', 'GP', 'MI', 'MZ', 'OT', 'RN', 'RZ', 'TZ', 'UR') THEN
        result = TT_MapText(land_cover_class_cd_1, '{''AP'', ''GP'', ''MI'', ''MZ'', ''OT'', ''RN'', ''RZ'', ''TZ'', ''UR''}', '{''FA'', ''IN'', ''IN'', ''IN'', ''OT'', ''FA'', ''FA'', ''IN'', ''FA''}');
      END IF;
    END IF;
        
    IF inventory_standard_cd='F' AND non_productive_descriptor_cd IS NOT NULL THEN
      IF non_productive_descriptor_cd IN ('C', 'GR', 'P', 'U') THEN
        result = TT_MapText(non_productive_descriptor_cd, '{''C'', ''GR'', ''P'', ''U''}', '{''CL'', ''IN'', ''CL'', ''FA''}');
      END IF;
    END IF;
    
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- THIS COULD BECOME A GENERIC FUNCTION IF IT'S USEFUL IN OTHER FRIs
--
-- TT_avi01_non_for_anth_translation(text, text, text, text, text)
--
--  anth_veg text
--  anth_non text
--  lst1 text
--  lst2 text
--  ignoreCase text
--
--  For two values, if one of them is null or empty and the other is not null or empty.
--  use the value that is not null or empty in mapText.
--
-- e.g. TT_avi01_non_for_anth_translation(val1, val2, lst1, lst2, ignoreCase)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_avi01_non_for_anth_translation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_avi01_non_for_anth_translation(
  val1 text,
  val2 text,
  lst1 text,
  lst2 text,
  ignoreCase text)
RETURNS text AS $$
  BEGIN
    PERFORM TT_ValidateParams('TT_avi01_non_for_anth_translation',
                              ARRAY['lst1', lst1, 'stringlist',
                                    'lst2', lst2, 'stringlist',  
                                    'ignoreCase', ignoreCase, 'boolean']);

    IF NOT TT_NotEmpty(val1) AND TT_NotEmpty(val2) THEN
      RETURN TT_MapText(val2, lst1, lst2, ignoreCase);
    ELSIF TT_NotEmpty(val1) AND NOT TT_NotEmpty(val2) THEN
      RETURN TT_MapText(val1, lst1, lst2, ignoreCase);
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_stand_structure_translation(text, text, text)
--
--  src_filename text
--  l1vs text
--  l2vs text
--
-- If src_filename=“Forest” and l2vs=0, then stand_structure=“S”
-- If src_filename=“Forest” and (l1vs>0 and l2vs>0) then stand_structure=“M”
-- If src_filename=“Forest” and (l1vs>1 and l2vs>1) then stand_structure=“C”
--
-- For NB01 src_filename should match 'Forest'.
-- For NB02 src_filename should match 'geonb_forest-foret'.
--
-- e.g. TT_nbi01_stand_structure_translation(src_filename, l1vs, l2vs)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_stand_structure_translation(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_stand_structure_translation(
  src_filename text,
  l1vs text,
  l2vs text
)
RETURNS text AS $$
  DECLARE
    _l1vs int;
    _l2vs int;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_stand_structure_translation',
                              ARRAY['src_filename', src_filename, 'text',
                                    'l1vs', l1vs, 'int',  
                                    'l2vs', l2vs, 'int']);
    _l1vs = l1vs::int;
    _l2vs = l2vs::int;
		
	IF src_filename IN ('Forest', 'geonb_forest-foret') THEN
	  IF _l2vs = 0 THEN
		RETURN 'S';
	  ELSIF _l1vs > 1 AND _l2vs > 1 THEN
		  RETURN 'C';
	  ELSIF _l1vs > 0 AND _l2vs > 0 THEN
		  RETURN 'M';
	  END IF;
	END IF;				
	RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_num_of_layers_translation(text, text, text)
--
--  src_filename text
--  l1vs text
--  l2vs text
--
-- If src_filename=“Forest” stand_structure = S, num_of_layers = 1.
-- If src_filename=“Forest” stand_structure = M or C, then stand_structure=“M”
--
-- For NB01 src_filename should match 'Forest'.
-- For NB02 src_filename should match 'geonb_forest-foret'.
--
-- e.g. TT_nbi01_num_of_layers_translation(src_filename, l1vs, l2vs)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_num_of_layers_translation(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_num_of_layers_translation(
  src_filename text,
  l1vs text,
  l2vs text
)
RETURNS int AS $$
  DECLARE
    _l1vs int;
    _l2vs int;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_num_of_layers_translation',
                              ARRAY['src_filename', src_filename, 'text',
                                    'l1vs', l1vs, 'int',  
                                    'l2vs', l2vs, 'int']);
		
		IF src_filename IN ('Forest', 'geonb_forest-foret') THEN
		  IF TT_nbi01_stand_structure_translation(src_filename, l1vs, l2vs) = 'S' THEN
			  RETURN 1;
			ELSIF TT_nbi01_stand_structure_translation(src_filename, l1vs, l2vs) IN ('M', 'C') THEN
			  RETURN 2;
		  END IF;
		END IF;				
		RETURN NULL;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_translation(text, text, text, text)
--
--  wc text
--  vt text
--  im text
--  ret_char_pos text
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nbi01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_translation(
  wc text,
  vt text,
  im text,
  ret_char_pos text
)
RETURNS text AS $$
  DECLARE
	wetland_code text;
    result text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nbi01_wetland_translation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	wetland_code = TT_nbi01_wetland_code(wc, vt, im);

    -- substring wetland_code
    IF wetland_code IS NOT NULL THEN
      result = substring(wetland_code from ret_char_pos::int for 1);
    END IF;
    
    -- return value or null
    IF wetland_code IS NULL OR result = '-' THEN
      RETURN NULL;
    END IF;
    RETURN result;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_productive_for_translation(text, text, text, text, text)
--
--  l1cc text
--  l1ht text
--  l1trt text
--  l2trt text
--  fst text
--
-- If no valid crown closure value, or no valid height value. Assign PP.
-- Or if forest stand type is 0, and l1 or l2 trt is neither CC or empty string. Assign PP.
-- Otherwise assign PF (productive forest).
--
-- e.g. TT_nbi01_productive_for_translation(l1cc, l1ht, l1trt, l2trt, fst)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_productive_for_translation(text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_productive_for_translation(
  l1cc text,
  l1ht text,
  l1trt text,
  l2trt text,
  fst text
)
RETURNS text AS $$
  BEGIN
    IF NOT TT_NotNull(l1cc) THEN
      RETURN 'PP';
    ELSIF NOT TT_MatchList(l1cc, '{''1'', ''2'', ''3'', ''4'', ''5''}') THEN
      RETURN 'PP';
    ELSEIF NOT TT_NotNull(l1ht) THEN
      RETURN 'PP';
    ELSIF NOT TT_IsGreaterThan(l1ht, '0.1') THEN
      RETURN 'PP';
    ELSIF NOT TT_IsLessThan(l1ht, '100') THEN
      RETURN 'PP';
    ELSIF fst = '0'::text AND l1trt != 'CC' AND btrim(l1trt, ' ') != '' THEN
      RETURN 'PP';
    ELSIF fst = '0'::text AND l2trt != 'CC' AND btrim(l2trt, ' ') != '' THEN
      RETURN 'PP';
    END IF;
    RETURN 'PF';
  END;
$$ LANGUAGE plpgsql VOLATILE;