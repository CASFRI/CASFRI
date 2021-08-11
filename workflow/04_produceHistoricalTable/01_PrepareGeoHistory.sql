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
CREATE SCHEMA IF NOT EXISTS casfri50_coverage;
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RowIsValid(text[]);
CREATE OR REPLACE FUNCTION TT_RowIsValid(
  rowValues text[]
)
RETURNS boolean AS $$
  DECLARE
    val text;
  BEGIN
    FOREACH val IN ARRAY rowValues LOOP
      IF val IS NOT NULL AND 
         val != 'NULL_VALUE' AND 
         val != 'EMPTY_STRING' AND 
         val != 'NOT_APPLICABLE' AND 
         val != 'UNKNOWN_VALUE' AND 
         val != 'INVALID_VALUE' AND 
         val != 'NOT_IN_SET' AND 
         val != 'UNUSED_VALUE'  AND 
         val != '-8888'  AND 
         val != '-8887'  AND 
         val != '-8886'  AND 
         val != '-9997'  AND 
         val != '-9999'  AND 
         val != '-9995' THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
------------------------------------------------------------------------------
-- Create a table of inventory precedence rank. Polygons from inventories with 
-- higher ranks have precedence over polygons from inventories having lower 
-- ranks. 
-- This table is used by TT_HasPrecedence() to establish a precedence when two 
-- overlapping polygons have
--
--   1) the same photo_year and
--   2) all their attributes are meaningful (not NULL or '')
--
-- Inventory precedence rank is hence the third criteria when deciding which 
-- polygon has precedence over the other one when they are overlapping. This 
-- criteria is evidently useful only when two polygons are from two different 
-- overlapping inventories. Otherwise more recent polygons and more meaningful 
-- ones have precedence over older ones and less meaningful ones. The fourth 
-- criteria, if all other are equal or equivalent, is the unique identifier 
-- of the two polygons with polygons having higher ids having precedence over 
-- polygons having lower ones.
------------------------------------------------------------------------------
DROP TABLE IF EXISTS casfri50_history.inv_precedence;
CREATE TABLE casfri50_history.inv_precedence AS 
SELECT 'AB03' inv, 3 rank
UNION ALL
SELECT 'AB06', 6
UNION ALL
SELECT 'AB07', 7
UNION ALL
SELECT 'AB08', 8
UNION ALL
SELECT 'AB10', 10
UNION ALL
SELECT 'AB11', 11
UNION ALL
SELECT 'AB16', 16
UNION ALL
SELECT 'AB25', 25
UNION ALL
SELECT 'AB29', 29
UNION ALL
SELECT 'AB30', 30
UNION ALL
SELECT 'BC08', 8
UNION ALL
SELECT 'BC10', 10
UNION ALL
SELECT 'BC11', 11
UNION ALL
SELECT 'BC12', 12
UNION ALL
SELECT 'MB01', 1
UNION ALL
SELECT 'MB02', 2
UNION ALL
SELECT 'MB04', 4
UNION ALL
SELECT 'MB05', 5
UNION ALL
SELECT 'MB06', 6
UNION ALL
SELECT 'MB07', 7
UNION ALL
SELECT 'NB01', 1
UNION ALL
SELECT 'NB02', 2
UNION ALL
SELECT 'NL01', 1
UNION ALL
SELECT 'NS01', 1
UNION ALL
SELECT 'NS02', 2
UNION ALL
SELECT 'NS03', 3
UNION ALL
SELECT 'NT01', 1
UNION ALL
SELECT 'NT03', 3
UNION ALL
SELECT 'ON01', 1
UNION ALL
SELECT 'ON02', 2
UNION ALL
SELECT 'PC01', 1
UNION ALL
SELECT 'PC02', 2
UNION ALL
SELECT 'PE01', 1
UNION ALL
SELECT 'QC01', 1
UNION ALL
SELECT 'QC02', 2
UNION ALL
SELECT 'QC03', 3
UNION ALL
SELECT 'QC04', 4
UNION ALL
SELECT 'QC05', 5
UNION ALL
SELECT 'QC06', 6
UNION ALL
SELECT 'QC07', 7
UNION ALL
SELECT 'SK01', 1
UNION ALL
SELECT 'SK02', 2
UNION ALL
SELECT 'SK03', 3
UNION ALL
SELECT 'SK04', 5
UNION ALL
SELECT 'SK05', 4 -- SK05 has lower precedence than SK04
UNION ALL
SELECT 'SK06', 6
UNION ALL
SELECT 'YT01', 1
UNION ALL
SELECT 'YT02', 2
UNION ALL
SELECT 'YT03', 3;

