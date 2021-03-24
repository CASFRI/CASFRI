------------------------------------------------------------------------------
-- CASFRI Sample workflow file for CASFRI v5 beta
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
-------------------------------------------------------------------------------
-- Debug configuration variable. Set tt.debug to TRUE to display all RAISE NOTICE
SET tt.debug_l1 TO FALSE;
SET tt.debug_l2 TO FALSE;
-------------------------------------------------------------------------------
-- TT_RowIsValid()
-- Returns TRUE if any value in the provided text array is NOT NULL AND NOT = '' 
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RowIsValid(text[]);
CREATE OR REPLACE FUNCTION TT_RowIsValid(
  rowValues text[]
)
RETURNS boolean AS $$
  DECLARE
    val text;
  BEGIN
    FOREACH val IN ARRAY rowValues LOOP
      IF val IS NOT NULL AND val != '' THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END
$$ LANGUAGE plpgsql VOLATILE;

--SELECT * FROM test_geohistory;
--SELECT ARRAY[id::text, att] FROM test_geohistory;
--SELECT TT_RowIsValid(ARRAY[id::text, att]) FROM test_geohistory;
--SELECT TT_RowIsValid(ARRAY[att]) FROM test_geohistory;

-------------------------------------------------------------------------------
-- TT_SafeDifference()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SafeDifference(geometry, geometry, double precision, text, text, boolean);
CREATE OR REPLACE FUNCTION TT_SafeDifference(
  geom1 geometry,
  geom2 geometry,
  tolerance double precision DEFAULT NULL,
  geom1id text DEFAULT NULL,
  geom2id text DEFAULT NULL,
  safe boolean DEFAULT FALSE
)
RETURNS geometry AS $$
  DECLARE
  BEGIN
    --RAISE NOTICE 'geom1=%', ST_AsText(geom1);
    --RAISE NOTICE 'geom2=%', ST_AsText(geom2);
    IF safe THEN
      RAISE NOTICE 'TT_SafeDifference() Safe is TRUE...';
      BEGIN
        -- Attempt the normal operation
        RETURN ST_Difference(geom1, geom2);
      EXCEPTION WHEN OTHERS THEN
        IF tolerance IS NULL THEN
          RAISE NOTICE 'TT_SafeDifference() ERROR 1: Normal ST_Difference() failed. Try by buffering the first polygon (%) by 0...', coalesce(geom1id, 'no ID provided');
        ELSE
          RAISE NOTICE 'TT_SafeDifference() ERROR 1: Normal ST_Difference() failed. Try by snapping the first polygon (%) to grid using tolerance...', coalesce(geom1id, 'no ID provided');
        END IF;
      END;
      IF NOT tolerance IS NULL THEN
        BEGIN
          RETURN ST_Difference(ST_MakeValid(ST_SnapToGrid(geom1, tolerance)), geom2);
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeDifference() ERROR 2: Snapping the first polygon failed. Try by snapping the second polygon (%) to grid using tolerance...', coalesce(geom2id, 'no ID provided');
        END;

        BEGIN
          RETURN ST_Difference(geom1, ST_MakeValid(ST_SnapToGrid(geom2, tolerance)));
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeDifference() ERROR 3: Snapping the second polygon failed. Try by snapping the both polygons (% and %) to grid using tolerance...', coalesce(geom1id, 'no ID provided'), coalesce(geom2id, 'no ID provided');
        END;            

        BEGIN
          RETURN ST_Difference(ST_MakeValid(ST_SnapToGrid(geom1, tolerance)), ST_MakeValid(ST_SnapToGrid(geom2, tolerance)));          
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeDifference() ERROR 4: Snapping both polygons failed. Try by buffering the first polygon (%) by 0...', coalesce(geom1id, 'no ID provided');
        END;            
      END IF;

      BEGIN
        RETURN ST_Difference(ST_Buffer(geom1, 0), geom2);
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TT_SafeDifference() ERROR 5: Buffering the first polygon by 0 failed. Try by buffering the second polygon (%) by 0...', coalesce(geom2id, 'no ID provided');
      END;

      BEGIN
        RETURN ST_Difference(geom1, ST_Buffer(geom2, 0));
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TT_SafeDifference() FATAL ERROR: Operation failed. Returning MULTIPOLYGON EMPTY...';
      END;
      RETURN ST_GeomFromText('MULTIPOLYGON EMPTY');
    ELSE
      RETURN ST_Difference(geom1, geom2);
      --RETURN ST_Difference(ST_MakeValid(ST_SnapToGrid(geom1, tolerance)), ST_MakeValid(ST_SnapToGrid(geom2, tolerance)));
    END IF;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_GeoHistoryOverlaps()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_GeoHistoryOverlaps(geometry, geometry);
