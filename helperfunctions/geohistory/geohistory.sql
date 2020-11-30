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
-- TT_RowIsValid()
-- Returns TRUE if any value in the provided text array is NOT NULL AND NOT = '' 
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_RowIsValid(text[]);
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

------------------------------------------------------------------
-- TT_HasPrecedence()
--
-- Determine if the first polygon has precedence over the second one based on:
--
  -- 1) their inventory rank: an established priority rank among inventories 
  --    determines which polygon has priority.
  -- 2) their unique ID: when inventory ranks are equivalent for both polygons, 
  --    the polygon with the highest ID has priority.
  --
  -- numInv and numUid can be used to specify if inv1 and inv2 and uid1 and uid2 
  -- must be treated as numerical values. They both default to FALSE.
------------------------------------------------------------------
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
    refInv text = 'AA00';
    refUID text = 'A';
  BEGIN
    -- Assign default hardcoded values
    IF inv1 IS NULL THEN
      RAISE NOTICE 'TT_HasPrecedence() WARNING : inv1 for polygon ''%'' is NULL. Assigning %...', uid1, refInv;
      inv1 = refInv;
    END IF;
    IF inv2 IS NULL THEN
      RAISE NOTICE 'TT_HasPrecedence() WARNING : inv2 for polygon ''%'' is NULL. Assigning %...', uid2, refInv;
      inv2 = refInv;
    END IF;
    IF inv1 = inv2 THEN
      IF uid1 IS NULL THEN
        RAISE NOTICE 'TT_HasPrecedence() WARNING : uid1 is NULL. Assigning %...', refUID;
        uid1 = refUID;
      END IF;
      IF uid2 IS NULL THEN
        RAISE NOTICE 'TT_HasPrecedence() WARNING : uid2 is NULL. Assigning %...', refUID;
        uid2 = refUID;
      END IF;
      IF uid1 = uid2 THEN
        RAISE NOTICE 'TT_HasPrecedence() WARNING : uid1 and uid2 are equal (%). Can''t give precedence to a polygon. Returning FALSE...', uid1;
        RETURN FALSE;
      END IF;
    END IF;
IF inv1 != inv2 THEN
  RAISE NOTICE 'inv1 (%) % has precedence on inv2(%)', inv1, CASE WHEN (numInv AND inv1::decimal > inv2::decimal) OR (NOT numInv AND inv1 > inv2) 
                                                                  THEN '' ELSE 'does not' END, inv2;
ELSE
  RAISE NOTICE 'uid1(%) % has precedence on uid2(%)', uid1, CASE WHEN (numUid AND uid1::decimal > uid2::decimal) OR (NOT numUid AND uid1 > uid2) 
                                                     THEN '' ELSE 'does not' END, uid2;
END IF;
      RETURN ((numInv AND inv1::decimal > inv2::decimal) OR (NOT numInv AND inv1 > inv2)) OR 
           (inv1 = inv2 AND ((numUid AND uid1::decimal > uid2::decimal) OR (NOT numUid AND uid1 > uid2)));
  END
$$ LANGUAGE plpgsql VOLATILE;

--SELECT TT_HasPrecedence(NULL, NULL, NULL, NULL); -- false
--SELECT TT_HasPrecedence('AB06', NULL, NULL, NULL); -- true
--SELECT TT_HasPrecedence('AB06', NULL, 'AB06', NULL); -- false
--SELECT TT_HasPrecedence('AB06', NULL, 'AB16', NULL); -- false
--SELECT TT_HasPrecedence('AB16', NULL, 'AB06', NULL); -- true
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', NULL); -- true
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AA'); -- false
--SELECT TT_HasPrecedence('AB06', 'AA', 'AB06', 'AB'); -- false
--SELECT TT_HasPrecedence('AB06', 'AB', 'AB06', 'AA'); -- true
--SELECT TT_HasPrecedence('AB06', '2', 'AB06', '3'); -- false
--SELECT TT_HasPrecedence('AB06', '3', 'AB06', '2'); -- true
--SELECT TT_HasPrecedence('2', '2', '13', '13');  -- true
--SELECT TT_HasPrecedence('2', '2', '13', '13', true, true); -- false
--SELECT TT_HasPrecedence('13', '2', '2', '13', true, true); -- true

--SELECT TT_HasPrecedence('1', '2', '1', '13', true, false); -- true
--SELECT TT_HasPrecedence('1', '13', '1', '2', true, false); -- false
--SELECT TT_HasPrecedence('1', '2', '1', '13', true, true); -- false
--SELECT TT_HasPrecedence('1', '13', '1', '2', true, true); -- true

