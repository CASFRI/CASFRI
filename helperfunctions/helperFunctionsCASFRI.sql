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
-- casId
--
-- inventoryId text - table name (e.g. 'BC08')
-- sourceFile - original name of source file, stored in src_filename create during loading
-- mapsheetId - mapsheet name
-- polygonIdCol - polygon id from source data
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
-- SELECT TT_casId('ab06', src_filename::text, trm_1::text, poly_num::text, ogc_fid::text) AS CAS_ID FROM rawfri.ab06;
-- In lookup table would be written: casId('ab06', src_filename, trm_1, poly_num, ogc_fid)
--
-- NB01 - only FOREST.shp had the STDLAB attribute so objectId for many attributes will be 0
-- SELECT TT_casId('nb01', src_filename::text, '', stdlab::text, ogc_fid::text) AS CAS_ID FROM rawfri.nb01;
-- In lookup table would be written: casId('nb01', src_filename, '', stdlab, ogc_fid)
--
-- AB16 - We can use src_filename as the mapsheet instead of reconstructing the mapsheet name using the township, range, and meridian attributes.
--        - Letters will be lower case, cas04 was upper. Could change by making uppercase during loading.        
--      - FilenameCol will be a text string 'CANFOR' in this case
-- SELECT TT_casId('ab16', 'CANFOR', src_filename::text, forest_id_2::text, ogc_fid::text) AS CAS_ID FROM rawfri.ab16;
-- In lookup table would be written: casId('nb01', src_filename, '', stdlab, ogc_fid)
-- 
-- BC08 - cas04 has SOURCE_ID column, don't know where this came from?
-- SELECT TT_casId('bc08', 'VEG_COMP_LYR_R1', map_id::text, feature_id::text, ogc_fid::text) AS CAS_ID FROM rawfri.bc08;
-- In lookup table would be written: casId('bc08', 'VEG_COMP_LYR_R1', map_id, feature_id, ogc_fid)
-------------------------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_casId(text,text,text,text,text);
CREATE OR REPLACE FUNCTION TT_casId(
  inventoryId text,
  sourceFile text,
  mapsheetId text,
  polygonIdCol text,
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
    var1 = TT_Pad(upper(inventoryId),4,'x');
    var2 = TT_Pad(upper(sourceFile),15,'x');
    var3 = TT_Pad(upper(mapsheetId),10, 'x');
    var4 = TT_Pad(polygonIdCol,10,'0');
    var5 = TT_Pad(rowId,7,'0');
    RETURN TT_Concat('-', FALSE, var1, var2, var3, var4, var5);
  END;
$$ LANGUAGE plpgsql VOLATILE;



