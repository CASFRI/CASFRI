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
-- TT_vri01_site_index_validation(text, text)
--
--  site_index text
--  site_index_est text
--
-- Return TRUE one of the vals is not null. If both are null return FALSE.
-- Translation rule will return site_class if present, if not returns site_class_est.
-- If both null returns error code during validation. 
-- Should also return error messages if not numeric, and not between 0 and 99. 
--    Cannot return specific error codes in translation table because failure of one column does not mean failure of the entire row.
--    THIS IS AN EXAMPLE OF A TRANSLATION THAT COULD RETURN A VALUE FROM MULTIPLE COLUMNS.
--    CANNOT VALIDATE EACH COLUMN SEPERATELY BECAUSE FAILURE WILL RETURN ERROR CODE, WE ONLY WANT AN ERROR CODE IF BOTH COLUMNS HAVE
--    INVALID VALUES. tHEREFORE NEED TO HARDCODE THESE CHECKS IN A SINGLE VALIDATION FUNCTION.
-- 
-- e.g. TT_vri01_site_index_validation(1,1)
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_site_index_validation(text, text);
CREATE OR REPLACE FUNCTION TT_vri01_site_index_validation(
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
    
    IF _site_index = 'not_empty' THEN -- if site_index is not null, return it after running checks.
      IF NOT TT_IsNumeric(site_index) THEN -- check for numeric
        RAISE NOTICE 'site_index: %, is not numeric', site_index;
        RETURN FALSE;
      ELSIF NOT TT_Between(site_index,'0'::text,'99'::text) THEN -- check for between
        RAISE NOTICE 'site_index: %, is not between 0 - 99', site_index;
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    ELSIF _site_index_est = 'not_empty' THEN -- otherwise return est_site_index if not null, after running checks
      IF NOT TT_IsNumeric(site_index_est) THEN -- check for numeric
        RAISE NOTICE 'est_site_index: %, is not numeric', site_index_est;
        RETURN FALSE;
      ELSIF NOT TT_Between(site_index_est,'0'::text,'99'::text) THEN -- check for between
        RAISE NOTICE 'est_site_index: %, is not between 0 - 99', site_index_est;
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    ELSE -- if both empty return FALSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Begin Translation Function Definitions...
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- TT_vri01_origin_translation(text)
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
--DROP FUNCTION IF EXISTS TT_vri01_origin_translation(text,text);
CREATE OR REPLACE FUNCTION TT_vri01_origin_translation(
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
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TRANSLATION_ERROR';
    RETURN '-3333';
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_veg_translation(text, text)
--
-- inputs - inventory_standard_cd, land_cover_class_cd_1
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
    _land_cover_class_cd_1 boolean;
    _bclcs_level_4 boolean;
    _non_productive_descriptor_cd boolean;
    return text;
  BEGIN
    -- initialize return, and flag variables as empty if null or empty strings
    return = 'NULL'; -- returns NULL if not naturally non-vegetated
    IF land_cover_class_cd_1 IS NULL OR replace(land_cover_class_cd_1, ' ', '') = ''::text THEN
      _land_cover_class_cd_1 = FALSE;
    ELSE
      _land_cover_class_cd_1 = TRUE;
    END IF;
    IF bclcs_level_4 IS NULL OR replace(bclcs_level_4, ' ', '') = ''::text THEN
      _bclcs_level_4 = FALSE;
    ELSE
      _bclcs_level_4 = TRUE;
    END IF;
    IF non_productive_descriptor_cd IS NULL OR replace(non_productive_descriptor_cd, ' ', '') = ''::text THEN
      _non_productive_descriptor_cd = FALSE;
    ELSE
      _non_productive_descriptor_cd = TRUE;
    END IF;
    
    -- run if statements
    IF inventory_standard_cd IN ('V','I') AND _land_cover_class_cd_1 THEN
      IF land_cover_class_cd_1 IN ('BL','BM','BY','HE','HF','HG','SL','ST') THEN
        return = TT_MapText(land_cover_class_cd_1, 'BL,BM,BY,HE,HF,HG,SL,ST', 'BR,BR,BR,HE,HF,HG,SL,ST');
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V','I') AND _bclcs_level_4 AND return = 'NULL' THEN
      IF bclcs_level_4 IN ('BL','BM','BY','HE','HF','HG','SL','ST') THEN
        return = TT_MapText(bclcs_level_4, 'BL,BM,BY,HE,HF,HG,SL,ST', 'BR,BR,BR,HE,HF,HG,SL,ST');
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND _non_productive_descriptor_cd THEN
      IF non_productive_descriptor_cd IN ('AF','M','NPBR','OR') THEN
        return = TT_MapText(non_productive_descriptor_cd, 'AF,M,NPBR,OR', 'AF,HG,ST,HG');
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND _bclcs_level_4 AND return = 'NULL' THEN
      IF bclcs_level_4 IN ('BL','BM','BY','HE','HF','HG','SL','ST') THEN
        return = TT_MapText(bclcs_level_4, 'BL,BM,BY,HE,HF,HG,SL,ST', 'BR,BR,BR,HE,HF,HG,SL,ST');
      END IF;
    END IF;
    RETURN return;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TRANSLATION_ERROR';
    RETURN 'TRANSLATION_ERROR';
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
    _land_cover_class_cd_1 boolean;
    _bclcs_level_4 boolean;
    _non_productive_descriptor_cd boolean;
    _non_veg_cover_type_1 boolean;
    return text;
  BEGIN
    -- initialize return, and flag variables as empty if null or empty strings
    return = 'NULL'; -- returns NULL if not naturally non-vegetated
    IF land_cover_class_cd_1 IS NULL OR replace(land_cover_class_cd_1, ' ', '') = ''::text THEN
      _land_cover_class_cd_1 = FALSE;
    ELSE
      _land_cover_class_cd_1 = TRUE;
    END IF;
    IF bclcs_level_4 IS NULL OR replace(bclcs_level_4, ' ', '') = ''::text THEN
      _bclcs_level_4 = FALSE;
    ELSE
      _bclcs_level_4 = TRUE;
    END IF;
    IF non_productive_descriptor_cd IS NULL OR replace(non_productive_descriptor_cd, ' ', '') = ''::text THEN
      _non_productive_descriptor_cd = FALSE;
    ELSE
      _non_productive_descriptor_cd = TRUE;
    END IF;
    IF non_veg_cover_type_1 IS NULL OR replace(non_veg_cover_type_1, ' ', '') = ''::text THEN
      _non_veg_cover_type_1 = FALSE;
    ELSE
      _non_veg_cover_type_1 = TRUE;
    END IF;

    -- run if statements
    IF inventory_standard_cd IN ('V','I') AND _non_veg_cover_type_1 THEN
      IF non_veg_cover_type_1 IN ('BE','BI','BR','BU','CB','DW','ES','GL','LA','LB','LL','LS','MN','MU','OC','PN','RE','RI','RM','RS','TA') THEN
        return = TT_MapText(non_veg_cover_type_1, 'BE,BI,BR,BU,CB,DW,ES,GL,LA,LB,LL,LS,MN,MU,OC,PN,RE,RI,RM,RS,TA', 'BE,RK,RK,EX,EX,DW,EX,SI,LA,RK,EX,WS,EX,WS,OC,SI,LA,RI,EX,WS,RK');
      END IF;
    END IF;

    IF inventory_standard_cd IN ('V','I') AND _land_cover_class_cd_1 AND return = 'NULL' THEN
      IF land_cover_class_cd_1 IN ('BE','BI','BR','BU','CB','EL','ES','GL','LA','LB','LL','LS','MN','MU','OC','PN','RE','RI','RM','RO','RS','SI','TA') THEN
        return = TT_MapText(land_cover_class_cd_1, 'BE,BI,BR,BU,CB,EL,ES,GL,LA,LB,LL,LS,MN,MU,OC,PN,RE,RI,RM,RO,RS,SI,TA', 'BE,RK,RK,EX,EX,EX,EX,SI,LA,RK,EX,WS,EX,WS,OC,SI,LA,RI,EX,RK,WS,SI,RK');
      END IF;
    END IF;
    
    IF inventory_standard_cd IN ('V','I') AND _bclcs_level_4 AND return = 'NULL' THEN
      IF bclcs_level_4 IN ('EL','RO','SI') THEN
        return = TT_MapText(bclcs_level_4, 'EL,RO,SI', 'EX,RK,SI');
      END IF;
    END IF;
    
    IF inventory_standard_cd='F' AND _non_productive_descriptor_cd THEN
      IF non_productive_descriptor_cd IN ('A','CL','G','ICE','L','MUD','R','RIV','S','SAND','TIDE') THEN
        return = TT_MapText(non_productive_descriptor_cd, 'A,CL,G,ICE,L,MUD,R,RIV,S,SAND,TIDE', 'AP,EX,WS,SI,LA,EX,RK,RI,SL,SA,TF');
      END IF;
    END IF;

    IF inventory_standard_cd='F' AND _bclcs_level_4 AND return = 'NULL' THEN
      IF bclcs_level_4 IN ('EL','RO','SI') THEN
        return = TT_MapText(bclcs_level_4, 'EL,RO,SI', 'EX,RK,SI');
      END IF;
    END IF;
    RETURN return;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TRANSLATION_ERROR';
    RETURN 'TRANSLATION_ERROR';
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_non_for_anth_translation(text, text, text, text
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
    _land_cover_class_cd_1 boolean;
    _non_productive_descriptor_cd boolean;
    _non_veg_cover_type_1 boolean;
    return text;
  BEGIN
    -- initialize return, and flag variables as empty if null or empty strings
    return = 'NULL'; -- returns NULL if not naturally non-vegetated
    IF land_cover_class_cd_1 IS NULL OR replace(land_cover_class_cd_1, ' ', '') = ''::text THEN
      _land_cover_class_cd_1 = FALSE;
    ELSE
      _land_cover_class_cd_1 = TRUE;
    END IF;
    IF non_productive_descriptor_cd IS NULL OR replace(non_productive_descriptor_cd, ' ', '') = ''::text THEN
      _non_productive_descriptor_cd = FALSE;
    ELSE
      _non_productive_descriptor_cd = TRUE;
    END IF;
    IF non_veg_cover_type_1 IS NULL OR replace(non_veg_cover_type_1, ' ', '') = ''::text THEN
      _non_veg_cover_type_1 = FALSE;
    ELSE
      _non_veg_cover_type_1 = TRUE;
    END IF;

    -- run if statements
    IF inventory_standard_cd IN ('V','I') AND _non_veg_cover_type_1 THEN
      IF non_veg_cover_type_1 IN ('AP','GP','MI','MZ','OT','RN','RZ','TZ','UR') THEN
        return = TT_MapText(non_veg_cover_type_1, 'AP,GP,MI,MZ,OT,RN,RZ,TZ,UR', 'FA,IN,IN,IN,OT,FA,FA,IN,FA');
      END IF;
    END IF;

    IF inventory_standard_cd IN ('V','I') AND _land_cover_class_cd_1 AND return = 'NULL' THEN
      IF land_cover_class_cd_1 IN ('AP','GP','MI','MZ','OT','RN','RZ','TZ','UR') THEN
        return = TT_MapText(land_cover_class_cd_1, 'AP,GP,MI,MZ,OT,RN,RZ,TZ,UR', 'FA,IN,IN,IN,OT,FA,FA,IN,FA');
      END IF;
    END IF;
        
    IF inventory_standard_cd='F' AND _non_productive_descriptor_cd THEN
      IF non_productive_descriptor_cd IN ('C','GR','P','U') THEN
        return = TT_MapText(non_productive_descriptor_cd, 'C,GR,P,U', 'CL,IN,CL,FA');
      END IF;
    END IF;

    RETURN return;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'TRANSLATION_ERROR';
    RETURN 'TRANSLATION_ERROR';
  END;
$$ LANGUAGE plpgsql VOLATILE;
