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
-- Begin Translation Function Definitions...
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- casId1 - used for ab06, nb01
--
-- inventoryId text - table name (e.g. 'BC08')
-- sourceFile - original name of source file, stored in src_filename create during loading
-- mapsheetId - mapsheet name
-- objectIdCol - object id from source data
-- rowIdCol - unique row id, e.g. ogc_fid primary key created on loading
--
-- Arguments can be supplied as:
--  1. Column names by calling e.g. src_filename::text.
--     In this case column values will be used from each row in table
--  2. Text strings by calling e.g. 'BC08'
--     In this case the string is applied to all rows
--
-- Examples
-- AB06
-- SELECT casId1('ab06', src_filename::text, trm_1::text, poly_num::text, ogc_fid::text) AS CAS_ID FROM rawfri.ab06;
--
-- NB01 - only FOREST.shp had the STDLAB attribute so objectId for many attributes will be 0
-- SELECT casId1('nb01', src_filename::text, '', stdlab::text, ogc_fid::text) AS CAS_ID FROM rawfri.nb01;
--
-- AB16 - We can use src_filename as the mapsheet instead of reconstructing the mapsheet name using the township, range, and meridian attributes.
--        - Letters will be lower case, cas04 was upper. Could change by making uppercase during loading.        
--      - FilenameCol will be a text string 'CANFOR' in this case
-- SELECT casId1('ab16', 'CANFOR', src_filename::text, forest_id_2::text, ogc_fid::text) AS CAS_ID FROM rawfri.ab16;
-------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS casId1(text,text,text,text,text);
CREATE OR REPLACE FUNCTION casId1(
  inventoryId text,
  sourceFile text,
  mapsheetId text,
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
    var1 = TT_Pad(inventoryId,4,'x');
    var2 = TT_Pad(sourceFile,15,'x');
    var3 = TT_Pad(mapsheetId,10, 'x');
    var4 = TT_Pad(objectId,10,'0');
    var5 = TT_Pad(rowId,7,'0');
    RETURN TT_Concat('-', FALSE, var1, var2, var3, var4, var5);
  END;
$$ LANGUAGE plpgsql VOLATILE;