CREATE OR REPLACE FUNCTION TT_GeoHistoryOverlaps(
  geom1 geometry, 
  geom2 geometry
)
RETURNS boolean AS $$
  SELECT (ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2))
         AND ST_Area(ST_Intersection(geom1, geom2)) > 0.00001
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- New TYPE for TT_ValidYearUnionStateFct()
------------------------------------------------------------------
--DROP TYPE IF EXISTS geomlowuppval;
CREATE TYPE geomlowuppval AS
(
  geom geometry,
  lowerVal int,
  upperVal int
);
-------------------------------------------------------------------------------
-- TT_UnnestValidYearUnion() aggregate state function
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_UnnestValidYearUnion(geomlowuppval[]);
CREATE OR REPLACE FUNCTION TT_UnnestValidYearUnion(
  gluv geomlowuppval[]
) RETURNS TABLE (geom geometry, lowerVal int, upperVal int) AS $$
  WITH unnested AS (
    SELECT unnest(gluv) unnestedGluv
  )
  SELECT (unnestedGluv).geom, (unnestedGluv).lowerVal, (unnestedGluv).upperVal
  FROM unnested
$$ LANGUAGE sql;
-------------------------------------------------------------------------------
-- TT_ValidYearUnion() aggregate state function
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidYearUnionStateFct(geomlowuppval[], geometry, int, int);
CREATE OR REPLACE FUNCTION TT_ValidYearUnionStateFct(
  storedGYRArr geomlowuppval[],
  geom geometry,
  newYLow int,
  newYUpp int
)
RETURNS geomlowuppval[] AS $$
  DECLARE
    storedGYR geomlowuppval;
    storedYLow int;
    storedYUpp int;
    newGYRArr geomlowuppval[] = ARRAY[]::geomlowuppval[];
    logStr text = '';
  BEGIN
--RAISE NOTICE '000 ----------------';
--RAISE NOTICE '111 new range = [%,%]', newYLow, newYUpp;
    IF newYLow > newYupp THEN
      RAISE EXCEPTION 'TT_ValidYearUnion() ERROR: Lower value is higher than higher value...';
    END IF;
    IF NOT storedGYRArr IS NULL THEN
--RAISE NOTICE '--- BEGIN LOOP';
      FOREACH storedGYR IN ARRAY storedGYRArr LOOP
        storedYLow = storedGYR.lowerVal;
        storedYUpp = storedGYR.upperVal;
--RAISE NOTICE '222 stored range = [%,%]', storedYLow, storedYUpp;
        
        ------------------------------------------------
        -- new range has been all integrated (is now NULL) or is after stored range
        IF newYLow IS NULL OR newYUpp IS NULL OR (newYLow > storedYUpp) THEN
--RAISE NOTICE '333 just add stored range';
          -- add stored range
          newGYRArr = array_append(newGYRArr, storedGYR);
  
        ------------------------------------------------
        -- new range lower bound is lower than stored lower bound (n1 s1)
        ELSIF newYLow < storedYLow THEN
--RAISE NOTICE '444 newYLow < storedYLow';
      
          -- new range upper bound is lower than stored lower bound  (n1 n2 s1 s2) -> (n1 n2), (s1 s2)
          IF newYUpp < storedYLow THEN
--RAISE NOTICE '444.1 newYUpp < storedYLow';
            -- add new range
            newGYRArr = array_append(newGYRArr, (geom, newYLow, newYUpp)::geomlowuppval);
            -- add stored range
            newGYRArr = array_append(newGYRArr, storedGYR);
            
            -- new range was totally processed
            newYLow = NULL;
            newYUpp = NULL;
  
          -- new range upper bound is lower than stored upper bound (n1 s1 n2 s2) -> (n1 s1 - 1, s1 n2) (n2 + 1, s2)
          ELSIF newYUpp < storedYUpp THEN 
--RAISE NOTICE '444.2 newYUpp < storedYUpp';
            -- add new range (newYLow, storedYLow - 1)
            newGYRArr = array_append(newGYRArr, (geom, newYLow, storedYLow - 1)::geomlowuppval);
            -- add new range (storedYLow, newYUpp)
            newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), storedYLow, newYUpp)::geomlowuppval);
            -- add stored range (newYUpp + 1, storedYUpp)
            newGYRArr = array_append(newGYRArr, ((storedGYR).geom, newYUpp + 1, storedYUpp)::geomlowuppval);
            -- new range was totally processed
            newYLow = NULL;
            newYUpp = NULL;
  
          -- new range upper bound is equal to or greater than stored upper bound (n1 s1 ns2) -> (n1 s1 - 1) (s1 s2)
          ELSE --IF newYUpp = storedYUpp OR newYUpp > storedYUpp THEN
--RAISE NOTICE '444.3 newYUpp >= storedYUpp';
            -- add new range (newYLow, storedYLow - 1)
            newGYRArr = array_append(newGYRArr, (geom, newYLow, storedYLow - 1)::geomlowuppval);
            -- add new range (storedYLow, storedYUpp)
            newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), storedYLow, storedYUpp)::geomlowuppval);
            
            IF newYUpp > storedYUpp THEN
              newYLow = storedYUpp + 1;
            ELSE
              -- new range was totally processed
              newYLow = NULL;
              newYUpp = NULL;
            END IF;
          END IF;
        
        ------------------------------------------------
        -- new range lower bound is equal to stored lower bound (ns1)
        ELSIF newYLow = storedYLow THEN
