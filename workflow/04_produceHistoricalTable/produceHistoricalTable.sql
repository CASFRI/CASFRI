------------------------------------------------------------------------------
-- CASFRI Historical table production script for CASFRI v5 beta
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
------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_history;
-----------------------------------------------
DROP SEQUENCE IF EXISTS bug_splitbygrid;
CREATE SEQUENCE bug_splitbygrid START 1;
SELECT nextval('bug_splitbygrid');

-- Create a gridded version of the flat version of CASFRI
DROP TABLE IF EXISTS casfri50_history.casflat_gridded;
CREATE TABLE casfri50_history.casflat_gridded AS
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGrid(geometry, 1000)).geom geom
FROM casfri50_flat.cas_flat_all_layers_same_row
WHERE CASE WHEN nextval('bug_splitbygrid') % 10000 = 0 THEN TT_PrintMessage(currval('bug_splitbygrid')::text) ELSE TRUE END;

SELECT count(*) FROM casfri50_history.casflat_gridded;

CREATE INDEX ON casfri50_history.casflat_gridded USING btree(inventory_id);
CREATE INDEX ON casfri50_history.casflat_gridded USING btree(cas_id);
CREATE INDEX ON casfri50_history.casflat_gridded USING gist(geom);

------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ProduceInvGeoHistory(text) CASCADE;
CREATE OR REPLACE FUNCTION TT_ProduceInvGeoHistory(
  inv text
)
RETURNS boolean AS $$
  DECLARE
    queryStr text;
  BEGIN
    queryStr = 'DROP TABLE IF EXISTS casfri50_history.' || lower(inv) || '_history;
    CREATE TABLE casfri50_history.' || lower(inv) || '_history AS
    WITH geohistory_gridded AS (
      SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, stand_photo_year, TRUE, geom,
                                   ''casfri50_history'', ''casflat_gridded'', ''cas_id'', ''geom'', ''stand_photo_year'', ''inventory_id'')).*
      FROM casfri50_history.casflat_gridded
      WHERE inventory_id = ''' || inv || '''
      ORDER BY id, poly_id
    ), wkb_version AS (
      SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
      FROM geohistory_gridded
      GROUP BY id
    )
    SELECT id cas_id, geom, lowerval valid_year_begin, upperval valid_year_end
    FROM wkb_version;';
    EXECUTE queryStr;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-- Compute each inventory
SELECT TT_ProduceInvGeoHistory('AB03'); --   61633, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB06'); --   11484, pg11: , pg13:  2m13
SELECT TT_ProduceInvGeoHistory('AB07'); --   23268, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB08'); --   34474, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB10'); --  194696, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB11'); --  118624, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB16'); --  120476, pg11: , pg13: 15m39 
SELECT TT_ProduceInvGeoHistory('AB25'); --  527038, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB29'); --  620944, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('AB30'); --    4555, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('BC08'); -- 4677411, pg11: , pg13: 
SELECT TT_ProduceInvGeoHistory('BC10'); -- 5151772, pg11: , pg13: 
SELECT TT_ProduceInvGeoHistory('MB01'); --  134790, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('MB02'); --   60370, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('MB04'); --   27221, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('MB05'); --  514157, pg11: , pg13: 18h32
SELECT TT_ProduceInvGeoHistory('MB06'); --  160218, pg11: , pg13: 35m44
SELECT TT_ProduceInvGeoHistory('MB07'); --  219682, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('NB01'); --  927177, pg11: , pg13:  3h32
SELECT TT_ProduceInvGeoHistory('NB02'); -- 1123893, pg11: , pg13:  3h27
SELECT TT_ProduceInvGeoHistory('NL01'); -- 1863664, pg11: , pg13:  4h46
SELECT TT_ProduceInvGeoHistory('NS01'); -- 1127926, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('NS02'); -- 1090671, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('NS03'); --  995886, pg11: , pg13:  2h16
SELECT TT_ProduceInvGeoHistory('NT01'); --  281388, pg11: , pg13:  1h40
SELECT TT_ProduceInvGeoHistory('NT03'); --  320944, pg11: , pg13:  1h40
SELECT TT_ProduceInvGeoHistory('ON02'); -- 3629072, pg11: , pg13:
SELECT TT_ProduceInvGeoHistory('PC01'); --    8094, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('PC02'); --    1053, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('PE01'); --  107220, pg11: , pg13: 11m23
SELECT TT_ProduceInvGeoHistory('QC03'); --  401188, pg11: , pg13:  1h08
SELECT TT_ProduceInvGeoHistory('QC04'); -- 2487519, pg11: , pg13: 12h51
SELECT TT_ProduceInvGeoHistory('QC05'); -- 6768074, pg11: , pg13: 21h32
SELECT TT_ProduceInvGeoHistory('SK01'); -- 1501667, pg11: , pg13: ERROR:  TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on SK01-xxxxxxxxxxxxUTM-xxxxxxxxxx-1269593033-1035665...
SELECT TT_ProduceInvGeoHistory('SK02'); --   27312, pg11: , pg13:  5m46
SELECT TT_ProduceInvGeoHistory('SK03'); --    8964, pg11: , pg13:  2m42
SELECT TT_ProduceInvGeoHistory('SK04'); --  633522, pg11: , pg13:  3h04
SELECT TT_ProduceInvGeoHistory('SK05'); --  421977, pg11: , pg13:  2h05
SELECT TT_ProduceInvGeoHistory('SK06'); --  211482, pg11: , pg13:  1h00
SELECT TT_ProduceInvGeoHistory('YT01'); --  249636, pg11: , pg13:  xmxx
SELECT TT_ProduceInvGeoHistory('YT02'); --  231137, pg11: , pg13:  2h00

