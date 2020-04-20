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
-- hasPrededence determine if the first polygon has precedence over the second one based on:
  -- 1) their validity: a valid polygon has always precedence over an invalid polygon, whatever their base year. 
  --                    A polygon is invalid when all it's key attribute are NULL.
  -- 2) their base year: when both polygons are valid, newer polygons have precedence over older polygons.
  -- 3) their inventory rank: when two polygons are valid and have the same base year, an established priority rank among inventories determine which polygon has priority
  -- 4) their unique ID: when all the above are equivalent for both polygons, the polygon with the highest ID has priority.

------------------------------------------------------------------
-- TT_HasPrecedence()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_HasPrecedence(text[], text[]);
CREATE OR REPLACE FUNCTION TT_HasPrecedence(
  val_arr1 text[],
  val_arr2 text[]
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    RETURN val_arr1[1]::int >= val_arr2[1]::int;
    --RETURN TRUE;
  END
$$ LANGUAGE plpgsql VOLATILE;

--SELECT TT_HasPrecedence(ARRAY[1::text], ARRAY[2::text]);
--SELECT TT_HasPrecedence(ARRAY[2::text], ARRAY[1::text]);

------------------------------------------------------------------
-- TT_GeoHistory()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_GeoHistory(name, name, name, name, name, text);
CREATE OR REPLACE FUNCTION TT_GeoHistory(
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  hasPrecedenceFct text DEFAULT 'TT_HasPrecedence'
)
RETURNS TABLE (id text, 
               wkb_geometry geometry, 
               poly_type text,
               ref_year int,
               valid_year_begin int, 
               valid_year_end int, 
               valid_time text) AS $$
  DECLARE
    currentPolyQuery text;
    ovlpPolyQuery text;

    refYearBegin int = 1990;
    refYearEnd int = 3000;

    currentPoly geometry;
    olderPoly geometry; -- current polygon minus older polygons
    olderPolyYearEnd int;

    newerPoly geometry; -- current polygon minus newer polygons
    newerPolyYearBegin int;

    oldOvlpPolyYear int;

    currentRow RECORD;
    ovlpRow RECORD;
    colNames text[];
  BEGIN
    -- TODO
    -- Try to make a list of all possible overlapping cases and test them
    -- Build the array of significant attributes to pass to hasPrecedence from the main and the inner loop
    -- See if we have to check the validity of older and newer polygons
       -- If they are valid, proceed normally
       -- If currentPoly is invalid, all older and newer overlapping part have to be removed
       -- If older or newer polygon are invalid, ignore them
       -- If both current and older or newer polygon are invalid, hasPrecedence decide which part to keep
    
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

    -- LOOP over each polygon of the table
    currentPolyQuery = 'SELECT ' || idColName || '::text gh_row_id, ' ||
                            geoColName || ' gh_geom, ' ||
                           'coalesce(' || photoYearColName || ', ' || refYearBegin || ') gh_photo_year, ' ||
               '* FROM ' || TT_FullTableName(schemaName, tableName) ||
             --   ' WHERE id = 2 ' ||
                ' ORDER BY gh_photo_year DESC;';
RAISE NOTICE '111 currentPolyQuery = %', currentPolyQuery;
      ovlpPolyQuery = 'SELECT ' || idColName || '::text gh_row_id, ' ||
                              geoColName || ' gh_geom, ' ||
                             'coalesce(' || photoYearColName || ', ' || refYearBegin || ') gh_photo_year, * ' ||
                 'FROM ' || TT_FullTableName(schemaName, tableName) || 
                ' WHERE ' || idColName || '::text != $1 AND ' ||
                '(' || photoYearColName || '!= $3 OR '|| hasPrecedenceFct || '(ARRAY[' || idColName ||'::text], ARRAY[$1::text])) AND ' ||
                '(' ||
                 'ST_Overlaps(' || geoColName || ', $2) OR ' ||
                 'ST_Contains($2, ' || geoColName || ') OR ' ||
                 'ST_Contains(' || geoColName || ', $2)) ' ||
                 'ORDER BY CASE WHEN ' || photoYearColName || ' = $3 THEN 1' ||
                              ' WHEN ' || photoYearColName || ' < $3 THEN 2' ||
                              ' ELSE 3 END, ' || photoYearColName || ';';
RAISE NOTICE '222 ovlpPolyQuery = %', ovlpPolyQuery;
    FOR currentRow IN EXECUTE currentPolyQuery LOOP
RAISE NOTICE '---------------------';
RAISE NOTICE '000 currentRow.gh_photo_year = %', currentRow.gh_photo_year;
        
      olderPoly = currentRow.gh_geom;
      olderPolyYearEnd = refYearEnd;

      newerPoly = NULL;
      currentPoly= NULL;
      newerPolyYearBegin = currentRow.gh_photo_year;

      oldOvlpPolyYear = NULL;
      id = currentRow.gh_row_id::text;
      ref_year = currentRow.gh_photo_year;

RAISE NOTICE '111';
      -- LOOP over all overlapping polygons sorted by photoYear ASC
      FOR ovlpRow IN EXECUTE ovlpPolyQuery USING currentRow.gh_row_id, currentRow.gh_geom, currentRow.gh_photo_year LOOP
RAISE NOTICE '---------';
--RAISE NOTICE '333 ovlpRow.gh_photo_year = %', ovlpRow.gh_photo_year;
RAISE NOTICE '333 id=%, py=%', currentRow.gh_row_id, currentRow.gh_photo_year;
RAISE NOTICE '444 id=%, py=%', ovlpRow.gh_row_id, ovlpRow.gh_photo_year;
RAISE NOTICE '555 A hasprecedence=%', TRUE;
      
        IF ovlpRow.gh_photo_year = currentRow.gh_photo_year THEN -- Same year polygons
          -- Blindly remove all same year polygons having precedence
          olderPoly = ST_Difference(olderPoly, ovlpRow.gh_geom);
        ELSIF ovlpRow.gh_photo_year < currentRow.gh_photo_year THEN -- Older polygons
RAISE NOTICE '666 treat older poly = %', ovlpRow.gh_photo_year;
          IF ST_Intersects(ovlpRow.gh_geom, olderPoly) AND TRUE THEN -- (isValidFct IS NULL OR isValidFct(ovlpPoly))
            -- If any older polygon has to be removed, initialize a newer polygon to 
            -- the current polygon (which is the same as olderPoly for now)
            IF newerPoly IS NULL THEN
              newerPoly = olderPoly;
            END IF;
            olderPoly = ST_Difference(olderPoly, ovlpRow.gh_geom);
            olderPolyYearEnd = currentRow.gh_photo_year - 1;
          END IF;
        ELSE -- Newer polygons
RAISE NOTICE '666 treat newer poly = %', ovlpRow.gh_photo_year;

            IF newerPoly IS NULL THEN
              newerPoly = currentRow.gh_geom;
RAISE NOTICE 'YYY currentRow.gh_photo_year = %', currentRow.gh_photo_year;
            END IF;
            IF ST_Intersects(ovlpRow.gh_geom, newerPoly) THEN
              -- Return the previously computed polygon part if it exists
              IF NOT oldOvlpPolyYear IS NULL AND oldOvlpPolyYear != ovlpRow.gh_photo_year THEN
                wkb_geometry = newerPoly;
                poly_type = '2_newer1';
                valid_year_begin = greatest(oldOvlpPolyYear, currentRow.gh_photo_year);
                valid_year_end = ovlpRow.gh_photo_year - 1;
                valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE '---------';
RAISE NOTICE 'AAA1 newerPoly valid_time=%', valid_time;
RAISE NOTICE '---------';
                RETURN NEXT;
              END IF;

              -- A newer part is always the current part minus the newest overlapping polygon
              newerPoly = ST_Difference(newerPoly, ovlpRow.gh_geom);
              
              -- This part begins the same year as the newest overlapping polygon
              newerPolyYearBegin = ovlpRow.gh_photo_year;
              
            END IF;
            -- Set or reset the end of the older polygon if it was not set
            olderPolyYearEnd = least(olderPolyYearEnd, ovlpRow.gh_photo_year - 1);
        END IF;
        oldOvlpPolyYear = ovlpRow.gh_photo_year;
      END LOOP; -- ovlpRow

RAISE NOTICE '---------';
      ---------------------------------------------------------------------------
      -- Return the last new polygon (newestPoly, oldCurrentYear, ovlpPoly.photoYear)
      --IF NOT ST_IsEmpty(coalesce(newerPoly, currentPoly)) THEN
      IF NOT ST_IsEmpty(newerPoly) THEN
        --wkb_geometry = coalesce(newerPoly, currentPoly);
        wkb_geometry = newerPoly;
        poly_type = '2_newer2';
        valid_year_begin = newerPolyYearBegin;
        valid_year_end = refYearEnd;
        valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE 'AAA2 newerPoly valid_time=%', valid_time;
        RETURN NEXT;
      END IF;

      ---------------------------------------------------------------------------
      -- Return the current polygon (olderPoly, refYearBegin, currentPoly.photoYear - 1))
      IF NOT ST_IsEmpty(olderPoly) THEN
        wkb_geometry = olderPoly;
        poly_type = '1_older';
        valid_year_begin = refYearBegin;
        valid_year_end = olderPolyYearEnd;
        valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE 'CCC olderPoly valid_time=%', valid_time;
        RETURN NEXT;
      END IF;
    END LOOP; -- currentRow
    RETURN;
  END