------------------------------------------------------------------
-- TT_GeoHistory()
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
DROP FUNCTION IF EXISTS TT_GeoHistory(name, name, name, name, name, text, text[]);
CREATE OR REPLACE FUNCTION TT_GeoHistory(
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  precedenceColName text,
  validityColNames text[] DEFAULT NULL
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
    currentPolyQuery text;
    ovlpPolyQuery text;

    colNames text[];
    
    currentRow RECORD;
    ovlpRow RECORD;

    refYearBegin int = 1930;
    refYearEnd int = 2030;
    
    preValidYearPoly geometry;
    preValidYearPolyYearEnd int;
    postValidYearPoly geometry;
    postValidYearPolyYearBegin int;

    oldOvlpPolyYear int;
  BEGIN
      -- Check that idColName, geoColName and photoYearColName exists
    colNames = TT_TableColumnNames(schemaName, tableName);
    IF NOT idColName = ANY (colNames) THEN
      RAISE EXCEPTION 'TT_GeoHistory(): Column ''%'' not found in table %.%...', idColName, schemaName, tableName;
    END IF;
    IF NOT geoColName = ANY (colNames) THEN
      RAISE EXCEPTION 'TT_GeoHistory(): Column ''%'' not found in table %.%...', geoColName, schemaName, tableName;
    END IF;
    IF NOT photoYearColName = ANY (colNames) THEN
      RAISE EXCEPTION 'TT_GeoHistory(): Column ''%'' not found in table %.%...', photoYearColName, schemaName, tableName;
    END IF;
    -- Prepare the main LOOP query looping through all polygons of the processed table
    currentPolyQuery = 'SELECT ' || quote_ident(idColName) || '::text gh_row_id, ' ||
                            quote_ident(geoColName) || ' gh_geom, ' ||
                           'coalesce(' || quote_ident(photoYearColName) || ', ' || refYearBegin || ') gh_photo_year, ' ||
                            quote_ident(precedenceColName) || '::text gh_inv, ' ||
                            CASE WHEN validityColNames IS NULL THEN 'TRUE' ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, ',') || '])' END || ' gh_is_valid ' ||
               'FROM ' || TT_FullTableName(schemaName, tableName) ||
             --   ' WHERE ' || quote_ident(idColName) || '::text = ''6'' ' ||
              ' ORDER BY gh_photo_year DESC;';
RAISE NOTICE '111 currentPolyQuery = %', currentPolyQuery;
    -- Prepare the nested LOOP query looping through polygons overlapping the current main loop polygons
    ovlpPolyQuery = 'SELECT ' || quote_ident(idColName) || '::text gh_row_id, ' ||
                                 quote_ident(geoColName) || ' gh_geom, ' ||
                                 'coalesce(' || quote_ident(photoYearColName) || ', ' || refYearBegin || ') gh_photo_year, ' ||
                                 quote_ident(precedenceColName) || '::text gh_inv, ' ||
                                 CASE WHEN validityColNames IS NULL THEN 'TRUE' ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, ',') || '])' END || ' gh_is_valid ' ||
                    'FROM ' || TT_FullTableName(schemaName, tableName) || 
                   ' WHERE ' || quote_ident(idColName) || '::text != $1 AND ' ||
                          '(' ||
                           'ST_Overlaps(' || quote_ident(geoColName) || ', $2) OR ' ||
                           'ST_Contains($2, ' || quote_ident(geoColName) || ') OR ' ||
                           'ST_Contains(' || quote_ident(geoColName) || ', $2)) ' ||
                    'ORDER BY ' || quote_ident(photoYearColName) || ';';
RAISE NOTICE '222 ovlpPolyQuery = %', ovlpPolyQuery;

    -- LOOP over each polygon of the table
    FOR currentRow IN EXECUTE currentPolyQuery LOOP
RAISE NOTICE '---------------------';
RAISE NOTICE '000 currentRow.gh_photo_year = %', currentRow.gh_photo_year;
      -- Initialize preValidYearPoly to the current polygon
      preValidYearPoly = currentRow.gh_geom;
      preValidYearPolyYearEnd = refYearEnd;

      -- postValidYearPoly will be initialized only if the current polygon 
      -- is cut by pre_valid_year polygons or same_valid_year polygons
      postValidYearPoly = NULL;
      postValidYearPolyYearBegin = currentRow.gh_photo_year;

      oldOvlpPolyYear = NULL;
      
      -- Assign some RETURN values now that are useful for debug only
      ref_year = currentRow.gh_photo_year;
      id = currentRow.gh_row_id;
      poly_id = 0;
      isvalid = currentRow.gh_is_valid;

      -- LOOP over all overlapping polygons sorted by photoYear ASC
      FOR ovlpRow IN EXECUTE ovlpPolyQuery 
      USING currentRow.gh_row_id, currentRow.gh_geom, currentRow.gh_photo_year, currentRow.gh_inv LOOP
