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

SELECT TT_HasPrecedence(ARRAY[1::text], ARRAY[2::text]);
SELECT TT_HasPrecedence(ARRAY[2::text], ARRAY[1::text]);

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
    queryStr text;

    refYearBegin int = 1990;
    refYearEnd int = 3000;

    currentPoly geometry;
    olderPoly geometry; -- current polygon minus older polygons
    olderPolyYearEnd int;

    newerPoly geometry; -- current polygon minus newer polygons
    newerPolyYearBegin int;
    newerPolyId text;
    
    currentPolyYear int;

    ovlpPolyYear int;
    oldOvlpPolyYear int;

    currentRow RECORD;
    ovlpRow RECORD;
    colNames text[];
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

    -- LOOP over each polygon of the table
    queryStr = 'SELECT ' || idColName || ' gh_row_id, ' ||
                           geoColName || ' gh_geom, ' ||
                     photoYearColName || ' gh_photo_year, ' ||
               '* FROM ' || TT_FullTableName(schemaName, tableName) ||
             --   ' WHERE id = 1 ' ||
                ' ORDER BY gh_photo_year DESC;';
RAISE NOTICE '111 queryStr = %', queryStr;
    FOR currentRow IN EXECUTE queryStr LOOP

      -- If currentPolygon.stand_photo_year IS NULL RAISE NOTICE
      currentPolyYear = currentRow.gh_photo_year;
RAISE NOTICE '---------------------';
RAISE NOTICE '000 currentPolyYear = %', currentPolyYear;
      IF currentPolyYear IS NULL THEN
        RAISE NOTICE 'TT_GeoHistory(): Row ID % have a NULL %. Assigning %...', currentRow.gh_row_id, photoYearColName, refYear;
        currentPolyYear = refYearBegin;
      END IF;
        
      olderPoly = currentRow.gh_geom;
      olderPolyYearEnd = refYearEnd;

      newerPoly = NULL;
      currentPoly= NULL;
      newerPolyYearBegin = currentPolyYear;

      oldOvlpPolyYear = NULL;
      id = currentRow.gh_row_id;
      ref_year = currentPolyYear;

      -- LOOP over all overlapping polygons sorted by photoYear ASC
      queryStr = 'SELECT ' || idColName || ' gh_row_id, ' ||
                             geoColName || ' gh_geom, ' ||
                       photoYearColName || ' gh_photo_year, ' ||
               '* FROM ' || TT_FullTableName(schemaName, tableName) || 
                ' WHERE ' || idColName || ' != $1 AND ' ||
                '(' || photoYearColName || '!= ' || currentPolyYear || ' OR '|| hasPrecedenceFct || '(ARRAY[' || idColName ||'::text], ARRAY[$1::text])) AND ' ||
                '(' ||
                 'ST_Overlaps(' || geoColName || ', $2) OR ' ||
                 'ST_Contains($2, ' || geoColName || ') OR ' ||
                 'ST_Contains(' || geoColName || ', $2)) ' ||
                 'ORDER BY CASE WHEN ' || photoYearColName || ' = '|| currentPolyYear || ' THEN 1' ||
                              ' WHEN ' || photoYearColName || ' < '|| currentPolyYear || ' THEN 2' ||
                              ' ELSE 3 END;';
RAISE NOTICE '---------';
RAISE NOTICE '222 queryStr = %', queryStr;
      FOR ovlpRow IN EXECUTE queryStr USING currentRow.gh_row_id, currentRow.gh_geom LOOP
        IF ovlpRow.gh_photo_year IS NULL THEN
          RAISE NOTICE 'TT_GeoHistory(): Row ID % have a NULL %. Assigning %...', ovlpRow.gh_row_id, photoYearColName, refYear;
        END IF;
        ovlpPolyYear = coalesce(ovlpRow.gh_photo_year, refYearBegin);
