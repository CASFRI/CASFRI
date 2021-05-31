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
$$ LANGUAGE plpgsql IMMUTABLE;

--SELECT * FROM test_geohistory;
--SELECT ARRAY[id::text, att] FROM test_geohistory;
--SELECT TT_RowIsValid(ARRAY[id::text, att]) FROM test_geohistory;
--SELECT TT_RowIsValid(ARRAY[att]) FROM test_geohistory;

-------------------------------------------------------------------------------
-- TT_AreasForSignificantYearsDebugQuery()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_AreasForSignificantYearsDebugQuery(name, boolean);
CREATE OR REPLACE FUNCTION TT_AreasForSignificantYearsDebugQuery(
  tableName name,
  gridded boolean DEFAULT FALSE
)
RETURNS text AS $$
  SELECT '
-- Search for most different year
SELECT * 
FROM TT_AreasForSignificantYears(''' || lower(tableName) || ''', ' || gridded || ');

-- Display all polygons for this year
SELECT *, wkt_geometry::geometry geom
FROM casfri50_history_test.sampling_area_' || lower(tableName) || CASE WHEN gridded THEN '_gridded' ELSE '' END || '_history_new
WHERE valid_year_begin <= XXXX AND XXXX <= valid_year_end;

-- Display all polygons for this year unioned
SELECT ST_Union(wkt_geometry::geometry) geom
FROM casfri50_history_test.sampling_area_' || lower(tableName) || CASE WHEN gridded THEN '_gridded' ELSE '' END || '_history_new
WHERE valid_year_begin <= XXXX AND XXXX <= valid_year_end;

-- Display overlaps
WITH history AS (
  SELECT *, wkt_geometry::geometry wkb_geometry
  FROM casfri50_history_test.sampling_area_' || lower(tableName) || CASE WHEN gridded THEN '_gridded' ELSE '' END || '_history_new
  WHERE valid_year_begin <= XXXX AND XXXX <= valid_year_end
)
SELECT a.id aid, b.id bid, 
       ST_Area(ST_Intersection(a.wkb_geometry, b.wkb_geometry)) area, 
       ST_Intersection(a.wkb_geometry, b.wkb_geometry) geom
FROM history a,
     history b
WHERE a.id != b.id AND TT_GeoHistoryOverlaps(a.wkb_geometry, b.wkb_geometry)
ORDER BY area DESC;

-- Debug geohistory query
SET tt.debug_l2 TO TRUE;

SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             ''casfri50_history_test'', ''sampling_area_' || lower(tableName) || CASE WHEN gridded THEN '_gridded' ELSE '' END || ''', ''cas_id'', ''geometry'', ''photo_year'', ''inventory_id'')).*
FROM casfri50_history_test.sampling_area_' || lower(tableName) || '_gridded
WHERE cas_id =  ''YYYY'';
'
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_AreasForSignificantYears()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_AreasForSignificantYears(name, boolean, double precision);
CREATE OR REPLACE FUNCTION TT_AreasForSignificantYears(
  tableName name,
  gridded boolean DEFAULT FALSE,
  tolerance double precision DEFAULT 0.001
)
RETURNS TABLE (year int, 
               sum_of_areas double precision, 
               area_of_union double precision, 
               area_diff_in_sq_meters double precision, 
               area_diff_in_sq_centimeters double precision) AS $$
  DECLARE
    queryStr text;
  BEGIN
    queryStr = format('
    WITH history AS (
      SELECT *, wkt_geometry::geometry wkb_geometry 
      FROM casfri50_history_test.sampling_area_%s%s_history_new 
    ), all_significant_years AS (
      SELECT DISTINCT syear
      FROM (
        SELECT DISTINCT valid_year_begin syear
        FROM history
        UNION ALL
        SELECT DISTINCT valid_year_end syear
        FROM history
      ) foo
      ORDER BY syear
    ), sum_of_areas AS (
      SELECT syear, 
             sum(ST_Area(wkb_geometry)) sum_area
      FROM history, all_significant_years
      WHERE valid_year_begin <= syear AND syear <= valid_year_end
      GROUP BY syear
      ORDER BY syear
    ), area_of_union AS (
      SELECT syear, 
             ST_Area(ST_Union(wkb_geometry)) union_area
      FROM history, all_significant_years
      WHERE valid_year_begin <= syear AND syear <= valid_year_end
      GROUP BY syear
      ORDER BY syear
    )
    SELECT sa.syear, sum_area, 
           union_area, 
           sum_area - union_area area_diff_in_sq_meters, 
           10000 * (sum_area - union_area) area_diff_in_sq_centimeters
    FROM sum_of_areas sa, area_of_union au
    WHERE sa.syear = au.syear AND abs(sum_area - union_area) > %s
    ORDER BY area_diff_in_sq_meters DESC, syear DESC;', tableName, CASE WHEN gridded THEN '_gridded' ELSE '' END, tolerance);
RAISE NOTICE 'queryStr=%', queryStr;
    RETURN QUERY EXECUTE queryStr;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
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
-- TT_SplitByGrid
--
--   geom geometry - Geometry to split.
--
--   xgridsize double precision  - Horizontal grid cell size.
--
--   ygridsize double precision  - Vertical grid cell size.
--
--   xgridoffset double precision  - Horizontal grid offset.
--
--   ygridoffset double precision  - Vertical grid offset.
--
--   RETURNS TABLE (geom geometry, tid int8, x int, y int, tgeom geometry)
--
-- Set function returnings the geometry splitted in multiple parts by a grid of the
-- specified size and optionnaly shifted by the specified offset. Each part comes
-- with a unique identifier for each cell of the grid it intersects with, the x and
-- y coordinate of the cell and a geometry representin the cell itself.
-- The unique identifier returned remains the same for any subsequent call to the
-- function so that all geometry parts inside the same cell, from call to call get
-- the same uid.
--
-- This function is usefull to parallelize some queries.
--
--
-- Self contained and typical example:
--
-- WITH splittable AS (
--   SELECT 1 id, ST_GeomFromText('POLYGON((0 1, 3 2, 3 0, 0 1))') geom
--   UNION ALL
--   SELECT 2 id, ST_GeomFromText('POLYGON((1 1, 4 2, 4 0, 1 1))')
--   UNION ALL
--   SELECT 3 id, ST_GeomFromText('POLYGON((2 1, 5 2, 5 0, 2 1))')
--   UNION ALL
--   SELECT 4 id, ST_GeomFromText('POLYGON((3 1, 6 2, 6 0, 3 1))')
-- )
-- SELECT (TT_SplitByGrid(geom, 0.5)).* FROM splittable
--
-----------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SplitByGrid(geometry, double precision, double precision, double precision, double precision);
CREATE OR REPLACE FUNCTION TT_SplitByGrid(
    ingeom geometry,
    xgridsize double precision,
    ygridsize double precision DEFAULT NULL,
    xgridoffset double precision DEFAULT 0.0,
    ygridoffset double precision DEFAULT 0.0
)
RETURNS TABLE (geom geometry, tid int8, tx int, ty int, tgeom geometry) AS $$
    DECLARE
        width int;
        height int;
        xminrounded double precision;
        yminrounded double precision;
        xmaxrounded double precision;
        ymaxrounded double precision;
        xmin double precision := ST_XMin(ingeom);
        ymin double precision := ST_YMin(ingeom);
        xmax double precision := ST_XMax(ingeom);
        ymax double precision := ST_YMax(ingeom);
        x int;
        y int;
        env geometry;
        xfloor int;
        yfloor int;
    BEGIN
        IF ingeom IS NULL OR ST_IsEmpty(ingeom) THEN
            geom = ingeom;
            tid = NULL;
            tx = NULL;
            ty = NULL;
            tgeom = NULL;
            RETURN NEXT;
            RETURN;
        END IF;
        IF xgridsize IS NULL OR xgridsize <= 0 THEN
            RAISE NOTICE 'Defaulting xgridsize to 1...';
            xgridsize = 1;
        END IF;
        IF ygridsize IS NULL OR ygridsize <= 0 THEN
            ygridsize = xgridsize;
        END IF;
        xfloor = floor((xmin - xgridoffset) / xgridsize);
        xminrounded = xfloor * xgridsize + xgridoffset;
        xmaxrounded = ceil((xmax - xgridoffset) / xgridsize) * xgridsize + xgridoffset;
        yfloor = floor((ymin - ygridoffset) / ygridsize);
        yminrounded = yfloor * ygridsize + ygridoffset;
        ymaxrounded = ceil((ymax - ygridoffset) / ygridsize) * ygridsize + ygridoffset;

        width = round((xmaxrounded - xminrounded) / xgridsize);
        height = round((ymaxrounded - yminrounded) / ygridsize);

        FOR x IN 1..width LOOP
            FOR y IN 1..height LOOP
                env = ST_MakeEnvelope(xminrounded + (x - 1) * xgridsize, yminrounded + (y - 1) * ygridsize, xminrounded + x * xgridsize, yminrounded + y * ygridsize, ST_SRID(ingeom));
                IF ST_Intersects(env, ingeom) AND (
                     ST_Dimension(ST_Intersection(ingeom, env)) = ST_Dimension(ingeom) OR
                     ST_GeometryType(ST_Intersection(ingeom, env)) = ST_GeometryType(ingeom)
                   ) 
                   THEN
                   geom = ST_Intersection(ingeom, env);
                   tid = ((xfloor::int8 + x) * 10000000 + (yfloor::int8 + y))::int8;
                   tx = xfloor + x;
                   ty = yfloor + y;
                   tgeom = env;
                   RETURN NEXT;
                 END IF;
            END LOOP;
        END LOOP;
    RETURN;
    END;
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;
/*
SELECT * FROM TT_SplitByGrid(ST_Buffer(ST_MakePoint(0, 0), 100), 100);
SELECT * FROM TT_SplitByGrid(NULL::geometry, 10);
*/
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_PrintMessage
--
-- Print debug information when executing SQL
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_PrintMessage(text);
CREATE OR REPLACE FUNCTION TT_PrintMessage(
  msg text
)
RETURNS boolean AS $$
  DECLARE
  BEGIN
    RAISE NOTICE '%', msg;
    RETURN TRUE;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE STRICT;
------------------------------------------------------------------------------
-- TT_BufferedSmooth
--
-- Simplify a polygon by adding and removing a buffer around it
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_BufferedSmooth(geometry, double precision);
CREATE OR REPLACE FUNCTION TT_BufferedSmooth(
    geom geometry,
    bufsize double precision DEFAULT 0
)
RETURNS geometry AS $$
  SELECT ST_Buffer(ST_Buffer($1, $2), -$2)
$$ LANGUAGE sql IMMUTABLE;
------------------------------------------------------------------------------
-- TT_RemoveHoles
--
-- Remove all hole from a polygon or a multipolygon
-- Used by TT_IsSurrounded_FinalFN2()
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RemoveHoles(geometry, double precision);
CREATE OR REPLACE FUNCTION TT_RemoveHoles(
  inGeom geometry,
  minArea double precision DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    returnGeom geometry;
  BEGIN
    IF inGeom IS NULL OR ST_IsEmpty(inGeom) OR (ST_GeometryType(inGeom) != 'ST_Polygon' AND ST_GeometryType(inGeom) != 'ST_MultiPolygon') THEN
      RETURN inGeom;
    END IF;
--RAISE NOTICE 'inGeom is %', CASE WHEN ST_IsValid(inGeom) THEN 'VALID' ELSE 'INVALID' END;
    WITH all_geoms AS (
      SELECT ST_GeometryN(ST_Multi(inGeom), generate_series(1, ST_NumGeometries(ST_Multi(inGeom)))) AS geom
    ), polygons AS (
      SELECT ST_MakePolygon(ST_ExteriorRing(a.geom),  
                       ARRAY(SELECT ST_ExteriorRing(b.geom) inner_ring
                             FROM (SELECT (ST_DumpRings(geom)).*) b 
                             WHERE b.path[1] > 0 AND
                                   CASE WHEN minArea IS NULL OR minArea = 0 THEN FALSE ELSE TRUE END AND
                                   ST_Area(b.geom) >= minArea
                            )
                           ) final_geom
      FROM all_geoms a
    )
    SELECT ST_BuildArea(ST_Union(final_geom)) geom
    FROM polygons INTO returnGeom;

    RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
------------------------------------------------------------------------------
-- TT_TrimSubPolygons
--
-- Return only the biggest polygons from a multipolygon
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TrimSubPolygons(geometry, double precision);
CREATE OR REPLACE FUNCTION TT_TrimSubPolygons(
  inGeom geometry,
  minArea double precision DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    returnGeom geometry;
  BEGIN
    IF inGeom IS NULL OR ST_IsEmpty(inGeom) OR (ST_GeometryType(inGeom) != 'ST_Polygon' AND ST_GeometryType(inGeom) != 'ST_MultiPolygon') THEN
      RETURN inGeom;
    END IF;
    WITH all_geoms AS (
      SELECT ST_GeometryN(ST_Multi(inGeom), generate_series(1, ST_NumGeometries(ST_Multi(inGeom)))) AS geom
    )
    SELECT ST_Union(geom) geom
    FROM all_geoms
    WHERE ST_Area(geom) >= minArea INTO returnGeom;

    IF returnGeom IS NULL THEN
      RETURN ST_SetSRID('POLYGON EMPTY'::geometry, ST_SRID(inGeom));
    END IF;
    RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

------------------------------------------------------------------------------
-- TT_SuperUnion
--
-- ST_Union() all polygons in a two stage process 
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SuperUnion(name, name, name, text);
CREATE OR REPLACE FUNCTION TT_SuperUnion(
  schemaName name,
  tableName name,
  geomColumnName name,
  filterStr text DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    queryStr text;
    returnGeom geometry;
  BEGIN
    queryStr = 'WITH gridded AS (' ||
                  'SELECT TT_SplitByGrid(' || geomColumnName ||', 10000) split ' ||
                  'FROM ' || TT_FullTableName(schemaName, tableName) ||
                  CASE WHEN NOT filterStr IS NULL THEN ' WHERE ' || filterStr ELSE '' END ||
               '), first_level_union AS (' ||
                  'SELECT ST_Union((split).geom) geom ' ||
                  'FROM gridded ' ||
                  'GROUP BY (split).tid' ||
               ') ' ||
               'SELECT ST_Union(geom) geom ' ||
               'FROM first_level_union;';
    --RAISE NOTICE 'queryStr=%', queryStr;
    EXECUTE queryStr INTO returnGeom;
    RETURN returnGeom;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
-- Test
-- SELECT TT_SuperUnion('casfri50', 'geo_all', 'left(cas_id, 4) = ''SK03''');
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ProduceDerivedCoverages(text, geometry, double precision, boolean, double precision);
CREATE OR REPLACE FUNCTION TT_ProduceDerivedCoverages(
  fromInv text,
  detailedGeom geometry, 
  minArea double precision DEFAULT 10000000,
  sparse boolean DEFAULT FALSE,
  sparseBuf double precision DEFAULT 5000
)
RETURNS boolean AS $$
  DECLARE
    tableNameArr text[] = ARRAY['detailed', 'noholes', 'noislands', 'simplified', 'smoothed'];
    tableName text;
    queryStr text;
    outGeom geometry;
    noHolesGeom geometry;
    noIslandsGeom geometry;
    simplifiedGeom geometry;
    smoothedGeom geometry;
    cnt int;
  BEGIN
    noHolesGeom = TT_RemoveHoles(detailedGeom, minArea);
    noIslandsGeom = TT_TrimSubPolygons(noHolesGeom, minArea);
    simplifiedGeom = ST_SimplifyPreserveTopology(noIslandsGeom, 100);
    IF sparse THEN
      smoothedGeom = TT_TrimSubPolygons(TT_BufferedSmooth(simplifiedGeom, sparseBuf), minArea);
    ELSE
      smoothedGeom = TT_TrimSubPolygons(TT_BufferedSmooth(simplifiedGeom, 100), minArea);
    END IF;
    SELECT a.cnt FROM casfri50_coverage.inv_counts a WHERE inv = fromInv INTO cnt;
    FOREACH tableName IN ARRAY tableNameArr LOOP
      outGeom = CASE WHEN tableName = 'detailed' THEN detailedGeom
                     WHEN tableName = 'noholes' THEN noHolesGeom
                     WHEN tableName = 'noislands' THEN noIslandsGeom
                     WHEN tableName = 'simplified' THEN simplifiedGeom
                     WHEN tableName = 'smoothed' THEN smoothedGeom
                END;
      queryStr = 'CREATE TABLE IF NOT EXISTS casfri50_coverage.' || tableName || '
                 (inv text, nb_polys int, nb_points int, geom geometry);
                 DELETE FROM casfri50_coverage.' || tableName || '
                 WHERE inv = ''' || upper(fromInv) || ''';
                 INSERT INTO casfri50_coverage.' || tableName || ' (inv, nb_polys, nb_points, geom) VALUES ($2, $3, $4, $5);';
      EXECUTE queryStr USING tableName, upper(fromInv), cnt, ST_NPoints(outGeom), outGeom;
    END LOOP;
    RETURN TRUE;
  END
$$ LANGUAGE plpgsql VOLATILE;

------------------------------------------------------------------------------
-- TT_ProgressMsg()
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ProgressMsg(bigint, int, timestamptz);
CREATE OR REPLACE FUNCTION TT_ProgressMsg(
  currentRowNb bigint,
  expectedRowNb int,
  startTime timestamptz DEFAULT NULL
)
RETURNS text AS $$
  DECLARE
    msg text = '';
    percentDone numeric;
    remainingTime double precision;
    elapsedTime double precision;
  BEGIN
    percentDone = currentRowNb::numeric/expectedRowNb * 100;
    msg = currentRowNb || '/' || expectedRowNb || ' (' || round(percentDone, 2) || '%) processed';
    IF NOT startTime IS NULL THEN
      elapsedTime = EXTRACT(EPOCH FROM clock_timestamp() - startTime);
      remainingTime = ((100 - percentDone) * elapsedTime)/percentDone;
      msg = msg || ' - ' || TT_PrettyDuration(elapsedTime, 3) || ' elapsed, ' || TT_PrettyDuration(remainingTime, 3) || ' remaining';
    END IF;
    msg = msg || '...';
    RETURN msg;
  END;
$$ LANGUAGE plpgsql VOLATILE;

-- SELECT TT_ProgressMsg(1, 10, now())

------------------------------------------------------------------------------
-- TT_ProduceInvGeoHistory()
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ProduceInvGeoHistory(text, boolean, boolean);
CREATE OR REPLACE FUNCTION TT_ProduceInvGeoHistory(
  inv text,
  individualTables boolean DEFAULT FALSE,
  progress boolean DEFAULT TRUE
)
RETURNS boolean AS $$
  DECLARE
    queryStr text = '';
    seqName text;
    countQuery text;
    expectedRowNb int = 0;
    startTime timestamptz;
  BEGIN
    IF progress THEN
      countQuery = '
      SELECT count(*) 
      FROM casfri50_history.casflat_gridded
      WHERE inventory_id = ''' || inv || ''';';
      EXECUTE countQuery INTO expectedRowNb;

      RAISE NOTICE 'TT_ProduceInvGeoHistory() - % gridded polygon to process...', expectedRowNb;
      
      seqName = 'geohistory_' || lower(inv);
      queryStr = 'DROP SEQUENCE IF EXISTS ' || seqName || '_1;
      CREATE SEQUENCE ' || seqName || '_1 START 1;
      DROP SEQUENCE IF EXISTS ' || seqName || '_2;
      CREATE SEQUENCE ' || seqName || '_2 START 1;';
    END IF;
    startTime = clock_timestamp();
    
    IF individualTables THEN
      queryStr = queryStr || '
DROP TABLE IF EXISTS casfri50_history.' || lower(inv) || '_history;
CREATE TABLE casfri50_history.' || lower(inv) || '_history AS
';
    ELSE
      queryStr = '
INSERT INTO casfri50_history.geo_history
';
    END IF;
    queryStr = queryStr || '(WITH geohistory_gridded AS (
      SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, stand_photo_year, TRUE, geom,
                                   ''casfri50_history'', ''casflat_gridded'', ''cas_id'', ''geom'', ''stand_photo_year'', ''inventory_id'')).*
      FROM casfri50_history.casflat_gridded
      WHERE inventory_id = ''' || inv || '''';
      
    IF progress THEN
      queryStr = queryStr || ' AND CASE WHEN nextval(''' || seqName || '_1'') % 1000 = 0 THEN TT_PrintMessage(''' || inv || ' - TT_PolygonGeoHistory() - '' || TT_ProgressMsg(currval(''' || seqName || '_1''), $1, $2)) ELSE TRUE END';
    END IF;
    
    queryStr = queryStr || '
    ORDER BY id, poly_id
    ), wkb_version AS (
      SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
      FROM geohistory_gridded';
      
    IF progress THEN
      queryStr = queryStr || '
      WHERE CASE WHEN nextval(''' || seqName || '_2'') % 1000 = 0 THEN TT_PrintMessage(''' || inv || ' - TT_ValidYearUnion() - '' || TT_ProgressMsg(currval(''' || seqName || '_2''), $1)) ELSE TRUE END';
    END IF;

    queryStr = queryStr || '
      GROUP BY id
    )
    SELECT id cas_id, geom, lowerval valid_year_begin, upperval valid_year_end
    FROM wkb_version;';
    RAISE NOTICE 'queryStr = %', queryStr;
    EXECUTE queryStr USING expectedRowNb, startTime;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-------------------------------------------------------------------------------
-- TT_IntersectingArea()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_IntersectingArea(geometry, geometry);
CREATE OR REPLACE FUNCTION TT_IntersectingArea(
  geom1 geometry, 
  geom2 geometry,
  tolerance double precision DEFAULT 0.0000001
)
RETURNS double precision AS $$
  DECLARE
    area double precision;
  BEGIN
    area = ST_Area(ST_Intersection(ST_MakeValid(ST_SnapToGrid(geom1, tolerance)), ST_MakeValid(ST_SnapToGrid(geom2, tolerance))));
    RETURN area;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_GeoHistoryOverlaps()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_GeoHistoryOverlaps(geometry, geometry, boolean, double precision);
CREATE OR REPLACE FUNCTION TT_GeoHistoryOverlaps(
  geom1 geometry, 
  geom2 geometry,
  checkIntArea boolean DEFAULT FALSE,
  tolerance double precision DEFAULT 0.000001
)
RETURNS boolean AS $$
  DECLARE
    test boolean;
  BEGIN
    RETURN (ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2))
           AND (NOT checkIntArea OR TT_IntersectingArea(geom1, geom2) > tolerance);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
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
-- from prePoly.
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
--DROP FUNCTION IF EXISTS TT_PolygonGeoHistory(text, text, int, boolean, geometry, name, name, name, name, name, name, name[]);
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
    --debug_l2 boolean = true;
    debugID int = 0;

    ovlpPolyQuery text;

    currentRow RECORD;
    ovlpRow RECORD;

    refYearBegin int = 1930;
    refYearEnd int = 2030;
    smallestPolyArea double precision = 0.0001; -- 1 square cm
    safeDiffGridSize  double precision = 0.01; -- 1 cm
        
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
                          '($2 && ' || quote_ident(geoColName) || ' AND ' ||
                          'TT_GeoHistoryOverlaps(' || quote_ident(geoColName) || ', $2)) ' ||
                          'ORDER BY gh_photo_year;';
    IF debug_l2 THEN RAISE NOTICE E'000 ovlpPolyQuery = \n%\n', ovlpPolyQuery;END IF;
    
    time = clock_timestamp();
    IF debug_l2 THEN RAISE NOTICE 'Setting diffAttempts to 0...';END IF;
    diffAttempts = 0;

    IF debug_l2 THEN RAISE NOTICE 'Setting safeDiff to FALSE...';END IF;
    safeDiff = FALSE;
    -- Here we loop until a satistactory set of historical polygon has been computed first 
    -- using the unsafe version of ST_Difference() and then with a safe version of it
    WHILE diffAttempts < 2 LOOP
      BEGIN
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE '---------------------------------------------------------------';END IF;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE '000 processing polyID %. photo_year=%', poly_row_id, poly_photo_year;END IF;

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

        IF debug_l2 THEN
          wkb_geometry = preValidYearPoly;
          poly_type = 'debug_' || debugID || '_startingpoly_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
          debugID = debugID + 1;
          valid_year_begin = refYearBegin;
          valid_year_end = preValidYearPolyYearEnd;
          valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
          RAISE NOTICE '000 Debug_poly = %', left(poly_type, 50);
          RETURN NEXT;
        END IF;

        -- LOOP over all overlapping polygons sorted by photoYear ASC
        FOR ovlpRow IN EXECUTE ovlpPolyQuery 
        USING poly_row_id, poly_geom LOOP
          IF debug_l2 THEN RAISE NOTICE '---------------------------';END IF;
          IF debug_l1 THEN RAISE NOTICE 'Processing overlapping polygon %', ovlpRow.gh_row_id;END IF;
          IF debug_l2 THEN RAISE NOTICE '111 ovlp poly id=%, py=%, inv=%, isvalid=%', ovlpRow.gh_row_id, ovlpRow.gh_photo_year, ovlpRow.gh_inv, ovlpRow.gh_is_valid;END IF;
          IF debug_l2 THEN RAISE NOTICE '111 ovlp_area=%', ST_Area(ST_Intersection(poly_geom, ovlpRow.gh_geom));END IF;

          -----------------------------------------------------------
          -- CASE B - (A - B) RefYB -> RefYE (see logic table above)
          -----------------------------------------------------------
          hasPrecedence = TT_HasPrecedence(poly_inv, poly_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id, true, true);
          IF debug_l2 THEN RAISE NOTICE E'111 hasPrecedence = %\n', hasPrecedence;END IF;
         
          IF (ovlpRow.gh_photo_year = poly_photo_year AND 
             ((hasPrecedence AND NOT poly_is_valid AND ovlpRow.gh_is_valid) OR
             (NOT hasPrecedence AND (NOT poly_is_valid OR (poly_is_valid AND ovlpRow.gh_is_valid))))) OR
             (ovlpRow.gh_photo_year < poly_photo_year AND NOT poly_is_valid AND ovlpRow.gh_is_valid) OR
             (ovlpRow.gh_photo_year > poly_photo_year AND NOT poly_is_valid) THEN
            IF debug_l2 THEN RAISE NOTICE 'AAA.1 CASE SAME YEAR: Remove ovlpPoly from prePoly. ovlp.py = %', ovlpRow.gh_photo_year;END IF;

            preValidYearPoly = TT_SafeDifference(preValidYearPoly, ovlpRow.gh_geom, safeDiffGridSize, 'preValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
            preValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(preValidYearPoly, 3), smallestPolyArea));
            IF debug_l2 THEN
              wkb_geometry = preValidYearPoly;
              poly_type = 'debug_' || debugID || '_preValid_666_same_year_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
              debugID = debugID + 1;
              valid_year_begin = refYearBegin;
              valid_year_end = preValidYearPolyYearEnd;
              valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
              RAISE NOTICE 'AAA.2 Debug_poly = %', left(poly_type, 50);
              RETURN NEXT;
            END IF;

            IF postValidYearPoly IS NOT NULL THEN
              postValidYearPoly = TT_SafeDifference(postValidYearPoly, ovlpRow.gh_geom, safeDiffGridSize, 'postValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
              postValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
              IF debug_l2 THEN
                wkb_geometry = postValidYearPoly;
                poly_type = 'debug_' || debugID || '_postValid_666_same_year_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
                debugID = debugID + 1;
                valid_year_begin = postValidYearPolyYearBegin;
                valid_year_end = refYearEnd;
                valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
                RAISE NOTICE 'AAA.3 Debug_poly = %', left(poly_type, 50);
                RETURN NEXT;
              END IF;
            END IF;

            IF debug_l2 THEN RAISE NOTICE 'AAA CASE SAME YEAR Done';END IF;

          -----------------------------------------------------------
          -- CASE C - (A - B) RefYB -> AY - 1 and A AY -> RefYE (see logic table above)
          -----------------------------------------------------------
          ELSIF ovlpRow.gh_photo_year < poly_photo_year AND poly_is_valid AND ovlpRow.gh_is_valid THEN
            IF debug_l2 THEN RAISE NOTICE 'CCC CASE 2: Initialize postPoly and remove ovlpPoly from prePoly. ovlp.py = %', ovlpRow.gh_photo_year;END IF;

            postValidYearPoly = coalesce(postValidYearPoly, preValidYearPoly);
            postValidYearPolyYearBegin = poly_photo_year;
            
            preValidYearPoly = TT_SafeDifference(preValidYearPoly, ovlpRow.gh_geom, safeDiffGridSize, 'preValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
            preValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(preValidYearPoly, 3), smallestPolyArea));
            preValidYearPolyYearEnd = poly_photo_year - 1;

            IF debug_l2 THEN
              wkb_geometry = preValidYearPoly;
              poly_type = 'debug_' || debugID || '_preValid_777_case_2_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
              debugID = debugID + 1;
              valid_year_begin = refYearBegin;
              valid_year_end = preValidYearPolyYearEnd;
              valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
              RAISE NOTICE 'CCC Debug_poly = %', left(poly_type, 50);
              RETURN NEXT;
            END IF;
            IF debug_l2 THEN RAISE NOTICE 'CCC CASE 2 Done';END IF;
          -----------------------------------------------------------
          -- CASE D - A RefYB -> BY - 1 and (A - B) BY -> RefYE (see logic table above)
          -----------------------------------------------------------
          ELSIF ovlpRow.gh_photo_year > poly_photo_year AND poly_is_valid AND ovlpRow.gh_is_valid THEN
            IF debug_l2 THEN RAISE NOTICE 'DDD CASE 3: Return intermediate postPoly and set the next one by removing ovlpPoly. ovlp.ph = %', ovlpRow.gh_photo_year;END IF;

            -- Make sure the last computed polygon still intersect with ovlpPoly
            IF TT_GeoHistoryOverlaps(ovlpRow.gh_geom, coalesce(postValidYearPoly, preValidYearPoly)) THEN
              IF oldOvlpPolyYear IS NOT NULL AND oldOvlpPolyYear != ovlpRow.gh_photo_year AND postValidYearPoly IS NOT NULL THEN
                poly_id = poly_id + 1;
                wkb_geometry = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
                IF wkb_geometry IS NOT NULL AND NOT ST_IsEmpty(wkb_geometry) AND ST_Area(wkb_geometry) > smallestPolyArea THEN
                  poly_type = '2_post_1';
                  valid_year_begin = postValidYearPolyYearBegin;
                  valid_year_end = ovlpRow.gh_photo_year - 1;
                  valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
                  IF debug_l2 THEN RAISE NOTICE '---------';END IF;
                  IF debug_l2 THEN RAISE NOTICE 'RETURNING INTERMEDIATE postPoly valid_time=%', valid_time;END IF;
                  IF debug_l2 THEN RAISE NOTICE '---------';END IF;
                  RETURN NEXT;
                ELSE
                  IF debug_l2 THEN RAISE NOTICE 'DDD: postPoly is too small. No INTERMEDIATE postPoly RETURNED';END IF;
                END IF;
              ELSE
                IF debug_l2 THEN RAISE NOTICE 'DDD: (oldOvlpPolyYear IS NULL) = %', oldOvlpPolyYear IS NULL;END IF;
                IF debug_l2 THEN RAISE NOTICE 'DDD: (oldOvlpPolyYear = ovlpRow.gh_photo_year) = %', oldOvlpPolyYear = ovlpRow.gh_photo_year;END IF;
                IF debug_l2 THEN RAISE NOTICE 'DDD: (postValidYearPoly IS NULL) = %', postValidYearPoly IS NULL;END IF;
                IF debug_l2 THEN RAISE NOTICE 'DDD: No INTERMEDIATE postPoly RETURNED';END IF;
              END IF;

              postValidYearPoly = TT_SafeDifference(coalesce(postValidYearPoly, preValidYearPoly), ovlpRow.gh_geom, safeDiffGridSize, 'coalesce(postValidYearPoly, preValidYearPoly) from ' || poly_row_id, ovlpRow.gh_row_id, safeDiff);
              postValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
              
              postValidYearPolyYearBegin = ovlpRow.gh_photo_year;
              IF debug_l2 THEN
                wkb_geometry = postValidYearPoly;
                poly_type = 'debug_' || debugID || '_postValid_888_case_3_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
                debugID = debugID + 1;
                valid_year_begin = postValidYearPolyYearBegin;
                valid_year_end = refYearEnd;
                valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
                RAISE NOTICE 'DDD: Debug_poly = %', left(poly_type, 50);
                RETURN NEXT;
              END IF;
              preValidYearPolyYearEnd = least(preValidYearPolyYearEnd, ovlpRow.gh_photo_year - 1);
            ELSE
              IF debug_l2 THEN RAISE NOTICE 'DDD: TT_GeoHistoryOverlaps() is FALSE';END IF;
            END IF;
            IF debug_l2 THEN RAISE NOTICE 'DDD CASE 3 Done';END IF;
          END IF;
          oldOvlpPolyYear = ovlpRow.gh_photo_year;
        END LOOP;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'Setting diffAttempts to 2...';END IF;
        diffAttempts = 2;
      EXCEPTION WHEN OTHERS THEN
        IF diffAttempts = 1 THEN RAISE EXCEPTION 'TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on %...', poly_row_id;END IF;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'Setting diffAttempts to 1...';END IF;
        diffAttempts = 1;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'Setting safeDiff to TRUE...';END IF;
        safeDiff = TRUE;
      END;
    END LOOP; -- WHILE
    
    IF debug_l2 THEN RAISE NOTICE '---------';END IF;
    ---------------------------------------------------------------------------
    -- Return the last new polygon (newestPoly, oldCurrentYear, ovlpPoly.photoYear)
    ---------------------------------------------------------------------------
    IF NOT ST_IsEmpty(postValidYearPoly) THEN
      poly_id = poly_id + 1;
      wkb_geometry = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
      IF NOT wkb_geometry IS NULL AND NOT ST_IsEmpty(wkb_geometry) AND ST_Area(wkb_geometry) > smallestPolyArea THEN

        poly_type = '2_post_2';
        valid_year_begin = postValidYearPolyYearBegin;
        valid_year_end = refYearEnd;
        valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
        IF debug_l2 THEN RAISE NOTICE 'RETURNING FINAL postPoly valid_time=%', valid_time;END IF;
        RETURN NEXT;
      END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- Return the current polygon (olderPoly, refYearBegin, currentPoly.photoYear - 1))
    ---------------------------------------------------------------------------
    IF NOT ST_IsEmpty(preValidYearPoly) THEN
      poly_id = poly_id + 1;
      wkb_geometry = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(preValidYearPoly, 3), smallestPolyArea));
      IF NOT wkb_geometry IS NULL AND NOT ST_IsEmpty(wkb_geometry) AND ST_Area(wkb_geometry) > smallestPolyArea THEN
        poly_type = '1_pre';
        valid_year_begin = refYearBegin;
        valid_year_end = preValidYearPolyYearEnd;
        valid_time = id || '_' || valid_year_begin || '-' || valid_year_end;
        IF debug_l2 THEN RAISE NOTICE 'RETURNING prePoly valid_time=%', valid_time;END IF;
        RETURN NEXT;
      END IF;
    END IF;
    IF debug_l1 OR debug_l2 THEN RAISE NOTICE  'TOOK % SECONDS', EXTRACT(EPOCH FROM clock_timestamp() - time);END IF;
  END
$$ LANGUAGE plpgsql VOLATILE;

--DROP FUNCTION IF EXISTS TT_PolygonGeoHistory(text, text, geometry, name, name, name, name, name, name, name[]);
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
--DROP FUNCTION IF EXISTS TT_TableGeoHistory(name, name, name, name, name, name, name[]);
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
--DROP FUNCTION IF EXISTS TT_GeoOblique(geometry, int, double precision, double precision);
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
--DROP FUNCTION IF EXISTS TT_GeoHistoryOblique(name, name, name, name, name, text, text[], double precision, double precision);
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
$$ LANGUAGE sql IMMUTABLE;