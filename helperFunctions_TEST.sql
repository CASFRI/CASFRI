-- Testing Cas id function

DROP FUNCTION IF EXISTS CasIdTest(text,text,text,text,text);
CREATE OR REPLACE FUNCTION CasIdTest(
  headerId text,
  source_filename text,
  mapsheet text,
  objectId text,
  rowId text
)
RETURNS text AS $$
  DECLARE
    var1 text;
    var2 text;
    var3 text;
    var4 text;
    var5 text;
  BEGIN
    var1 = headerId;
    var2 = TT_Pad(source_filename,15,'x');
    var3 = TT_Pad(mapsheet,10, 'x');
    var4 = TT_Pad(objectID,10,'0');
    var5 = TT_Pad(rowId,7,'0');
    RETURN TT_Concat('-', FALSE, var1, var2, var3, var4, var5);
  END;
$$ LANGUAGE plpgsql VOLATILE;


-- test on ab06
SELECT CasIdTest('ab_06', src_filename::text, trm_1::text, poly_num::text, poly_num::text) AS CAS_ID FROM rawfri.ab06;