$$ LANGUAGE plpgsql VOLATILE;

------------------------------------------------------------------
-- TT_RowIsValid()
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
-- TT_HasPrecedence2()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_HasPrecedence2(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_HasPrecedence2(
  inv1 text, 
  uid1 text,
  inv2 text,
  uid2 text
)
RETURNS boolean AS $$
  DECLARE
    refInv text = 'AA00';
    refUID text = 'A';
  BEGIN
      IF inv1 IS NULL THEN
        RAISE NOTICE 'TT_HasPrecedence2() WARNING : inv1 for polygon ''%'' is NULL. Assigning %...', uid1, refInv;
        inv1 = refInv;
      END IF;
      IF inv2 IS NULL THEN
        RAISE NOTICE 'TT_HasPrecedence2() WARNING : inv2 for polygon ''%'' is NULL. Assigning %...', uid2, refInv;
        inv2 = refInv;
      END IF;
      IF inv1 = inv2 THEN
        IF uid1 IS NULL THEN
          RAISE NOTICE 'TT_HasPrecedence2() WARNING : uid1 is NULL. Assigning %...', refUID;
          uid1 = refUID;
        END IF;
        IF uid2 IS NULL THEN
          RAISE NOTICE 'TT_HasPrecedence2() WARNING : uid2 is NULL. Assigning %...', refUID;
          uid2 = refUID;
        END IF;
        IF uid1 = uid2 THEN
          RAISE NOTICE 'TT_HasPrecedence2() WARNING : uid1 and uid2 are equal (%). Can''t give precedence to a polygon. Returning FALSE...', uid1;
          RETURN FALSE;
        END IF;
      END IF;
RAISE NOTICE '1 % has precedence on 2', CASE WHEN inv1 > inv2 OR (inv1 = inv2 AND uid1 > uid2) THEN '' ELSE 'does not' END;
    RETURN inv1 > inv2 OR 
           (inv1 = inv2 AND uid1 > uid2);
  END
$$ LANGUAGE plpgsql VOLATILE;

--SELECT TT_HasPrecedence2(NULL, NULL, NULL, NULL);
--SELECT TT_HasPrecedence2('AB06', NULL, NULL, NULL);
--SELECT TT_HasPrecedence2('AB06', NULL, 'AB06', NULL);
--SELECT TT_HasPrecedence2('AB06', NULL, 'AB16', NULL);
--SELECT TT_HasPrecedence2('AB16', NULL, 'AB06', NULL);
--SELECT TT_HasPrecedence2('AB06', 'AA', 'AB06', NULL);
--SELECT TT_HasPrecedence2('AB06', 'AA', 'AB06', 'AA');
--SELECT TT_HasPrecedence2('AB06', 'AA', 'AB06', 'AB');
--SELECT TT_HasPrecedence2('AB06', 'AB', 'AB06', 'AA');
--SELECT TT_HasPrecedence2('AB06', '2', 'AB06', '3');

------------------------------------------------------------------
-- TT_GeoHistory2()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_GeoHistory2(name, name, name, name, name, text, text[]);
CREATE OR REPLACE FUNCTION TT_GeoHistory2(
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

    refYearBegin int = 1990;
    refYearEnd int = 3000;
    
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

    currentPolyQuery = 'SELECT ' || quote_ident(idColName) || '::text gh_row_id, ' ||
                            quote_ident(geoColName) || ' gh_geom, ' ||
                           'coalesce(' || quote_ident(photoYearColName) || ', ' || refYearBegin || ') gh_photo_year, ' ||
                            quote_ident(precedenceColName) || '::text gh_inv, ' ||
                            CASE WHEN validityColNames IS NULL THEN 'TRUE' ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, ',') || '])' END || ' gh_is_valid ' ||
               'FROM ' || TT_FullTableName(schemaName, tableName) ||
             --   ' WHERE ' || quote_ident(idColName) || '::text = ''6'' ' ||
              ' ORDER BY gh_photo_year DESC;';
RAISE NOTICE '111 currentPolyQuery = %', currentPolyQuery;

    ovlpPolyQuery = 'SELECT ' || quote_ident(idColName) || '::text gh_row_id, ' ||
                                 quote_ident(geoColName) || ' gh_geom, ' ||
                                 'coalesce(' || quote_ident(photoYearColName) || ', ' || refYearBegin || ') gh_photo_year, ' ||
                                 quote_ident(precedenceColName) || '::text gh_inv, ' ||
                                 CASE WHEN validityColNames IS NULL THEN 'TRUE' ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, ',') || '])' END || ' gh_is_valid ' ||
                           --  'TT_HasPrecedence2($3, $4, $1::text, ' || quote_ident(photoYearColName) || ', ' || quote_ident(precedenceColName) || '::text, ' || quote_ident(idColName) || '::text) gh_currentHasPrecedence ' ||
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
      -- initialize preValidYearPoly to the current polygon
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
        IF (ovlpRow.gh_photo_year = currentRow.gh_photo_year AND 
           ((TT_HasPrecedence2(currentRow.gh_inv, currentRow.gh_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id) AND 
            NOT currentRow.gh_is_valid AND ovlpRow.gh_is_valid) OR
           (NOT TT_HasPrecedence2(currentRow.gh_inv, currentRow.gh_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id) AND 
            (NOT currentRow.gh_is_valid OR (currentRow.gh_is_valid AND ovlpRow.gh_is_valid))))) OR
           (ovlpRow.gh_photo_year < currentRow.gh_photo_year AND NOT currentRow.gh_is_valid AND ovlpRow.gh_is_valid) OR
           (ovlpRow.gh_photo_year > currentRow.gh_photo_year AND NOT currentRow.gh_is_valid) THEN