RAISE NOTICE '---------';
RAISE NOTICE '333 id=%, py=%, inv=%, isvalid=%', currentRow.gh_row_id, currentRow.gh_photo_year, currentRow.gh_inv, currentRow.gh_is_valid;
RAISE NOTICE '444 id=%, py=%, inv=%, isvalid=%', ovlpRow.gh_row_id, ovlpRow.gh_photo_year, ovlpRow.gh_inv, ovlpRow.gh_is_valid;
        -- CASE B - (A - B) RefYB -> RefYE (see logic table above)
        IF (ovlpRow.gh_photo_year = currentRow.gh_photo_year AND 
           ((TT_HasPrecedence(currentRow.gh_inv, currentRow.gh_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id, true, true) AND 
            NOT currentRow.gh_is_valid AND ovlpRow.gh_is_valid) OR
           (NOT TT_HasPrecedence(currentRow.gh_inv, currentRow.gh_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id, true, true) AND 
            (NOT currentRow.gh_is_valid OR (currentRow.gh_is_valid AND ovlpRow.gh_is_valid))))) OR
           (ovlpRow.gh_photo_year < currentRow.gh_photo_year AND NOT currentRow.gh_is_valid AND ovlpRow.gh_is_valid) OR
           (ovlpRow.gh_photo_year > currentRow.gh_photo_year AND NOT currentRow.gh_is_valid) THEN
RAISE NOTICE '555 CASE SAME YEAR: Remove ovlpPoly from prePoly. year = %', ovlpRow.gh_photo_year;

          preValidYearPoly = ST_Difference(preValidYearPoly, ovlpRow.gh_geom);
          IF postValidYearPoly IS NOT NULL THEN
            postValidYearPoly = ST_Difference(postValidYearPoly, ovlpRow.gh_geom);
          END IF;

        -- CASE C - (A - B) RefYB -> AY - 1 and A AY -> RefYE (see logic table above)
        ELSIF ovlpRow.gh_photo_year < currentRow.gh_photo_year AND currentRow.gh_is_valid AND ovlpRow.gh_is_valid THEN
RAISE NOTICE '666 CASE 2: Initialize postPoly and remove ovlpPoly from prePoly. year = %', ovlpRow.gh_photo_year;
          postValidYearPoly = coalesce(postValidYearPoly, preValidYearPoly);
          postValidYearPolyYearBegin = currentRow.gh_photo_year;
          preValidYearPoly = ST_Difference(preValidYearPoly, ovlpRow.gh_geom);
          preValidYearPolyYearEnd = currentRow.gh_photo_year - 1;

        -- CASE D - A RefYB -> BY - 1 and (A - B) BY -> RefYE (see logic table above)
        ELSIF ovlpRow.gh_photo_year > currentRow.gh_photo_year AND currentRow.gh_is_valid AND ovlpRow.gh_is_valid THEN
RAISE NOTICE '777 CASE 3: Return postPoly and set the next one by removing ovlpPoly. year = %', ovlpRow.gh_photo_year;
          -- Make sure the last computed polygon still intersect with ovlpPoly
          IF ST_Intersects(ovlpRow.gh_geom, coalesce(postValidYearPoly, preValidYearPoly)) THEN
            IF oldOvlpPolyYear IS NOT NULL AND oldOvlpPolyYear != ovlpRow.gh_photo_year AND postValidYearPoly IS NOT NULL THEN
              poly_id = poly_id + 1;
              wkb_geometry = postValidYearPoly;
              poly_type = '2_post_1';
              valid_year_begin = postValidYearPolyYearBegin;
              valid_year_end = ovlpRow.gh_photo_year - 1;
              valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE '---------';
RAISE NOTICE 'AAA1 postPoly valid_time=%', valid_time;
RAISE NOTICE '---------';
              RETURN NEXT;
            END IF;
            postValidYearPoly = ST_Difference(coalesce(postValidYearPoly, preValidYearPoly), ovlpRow.gh_geom);
            postValidYearPolyYearBegin = ovlpRow.gh_photo_year;
            preValidYearPolyYearEnd = least(preValidYearPolyYearEnd, ovlpRow.gh_photo_year - 1);
          END IF;
        END IF;
        oldOvlpPolyYear = ovlpRow.gh_photo_year;
      END LOOP;
    
      RAISE NOTICE '---------';
      ---------------------------------------------------------------------------
      -- Return the last new polygon (newestPoly, oldCurrentYear, ovlpPoly.photoYear)
      IF NOT ST_IsEmpty(postValidYearPoly) THEN
        poly_id = poly_id + 1;
        wkb_geometry = postValidYearPoly;
        poly_type = '2_post_2';
        valid_year_begin = postValidYearPolyYearBegin;
        valid_year_end = refYearEnd;
        valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE 'AAA2 postPoly valid_time=%', valid_time;
        RETURN NEXT;
      END IF;

      ---------------------------------------------------------------------------
      -- Return the current polygon (olderPoly, refYearBegin, currentPoly.photoYear - 1))
      IF NOT ST_IsEmpty(preValidYearPoly) THEN
        poly_id = poly_id + 1;
        wkb_geometry = preValidYearPoly;
        poly_type = '1_pre';
        valid_year_begin = refYearBegin;
        valid_year_end = preValidYearPolyYearEnd;
        valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE 'CCC prePoly valid_time=%', valid_time;
        RETURN NEXT;
      END IF;
    END LOOP;
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
$$ LANGUAGE sql VOLATILE;

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
    FROM TT_GeoHistory(schemaName, tableName, idColName, geoColName, photoYearColName, precedenceColName, validityColNames);
$$ LANGUAGE sql VOLATILE;