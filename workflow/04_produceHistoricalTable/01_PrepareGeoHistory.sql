------------------------------------------------------------------------------
-- CASFRI - Historical table production preparation script for CASFRI v5
-- For use with PostgreSQL Table Tranlation Framework v2.0.1 for PostgreSQL 13.x
-- https://github.com/CASFRI/PostgreSQL-Table-Translation-Framework
-- https://github.com/CASFRI/CASFRI
--
-- This is free software; you can redistribute and/or modify it under
-- the terms of the GNU General Public Licence. See the COPYING file.
--
-- Copyright (C) 2018-2021 Pierre Racine <pierre.racine@sbf.ulaval.ca>, 
--                         Marc Edwards <medwards219@gmail.com>,
--                         Pierre Vernier <pierre.vernier@gmail.com>
--                         Melina Houle <melina.houle@sbf.ulaval.ca>
------------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50_history;
CREATE SCHEMA IF NOT EXISTS casfri50_coverage;
------------------------------------------------------------------------------
-- Redefine TT_RowIsValid() previously defined when running the geo history tests.
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
-- Redefine TT_HasPrecedence() to something more simple and efficient taking
-- inventory precedence into account as numbers and uid as text. Both are never
-- NULLs. numInv and numUid are ignored.
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
    inv1_rank int = 0;
    inv2_rank int = 0;
  BEGIN
    IF inv1 != inv2 THEN
      SELECT precedence_rank FROM inventory_metadata WHERE inventory_id = inv1 INTO inv1_rank;
      SELECT precedence_rank FROM inventory_metadata WHERE inventory_id = inv2 INTO inv2_rank;
    END IF;
    RETURN inv1_rank > inv2_rank OR (inv1_rank = inv2_rank AND uid1 > uid2);
  END
$$ LANGUAGE plpgsql IMMUTABLE;

/*
SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AA'); -- false
SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AB'); -- false
SELECT TT_HasPrecedence('AB06', 'AB', 'AB06', 'AA'); -- true
SELECT TT_HasPrecedence('AB06', '2', 'AB06', '3'); -- false
SELECT TT_HasPrecedence('AB06', '3', 'AB06', '2'); -- true
SELECT TT_HasPrecedence('AB06', '3', 'AB16', '3'); -- false
SELECT TT_HasPrecedence('AB06', '3', 'AB16', '2'); -- false
SELECT TT_HasPrecedence('AB16', '3', 'AB06', '3'); -- true
SELECT TT_HasPrecedence('AB16', '3', 'AB06', '2'); -- true
*/
------------------------------------------------------------------------------
-- Create a table of polygon counts that will be used by TT_ProduceDerivedCoverages()
DROP TABLE IF EXISTS casfri50_coverage.inv_counts;
CREATE TABLE casfri50_coverage.inv_counts AS
SELECT left(cas_id, 4) inv, count(*) cnt
FROM casfri50.cas_all
GROUP BY left(cas_id, 4);
-----------------------------------------------
/*
-- Check the completeness of STAND_PHOTO_YEAR

SELECT left(cas_id, 4) inv, stand_photo_year, count(*) nb
FROM casfri50_flat.cas_flat_all_layers_same_row
GROUP BY inv, stand_photo_year
ORDER BY inv, stand_photo_year;
*/

------------------------------------------------------------------------------
-- Create the table that will ingest geohistory polygons
DROP TABLE If EXISTS casfri50_history.geo_history;
CREATE TABLE casfri50_history.geo_history
(
  cas_id text,
  geom geometry,
  valid_year_begin integer,
  valid_year_end integer
);

------------------------------------------------------------------------------
-- Create a sequence to be able to show the progress of the flat grid creation
DROP SEQUENCE IF EXISTS bug_splitbygrid;
CREATE SEQUENCE bug_splitbygrid START 1;
SELECT nextval('bug_splitbygrid');

-- Display the number of polygons to be gridded
SELECT count(*) number_of_polygons_to_grid
FROM casfri50_flat.cas_flat_all_layers_same_row;

-- Create a gridded version of the flat version of CASFRI (parallel safe)
-- 139M polygons, 6h15
SET max_parallel_workers_per_gather = 16;
SET max_parallel_workers = 16;
--SET max_worker_processes = 16;
--SHOW max_parallel_workers_per_gather;
--SHOW max_parallel_workers;
--SHOW max_worker_processes;

DROP TABLE IF EXISTS casfri50_history.casflat_gridded;
/*
-- Parallel safe faster version using TT_SplitByGrid(). 
-- This is the version that should be used but it is currently failing without 
-- proper handling. The debug version below is used instead for now.
CREATE TABLE casfri50_history.casflat_gridded AS
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGrid(geometry, 1000)).*
FROM casfri50_flat.cas_flat_all_layers_same_row;
*/

-- Parallel unsafe version using some RAISE NOTICE and nextval() to display cas_id of failing polygons.
-- We still prefer this version as it also display progress messages every 10000 polygons.
-- Better being a bit slow with some feedback then fast without...
WITH cnt_and_start AS (
  SELECT count(*) cnt, clock_timestamp() start_time
  FROM casfri50_flat.cas_flat_all_layers_same_row
)
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGridDebug(cas_id, geometry, 1000)).*
FROM casfri50_flat.cas_flat_all_layers_same_row, cnt_and_start
WHERE CASE WHEN nextval('bug_splitbygrid') % 10000 = 0 
           THEN TT_PrintMessage('Gridding polygons - ' || TT_ProgressMsg(currval('bug_splitbygrid'), cnt::int, start_time)) 
           ELSE TRUE 
      END;

SELECT count(*) number_of_gridded_polygons_generated 
FROM casfri50_history.casflat_gridded;

CREATE INDEX ON casfri50_history.casflat_gridded USING btree(inventory_id); -- 30m
CREATE INDEX ON casfri50_history.casflat_gridded USING btree(cas_id); -- 40m
CREATE INDEX ON casfri50_history.casflat_gridded USING gist(geom); --1h40

/*
-- Add an inventory to the gridded table if necessary

INSERT INTO casfri50_history.casflat_gridded 
WITH cnt_and_start AS (
  SELECT count(*) cnt, clock_timestamp() start_time
  FROM casfri50_flat.cas_flat_all_layers_same_row
  WHERE inventory_id = 'BC08'
)
SELECT cas_id, inventory_id, stand_photo_year, (TT_SplitByGridDebug(cas_id, geometry, 1000)).*
FROM casfri50_flat.cas_flat_all_layers_same_row, cnt_and_start
WHERE inventory_id = 'BC08' AND
      CASE WHEN nextval('bug_splitbygrid') % 10000 = 0 
           THEN TT_PrintMessage('Gridding polygons - ' || TT_ProgressMsg(currval('bug_splitbygrid'), cnt::int, start_time)) 
           ELSE TRUE 
      END;
*/