RAISE NOTICE '555 CASE SAME YEAR: Remove ovlpPoly from prePoly. year = %', ovlpRow.gh_photo_year;

          preValidYearPoly = ST_Difference(preValidYearPoly, ovlpRow.gh_geom);
          IF postValidYearPoly IS NOT NULL THEN
            postValidYearPoly = ST_Difference(postValidYearPoly, ovlpRow.gh_geom);
          END IF;
 
        ELSIF ovlpRow.gh_photo_year < currentRow.gh_photo_year AND currentRow.gh_is_valid AND ovlpRow.gh_is_valid THEN
RAISE NOTICE '666 CASE 2: Initialize postPoly and remove ovlpPoly from prePoly. year = %', ovlpRow.gh_photo_year;
          postValidYearPoly = coalesce(postValidYearPoly, preValidYearPoly);
          postValidYearPolyYearBegin = currentRow.gh_photo_year;
          preValidYearPoly = ST_Difference(preValidYearPoly, ovlpRow.gh_geom);
          preValidYearPolyYearEnd = currentRow.gh_photo_year - 1;

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

--SELECT * FROM TT_GeoHistoryOblique2('public', 'test_geohistory3', 'id', 'geom', 'valid_year', ARRAY['att'], 'att', 0.1)
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
DROP FUNCTION IF EXISTS TT_GeoHistoryOblique(name, name, name, name, name, double precision, double precision);
CREATE OR REPLACE FUNCTION TT_GeoHistoryOblique(
  schemaName name,
  tableName name,
  idColName name,
  geoColName name,
  photoYearColName name,
  z_factor double precision DEFAULT 0.4,
  y_factor double precision DEFAULT 0.4
)
RETURNS TABLE (id text, 
               wkb_geometry geometry, 
               poly_type text,
               ref_year int,
               valid_year_begin int, 
               valid_year_end int, 
               valid_time text) AS $$
    SELECT id, 
           TT_GeoOblique(wkb_geometry, valid_year_begin, z_factor, y_factor) wkb_geometry,
           poly_type,
           ref_year,
           valid_year_begin, 
           valid_year_end,
           valid_time
    FROM TT_GeoHistory(schemaName, tableName, idColName, geoColName, photoYearColName);