-- Overwrite development and test TT_HasPrecedence() function to something
-- more simple and efficient taking inventory precedence into account as 
-- numbers and uid as text. Both are never NULLs. numInv and numUid are ignored.
DROP FUNCTION IF EXISTS TT_HasPrecedence(text, text, text, text, boolean, boolean);
CREATE OR REPLACE FUNCTION TT_HasPrecedence(
  inv1 text, 
  uid1 text,
  inv2 text,
  uid2 text,
  numInv boolean DEFAULT FALSE,
  numUid boolean DEFAULT FALSE
)
RETURNS boolean AS $$
  DECLARE
    inv1_num int = 0;
    inv2_num int = 0;
  BEGIN
    IF inv1 != inv2 THEN
      SELECT rank FROM casfri50_history.inv_precedence WHERE inv = inv1 INTO inv1_num;
      SELECT rank FROM casfri50_history.inv_precedence WHERE inv = inv2 INTO inv2_num;
    END IF;
    RETURN inv1_num > inv2_num OR (inv1_num = inv2_num AND uid1 > uid2);
  END
$$ LANGUAGE plpgsql IMMUTABLE;

--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AA'); -- false
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AB'); -- false
--SELECT TT_HasPrecedence('AB06', 'AB', 'AB06', 'AA'); -- true
--SELECT TT_HasPrecedence('AB06', '2', 'AB06', '3'); -- false
--SELECT TT_HasPrecedence('AB06', '3', 'AB06', '2'); -- true
--SELECT TT_HasPrecedence('AB06', '3', 'AB16', '3'); -- false
--SELECT TT_HasPrecedence('AB06', '3', 'AB16', '2'); -- false
--SELECT TT_HasPrecedence('AB16', '3', 'AB06', '3'); -- true
--SELECT TT_HasPrecedence('AB16', '3', 'AB06', '2'); -- true
------------------------------------------------------------------------------
-- Create a table of polygon counts for 
DROP TABLE IF EXISTS casfri50_coverage.inv_counts;
CREATE TABLE casfri50_coverage.inv_counts AS
SELECT left(cas_id, 4) inv, count(*) cnt
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);
-----------------------------------------------
-- Check the completeness of STAND_PHOTO_YEAR
/*
SELECT left(cas_id, 4) inv, stand_photo_year, count(*) nb
FROM casfri50_flat.cas_flat_all_layers_same_row
GROUP BY inv, stand_photo_year
ORDER BY inv, stand_photo_year;
*/

-- Create a sequence to be able to show the progress of the flat grid creation
--DROP SEQUENCE IF EXISTS bug_splitbygrid;
--CREATE SEQUENCE bug_splitbygrid START 1;
--SELECT nextval('bug_splitbygrid');

-- Create a gridded version of the flat version of CASFRI 
-- 139M polygons, 6h15
DROP TABLE IF EXISTS casfri50_history.casflat_gridded;
CREATE TABLE casfri50_history.casflat_gridded AS
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGrid(geometry, 1000)).*
FROM casfri50_flat.cas_flat_all_layers_same_row
--WHERE CASE WHEN nextval('bug_splitbygrid') % 10000 = 0 THEN TT_PrintMessage(currval('bug_splitbygrid')::text) ELSE TRUE END
;

SELECT count(*) FROM casfri50_history.casflat_gridded;

CREATE INDEX ON casfri50_history.casflat_gridded USING btree(inventory_id); -- 30m
CREATE INDEX ON casfri50_history.casflat_gridded USING btree(cas_id); -- 40m
CREATE INDEX ON casfri50_history.casflat_gridded USING gist(geom); --1h40

-- Add an inventory to the gridded table
/*
INSERT INTO casfri50_history.casflat_gridded 
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGrid(geometry, 1000)).geom geom
FROM casfri50_flat.cas_flat_all_layers_same_row
WHERE left(cas_id, 4) = 'QC06' AND CASE WHEN nextval('bug_splitbygrid') % 10000 = 0 THEN TT_PrintMessage(currval('bug_splitbygrid')::text) ELSE TRUE END;
*/
------------------------------------------------------------------------------
-- Create the table that will ingest geohistory polygons
CREATE TABLE casfri50_history.geo_history
(
  cas_id text,
  geom geometry,
  valid_year_begin integer,
  valid_year_end integer
);