--RAISE NOTICE '555 newYLow = storedYLow';
          -- new range upper bound is lower than stored upper bound (ns1 n2 s2) -> (s1 n2) (n2 + 1 s2)
          IF newYUpp < storedYUpp THEN
--RAISE NOTICE '555.1 newYUpp < storedYUpp';
            -- add new range (newYLow, newYUpp)
            newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), newYLow, newYUpp)::geomlowuppval);
  
            -- add stored range (newYUpp + 1, storedYUpp)
            newGYRArr = array_append(newGYRArr, ((storedGYR).geom, newYUpp + 1, storedYUpp)::geomlowuppval);
  
            -- new range was totally processed
            newYLow = NULL;
            newYUpp = NULL;
  
          -- new range upper bound is equal to or higher than stored upper bound (ns1 ns2) -> (s1 s2)
          ELSE --IF newYUpp >= storedYUpp THEN
--RAISE NOTICE '555.2 newYUpp >= storedYUpp';
            -- add new range (storedYLow, storedYUpp)
            newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), storedYLow, storedYUpp)::geomlowuppval);
  
            IF newYUpp > storedYUpp THEN
              newYLow = storedYUpp + 1;
            ELSE
              -- new range was totally processed
              newYLow = NULL;
              newYUpp = NULL;
            END IF;
          END IF;
          
        ------------------------------------------------
        -- new range lower bound is lower than stored upper bound (s1 n1 s2)
        ELSIF newYLow < storedYUpp THEN
--RAISE NOTICE '666 newYLow < storedYUpp';

          -- new range upper bound is lower than stored upper bound (s1 n1 n2 s2) -> (s1 n1 - 1) (n1 n2) (n2 + 1 s2)
          IF newYUpp < storedYUpp THEN
--RAISE NOTICE '666.1 newYUpp < storedYUpp';
            -- add stored range (storedYLow, newYLow - 1)
            newGYRArr = array_append(newGYRArr, ((storedGYR).geom, storedYLow, newYLow - 1)::geomlowuppval);
            -- add new range (newYLow, newYUpp)
            newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), newYLow, newYUpp)::geomlowuppval);
            -- add stored range (newYUpp + 1, storedYUpp)
            newGYRArr = array_append(newGYRArr, ((storedGYR).geom, newYUpp + 1, storedYUpp)::geomlowuppval);
            -- new range was totally processed
            newYLow = NULL;
            newYUpp = NULL;
  
          -- new range upper bound is equal to or greater than stored upper bound (s1 n1 ns2) -> (s1 n1 - 1) (n1 s2)
          ELSE --IF newYUpp >= storedYUpp THEN
--RAISE NOTICE '666.2 newYUpp >= storedYUpp';
            -- add stored range (storedYLow, newYLow - 1)
            newGYRArr = array_append(newGYRArr, ((storedGYR).geom, storedYLow, newYLow - 1)::geomlowuppval);
            -- add new range (newYLow, storedYUpp)
            newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), newYLow, storedYUpp)::geomlowuppval);
  
            IF newYUpp > storedYUpp THEN
              newYLow = storedYUpp + 1;
            ELSE
              -- new range was totally processed
              newYLow = NULL;
              newYUpp = NULL;
            END IF;
          END IF;
          
        ------------------------------------------------
        -- new range lower bound is equal to stored upper bound (s1 n1s2)
        ELSIF newYLow = storedYUpp THEN
--RAISE NOTICE '777 newYLow = storedYUpp';
          -- new range upper bound is equal to or greater than stored upper bound (s1 n1ns2) -> (s1 n1 - 1) (n1 s2)
          -- add stored range (storedYLow, newYLow - 1)
          newGYRArr = array_append(newGYRArr, ((storedGYR).geom, storedYLow, newYLow - 1)::geomlowuppval);
          -- add new range (newYLow, storedYUpp)
          newGYRArr = array_append(newGYRArr, (ST_Multi(ST_Union((storedGYR).geom, geom)), newYLow, storedYUpp)::geomlowuppval);
          IF newYUpp > storedYUpp THEN
            newYLow = storedYUpp + 1;
          ELSE -- new range was totally processed
            newYLow = NULL;
            newYUpp = NULL;
          END IF;
        END IF;
      END LOOP;
--RAISE NOTICE '--- END LOOP';
    END IF;
    -- if new range lower bound and new range upper bound are not NULL
    IF NOT newYLow IS NULL AND NOT newYUpp IS NULL THEN
--RAISE NOTICE '888 add new range';
      -- add new range
      newGYRArr = array_append(newGYRArr, (geom, newYLow, newYUpp)::geomlowuppval);
    END IF;