$$ LANGUAGE sql VOLATILE;

------------------------------------------------------------------
-- TT_GeoHistoryOblique2()
------------------------------------------------------------------
DROP FUNCTION IF EXISTS TT_GeoHistoryOblique2(name, name, name, name, name, text, text[], double precision, double precision);
CREATE OR REPLACE FUNCTION TT_GeoHistoryOblique2(
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
    FROM TT_GeoHistory2(schemaName, tableName, idColName, geoColName, photoYearColName, precedenceColName, validityColNames);
$$ LANGUAGE sql VOLATILE;

------------------------------------------------------------------
-- Tests
------------------------------------------------------------------

--SELECT id, 
--       ST_Affine(geom, 1, 1, 0, 0.4, 0, (valid_year - 2000) * 0.4) geom,
--       valid_year
--FROM test_geohistory
--ORDER BY ref_year DESC, poly_type DESC
--;

-- Display flat
--SELECT *, id || '_' || valid_year idy FROM test_geohistory;

-- Display oblique
--SELECT TT_GeoOblique(geom, valid_year), id || '_' || valid_year idy FROM test_geohistory;

-- Display flat history
--SELECT * FROM TT_GeoHistory('public', 'test_geohistory', 'id', 'geom', 'valid_year');

-- Display oblique history
--SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory', 'id', 'geom', 'valid_year');