--RAISE NOTICE '333 ovlpPolyYear = %', ovlpPolyYear;
        
        IF ovlpPolyYear = currentPolyYear THEN -- Same year polygons
          -- Remove all same year polygons having precedence
          olderPoly = ST_Difference(olderPoly, ovlpRow.gh_geom);
        ELSIF ovlpPolyYear < currentPolyYear THEN -- Older polygons
RAISE NOTICE '555 treat older poly = %', ovlpPolyYear;
          IF ST_Intersects(ovlpRow.gh_geom, olderPoly) AND TRUE THEN -- (isValidFct IS NULL OR isValidFct(ovlpPoly))
            -- If any older polygon has to be removed, initialize a newer polygon
            IF newerPoly IS NULL THEN
              newerPoly = olderPoly;
            END IF;
            olderPoly = ST_Difference(olderPoly, ovlpRow.gh_geom);
            olderPolyYearEnd = currentPolyYear - 1;
          END IF;
        ELSE -- Newer polygons
RAISE NOTICE '666 treat newer poly = %', ovlpPolyYear;

            IF newerPoly IS NULL THEN
              newerPoly = currentRow.gh_geom;
              newerPolyId = currentRow.gh_row_id::text;
RAISE NOTICE 'YYY currentPolyYear = %', currentPolyYear;
            END IF;
            IF ST_Intersects(ovlpRow.gh_geom, newerPoly) THEN
              -- Return the previously computed polygon part if it exists
              IF NOT oldOvlpPolyYear IS NULL AND oldOvlpPolyYear != ovlpPolyYear THEN
                wkb_geometry = newerPoly;
                poly_type = '2_newer1';
                valid_year_begin = greatest(oldOvlpPolyYear, currentPolyYear);
                valid_year_end = ovlpPolyYear - 1;
                valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
RAISE NOTICE '---------';
RAISE NOTICE 'AAA1 newerPoly valid_time=%', valid_time;
RAISE NOTICE '---------';
                RETURN NEXT;
              END IF;

              -- A newer part is always the current part minus the newest overlapping polygon
              newerPoly = ST_Difference(newerPoly, ovlpRow.gh_geom);
              
              -- This part begins the same year as the newest overlapping polygon
              newerPolyYearBegin = ovlpPolyYear;
              
            END IF;
            -- Set or reset the end of the older polygon if it was not set
            olderPolyYearEnd = least(olderPolyYearEnd, ovlpPolyYear - 1);
        END IF;
        oldOvlpPolyYear = ovlpPolyYear;
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

CREATE OR REPLACE FUNCTION TT_GeoOblique(
  geom geometry,
  year int
)
RETURNS geometry AS $$
  SELECT ST_Affine(geom, 1, 1, 0, 0.4, 0, (year - 2000) * 0.4);
$$ LANGUAGE sql VOLATILE;

  
CREATE OR REPLACE FUNCTION TT_GeoHistoryOblique(
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
    SELECT id, 
           TT_GeoOblique(wkb_geometry, valid_year_begin) wkb_geometry,
           poly_type,
           ref_year,
           valid_year_begin, 
           valid_year_end,
           valid_time
    FROM TT_GeoHistory(schemaName, tableName, idColName, geoColName, photoYearColName, hasPrecedenceFct);
$$ LANGUAGE sql VOLATILE;

SELECT id, 
       ST_Affine(geom, 1, 1, 0, 0.4, 0, (valid_year - 2000) * 0.4) geom,
       valid_year
FROM test_geohistory
--ORDER BY ref_year DESC, poly_type DESC
;
SELECT * FROM test_geohistory_2_3;

SELECT *, ST_AsText(wkb_geometry) FROM TT_GeoHistory('public', 'test_geohistory_2_3', 'id', 'geom', 'valid_year');

SELECT * FROM TT_GeoHistoryOblique('public', 'test_geohistory_2_3', 'id', 'geom', 'valid_year');