--FOREACH storedGYR IN ARRAY newGYRArr LOOP
--  logStr = logStr || '[' || (storedGYR).lowerval || ',' || (storedGYR).upperval || ']';
--END LOOP; 
--RAISE NOTICE '999 new array=%', logStr;

    RETURN newGYRArr;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
--------------------------------------
--DROP AGGREGATE IF EXISTS TT_ValidYearUnion(geometry, int, int);
CREATE AGGREGATE TT_ValidYearUnion(
  geom geometry,
  yearLower int,
  yearUpper int
)(
    SFUNC = TT_ValidYearUnionStateFct,
    STYPE = geomlowuppval[]
);

------------------------------------------------------------------
-- TT_PolygonGeoHistory()
------------------------------------------------------------------
-- Logic table
-- Overlapping polygons are treated starting with 1) the same year 
-- ones, then 2) the older ones and finally 3) the newer ones as 
-- they are ordered in the ovlpPolyQuery.
--
-- 1) Same year polygons with higher precedence are first removed 
-- to form prePoly.
--
-- 2) Then postPoly is initialized from prePoly and all past polygons 
-- are removed from prePoly (when they are valid). prepoly is no 
-- more modified and is returned as is.
--
-- 3) Then one postPoly is produced by removing each newer polygon.
-- 
-- A = current polygon
-- B = overlapping polygon
-- AY = A year
-- BY = B year
-- RefYB = Reference year begin
-- RefYE = Reference year end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |   A year VS   |       A       |    A    |    B    | Resulting poly with    | Case  | Code                                       | Explanation 
-- |    B year     | hasPrecedence | isValid | isValid | begin and end year     |       |                                            |
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       T       |    T    |    T    | A RefYB -> RefYE       |   A   | Do nothing                                 | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |                                            | so just ignore ovlpPoly
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       T       |    T    |    F    | A RefYB -> RefYE       |   A   | Do nothing                                 | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |                                            | so just ignore ovlpPoly
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       T       |    F    |    T    | (A - B) RefYB -> RefYE |   B   | IF postPoly IS NOT NULL                    | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | but is invalid so remove ovlpPoly from
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | it and from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       T       |    F    |    F    | A RefYB -> RefYE       |   A   | Do nothing                                 | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |                                            | so just ignore ovlpPoly
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       F       |    T    |    T    | (A - B) RefYB-> RefYE  |   B   | IF postPoly IS NOT NULL                    | ovlpPoly has precedence over prePoly 
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | so remove it from prePoly and 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       F       |    T    |    F    | A RefYB -> RefYE       |   A   | Do nothing                                 | ovlpPoly has precedence over prePoly 
-- |               |               |         |         |                        |       |                                            | but is invalid, so just ignore ovlpPoly
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       F       |    F    |    T    | (A - B) RefYB -> RefYE |   B   | IF postPoly IS NOT NULL                    | ovlpPoly has precedence over prePoly 
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | so remove it from prePoly and 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |    0 (same)   |       F       |    F    |    F    | (A - B) RefYB -> RefYE |   B   | IF postPoly IS NOT NULL                    | ovlpPoly has precedence over prePoly 
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | so remove it from prePoly and 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 1 (post, A>B) |       T       |    T    |    T    | (A - B) RefYB -> AY - 1|   C   | postPoly = coalesce(postPoly, prePoly)     | Two polygons parts are produced:
-- |               |               |         |         | A AY -> RefYE          |       | postPolyYearBegin = currentPolyYear        | 1) postPoly, which is the same as prePoly 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               |    but starting at currentPolyYear
-- |               |               |         |         |                        |       | prePolyYearEnd = currentPolyYearBegin  - 1 | 2) prePoly from which we remove ovlpPoly 
-- |               |               |         |         |                        |       |                                            |    and ends at currentYear - 1
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 1 (post, A>B) |       T       |    T    |    F    | A RefYB -> RefYE       |   A   | Do nothing                                 | ovlpPoly is invalid so ignore it
-- |               |               |         |         |                        |       |                                            | 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 1 (post, A>B) |       T       |    F    |    T    | (A - B) RefYB -> RefYE |   B   | IF postPoly IS NOT NULL                    | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | but is invalid so remove ovlpPoly from 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | it and from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 1 (post, A>B) |       T       |    F    |    F    | A RefYB -> RefYE       |   A   | Do nothing                                 | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |                                            | so just ignore ovlpPoly
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 2 (pre, A<B)  |       F       |    T    |    T    | A RefYB -> BY - 1      |   D   | IF oldPostPolyYear IS NOT NULL AND         | Two polygons parts are produced:
-- |               |               |         |         | (A - B) BY -> RefYE    |       |   oldPostPolyYear != ovlpPolyYear          |
-- |               |               |         |         |                        |       |   postPolyYearEnd = ovlpPolyYear  - 1      | 1) postPoly before ovlpPoly, which is the 
-- |               |               |         |         |                        |       |   RETURN postPoly                          |    same as postPoly but ending at ovlpPolyYear
-- |               |               |         |         |                        |       |                                            |
-- |               |               |         |         |                        |       | postPoly = coalesce(postPoly, prePoly) -   | 2) the new postPoly from which we remove 
-- |               |               |         |         |                        |       |            ovlpPoly                        |    ovlpPoly and begin at ovlpPoly and ends at 
-- |               |               |         |         |                        |       | postPolyYearBegin = ovlpPolyYear           |    refYearEnd
-- |               |               |         |         |                        |       | prePolyYearEnd = ovlpPolyYear - 1          |
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 2 (pre, A<B)  |       F       |    T    |    F    | A RefYB -> RefYE       |   A   | Do nothing                                 | prePoly has prededence over ovlpPoly 
-- |               |               |         |         |                        |       |                                            | so just ignore ovlpPoly
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 2 (pre, A<B)  |       F       |    F    |    T    | (A - B) RefYB -> RefYE |   B   | IF postPoly IS NOT NULL                    | ovlpPoly has precedence over prePoly
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | so remove it from prePoly and 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | 2 (pre, A<B)  |       F       |    F    |    F    | (A - B) RefY -> RefYE  |   B   | IF postPoly IS NOT NULL                    | ovlpPoly has precedence over prePoly
-- |               |               |         |         |                        |       |   postPoly = postPoly - ovlpPoly           | so remove it from prePoly and 
-- |               |               |         |         |                        |       | prePoly = prePoly - ovlpPoly               | from postPoly if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_PolygonGeoHistory(text, text, int, boolean, geometry, name, name, name, name, name, name, name[]);
CREATE OR REPLACE FUNCTION TT_PolygonGeoHistory(
  poly_inv text,
  poly_row_id text,
  poly_photo_year int,
  poly_is_valid boolean,
  poly_geom geometry,
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  precedenceColName name,
  validityColNames name[] DEFAULT NULL
)
RETURNS TABLE (id text,
               poly_id int,
               isvalid boolean,
               wkb_geometry geometry, 
               poly_type text,
               ref_year int,
               valid_year_begin int, 
               valid_year_end int, 
               valid_time text) AS $$
  DECLARE
    debug_l1 boolean = TT_Debug(1);
    debug_l2 boolean = TT_Debug(2);
    
    ovlpPolyQuery text;

    currentRow RECORD;
    ovlpRow RECORD;

    refYearBegin int = 1930;
    refYearEnd int = 2030;
        
    preValidYearPoly geometry;
    preValidYearPolyYearEnd int;
    postValidYearPoly geometry;
    postValidYearPolyYearBegin int;

    oldOvlpPolyYear int;
    
    hasPrecedence boolean;
    
    time timestamptz;
    diffAttempts int;
    safeDiff boolean;
  BEGIN
    IF poly_photo_year IS NULL OR poly_photo_year < 0 THEN
      poly_photo_year = refYearBegin;
    END IF;
    -- Prepare the nested LOOP query looping through polygons overlapping the current main loop polygons
    ovlpPolyQuery = 'SELECT ' || quote_ident(idColName) || '::text gh_row_id, ' ||
                                 quote_ident(geoColName) || ' gh_geom, ' ||
                                 'CASE WHEN ' || quote_ident(photoYearColName) || ' < 0 OR ' || quote_ident(photoYearColName) || ' IS NULL THEN ' || refYearBegin || ' ELSE ' || quote_ident(photoYearColName) || ' END gh_photo_year, ' ||
                                 quote_ident(precedenceColName) || '::text gh_inv, ' ||
                                 CASE WHEN validityColNames IS NULL THEN 'TRUE' ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, '::text,') || '::text])' END || ' gh_is_valid ' ||
                    'FROM ' || TT_FullTableName(schemaName, tableName) || 
                   ' WHERE ' || quote_ident(idColName) || '::text != $1 AND ' ||
                          '(' ||
                           'ST_Overlaps(' || quote_ident(geoColName) || ', $2) OR ' ||
                           'ST_Contains($2, ' || quote_ident(geoColName) || ') OR ' ||
                           'ST_Contains(' || quote_ident(geoColName) || ', $2)) AND ' ||
                           'ST_Area(ST_Intersection(' || quote_ident(geoColName) || ', $2)) > 0.01 ' ||
                           'ORDER BY gh_photo_year;';
    IF debug_l2 THEN RAISE NOTICE '222 ovlpPolyQuery = %', ovlpPolyQuery;END IF;
    
    time = clock_timestamp();
    IF debug_l2 THEN RAISE NOTICE 'Setting diffAttempts to 0...';END IF;
    diffAttempts = 0;

    IF debug_l2 THEN RAISE NOTICE 'Setting safeDiff to FALSE...';END IF;
    safeDiff = FALSE;
    -- Here we loop until a satistactory set of historical polygon has been computed first 
    -- using the unsafe version of ST_Difference() and then with a safe version of it
    WHILE diffAttempts < 2 LOOP
      BEGIN
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE '---------------------';END IF;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE '000 processing polygon ID %. poly_photo_year = %', poly_row_id, poly_photo_year;END IF;

        -- Initialize preValidYearPoly to the current polygon
        preValidYearPoly = poly_geom;
        preValidYearPolyYearEnd = refYearEnd;

        -- postValidYearPoly will be initialized only if the current polygon 
        -- is cut by pre_valid_year polygons or same_valid_year polygons
        postValidYearPoly = NULL;
        postValidYearPolyYearBegin = poly_photo_year;

        oldOvlpPolyYear = NULL;

        -- Assign some RETURN values now that are useful for debug only
        ref_year = postValidYearPolyYearBegin;
        id = poly_row_id;
        poly_id = 0;
        isvalid = poly_is_valid;

        -- LOOP over all overlapping polygons sorted by photoYear ASC
        FOR ovlpRow IN EXECUTE ovlpPolyQuery 
        USING poly_row_id, poly_geom LOOP
          IF debug_l2 THEN RAISE NOTICE '---------';END IF;
          IF debug_l1 THEN RAISE NOTICE 'Processing overlapping polygon %', ovlpRow.gh_row_id;END IF;
          IF debug_l2 THEN RAISE NOTICE '333 current id=%, py=%, inv=%, isvalid=%', poly_row_id, poly_photo_year, poly_inv, poly_is_valid;END IF;
          IF debug_l2 THEN RAISE NOTICE '444 ovlp    id=%, py=%, inv=%, isvalid=%, ovlp_area=%', ovlpRow.gh_row_id, ovlpRow.gh_photo_year, ovlpRow.gh_inv, ovlpRow.gh_is_valid, ST_Area(ST_Intersection(poly_geom, ovlpRow.gh_geom));END IF;
          -- CASE B - (A - B) RefYB -> RefYE (see logic table above)
          hasPrecedence = TT_HasPrecedence(poly_inv, poly_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id, true, true);
          IF debug_l2 THEN RAISE NOTICE '555 hasPrecedence = %', hasPrecedence;END IF;
         
          IF (ovlpRow.gh_photo_year = poly_photo_year AND 
             ((hasPrecedence AND NOT poly_is_valid AND ovlpRow.gh_is_valid) OR
             (NOT hasPrecedence AND (NOT poly_is_valid OR (poly_is_valid AND ovlpRow.gh_is_valid))))) OR
             (ovlpRow.gh_photo_year < poly_photo_year AND NOT poly_is_valid AND ovlpRow.gh_is_valid) OR
             (ovlpRow.gh_photo_year > poly_photo_year AND NOT poly_is_valid) THEN
            IF debug_l2 THEN RAISE NOTICE '666 CASE SAME YEAR: Remove ovlpPoly from prePoly. year = %', ovlpRow.gh_photo_year;END IF;

            preValidYearPoly = TT_SafeDifference(preValidYearPoly, ovlpRow.gh_geom, 0.01, 'preValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
            IF postValidYearPoly IS NOT NULL THEN
              postValidYearPoly = TT_SafeDifference(postValidYearPoly, ovlpRow.gh_geom, 0.01, 'postValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
            END IF;

          -- CASE C - (A - B) RefYB -> AY - 1 and A AY -> RefYE (see logic table above)
          ELSIF ovlpRow.gh_photo_year < poly_photo_year AND poly_is_valid AND ovlpRow.gh_is_valid THEN
            IF debug_l2 THEN RAISE NOTICE '777 CASE 2: Initialize postPoly and remove ovlpPoly from prePoly. year = %', ovlpRow.gh_photo_year;END IF;
            postValidYearPoly = coalesce(postValidYearPoly, preValidYearPoly);
            postValidYearPolyYearBegin = poly_photo_year;

            preValidYearPoly = TT_SafeDifference(preValidYearPoly, ovlpRow.gh_geom, 0.01, 'preValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);

            preValidYearPolyYearEnd = poly_photo_year - 1;

          -- CASE D - A RefYB -> BY - 1 and (A - B) BY -> RefYE (see logic table above)
          ELSIF ovlpRow.gh_photo_year > poly_photo_year AND poly_is_valid AND ovlpRow.gh_is_valid THEN
            IF debug_l2 THEN RAISE NOTICE '888 CASE 3: Return postPoly and set the next one by removing ovlpPoly. year = %', ovlpRow.gh_photo_year;END IF;
            -- Make sure the last computed polygon still intersect with ovlpPoly

            IF ST_Intersects(ovlpRow.gh_geom, coalesce(postValidYearPoly, preValidYearPoly)) THEN
              IF oldOvlpPolyYear IS NOT NULL AND oldOvlpPolyYear != ovlpRow.gh_photo_year AND postValidYearPoly IS NOT NULL THEN
                poly_id = poly_id + 1;
                wkb_geometry = ST_Multi(ST_CollectionExtract(postValidYearPoly, 3));
                --wkb_geometry = postValidYearPoly;

                poly_type = '2_post_1';
                valid_year_begin = postValidYearPolyYearBegin;
                valid_year_end = ovlpRow.gh_photo_year - 1;
                valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
                IF debug_l2 THEN RAISE NOTICE '---------';END IF;
                IF debug_l2 THEN RAISE NOTICE 'AAA1 postPoly valid_time=%', valid_time;END IF;
                IF debug_l2 THEN RAISE NOTICE '---------';END IF;
                RETURN NEXT;
              END IF;

              postValidYearPoly = TT_SafeDifference(coalesce(postValidYearPoly, preValidYearPoly), ovlpRow.gh_geom, 0.01, 'coalesce(postValidYearPoly, preValidYearPoly) from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
              postValidYearPolyYearBegin = ovlpRow.gh_photo_year;
              preValidYearPolyYearEnd = least(preValidYearPolyYearEnd, ovlpRow.gh_photo_year - 1);
            END IF;
          END IF;
          oldOvlpPolyYear = ovlpRow.gh_photo_year;
        END LOOP;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'Setting diffAttempts to 2...';END IF;
        diffAttempts = 2;
      EXCEPTION WHEN OTHERS THEN
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'Setting safeDiff to TRUE...';END IF;
        safeDiff = TRUE;
        IF diffAttempts = 1 THEN RAISE EXCEPTION 'TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on %...', poly_row_id;END IF;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'Setting diffAttempts to 1...';END IF;
        diffAttempts = 1;
      END;
    END LOOP; -- WHILE
    
    IF debug_l2 THEN RAISE NOTICE '---------';END IF;
    ---------------------------------------------------------------------------
    -- Return the last new polygon (newestPoly, oldCurrentYear, ovlpPoly.photoYear)
    IF NOT ST_IsEmpty(postValidYearPoly) THEN
      poly_id = poly_id + 1;
      wkb_geometry = ST_Multi(ST_CollectionExtract(postValidYearPoly, 3));
      --wkb_geometry = postValidYearPoly;

      poly_type = '2_post_2';
      valid_year_begin = postValidYearPolyYearBegin;
      valid_year_end = refYearEnd;
      valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
      IF debug_l2 THEN RAISE NOTICE 'AAA2 postPoly valid_time=%', valid_time;END IF;
      RETURN NEXT;
    END IF;

    ---------------------------------------------------------------------------
    -- Return the current polygon (olderPoly, refYearBegin, currentPoly.photoYear - 1))
    IF NOT ST_IsEmpty(preValidYearPoly) THEN
      poly_id = poly_id + 1;
      wkb_geometry = ST_Multi(ST_CollectionExtract(preValidYearPoly, 3));
      --wkb_geometry = preValidYearPoly;
  
      poly_type = '1_pre';
      valid_year_begin = refYearBegin;
      valid_year_end = preValidYearPolyYearEnd;
      valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
      IF debug_l2 THEN RAISE NOTICE 'CCC prePoly valid_time=%', valid_time;END IF;
      RETURN NEXT;
    END IF;
    IF debug_l1 OR debug_l2 THEN RAISE NOTICE  'TOOK % SECONDS', EXTRACT(EPOCH FROM clock_timestamp() - time);END IF;
  END
$$ LANGUAGE plpgsql VOLATILE;

DROP FUNCTION IF EXISTS TT_PolygonGeoHistory(text, text, geometry, name, name, name, name, name, name, name[]);
CREATE OR REPLACE FUNCTION TT_PolygonGeoHistory(
  poly_inv text,
  poly_row_id text,
  poly_geom geometry,
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  precedenceColName name,
  validityColNames name[] DEFAULT NULL
)
RETURNS TABLE (id text,
               poly_id int,
               isvalid boolean,
               wkb_geometry geometry, 
               poly_type text,
               ref_year int,
               valid_year_begin int, 
               valid_year_end int, 
               valid_time text) AS $$
 SELECT TT_PolygonGeoHistory(poly_inv, poly_row_id, 1930, TRUE, poly_geom, schemaName, tableName, idColName, geoColName, photoYearColName, precedenceColName, validityColNames);
$$ LANGUAGE sql VOLATILE;

---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_TableGeoHistory(name, name, name, name, name, name, name[]);
CREATE OR REPLACE FUNCTION TT_TableGeoHistory(
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  precedenceColName name,
  validityColNames name[] DEFAULT NULL
)
RETURNS TABLE (id text,
               poly_id int,
               isvalid boolean,
               wkb_geometry geometry, 
               poly_type text,
               ref_year int,
               valid_year_begin int, 
               valid_year_end int, 
               valid_time text) AS $$
  DECLARE
    debug_l1 boolean = TT_Debug(1);
    debug_l2 boolean = TT_Debug(2);

    currentPolyQuery text;
    colNames text[];
    currentRow RECORD;
   
    gtime timestamptz = clock_timestamp();
  BEGIN
      -- Check that idColName, geoColName and photoYearColName exists
    colNames = TT_TableColumnNames(schemaName, tableName);
    IF NOT idColName = ANY (colNames) THEN
      RAISE EXCEPTION 'TT_TableGeoHistory(): Column ''%'' not found in table %.%...', idColName, schemaName, tableName;
    END IF;
    IF NOT geoColName = ANY (colNames) THEN
      RAISE EXCEPTION 'TT_TableGeoHistory(): Column ''%'' not found in table %.%...', geoColName, schemaName, tableName;
    END IF;
    IF NOT photoYearColName = ANY (colNames) THEN
      RAISE EXCEPTION 'TT_TableGeoHistory(): Column ''%'' not found in table %.%...', photoYearColName, schemaName, tableName;
    END IF;
    -- Prepare the main LOOP query looping through all polygons of the processed table
    currentPolyQuery = 'SELECT ' || quote_ident(precedenceColName) || '::text gh_inv, ' ||
                                    quote_ident(idColName)         || '::text gh_row_id, ' ||
                                    quote_ident(photoYearColName)  || ' gh_photo_year, ' ||
                                    CASE WHEN validityColNames IS NULL THEN 'TRUE' 
                                                                       ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, '::text,') || '::text])' 
                                    END || ' gh_is_valid, ' ||
                                    quote_ident(geoColName) || ' gh_geom ' ||
               'FROM ' || TT_FullTableName(schemaName, tableName) ||
           --    ' WHERE ' || quote_ident(idColName) || '::text = ''NB01-xxxxxxxxxFOREST-xxxxxxxxxx-0000083722-0242567'' ' ||
              ' ORDER BY gh_photo_year DESC;';
    IF debug_l2 THEN RAISE NOTICE '111 currentPolyQuery = %', currentPolyQuery;END IF;

    -- LOOP over each polygon of the table
    FOR currentRow IN EXECUTE currentPolyQuery LOOP
        RETURN QUERY SELECT * FROM TT_PolygonGeoHistory(currentRow.gh_inv, 
                                                        currentRow.gh_row_id, 
                                                        currentRow.gh_photo_year, 
                                                        currentRow.gh_is_valid, 
                                                        currentRow.gh_geom, 
                                                        schemaName, 
                                                        tableName, 
                                                        idColName, 
                                                        geoColName, 
                                                        photoYearColName, 
                                                        precedenceColName, 
                                                        validityColNames);
    END LOOP;
    IF debug_l1 OR debug_l2 THEN RAISE NOTICE  'TOTAL TOOK % SECONDS', EXTRACT(EPOCH FROM clock_timestamp() - gtime);END IF;
    RETURN;
  END
$$ LANGUAGE plpgsql VOLATILE;

--SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory3', 'id', 'geom', 'valid_year', ARRAY['att'], 'att', 0.1)
--ORDER BY id, valid_year_begin;

--SELECT id gh_row_id, geom gh_geom, valid_year gh_photo_year, TT_RowIsValid(ARRAY[att]) gh_is_valid, * 
--FROM public.test_geohistory ORDER BY gh_photo_year DESC;


------------------------------------------------------------------
-- TT_GeoOblique()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_GeoOblique(geometry, int, double precision, double precision);
CREATE OR REPLACE FUNCTION TT_GeoOblique(
  geom geometry,
  year int,
  z_factor double precision DEFAULT 0.4,
  y_factor double precision DEFAULT 0.4
)
RETURNS geometry AS $$
  SELECT ST_Affine(geom, 1, 1, 0, y_factor, 0, (year - 2000) * z_factor);
$$ LANGUAGE sql IMMUTABLE;

------------------------------------------------------------------
-- TT_GeoHistoryOblique()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_GeoHistoryOblique(name, name, name, name, name, text, text[], double precision, double precision);
CREATE OR REPLACE FUNCTION TT_GeoHistoryOblique(
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  precedenceColName text,
  validityColNames text[] DEFAULT NULL,
  z_factor double precision DEFAULT 0.4,
  y_factor double precision DEFAULT 0.4
)
RETURNS TABLE (id text, 
               isvalid boolean,
               wkb_geometry geometry, 
               poly_type text,
               ref_year int,
               valid_year_begin int, 
               valid_year_end int, 
               valid_time text) AS $$
    SELECT id, 
           isvalid,
           TT_GeoOblique(wkb_geometry, valid_year_begin, z_factor, y_factor) wkb_geometry,
           poly_type,
           ref_year,
           valid_year_begin, 
           valid_year_end,
           valid_time
    FROM TT_TableGeoHistory(schemaName, tableName, idColName, geoColName, photoYearColName, precedenceColName, validityColNames);
$$ LANGUAGE sql VOLATILE;