------------------------------------------------------------------------------
-- CASFRI - Geo history functions script for CASFRI v5
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
-------------------------------------------------------------------------------
-- Debug configuration variable. Set tt.debug to TRUE to display all RAISE NOTICE
SET tt.debug_l1 TO FALSE;
SET tt.debug_l2 TO FALSE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_AreasForSignificantYearsDebugQuery()
--
-- Generate a query helping to debug overlap problems in geo history tables.
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

-------------------------------------------------------------------------------
-- TT_AreasForSignificantYears()
--
-- Compare the unioned area with the sum of areas for significant year (DISTINCT 
-- years of begin and end validity) of a test geo history table.
-- 
-- When area_diff_in_sq_meters is close to 0, the geo history table was properly 
-- generated (no overlaps in space and time).
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
-- This function is useful to parallelize some queries.
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
    intgeom geometry;
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
        env = ST_MakeEnvelope(xminrounded + (x - 1) * xgridsize, 
                              yminrounded + (y - 1) * ygridsize, 
                              xminrounded + x * xgridsize, 
                              yminrounded + y * ygridsize, 
                              ST_SRID(ingeom)
        );
        IF ST_Intersects(env, ingeom) THEN
          intgeom = ST_Intersection(ingeom, env);
          IF ST_Dimension(intgeom) = ST_Dimension(ingeom) OR
             ST_GeometryType(intgeom) = ST_GeometryType(ingeom) THEN
            geom = intgeom;
            tid = ((xfloor::int8 + x) * 10000000 + (yfloor::int8 + y))::int8;
            tx = xfloor + x;
            ty = yfloor + y;
            tgeom = env;
            RETURN NEXT;
          END IF;
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

-- Debug version of TT_SplitByGrid. Not parallel safe and with RAISE NOTICE for debugging purposes.
--DROP FUNCTION IF EXISTS TT_SplitByGridDebug(text, geometry, double precision, double precision, double precision, double precision);
CREATE OR REPLACE FUNCTION TT_SplitByGridDebug(
  id text,
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
    intgeom geometry;
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
      --RAISE NOTICE 'Defaulting xgridsize to 1...';
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
        BEGIN
          IF ST_Intersects(env, ingeom) THEN
            intgeom = ST_Intersection(ingeom, env);
            IF ST_Dimension(intgeom) = ST_Dimension(ingeom) OR
               ST_GeometryType(intgeom) = ST_GeometryType(ingeom) THEN
              geom = intgeom;
              tid = ((xfloor::int8 + x) * 10000000 + (yfloor::int8 + y))::int8;
              tx = xfloor + x;
              ty = yfloor + y;
              tgeom = env;
              RETURN NEXT;
            END IF;
          END IF;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SplitByGridDebug() ST_Intersects() failed on cas_id=''%''', id;
        END;
      END LOOP;
    END LOOP;
  RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE PARALLEL UNSAFE;
/*
SELECT * FROM TT_SplitByGridDebug('1', ST_Buffer(ST_MakePoint(0, 0), 100), 100);
SELECT * FROM TT_SplitByGridDebug('2', NULL::geometry, 10);
*/
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_RandomPoints
--
--   geom geometry - Geometry in which to create the random points. Should be a
--                   polygon or a multipolygon.
--   nb int        - Number of random points to create.
--   seed numeric  - Value between -1.0 and 1.0, inclusive, setting the seek if
--                   repeatable results are desired. Default to NULL.
--
--   RETURNS SET OF geometry(point)
--
-- Generates points located randomly inside a geometry.
-----------------------------------------------------------
-- Self contained example creating 100 points:
--
-- SELECT TT_RandomPoints(ST_GeomFromText('POLYGON((-73 48,-72 49,-71 48,-69 49,-69 48,-71 47,-73 48))'), 1000, 0.5) geom;
--
-- Typical example creating a table of 1000 points inside the union of all the
-- geometries of a table:
--
-- CREATE TABLE random_points AS
-- SELECT TT_RandomPoints(ST_Union(geom), 1000) geom FROM geomtable;
-----------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RandomPoints(geometry, integer, numeric);
CREATE OR REPLACE FUNCTION TT_RandomPoints(
  geom geometry,
  nb integer,
  seed numeric DEFAULT NULL
)
RETURNS SETOF geometry AS $$
  DECLARE
    pt geometry;
    xmin float8;
    xmax float8;
    ymin float8;
    ymax float8;
    xrange float8;
    yrange float8;
    srid int;
    count integer := 0;
    gtype text;
  BEGIN
    SELECT ST_GeometryType(geom) INTO gtype;

    -- Make sure the geometry is some kind of polygon
    IF (gtype IS NULL OR (gtype != 'ST_Polygon') AND (gtype != 'ST_MultiPolygon')) THEN
      RAISE NOTICE 'Attempting to get random points in a non polygon geometry';
      RETURN NEXT NULL;
      RETURN;
    END IF;

    -- Compute the extent
    SELECT ST_XMin(geom), ST_XMax(geom), ST_YMin(geom), ST_YMax(geom), ST_SRID(geom)
    INTO xmin, xmax, ymin, ymax, srid;

    -- and the range of the extent
    SELECT xmax - xmin, ymax - ymin
    INTO xrange, yrange;

    -- Set the seed if provided
    IF seed IS NOT NULL THEN
      PERFORM setseed(seed);
    END IF;

    -- Find valid points one after the other checking if they are inside the polygon
    WHILE count < nb LOOP
      SELECT ST_SetSRID(ST_MakePoint(xmin + xrange * random(), ymin + yrange * random()), srid)
      INTO pt;

      IF ST_Contains(geom, pt) THEN
        count := count + 1;
        RETURN NEXT pt;
      END IF;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_GeneratePoints
--
-- Same as ST_GeneratePoints() but taking a NULL seed
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_GeneratePoints(geometry, int, int);
CREATE OR REPLACE FUNCTION TT_GeneratePoints(
  geom geometry,
  nbPoints int DEFAULT 1,
  seed int DEFAULT NULL
)
RETURNS geometry AS $$
  SELECT CASE WHEN seed IS NULL THEN 
                   ST_GeneratePoints(geom, nbPoints) 
              ELSE ST_GeneratePoints(geom, nbPoints, seed)
         END;
$$ LANGUAGE sql VOLATILE;
/*
SELECT TT_GeneratePoints(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 5)
SELECT TT_GeneratePoints(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 5, NULL)
*/
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_RandomBuffer
--
-- Create a random buffer inside a (multi)polygon
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_RandomBuffer(geometry, double precision, int, int);
CREATE OR REPLACE FUNCTION TT_RandomBuffer(
  mainGeom geometry,
  buffSize double precision DEFAULT 0,
  nbAttempts int DEFAULT 100,
  seed int DEFAULT NULL
)
RETURNS geometry AS $$
  WITH attempts AS (
    SELECT generate_series(1, nbAttempts) n
  ), buffers AS (
    SELECT CASE WHEN buffSize = 0 THEN
                     ST_GeometryN(TT_GeneratePoints(mainGeom, 1, seed), 1)
                ELSE ST_Buffer(ST_GeometryN(TT_GeneratePoints(ST_Buffer(mainGeom, -buffSize), 1, seed), 1), buffSize)
           END geom
    FROM attempts
  )
  SELECT geom
  FROM buffers
  WHERE ST_Contains(mainGeom, geom)
  LIMIT 1
$$ LANGUAGE sql VOLATILE;
/*
-- tests
SELECT TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 100000) - ok
SELECT TT_RandomBuffer(NULL, 100000) -- NULL geometry RETURNS NULL
SELECT TT_RandomBuffer(ST_SetSRID(ST_Point(10, 20), 900914), 100000) -- point geometry RETURNS NULL
SELECT TT_RandomBuffer(ST_SetSRID(ST_GeomFromText('POLYGON EMPTY'), 900914), 100000) -- POLYGON EMPTY geometry RETURNS NULL
SELECT TT_RandomBuffer(ST_SetSRID(ST_MakeLine(ST_MakePoint(10, 20), ST_MakePoint(30, 40)), 900914), 100000) -- line geometry RETURNS NULL
SELECT TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_Point(10, 20), 900914), 0), 100000) -- POLYGON EMPTY polygons RETURNS NULL
SELECT TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 100000) -- ok
SELECT TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), -1) -- negative buffSize RETURNS NULL
SELECT TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 100000, 0) -- 0 nbAttempts RETURNS NULL
SELECT ST_AsText(TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 0)) -- ok
SELECT TT_RandomBuffer(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 200000), 100000) -- ok
*/
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_NRandomBuffers
--
-- Create n random buffers inside a (multi)polygon
------------------------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_NRandomBuffers(geometry, int, double precision, int, int);
CREATE OR REPLACE FUNCTION TT_NRandomBuffers(
  mainGeom geometry,
  nbBuffers int DEFAULT 1,
  buffSize double precision DEFAULT 0,
  nbAttempts int DEFAULT 100,
  seed int DEFAULT NULL
)
RETURNS SETOF geometry AS $$
  DECLARE
    n int := 0;
    failed boolean := FALSE;
    buffer geometry := ST_SetSRID(ST_GeomFromText('POLYGON EMPTY'), ST_SRID(mainGeom));
  BEGIN
    IF mainGeom IS NULL THEN
      RAISE NOTICE 'TT_NRandomBuffers() - ERROR: mainGeom is NULL. Please provide a valid polygon...';
      RETURN;
    END IF;
    IF NOT ST_GeometryType(mainGeom) IN ('ST_Polygon', 'ST_MultiPolygon') THEN
      RAISE NOTICE 'TT_NRandomBuffers() - ERROR: mainGeom is not a (multi)polygon. Please provide a valid polygon...';
      RETURN;
    END IF;
    IF ST_Area(mainGeom) = 0 THEN
      RAISE NOTICE 'TT_NRandomBuffers() - ERROR: mainGeom is empty. Please provide a valid polygon...';
      RETURN;
    END IF;
    IF nbBuffers < 1 THEN
      RAISE NOTICE 'TT_NRandomBuffers() - ERROR: nbBuffers is smaller than 1. Please provide a positive value...';
      RETURN;
    END IF;
    IF buffSize < 0 THEN
      RAISE NOTICE 'TT_NRandomBuffers() - ERROR: buffSize is smaller than 0. Please provide a positive value...';
      RETURN;
    END IF;
    IF nbAttempts < 1 THEN
      RAISE NOTICE 'TT_NRandomBuffers() - ERROR: nbAttempts is smaller than 1. Please provide a positive value...';
      RETURN;
    END IF;
    PERFORM setseed(seed/2147483647::numeric);
    WHILE n < nbBuffers AND NOT buffer IS NULL LOOP
      mainGeom := ST_Difference(mainGeom, buffer);
      --RETURN NEXT mainGeom;
      buffer := TT_RandomBuffer(mainGeom, buffSize, nbAttempts, floor(random() * 2147483647)::int);
      --IF buffer IS NULL THEN RAISE NOTICE 'TT_NRandomBuffers() - buffer % is NULL', n; END IF;
      IF NOT buffer IS NULL THEN
        RETURN NEXT buffer;
        n := n + 1;     
      END IF;
    END LOOP;
    IF n < nbBuffers THEN RAISE NOTICE 'TT_NRandomBuffers() - Could produce only % buffers on %. Consider increasing the number of attempts (now %) or providing a smaller buffer size (now %)...', n, nbBuffers, nbAttempts, buffSize; END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql VOLATILE;
/*
-- tests
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 5, 100000);
SELECT TT_NRandomBuffers(NULL, 5, 100000);
SELECT TT_NRandomBuffers(ST_SetSRID(ST_Point(10, 20), 900914), 5, 100000);
SELECT TT_NRandomBuffers(ST_SetSRID(ST_GeomFromText('POLYGON EMPTY'), 900914), 5, 100000);
SELECT TT_NRandomBuffers(ST_SetSRID(ST_MakeLine(ST_MakePoint(10, 20), ST_MakePoint(30, 40)), 900914), 5, 100000);
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_Point(10, 20), 900914), 0), 5, 100000);
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 0, 100000);
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 2, -1);
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 2, 100000, 0);
SELECT ST_AsText(TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 2, 0));
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 200000), 5, 100000);
SELECT TT_NRandomBuffers(ST_Buffer(ST_SetSRID(ST_MakePoint(-100000, 1550000), 900914), 400000), 5, 100000, 100, 123);
*/
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_ExtractNRandomBuffers
--
-- Extract n random buffers for an inventory
----------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ExtractNRandomBuffers(text[], name, name, int, double precision, boolean, int, int, text, boolean);
CREATE OR REPLACE FUNCTION TT_ExtractNRandomBuffers(
  invArr text[],
  schemaName name DEFAULT 'casfri50',
  tableName name DEFAULT 'geo_all',
  nbBuffers int DEFAULT 1,
  buffSize double precision DEFAULT 0,
  trimToBuffer boolean DEFAULT FALSE,
  nbAttempts int DEFAULT 100,
  seed int DEFAULT NULL,
  whereClause text DEFAULT NULL,
  limitToInv boolean DEFAULT TRUE
)
RETURNS TABLE (cas_id text, geom geometry) AS $$
  DECLARE
    queryStr text;
    attArr text[];
    geomColumnName text;
    attList text;
  BEGIN
    IF NOT TT_TableExists(schemaName, tableName) THEN
      RAISE EXCEPTION 'TT_ExtractNRandomBuffers() - Table %.% does not exists...', schemaName, tableName;
    END IF;
    IF array_length(invArr, 1) = 0 THEN
      RAISE EXCEPTION 'TT_ExtractNRandomBuffers() - invList is empty...';
    END IF;
    -- try to identify the geometry column name automatically (it must just contain 'geom')
    attArr := TT_TableColumnNames(schemaName, tableName);
    geomColumnName := (regexp_match(array_to_string(attArr, ','), '([^,]*geom[^,]*)'))[1];
    RAISE NOTICE 'TT_ExtractNRandomBuffers() - geomColumnName = %', geomColumnName;
    queryStr := format('
WITH coverage AS (
  SELECT inv, geom
  FROM casfri50_coverage.simplified
  WHERE upper(inv) = ANY($1)
), buffers AS (
  SELECT TT_NRandomBuffers(geom, %1$s, %2$s, %3$s, %4$s) geometry
  FROM coverage
)
SELECT g.cas_id, g.%8$I
FROM %5$I.%6$I g, buffers b
WHERE %7$sST_Intersects(g.%8$I, b.geometry)%9$s', 
      nbBuffers, 
      buffsize,
      nbAttempts,
      coalesce(seed::text, 'NULL'),
      schemaName, 
      tableName,
      CASE WHEN limitToInv THEN 'left(g.cas_id, 4) = ANY($1) AND ' ELSE '' END,
      geomColumnName, 
      CASE WHEN whereClause IS NULL OR whereClause = '' THEN ';' ELSE ' AND ' || whereClause || ';' END
    );
    IF trimToBuffer THEN
      queryStr := replace(queryStr, ', g.' || geomColumnName, format(', ST_Intersection(g.%I, b.geometry) geom', geomColumnName));
    END IF;
    RAISE NOTICE 'queryStr=%', replace(queryStr, '$1', 'ARRAY[' || array_to_string(ARRAY(SELECT quote_literal(x) FROM unnest(invArr) AS t(x)), ',') || ']');
    RETURN QUERY EXECUTE queryStr USING invArr;
  END;
$$ LANGUAGE 'plpgsql' VOLATILE;

/*
-- tests
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'])).*;
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded')).*;
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5)).*; 
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5, 2000)).*; 
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5, 2000, TRUE)).*;
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5, 2000, TRUE, 10, 123)).*;
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5, 2000, TRUE, 10, 123, 'left(cas_id, 4) = ''MB05''')).*;
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5, 2000, TRUE, 10, 123, '', TRUE)).*;
SELECT (TT_ExtractNRandomBuffers(ARRAY['MB05'], 'casfri50_history', 'casflat_gridded', 5, 2000, TRUE, 10, 123, '', FALSE)).*;
*/
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_ExtractNRandomGeoHistoryBuffers
--
-- Simplify a polygon by adding and removing a buffer around it
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ExtractNRandomGeoHistoryBuffers(text[], int, int, double precision, boolean, int, int);
CREATE OR REPLACE FUNCTION TT_ExtractNRandomGeoHistoryBuffers(
  inv text[],
  year int,
  nbBuffers int DEFAULT 1,
  buffSize double precision DEFAULT 0,
  trimToBuffer boolean DEFAULT FALSE,
  nbAttempts int DEFAULT 100,
  seed int DEFAULT NULL
)
RETURNS TABLE (cas_id text, geom geometry) AS $$
  DECLARE
    queryStr text;
  BEGIN
    queryStr := format('
SELECT (TT_ExtractNRandomBuffers($1, ''casfri50_history'', ''geo_history'', 
                                %1$s, %2$s, %3$s, %4$s, %5$s, 
                                ''valid_year_begin <= %6$s AND %6$s <= valid_year_end'', FALSE)).*;
', nbBuffers, buffSize, trimToBuffer::text, nbAttempts, coalesce(seed::text, 'NULL'), year);
    RAISE NOTICE 'queryStr=%', queryStr;
    RETURN QUERY EXECUTE queryStr USING inv;
  END;
$$ LANGUAGE plpgsql VOLATILE;
/*
--  tests
SELECT count(*) cnt
FROM casfri50_history.geo_history
WHERE left(cas_id, 4) = 'BC08';

SELECT min(valid_year_begin) min_valid_year_begin, 
       max(valid_year_end) min_valid_year_end
FROM casfri50_history.geo_history
WHERE left(cas_id, 4) = 'BC08';

SELECT (TT_ExtractNRandomGeoHistoryBuffers(ARRAY['BC08'], 2010)).*;
SELECT (TT_ExtractNRandomGeoHistoryBuffers(ARRAY['BC08'], 2010, 100, 0, FALSE, 100, 110)).*;
SELECT (TT_ExtractNRandomGeoHistoryBuffers(ARRAY['BC08'], 2010, 3, 10000, TRUE, 100, 110)).*;

*/
-------------------------------------------------------------------------------

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
-------------------------------------------------------------------------------

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
-------------------------------------------------------------------------------

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
    --RAISE NOTICE 'TT_RemoveHoles() : START...';

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
    
    --RAISE NOTICE 'TT_RemoveHoles() : END Geometry has now % points...', ST_NPoints(returnGeom);

    RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_TrimSubPolygons
--
-- Return only the biggest polygons from a multipolygon
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_TrimSubPolygons(geometry, double precision);
CREATE OR REPLACE FUNCTION TT_TrimSubPolygons(
  inGeom geometry,
  minArea double precision DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    returnGeom geometry;
  BEGIN
    --RAISE NOTICE 'TT_TrimSubPolygons() : START...';

    IF inGeom IS NULL OR ST_IsEmpty(inGeom) OR (ST_GeometryType(inGeom) != 'ST_Polygon' AND ST_GeometryType(inGeom) != 'ST_MultiPolygon') THEN
      RETURN inGeom;
    END IF;

    --RAISE NOTICE 'TT_TrimSubPolygons() : 111...';

    WITH all_geoms AS (
      SELECT ST_GeometryN(ST_Multi(inGeom), generate_series(1, ST_NumGeometries(ST_Multi(inGeom)))) AS geom
    )
    SELECT ST_Union(geom) geom
    FROM all_geoms
    WHERE ST_Area(geom) >= minArea INTO returnGeom;

    --RAISE NOTICE 'TT_TrimSubPolygons() : 222...';

    IF returnGeom IS NULL THEN
      --RAISE NOTICE 'TT_TrimSubPolygons() : 333...';
      RETURN ST_SetSRID('POLYGON EMPTY'::geometry, ST_SRID(inGeom));
    END IF;

    --RAISE NOTICE 'TT_TrimSubPolygons() : END Geometry has now % points...', ST_NPoints(returnGeom);

    RETURN returnGeom;
  END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_SuperUnion
--
-- ST_Union() all polygons in a two stage process 
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SuperUnion(name, name, name, text, boolean, int, boolean);
CREATE OR REPLACE FUNCTION TT_SuperUnion(
  schemaName name,
  tableName name,
  geomColumnName name,
  filterStr text DEFAULT NULL,
  alreadyGridded boolean DEFAULT TRUE,
  gridSize int DEFAULT 10000,
  progress boolean DEFAULT TRUE
)
RETURNS geometry AS $$
  DECLARE
    queryStr text := '';
    countQuery text := '';
    seqName text := '';
    expectedGroupNb int = 0;
    startTime timestamptz;
    returnGeom geometry;
  BEGIN
    IF filterStr IS NULL THEN 
      filterStr := '';
      RAISE NOTICE 'TT_SuperUnion() : START with no filterStr...';
    ELSE
      filterStr := format('
  WHERE %s', filterStr);
      RAISE NOTICE 'TT_SuperUnion() : START with ''%''...', filterStr;
    END IF;
 
    IF alreadyGridded THEN
      -- For now, we implemented progress only for the alreadyGridded case because it is the previleged method and
      -- the implementation for the non alreadyGridded case is very different (count has to be generated inside the CTE).
      IF progress THEN
        countQuery = format('
SELECT count(DISTINCT tid)
FROM %1$I.%2$I%3$s;', schemaName, tableName, filterStr);

        RAISE NOTICE 'TT_SuperUnion() - Counting the number of groups of gridded polygons to process from casfri50_history.casflat_gridded in order to display progress...';
        EXECUTE countQuery INTO expectedGroupNb;

        RAISE NOTICE 'TT_SuperUnion() - % groups of gridded polygons to process...', expectedGroupNb;
        seqName = 'superunion_' || floor(random() * 100000) + 1;

        queryStr = format('
DROP SEQUENCE IF EXISTS %1$s_1;
CREATE SEQUENCE %1$s_1 START 1;
DROP SEQUENCE IF EXISTS %1$s_2;
CREATE SEQUENCE %1$s_2 START 1;', seqName);
      END IF;

      queryStr := queryStr || format('
WITH first_level_union AS (
  SELECT tid, 
         ST_Union(%1$I) geom', geomColumnName);

      IF progress THEN
        queryStr := queryStr || format(',
         CASE WHEN nextval(%1$L) %% 1000 = 0 OR currval(%1$L) = %2$s THEN TT_PrintMessage(''TT_SuperUnion(1st level) - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) ELSE TRUE END', seqName || '_1', expectedGroupNb);
      END IF;

      queryStr := queryStr || format('
  FROM %1$I.%2$I%3$s
  GROUP BY tid
)
SELECT ST_Union(geom ORDER BY tid)', schemaName, tableName, filterStr);

      IF progress THEN
        queryStr := queryStr || format(',
       CASE WHEN nextval(%1$L) %% 10 = 0 OR currval(%1$L) = %2$s THEN TT_PrintMessage(''TT_SuperUnion(2nd level) - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) ELSE TRUE END', seqName || '_2', expectedGroupNb);
      END IF;

      queryStr := queryStr || ' 
FROM first_level_union;';
    ELSE
      queryStr = format('
WITH gridded AS (
  SELECT TT_SplitByGrid(%1$I, %5$s) split 
  FROM %2$I.%3$I%4$s
), first_level_union AS (
  SELECT (split).tid, ST_Union((split).geom) geom
  FROM gridded
  GROUP BY (split).tid
)
SELECT ST_Union(geom ORDER BY tid) geom 
FROM first_level_union;', geomColumnName, schemaName, tableName, filterStrs, gridSize);
    END IF;

    startTime = clock_timestamp();
    RAISE NOTICE 'queryStr = %', replace(queryStr, '$1', quote_literal(startTime::text) || '::timestamptz');
    EXECUTE queryStr INTO returnGeom USING startTime;
    
    RAISE NOTICE 'TT_SuperUnion() : END Geometry has now % points...', ST_NPoints(returnGeom);

    RETURN returnGeom;
  END
$$ LANGUAGE plpgsql VOLATILE;
-- Test
/*
SELECT TT_SuperUnion('casfri50', 'geo_all', 'left(cas_id, 4) = ''SK03''');
SELECT TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = upper(''PC01'')', FALSE, 100000);
SELECT TT_SuperUnion('casfri50_history', 'casflat_gridded', 'geom', 'inventory_id = upper(''PC01'')', TRUE);
*/

------------------------------------------------------------------------------
-- TT_InvSuperUnion
--
-- ST_Union() all polygons of an inventory in a two stage process 
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_InvSuperUnion(text, boolean);
CREATE OR REPLACE FUNCTION TT_InvSuperUnion(
  inv text,
  alreadyGridded boolean DEFAULT TRUE
)
RETURNS geometry AS $$
  SELECT CASE WHEN alreadyGridded THEN TT_SuperUnion('casfri50_history'::name, 'casflat_gridded'::name, 'geom'::name, 'inventory_id = upper(''' || inv || ''')', TRUE)
              ELSE TT_SuperUnion('casfri50'::name, 'geo_all'::name, 'geometry'::name, 'left(cas_id, 4) = upper(''' || inv || ''')', FALSE)
         END
$$ LANGUAGE sql STABLE;
-- SELECT TT_InvSuperUnion('PC01');
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SuperUnionDebug(name, name, name, name, text);
CREATE OR REPLACE FUNCTION TT_SuperUnionDebug(
  schemaName name,
  tableName name,
  idColumnName name,
  geomColumnName name,
  filterStr text DEFAULT NULL
)
RETURNS geometry AS $$
  DECLARE
    queryStr text;
    returnGeom geometry;
  BEGIN
    RAISE NOTICE 'TT_SuperUnion() : START...';
    queryStr = format('
WITH gridded AS (
  SELECT TT_SplitByGridDebug(%1$I, %2$I, 10000) split 
  FROM %3$I.%4$I%5$s
), first_level_union AS (
  SELECT ST_Union((split).geom) geom 
  FROM gridded
  GROUP BY (split).tid
)
SELECT ST_Union(geom) geom
FROM first_level_union;
', idColumnName, geomColumnName, 
   schemaName, tableName, CASE WHEN filterStr IS NULL THEN '' ELSE format('
  WHERE %s', filterStr) END);
    RAISE NOTICE 'queryStr=%', queryStr;
    EXECUTE queryStr INTO returnGeom;
    
    RAISE NOTICE 'TT_SuperUnion() : END Geometry has now % points...', ST_NPoints(returnGeom);

    RETURN returnGeom;
  END
$$ LANGUAGE plpgsql STABLE;
-- Test
-- SELECT TT_SuperUnionDebug('cas_id', 'casfri50', 'geo_all', 'left(cas_id, 4) = ''SK03''');
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_SigDigits()
--
-- Return the number with only a certain  umber of significant digits
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SigDigits(anyelement, int);
CREATE OR REPLACE FUNCTION TT_SigDigits(
  n anyelement, 
  digits int
) 
RETURNS numeric
AS $$
  SELECT round(n::numeric, digits - 1 - floor(CASE WHEN n = 0 THEN 0 ELSE log(abs(n)) END)::int)
$$ LANGUAGE sql IMMUTABLE STRICT;
/*
SELECT TT_SigDigits(0.0000372537::double precision, 3)
SELECT TT_SigDigits(12353263256525, 5)
SELECT TT_SigDigits(123, 2)
SELECT TT_SigDigits(0, 5)
SELECT TT_SigDigits(0.01, 5)
*/
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SplitAgg aggregate state function
--
-- Split a geometry with all aggregated geometries
-----------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SplitAgg_StateFN(geometry[], geometry, geometry, double precision);
CREATE OR REPLACE FUNCTION TT_SplitAgg_StateFN(
  geomarray geometry[],
  geom1 geometry,
  geom2 geometry,
  tolerance double precision
)
RETURNS geometry[] AS $$
  DECLARE
    newgeomarray geometry[];
    geom3 geometry;
    newgeom geometry;
    geomunion geometry;
  BEGIN
    -- First pass: geomarray is NULL
    IF geomarray IS NULL THEN
      geomarray = array_append(newgeomarray, geom1);
    END IF;

    IF NOT geom2 IS NULL THEN
      -- 2) Each geometry in the array - geom2
      FOREACH geom3 IN ARRAY geomarray LOOP
          newgeom = ST_Difference(geom3, geom2);
          IF tolerance > 0 THEN
              newgeom = TT_TrimSubPolygons(newgeom, tolerance);
          END IF;
          IF NOT newgeom IS NULL AND NOT ST_IsEmpty(newgeom) THEN
              newgeomarray = array_append(newgeomarray, newgeom);
          END IF;
      END LOOP;

    -- 3) gv1 intersecting each geometry in the array
      FOREACH geom3 IN ARRAY geomarray LOOP
          newgeom = ST_Intersection(geom3, geom2);
          IF tolerance > 0 THEN
              newgeom = TT_TrimSubPolygons(newgeom, tolerance);
          END IF;
          IF NOT newgeom IS NULL AND NOT ST_IsEmpty(newgeom) THEN
              newgeomarray = array_append(newgeomarray, newgeom);
          END IF;
      END LOOP;
    ELSE
      newgeomarray = geomarray;
    END IF;
    RETURN newgeomarray;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

---------------------------------------
-- ST_SplitAgg aggregate variant state function defaulting tolerance to 0.0
--DROP FUNCTION IF EXISTS TT_SplitAgg_StateFN(geometry[], geometry, geometry);
CREATE OR REPLACE FUNCTION TT_SplitAgg_StateFN(
  geomarray geometry[],
  geom1 geometry,
  geom2 geometry
)
RETURNS geometry[] AS $$
  SELECT TT_SplitAgg_StateFN($1, $2, $3, 0.0);
$$ LANGUAGE sql IMMUTABLE;

---------------------------------------
-- ST_SplitAgg aggregate
-- DROP AGGREGATE IF EXISTS TT_SplitAgg(geometry, geometry, double precision);
CREATE OR REPLACE AGGREGATE TT_SplitAgg(geometry, geometry, double precision) (
  SFUNC=TT_SplitAgg_StateFN,
  STYPE=geometry[]
);

---------------------------------------
-- ST_SplitAgg aggregate defaulting tolerance to 0.0
-- DROP AGGREGATE IF EXISTS TT_SplitAgg(geometry, geometry);
CREATE OR REPLACE AGGREGATE TT_SplitAgg(geometry, geometry) (
  SFUNC=TT_SplitAgg_StateFN,
  STYPE=geometry[]
);
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_GeoHistoryRowCount
--
-- Count the rows in the geo history table for an array of inventory_id
-- When an ARRAY of inv id is passed (e.g. ARRAY['AB34', 'AB06']), return the 
-- count only for these inventories.
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_GeoHistoryRowCount(text[]);
CREATE OR REPLACE FUNCTION TT_GeoHistoryRowCount(
  invArr text[]
) 
RETURNS TABLE (
  inventory_id text,
  flat_table_cnt int,
  geo_history_cnt int,
  diff text
) AS $$
  WITH inv_list AS (
    SELECT upper(unnest($1)) inv
  ), flat_table_cnts AS (
    SELECT i.inv, CASE WHEN f.inventory_id IS NULL THEN 0 ELSE count(*) END flat_table_cnt
    FROM inv_list i
    LEFT OUTER JOIN casfri50_flat.cas_flat_all_layers_same_row f ON (f.inventory_id = i.inv)
    GROUP BY i.inv, f.inventory_id

  ), geohistocnt AS (
    SELECT i.inv, CASE WHEN left(g.cas_id, 4) IS NULL THEN 0 ELSE count(*) END geo_history_cnt
    FROM inv_list i
    LEFT OUTER JOIN casfri50_history.geo_history g ON (left(g.cas_id, 4) = i.inv)
    GROUP BY i.inv, left(g.cas_id, 4)
  )
  SELECT coalesce(f.inv, g.inv) inventory_id,
        coalesce(flat_table_cnt, 0) flat_table_cnt,
        coalesce(geo_history_cnt, 0) geo_history_cnt,
        coalesce(geo_history_cnt, 0) - coalesce(flat_table_cnt, 0) diff
  FROM flat_table_cnts f
  FULL OUTER JOIN geohistocnt g USING (inv)
  ORDER BY inv;
$$ LANGUAGE sql STABLE;
--SELECT * FROM TT_GeoHistoryRowCount(ARRAY['Ab03', 'AB06', 'QC03']);
---------------------------------------
-- Variant counting for all inventories listed in 
-- inventory_metadata or only for those identified in a specific column 
-- (e.g. 'TRANSLATED_BY_CFS'). Otherwise return the count for all inventories 
-- found in the rawfri schema.
-------------------------------------------------------------------------------
-- DROP FUNCTION IF EXISTS TT_GeoHistoryRowCount(text); 
CREATE OR REPLACE FUNCTION TT_GeoHistoryRowCount(
  invMetadataColName text DEFAULT NULL
) 
RETURNS TABLE (
  inventory_id text,
  flat_table_cnt int,
  geo_history_cnt int,
  diff text
) AS $$
  DECLARE
    queryStr text;
  BEGIN
    queryStr := format('
WITH inv AS (
  SELECT array_agg(md.inventory_id) invarr 
  FROM inventory_metadata md
  %s
)
SELECT * FROM TT_GeoHistoryRowCount((SELECT invarr FROM inv));',
    CASE WHEN invMetadataColName IS NULL THEN '' ELSE format('  WHERE upper(%s) = ''YES''', invMetadataColName) END);
    RAISE NOTICE 'queryStr = %', queryStr;
    RETURN QUERY EXECUTE queryStr;
  END
$$ LANGUAGE plpgsql STABLE;
-- SELECT (TT_GeoHistoryRowCount()).*
-- SELECT (TT_GeoHistoryRowCount('TRANSLATED_BY_CUSTOM')).*
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_ProduceDerivedCoverages()
--
-- Produce different simplified versions of coverage geometries.
------------------------------------------------------------------------------
--DROP PROCEDURE IF EXISTS TT_ProduceDerivedCoverages(text, geometry, double precision, boolean, double precision);
CREATE OR REPLACE PROCEDURE TT_ProduceDerivedCoverages(
  fromInv text, -- inventoryID
  detailedGeom geometry, -- non simplified version of the coverage geometry
  minArea double precision DEFAULT 10000000, -- minimum area of holes and island to keep
  sparse boolean DEFAULT FALSE, -- apply a special treatment for sparce geometries
  sparseBuf double precision DEFAULT 5000 -- buffer to apply for sparse geometries
) AS $$
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
    RAISE NOTICE '-------------------------------------------------------------------';
    RAISE NOTICE 'TT_RemoveHoles() for ''%'' to produce noholes polygon...', fromInv;
    noHolesGeom = TT_RemoveHoles(detailedGeom, minArea);
    RAISE NOTICE 'After TT_RemoveHoles() geometry has % vertexes...', ST_NPoints(noHolesGeom);
    RAISE NOTICE '-------------------------------------------------------------------';

    RAISE NOTICE 'TT_TrimSubPolygons() for ''%'' to produce noislands polygon...', fromInv;
    noIslandsGeom = TT_TrimSubPolygons(noHolesGeom, minArea);
    RAISE NOTICE 'After TT_TrimSubPolygons() geometry has % vertexes...', ST_NPoints(noIslandsGeom);
    RAISE NOTICE '-------------------------------------------------------------------';

    RAISE NOTICE 'ST_SimplifyPreserveTopology() for ''%'' to produce simplified polygon...', fromInv;
    simplifiedGeom = ST_SimplifyPreserveTopology(noIslandsGeom, 100);
    RAISE NOTICE 'After ST_SimplifyPreserveTopology() geometry has % vertexes...', ST_NPoints(simplifiedGeom);
    RAISE NOTICE '-------------------------------------------------------------------';

    RAISE NOTICE 'TT_TrimSubPolygons(TT_BufferedSmooth()) for ''%'' to produce smoothed polygon...', fromInv;
    smoothedGeom = TT_TrimSubPolygons(TT_BufferedSmooth(simplifiedGeom, CASE WHEN sparse THEN sparseBuf ELSE 100 END), minArea);
    RAISE NOTICE 'After TT_BufferedSmooth() geometry has % vertexes...', ST_NPoints(smoothedGeom);
    RAISE NOTICE '-------------------------------------------------------------------';

    -- Get the count of point from a precomputed table
    SELECT a.cnt FROM casfri50_coverage.inv_counts a WHERE upper(inv) = upper(fromInv) INTO cnt;

    FOREACH tableName IN ARRAY tableNameArr LOOP
      outGeom = CASE WHEN tableName = 'detailed' THEN detailedGeom
                     WHEN tableName = 'noholes' THEN noHolesGeom
                     WHEN tableName = 'noislands' THEN noIslandsGeom
                     WHEN tableName = 'simplified' THEN simplifiedGeom
                     WHEN tableName = 'smoothed' THEN smoothedGeom
                END;
      -- First part is to INSERT the non gridded version.
      RAISE NOTICE '-------------------------------------------------------------------';
      RAISE NOTICE 'TT_ProduceDerivedCoverages() : Creating table % and inserting polygon...', tableName;
      queryStr = format('
CREATE TABLE IF NOT EXISTS casfri50_coverage.%1$I(inv text PRIMARY KEY, nb_polys int, nb_points int, geom geometry);
INSERT INTO casfri50_coverage.%1$I (inv, nb_polys, nb_points, geom) VALUES ($1, $2, $3, $4)
ON CONFLICT (inv)
DO UPDATE SET
    nb_polys = EXCLUDED.nb_polys,
    nb_points = EXCLUDED.nb_points,
    geom = EXCLUDED.geom;', tableName, upper(fromInv));
      EXECUTE queryStr USING upper(fromInv), cnt, ST_NPoints(outGeom), outGeom;
      COMMIT;

      -- Create a gridded version for each. Begin by deleting any existing parts.
      RAISE NOTICE 'TT_ProduceDerivedCoverages() : Creating table %...', tableName || '_gridded';
      queryStr = format('
CREATE TABLE IF NOT EXISTS casfri50_coverage.%1$I_gridded(inv text, nb_polys int, nb_points int, geom geometry);
CREATE INDEX IF NOT EXISTS %1$I_geom_idx ON casfri50_coverage.%1$I_gridded USING gist(geom);', tableName);
      EXECUTE queryStr;
      COMMIT;

      -- Create a gridded version for each. Begin by deleting any existing parts.
      RAISE NOTICE 'TT_ProduceDerivedCoverages() : Deleting % gridded polygons from %...', fromInv, tableName || '_gridded';
      queryStr = format('
DELETE FROM casfri50_coverage.%1$I_gridded
WHERE upper(inv) = %2$L;', tableName, upper(fromInv));
      EXECUTE queryStr;
      COMMIT;

      RAISE NOTICE 'TT_ProduceDerivedCoverages() : Deleting done. Inserting % gridded polygons into %...', fromInv, tableName || '_gridded';
      -- INSERT parts into the gridded version.
      queryStr = format('
INSERT INTO casfri50_coverage.%1$I_gridded (inv, nb_polys, nb_points, geom) 
SELECT inv, nb_polys, ST_NPoints((geom).geom) nb_points, (geom).geom geom
FROM (SELECT inv, nb_polys, TT_SplitByGridDebug(inv, geom, 10000) geom
      FROM casfri50_coverage.%1$I
      WHERE upper(inv) = %2$L
     ) foo;', tableName, upper(fromInv));
      EXECUTE queryStr;
      RAISE NOTICE 'TT_ProduceDerivedCoverages() : Processing of % done...', fromInv;
    END LOOP;
  END
$$ LANGUAGE plpgsql;
------------------------------------------------------------------------------

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
      msg = msg || ' - ' || to_char(clock_timestamp(), 'HH24hMI') || ', ' || TT_PrettyDuration(elapsedTime, 3) || ' elapsed, ' || TT_PrettyDuration(remainingTime, 3) || ' remaining';
    END IF;
    msg = msg || '...';
    RETURN msg;
  END;
$$ LANGUAGE plpgsql VOLATILE;
-- test
-- SELECT TT_ProgressMsg(1, 10, now())
------------------------------------------------------------------------------
-- TT_RaiseLog()
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ProgressMsg(text, text, int, int);
CREATE OR REPLACE FUNCTION TT_RaiseLog(
  process text,
  lastProcessedId text,
  currentRowNb int DEFAULT NULL,
  totalRowCnt int DEFAULT NULL
) RETURNS boolean AS $$
BEGIN
  -- Main log message
  RAISE LOG '%', format('%s, %s, %s, %s', process, lastProcessedId, currentRowNb, totalRowCnt);
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------------------------
-- TT_LoadPostgresCSVLogs()
--
-- Load a series of PostgreSQL log CSV tables into a queriable table.
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_LoadPostgresCSVLogs(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_LoadPostgresCSVLogs(
  logFolder text,        -- folder containing CSV logs
  filePrefix text,    -- e.g. 'postgresql-2026-03-18_'
  startSuffix text,   -- e.g. '162822'
  endSuffix text      -- e.g. '162832'
) RETURNS void AS $$
DECLARE
  csvFile text;
  queryStr text;
  fileList text[];
  thisFile text;
BEGIN
  -- Drop table if exists
  RAISE NOTICE 'Dropping table public.postgres_logs if it exists';
  EXECUTE 'DROP TABLE IF EXISTS public.postgres_logs;';

  -- Create fresh table
  queryStr := '
CREATE TABLE public.postgres_logs (
  log_time text,
  user_name text,
  database_name text,
  process_id text,
  connection_from text,
  session_id text,
  session_line_num text,
  command_tag text,
  session_start_time text,
  virtual_transaction_id text,
  transaction_id text,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos text,
  context text,
  query text,
  query_pos text,
  location text,
  application_name text,
  extra_field text
);';
  RAISE NOTICE 'Creating table public.postgres_logs...';
  EXECUTE queryStr;

  -- Get list of CSV files matching prefix
  SELECT array_agg(fname) INTO fileList
  FROM (
    SELECT files AS fname
    FROM pg_ls_dir(logFolder) AS files
    WHERE files LIKE filePrefix || '%.csv'
      AND substring(files from '(\d+)\.csv$') BETWEEN startSuffix AND endSuffix
    ORDER BY files
  ) t;

  IF fileList IS NULL THEN
    RAISE NOTICE 'No files found in the specified range...';
    RETURN;
  END IF;

  -- Loop through files and COPY into table
  FOREACH thisFile IN ARRAY fileList LOOP
    csvFile := logFolder || '/' || thisFile;
    RAISE NOTICE 'Loading CSV file: %', csvFile;

    EXECUTE format('
COPY public.postgres_logs FROM %L WITH (FORMAT csv, HEADER false, DELIMITER '','', QUOTE ''"'', ESCAPE ''"'');
', csvFile
    );
  END LOOP;

  RAISE NOTICE 'Finished loading logs...';
END;
$$ LANGUAGE plpgsql;
/*
-- test
SELECT TT_LoadPostgresLogs('F:/PostgreSQL13/data/log/', 'postgresql-2026-03-18', '162813', '162833');

SELECT log_time, message
FROM postgres_logs
WHERE left(message, 17) = 'TT_ValidYearUnion';
*/
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
      countQuery = format('
SELECT count(*) 
FROM casfri50_history.casflat_gridded
WHERE inventory_id = upper(%L);', inv);
      RAISE NOTICE 'TT_ProduceInvGeoHistory(%) - Counting the number of gridded polygon to process from casfri50_history.casflat_gridded in order to display progress...', inv;
      EXECUTE countQuery INTO expectedRowNb;

      RAISE NOTICE 'TT_ProduceInvGeoHistory(%) - % gridded polygon to process...', inv, expectedRowNb;
    END IF;

    -- If progress is true and we computed the number of rows to process, we process only if it's > 0
    -- If progress is false, we proceed even if expectedRowNb = 0
    IF NOT progress OR expectedRowNb > 0 THEN
      IF progress THEN
        seqName = 'geohistory_' || lower(inv);
        queryStr = format('
DROP SEQUENCE IF EXISTS %1$s_1;
CREATE SEQUENCE %1$s_1 START 1;
DROP SEQUENCE IF EXISTS %1$s_2;
CREATE SEQUENCE %1$s_2 START 1;', seqName);
      END IF;
      IF individualTables THEN
        queryStr = queryStr || format('
DROP TABLE IF EXISTS casfri50_history.%1$s_history CASCADE;
CREATE TABLE casfri50_history.%1$s_history AS (
  ', lower(inv));
      ELSE
        queryStr = queryStr || '
INSERT INTO casfri50_history.geo_history
  ';
      END IF;
      queryStr = queryStr || format('
WITH geohistory_gridded AS (
  SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, stand_photo_year, TRUE, geom,
                               ''casfri50_history'', ''casflat_gridded'', ''cas_id'', ''geom'', ''stand_photo_year'', ''inventory_id'')).*
  FROM casfri50_history.casflat_gridded
  WHERE inventory_id = %L', upper(inv));

      IF progress THEN
        queryStr = queryStr || format(' AND 
        CASE WHEN nextval(%1$L) %% 1000 = 0 OR currval(%1$L) = %2$s THEN TT_PrintMessage(''%3$s - TT_PolygonGeoHistory() - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) ELSE TRUE END', seqName || '_1', expectedRowNb, inv);
      END IF;

      queryStr = queryStr || '
  ORDER BY id, poly_id
), wkb_version AS (
  SELECT id, (TT_UnnestValidYearUnion(TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end))).* gvt
  FROM geohistory_gridded';
        
      IF progress THEN
        queryStr = queryStr || format('
  WHERE CASE WHEN nextval(%1$L) %% 1000 = 0 OR currval(%1$L) = %2$s THEN TT_PrintMessage(''%3$s - TT_ValidYearUnion() - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) ELSE TRUE END', seqName || '_2', expectedRowNb, inv);
      END IF;

      queryStr = queryStr || '
  GROUP BY id
)
SELECT id cas_id, geom, lowerval valid_year_begin, upperval valid_year_end
FROM wkb_version);';
      startTime = clock_timestamp();
    RAISE NOTICE 'queryStr = %', replace(queryStr, '$1', quote_literal(startTime::text) || '::timestamptz');
      EXECUTE queryStr USING startTime;
    END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------------------------
--DROP PROCEDURE IF EXISTS TT_ProduceInvGeoHistory2Steps(text, boolean, boolean, boolean);
CREATE OR REPLACE PROCEDURE TT_ProduceInvGeoHistory2Steps(
  inv text,
  createGeoHistory boolean DEFAULT TRUE,
  individualTables boolean DEFAULT FALSE,
  progress boolean DEFAULT TRUE
)
LANGUAGE plpgsql AS $$
DECLARE
    queryStr text = '';
    seqName text := 'geohistory_' || lower(inv);
    countQuery text;
    expectedRowNb int = 0;
    expectedGroupNb int = 0;
    expectedUnionNb int = 0;
    startTime timestamptz;
    raiseLog boolean := FALSE;
  BEGIN
    IF createGeoHistory OR NOT TT_TableExists('casfri50_history', lower(inv) || '_history') THEN
      IF NOT createGeoHistory THEN
        RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - createGeoHistory is set to FALSE but the casfri50_history.% table does not exist and we must create it before proceeding...', inv, lower(inv) || '_history';
      END IF;
      IF progress THEN
        -- Count the number of rows to process for progress tracking
        countQuery = format('
SELECT count(*) 
FROM casfri50_history.casflat_gridded
WHERE inventory_id = upper(%L);', inv);
        RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Counting the number of gridded polygon to process from casfri50_history.casflat_gridded in order to display progress...', inv;
        EXECUTE countQuery INTO expectedRowNb;
        RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - % gridded polygon to process...', inv, expectedRowNb;
      END IF;

    -- If progress is true and we computed the number of rows to process, we process only if it's >0
    -- If progress is false, we proceed even if expectedRowNb = 0
      IF NOT progress OR expectedRowNb > 0 THEN
        IF progress THEN
          -- Create a sequence for progress tracking
          queryStr = format('
DROP SEQUENCE IF EXISTS %1$s;
CREATE SEQUENCE %1$s START 1;
', seqName);
        END IF;
        -- Create the geo history table for the inventory
        queryStr = queryStr || format('
DROP TABLE IF EXISTS casfri50_history.%1$I_history CASCADE;
CREATE TABLE casfri50_history.%1$I_history AS', lower(inv));

        -- Fill the geo history table for the inventory with the result of TT_PolygonGeoHistory() on the gridded polygons
        queryStr = queryStr || format('
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, stand_photo_year, TRUE, geom,
                             ''casfri50_history'', ''casflat_gridded'', ''cas_id'', ''geom'', ''stand_photo_year'', ''inventory_id'')).*
FROM casfri50_history.casflat_gridded
WHERE inventory_id = upper(%L)', inv);
  
        IF progress THEN
          -- Add progress tracking to the query using the sequence created earlier
          queryStr = queryStr || format(' AND 
      CASE WHEN nextval(%1$L) %% 1000 = 0 OR currval(%1$L) = %2$s THEN 
                TT_PrintMessage(''%3$s - TT_PolygonGeoHistory() - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) 
            ELSE TRUE 
      END', seqName, expectedRowNb, inv);
        END IF;

        -- Order the results
        queryStr = queryStr || '
ORDER BY id, poly_id';
  
        startTime = clock_timestamp();
        RAISE NOTICE 'queryStr = %', replace(queryStr, '$1', quote_literal(startTime::text) || '::timestamptz');
        EXECUTE queryStr USING startTime;
        RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Committing...', inv;
        COMMIT;
        RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Commit done...', inv;
      END IF;
    END IF;
    --------------------------------------------------------------------------------
    --------------------------------- Union query ----------------------------------
    --------------------------------------------------------------------------------

    -- Reinitialize queryStr
    queryStr := '';
    IF progress THEN
      -- Count the number of rows to process for progress tracking
      countQuery = format('
SELECT count(*) 
FROM casfri50_history.%I_history;', lower(inv));
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Counting the number of geo history polygons to union from casfri50_history.%_history in order to display progress...', inv, lower(inv);
      EXECUTE countQuery INTO expectedRowNb;
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - % geo history polygon to union...', inv, expectedRowNb;
    END IF;

    -- If progress is true and we computed the number of rows to process, we process only if it's > 0
    -- If progress is false, we proceed even if expectedRowNb = 0 since we did not compute it
    IF NOT progress OR expectedRowNb > 0 THEN
      -- Create an index on the id column of casfri50_history.%1$I_history
      queryStr := format('
CREATE INDEX IF NOT EXISTS %1$s_history_id_idx
ON casfri50_history.%1$I_history(id);', lower(inv));
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Creating an index on casfri50_history.%_history id column...', inv, lower(inv);
      EXECUTE queryStr;
      COMMIT;
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Index created and committed...', inv;
    END IF;

    IF progress THEN
    -- Count the number of id, valid_year groups for progress tracking
      countQuery = format('
SELECT count(DISTINCT (id, valid_year_begin, valid_year_end)) 
FROM casfri50_history.%I_history;', lower(inv));
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Counting the number of geo history stands to GROUP BY in order to display progress...', inv;
      EXECUTE countQuery INTO expectedGroupNb;
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - % geo history stands to GROUP BY...', inv, expectedGroupNb;

      -- Count the number of unioned groups array to unnest for progress tracking
      countQuery = format('
SELECT count(DISTINCT id) 
FROM casfri50_history.%I_history;', lower(inv));
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - Counting the number of geo history unioned groups array to unnest in order to display progress...', inv;
      EXECUTE countQuery INTO expectedUnionNb;
      RAISE NOTICE 'TT_ProduceInvGeoHistory2Steps(%) - % geo history unioned groups to unnest...', inv, expectedUnionNb;
    END IF;

    -- If progress is true and we computed the number of rows to process, we process only if it's > 0
    -- If progress is false, we proceed even if expectedRowNb = 0 since we did not compute it
    IF NOT progress OR expectedRowNb > 0 THEN
      IF progress THEN
        -- Create a sequence for progress tracking
        queryStr := format('
DROP SEQUENCE IF EXISTS %1$s_1;
CREATE SEQUENCE %1$s_1 START 1;
DROP SEQUENCE IF EXISTS %1$s_2;
CREATE SEQUENCE %1$s_2 START 1;
DROP SEQUENCE IF EXISTS %1$s_3;
CREATE SEQUENCE %1$s_3 START 1;
DROP SEQUENCE IF EXISTS %1$s_4;
CREATE SEQUENCE %1$s_4 START 1;
DROP SEQUENCE IF EXISTS %1$s_5;
CREATE SEQUENCE %1$s_5 START 1;', seqName);
      END IF;

      IF individualTables THEN
        -- Create the individual geo history table for this inventory
        queryStr = queryStr || format('
DROP TABLE IF EXISTS casfri50_history.%1$I_history_unioned CASCADE;
CREATE TABLE casfri50_history.%1$I_history_unioned AS', lower(inv));
      ELSE
        -- Insert into the geo history table
        queryStr = queryStr || '
INSERT INTO casfri50_history.geo_history';
      END IF;

      -- Main query to union the geometries from the geo history table using TT_ValidYearUnion() and TT_UnnestValidYearUnion() to get the valid year ranges for each geometry
      queryStr = queryStr || format('
(WITH grouped AS (
  SELECT id, valid_year_begin, valid_year_end, ST_Union(wkb_geometry) wkb_geometry, clock_timestamp() lastTime
  FROM casfri50_history.%1$I_history', lower(inv));
      
      IF progress OR raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
  WHERE nextval(%1$L) > 0 AND', seqName || '_1');
      END IF;

      IF raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
        TT_RaiseLog(''TT_ProduceInvGeoHistory2Steps(Step 1/4 - BASE FILTER)'', id, currval(%1$L)::int, %2$s)', seqName || '_1', expectedRowNb);
        IF progress THEN
          queryStr = queryStr || ' AND';
        END IF;
      END IF;

      IF progress THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
        CASE WHEN currval(%1$L) %% 1000 = 0 OR currval(%1$L) = %2$s THEN 
                  TT_PrintMessage(''%3$s - TT_ProduceInvGeoHistory2Steps(Step 1/5 - BASE FILTER) - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) 
             ELSE TRUE 
        END', seqName || '_1', expectedRowNb, inv);
      END IF;

      -- GROUP BY and rename columns in a final SELECT
      queryStr = queryStr || '
  GROUP BY id, valid_year_begin, valid_year_end';

      IF progress OR raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
  HAVING nextval(%1$L) > 0 AND', seqName || '_2');
      END IF;

      IF raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
        TT_RaiseLog(''TT_ProduceInvGeoHistory2Steps(Step 2/4 - BASE AGGREGATE)'', id, currval(%1$L)::int, %2$s)', seqName || '_2', expectedGroupNb);
        IF progress THEN
          queryStr = queryStr || ' AND';
        END IF;
      END IF;
      
      IF progress THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
         CASE WHEN currval(%1$L) %% 1000 = 0 OR currval(%1$L) = %2$s THEN 
                   TT_PrintMessage(''%3$s - TT_ProduceInvGeoHistory2Steps(Step 2/5 - BASE AGGREGATE)  - '' || TT_ProgressMsg(currval(%1$L), %2$s, $1)) 
              ELSE TRUE 
         END', seqName || '_2', expectedGroupNb, inv);
      END IF;      
      IF progress THEN
        -- Reset the start time for the next portion of the CTE query
        queryStr = queryStr || '
), newStartTime1 AS (
  SELECT max(lastTime) newTime
  FROM grouped';
      END IF;

      queryStr = queryStr || '
), unioned AS (
  SELECT id, 
         TT_ValidYearUnion(wkb_geometry, valid_year_begin, valid_year_end) vyu';

      IF progress THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format(',
         CASE WHEN nextval(%1$L) %% 100 = 0 OR currval(%1$L) = %2$s THEN 
                   TT_PrintMessage(''%3$s - TT_ValidYearUnion(Step 3/5 - AGGREGATE) - '' || TT_ProgressMsg(currval(%1$L), %2$s, newTime)) 
              ELSE TRUE 
         END', seqName || '_3', expectedUnionNb, inv);
      END IF;

      IF raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format(',
        TT_RaiseLog(''TT_ValidYearUnion(Step 3/4 - AGGREGATE)'', id, %3$s(%1$L)::int, %2$s)', 
          seqName || '_3', 
          expectedGroupNb, 
          CASE WHEN progress THEN 'currval' ELSE 'nextval' END
        );
      END IF;

      queryStr = queryStr || '        
  FROM grouped';
      
      IF progress THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || ', newStartTime1';
      END IF;
      -- GROUP BY and rename columns in a final SELECT
      queryStr = queryStr || '
  GROUP BY id';

      IF progress OR raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('%2$s
  HAVING nextval(%1$L) > 0 AND', seqName || '_4', CASE WHEN progress THEN ', newtime' ELSE '' END);
      END IF;

      IF raiseLog THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
        TT_RaiseLog(''TT_ValidYearUnion(Step 4/4 - UNION)'', id, currval(%1$L)::int, %2$s)', seqName || '_4', expectedUnionNb);
        IF progress THEN
          queryStr = queryStr || ' AND';
        END IF;
      END IF;
      
      IF progress THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format('
         CASE WHEN currval(%1$L) %% 100 = 0 OR currval(%1$L) = %2$s THEN 
                   TT_PrintMessage(''%3$s - TT_ValidYearUnion(Step 4/5 - UNION)  - '' || TT_ProgressMsg(currval(%1$L), %2$s, newTime)) 
              ELSE TRUE 
         END', seqName || '_4', expectedUnionNb, inv);
      END IF;
 
      queryStr = queryStr || '
), union_cnt AS (
  SELECT sum(array_length(vyu, 1)) cnt, clock_timestamp() lastTime
  FROM unioned';
      
      IF progress THEN
        -- Reset the start time for the next portion of the CTE query
        queryStr = queryStr || '
), newStartTime2 AS (
  SELECT max(lastTime) newTime
  FROM union_cnt';
      END IF;

      queryStr = queryStr || '
), unnested AS (
  SELECT id, (TT_UnnestValidYearUnion(vyu)).* gvt';

      IF progress THEN
        -- Add progress tracking to the query using the sequence created earlier
        queryStr = queryStr || format(',
         CASE WHEN nextval(%1$L) %% 1000 = 0 OR currval(%1$L) = union_cnt.cnt::int THEN TT_PrintMessage(''%2$s - TT_UnnestValidYearUnion(Step 5/5) - '' || TT_ProgressMsg(currval(%1$L), union_cnt.cnt::int, newTime)) 
              ELSE TRUE 
         END msg', seqName || '_5', inv);
      END IF;

      queryStr = queryStr || '
  FROM unioned, union_cnt';
      
      IF progress THEN
        -- Reset the start time for the next portion of the CTE query
        queryStr = queryStr || ', newStartTime2';
      END IF;

      queryStr = queryStr || '
)
SELECT id cas_id, geom, lowerval valid_year_begin, upperval valid_year_end
FROM unnested);';

      startTime = clock_timestamp();
      RAISE NOTICE 'queryStr2 = %', replace(queryStr, '$1', quote_literal(startTime::text) || '::timestamptz');
      EXECUTE queryStr USING startTime;
    END IF;
  END;
$$;

/*
-- tests
CALL TT_ProduceInvGeoHistory2Steps('PC02', TRUE, TRUE, TRUE);
CALL TT_ProduceInvGeoHistory2Steps('PC02', FALSE, TRUE, TRUE)
*/
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_IntersectingArea()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_IntersectingArea(geometry, geometry, double precision);
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
------------------------------------------------------------------------------

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
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SafeOverlaps()
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SafeOverlaps(geometry, geometry, double precision, text, text, boolean, boolean, text);
CREATE OR REPLACE FUNCTION TT_SafeOverlaps(
  geom1 geometry,
  geom2 geometry,
  tolerance double precision DEFAULT NULL,
  geom1id text DEFAULT NULL,
  geom2id text DEFAULT NULL,
  safe boolean DEFAULT FALSE,
  showNotice boolean DEFAULT TRUE,
  context text DEFAULT ''
)
RETURNS boolean AS $$
  DECLARE
    ovlp boolean;
  BEGIN
    IF safe THEN
      IF showNotice THEN RAISE NOTICE 'TT_SafeOverlaps(%) : Safe is TRUE...', context; END IF;
      BEGIN
        -- Attempt the normal operation
        ovlp := ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
        IF showNotice THEN RAISE NOTICE 'TT_SafeOverlaps(%) : Safe is TRUE but normal operation worked...', context; END IF;
        RETURN ovlp;
      EXCEPTION WHEN OTHERS THEN
        IF tolerance IS NULL THEN
          RAISE NOTICE 'TT_SafeOverlaps(%) ERROR 1: Normal ST_Overlaps() failed. Try by buffering the first polygon (%) by 0...', context, coalesce(geom1id, 'no ID provided');
        ELSE
          RAISE NOTICE 'TT_SafeOverlaps(%) ERROR 1: Normal ST_Overlaps() failed. Try by snapping the first polygon (%) to grid using tolerance=%...', context, coalesce(geom1id, 'no ID provided'), tolerance::text;
        END IF;
      END;
      IF NOT tolerance IS NULL THEN
        BEGIN
          geom1 := ST_MakeValid(ST_SnapToGrid(geom1, tolerance));
          ovlp := ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
          RAISE NOTICE 'TT_SafeOverlaps(%) : That worked...', context;
          RETURN ovlp;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeOverlaps(%) ERROR 2: Snapping the first polygon failed. Try by snapping the second polygon (%) to grid using tolerance=%...', context, coalesce(geom2id, 'no ID provided'), tolerance::text;
        END;

        BEGIN
          geom2 := ST_MakeValid(ST_SnapToGrid(geom2, tolerance));
          ovlp := ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
          RAISE NOTICE 'TT_SafeOverlaps(%) : That worked...', context;
          RETURN ovlp;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeOverlaps(%) ERROR 3: Snapping the second polygon failed. Try by snapping the both polygons (% and %) to grid using tolerance=%...', context, coalesce(geom1id, 'no ID provided'), coalesce(geom2id, 'no ID provided'), tolerance::text;
        END;

        BEGIN
          geom1 := ST_MakeValid(ST_SnapToGrid(geom1, tolerance));
          geom2 := ST_MakeValid(ST_SnapToGrid(geom2, tolerance));
          ovlp := ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
          RAISE NOTICE 'TT_SafeOverlaps(%) : That worked...', context;
          RETURN ovlp;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeOverlaps(%) ERROR 4: Snapping both polygons failed. Try by buffering the first polygon (%) by 0...', context, coalesce(geom1id, 'no ID provided');
        END;
      END IF;

      BEGIN
        geom1 := ST_Buffer(geom1, 0);
        ovlp := ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
        RAISE NOTICE 'TT_SafeOverlaps(%) : That worked...', context;
        RETURN ovlp;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TT_SafeOverlaps(%) ERROR 5: Buffering the first polygon by 0 failed. Try by buffering the second polygon (%) by 0...', context, coalesce(geom2id, 'no ID provided');
      END;

      BEGIN
        geom2 := ST_Buffer(geom2, 0);
        ovlp := ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
        RAISE NOTICE 'TT_SafeOverlaps(%) : That worked...', context;
        RETURN ovlp;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TT_SafeOverlaps(%) FATAL ERROR: Operation failed. Returning FALSE...', context;
      END;
      RETURN FALSE;
    ELSE
      -- Safe is FALSE, just do the normal operation without any exception handling (faster)
      RETURN ST_Overlaps(geom1, geom2) OR ST_Contains(geom2, geom1) OR ST_Contains(geom1, geom2);
    END IF;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_SafeDifference()
--
-- Designed to be used once with safe=true to avoid testing for exception too
-- often (poor performance), and then with safe=false once the problematic cases
-- have been identified.
--
-- It will try to perform the difference operation in a normal way and if it
-- fails, it will try different approaches to make it work. It will also display 
-- RAISE NOTICE messages to help identify the problematic cases and the approach 
-- that worked.
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_SafeDifference(geometry, geometry, double precision, text, text, boolean, boolean, text);
CREATE OR REPLACE FUNCTION TT_SafeDifference(
  geom1 geometry,
  geom2 geometry,
  tolerance double precision DEFAULT NULL,
  geom1id text DEFAULT NULL,
  geom2id text DEFAULT NULL,
  safe boolean DEFAULT FALSE,
  showNotice boolean DEFAULT TRUE,
  context text DEFAULT ''
)
RETURNS geometry AS $$
  DECLARE
    diffGeom geometry;
  BEGIN
    --RAISE NOTICE 'geom1=%', ST_AsText(geom1);
    --RAISE NOTICE 'geom2=%', ST_AsText(geom2);
    IF safe THEN
      IF showNotice THEN RAISE NOTICE 'TT_SafeDifference(%) : Safe is TRUE...', context; END IF;
      BEGIN
        -- Attempt the normal operation
        diffGeom := ST_Difference(geom1, geom2);
        IF showNotice THEN RAISE NOTICE 'TT_SafeDifference(%) : Safe is TRUE but normal operation worked...', context; END IF;
        RETURN diffGeom;
      EXCEPTION WHEN OTHERS THEN
        IF tolerance IS NULL THEN
          RAISE NOTICE 'TT_SafeDifference(%) ERROR 1: Normal ST_Difference() failed. Try by buffering the first polygon (%) by 0...', context, coalesce(geom1id, 'no ID provided');
        ELSE
          RAISE NOTICE 'TT_SafeDifference(%) ERROR 1: Normal ST_Difference() failed. Try by snapping the first polygon (%) to grid using tolerance=%...', context, coalesce(geom1id, 'no ID provided'), tolerance::text;
        END IF;
      END;
      IF NOT tolerance IS NULL THEN
        BEGIN
          diffGeom := ST_Difference(ST_MakeValid(ST_SnapToGrid(geom1, tolerance)), geom2);
          RAISE NOTICE 'TT_SafeDifference(%) : That worked...', context;
          RETURN diffGeom;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeDifference(%) ERROR 2: Snapping the first polygon failed. Try by snapping the second polygon (%) to grid using tolerance=%...', context, coalesce(geom2id, 'no ID provided'), tolerance::text;
        END;

        BEGIN
          diffGeom := ST_Difference(geom1, ST_MakeValid(ST_SnapToGrid(geom2, tolerance)));
          RAISE NOTICE 'TT_SafeDifference(%) : That worked...', context;
          RETURN diffGeom;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeDifference(%) ERROR 3: Snapping the second polygon failed. Try by snapping the both polygons (% and %) to grid using tolerance=%...', context, coalesce(geom1id, 'no ID provided'), coalesce(geom2id, 'no ID provided'), tolerance::text;
        END;

        BEGIN
          diffGeom := ST_Difference(ST_MakeValid(ST_SnapToGrid(geom1, tolerance)), ST_MakeValid(ST_SnapToGrid(geom2, tolerance)));
          RAISE NOTICE 'TT_SafeDifference(%) : That worked...', context;
          RETURN diffGeom;
        EXCEPTION WHEN OTHERS THEN
          RAISE NOTICE 'TT_SafeDifference(%) ERROR 4: Snapping both polygons failed. Try by buffering the first polygon (%) by 0...', context, coalesce(geom1id, 'no ID provided');
        END;
      END IF;

      BEGIN
        diffGeom := ST_Difference(ST_Buffer(geom1, 0), geom2);
        RAISE NOTICE 'TT_SafeDifference(%) : That worked...', context;
        RETURN diffGeom;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TT_SafeDifference(%) ERROR 5: Buffering the first polygon by 0 failed. Try by buffering the second polygon (%) by 0...', context, coalesce(geom2id, 'no ID provided');
      END;

      BEGIN
        diffGeom := ST_Difference(geom1, ST_Buffer(geom2, 0));
        RAISE NOTICE 'TT_SafeDifference(%) : That worked...', context;
        RETURN diffGeom;
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'TT_SafeDifference(%) FATAL ERROR: Operation failed. Returning MULTIPOLYGON EMPTY...', context;
      END;
      RETURN ST_GeomFromText('MULTIPOLYGON EMPTY');
    ELSE
      -- Safe is FALSE, just do the normal operation without any exception handling (faster)
      RETURN ST_Difference(geom1, geom2);
    END IF;
  END
$$ LANGUAGE plpgsql IMMUTABLE;
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- New TYPE for TT_ValidYearUnionStateFct()
------------------------------------------------------------------------------
DROP TYPE IF EXISTS geomlowuppval CASCADE;
CREATE TYPE geomlowuppval AS
(
  geom geometry,
  lowerVal int,
  upperVal int
);
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_ValidYearUnion() aggregate state function
--
-- Union together year overlapping polygons.
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidYearUnionStateFct(geomlowuppval[], geometry, int, int) CASCADE;
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
BEGIN
  IF newYLow > newYUpp THEN
    RAISE EXCEPTION 'TT_ValidYearUnion() ERROR: Lower value (%) is higher than higher value (%)...', newYLow, newYUpp;
  END IF;

  IF storedGYRArr IS NOT NULL THEN
    FOREACH storedGYR IN ARRAY storedGYRArr LOOP
      storedYLow := storedGYR.lowerVal;
      storedYUpp := storedGYR.upperVal;

      -- New range already consumed, or entirely after stored: keep stored as-is
      IF newYLow IS NULL OR storedYUpp < newYLow THEN
        newGYRArr := array_append(newGYRArr, storedGYR);

      -- New range entirely before stored: flush new, then keep stored
      ELSIF newYUpp < storedYLow THEN
        newGYRArr := array_append(newGYRArr, (geom, newYLow, newYUpp)::geomlowuppval);
        newGYRArr := array_append(newGYRArr, storedGYR);
        newYLow := NULL; newYUpp := NULL;

      -- Ranges overlap: split into up-to-3 segments
      ELSE
        -- Segment before overlap (whichever range starts first)
        IF newYLow < storedYLow THEN
          newGYRArr := array_append(newGYRArr, (geom, newYLow, storedYLow - 1)::geomlowuppval);
        ELSIF storedYLow < newYLow THEN
          newGYRArr := array_append(newGYRArr, ((storedGYR).geom, storedYLow, newYLow - 1)::geomlowuppval);
        END IF;

        -- Overlapping segment (merged geometry)
        newGYRArr := array_append(newGYRArr,
          (ST_Collect((storedGYR).geom, geom), GREATEST(newYLow, storedYLow), LEAST(newYUpp, storedYUpp))::geomlowuppval);

        -- Segment after overlap (whichever range ends last)
        IF newYUpp < storedYUpp THEN
          newGYRArr := array_append(newGYRArr, ((storedGYR).geom, newYUpp + 1, storedYUpp)::geomlowuppval);
          newYLow := NULL; newYUpp := NULL;
        ELSIF storedYUpp < newYUpp THEN
          newYLow := storedYUpp + 1;  -- new range continues past stored; carry remainder forward
        ELSE
          newYLow := NULL; newYUpp := NULL;  -- both ended together
        END IF;
      END IF;
    END LOOP;
  END IF;

  -- Append any remaining new range not yet consumed
  IF newYLow IS NOT NULL AND newYUpp IS NOT NULL THEN
    newGYRArr := array_append(newGYRArr, (geom, newYLow, newYUpp)::geomlowuppval);
  END IF;

  RETURN newGYRArr;
END
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE COST 500;;
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidYearUnionCombineFct(geomlowuppval[], geomlowuppval[]) CASCADE;
CREATE OR REPLACE FUNCTION TT_ValidYearUnionCombineFct(
  state1 geomlowuppval[],
  state2 geomlowuppval[]
)
RETURNS geomlowuppval[] AS $$
DECLARE
  gyr geomlowuppval;
BEGIN
  IF state1 IS NULL THEN RETURN state2; END IF;
  IF state2 IS NULL THEN RETURN state1; END IF;

  FOREACH gyr IN ARRAY state2 LOOP
    state1 := TT_ValidYearUnionStateFct(state1, (gyr).geom, (gyr).lowerVal, (gyr).upperVal);
  END LOOP;

  RETURN state1;
END
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE COST 5000;;
------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_ValidYearUnionFinalFct(geomlowuppval[]) CASCADE;
CREATE OR REPLACE FUNCTION TT_ValidYearUnionFinalFct(
  state geomlowuppval[]
)
RETURNS geomlowuppval[] AS $$
DECLARE
  g geomlowuppval;
  result geomlowuppval[] := ARRAY[]::geomlowuppval[];
BEGIN

  IF state IS NULL THEN
    RETURN NULL;
  END IF;

  FOREACH g IN ARRAY state LOOP
    result := array_append(
      result,
      (
        ST_Multi(ST_UnaryUnion(g.geom)),
        g.lowerVal,
        g.upperVal
      )::geomlowuppval
    );
  END LOOP;

  RETURN result;

END
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE COST 5000;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--DROP AGGREGATE IF EXISTS TT_ValidYearUnion(geometry, int, int);
CREATE OR REPLACE AGGREGATE TT_ValidYearUnion(
  geom geometry,
  yearLower int,
  yearUpper int
) (
  STYPE = geomlowuppval[],
  SFUNC = TT_ValidYearUnionStateFct,
  COMBINEFUNC = TT_ValidYearUnionCombineFct,
  FINALFUNC = TT_ValidYearUnionFinalFct,
  INITCOND = '{}',
  PARALLEL = SAFE
);

------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_UnnestValidYearUnion() aggregate state function
------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_UnnestValidYearUnion(geomlowuppval[]);
CREATE OR REPLACE FUNCTION TT_UnnestValidYearUnion(
  gluv geomlowuppval[]
) RETURNS TABLE (lowerVal int, upperVal int, geom geometry) AS $$
  WITH unnested AS (
    SELECT unnest(gluv) unnestedGluv
  )
  SELECT (unnestedGluv).lowerVal, (unnestedGluv).upperVal, (unnestedGluv).geom
  FROM unnested
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_PolygonGeoHistory()
--
-- Logic table
-- Overlapping polygons are treated starting with 1) the same year 
-- ones, then 2) the older ones and finally 3) the newer ones as 
-- they are ordered in the ovlpPolyQuery.
--
-- 1) Same year polygons with higher precedence are first removed 
-- from preValidYearPoly (prePoly).
--
-- 2) Then a new postValidYearPoly (postPoly) is initialized from prePoly and all 
-- past polygons are removed from prePoly (when they are valid). prePoly is no 
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
-- |    0 (same)   |       F       |    T    |    T    | (A - B) RefYB -> RefYE |   B   | IF postPoly IS NOT NULL                    | ovlpPoly has precedence over prePoly 
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
               valid_time_id text) AS $$
  DECLARE
    debug_l1 boolean = TT_Debug(1);
    debug_l2 boolean = TT_Debug(2);
    --debug_l2 boolean = true;
    debugID int = 0;

    ovlpPolyQuery text;

    currentRow RECORD;
    ovlpRow RECORD;

    refYearBegin int = 1900;
    refYearEnd int = 2030;
    smallestPolyArea double precision = 0.0001; -- 1 square cm
    safeGridSize  double precision = 0.01; -- 1 cm
        
    preValidYearPoly geometry;
    preValidYearPolyYearEnd int;
    postValidYearPoly geometry;
    postValidYearPolyYearBegin int;

    oldOvlpPolyYear int;
    
    hasPrecedence boolean;
    
    time timestamptz;
    justBeforeSafeDiff boolean = FALSE;
    diffCnt int;
    --safeDiff boolean;
    justBeforeSafeOvlp boolean = FALSE;
    ovlpCnt int;
  BEGIN
    --IF poly_photo_year IS NULL OR poly_photo_year < refYearBegin THEN
    IF poly_photo_year IS NULL OR poly_photo_year < 0 THEN
      poly_photo_year = refYearBegin;
    END IF;
    -- Prepare the nested LOOP query looping through polygons overlapping the current main loop polygons
    ovlpPolyQuery = format('
SELECT  %1$I::text gh_row_id, 
        %2$I gh_geom, 
        CASE WHEN %3$I < 0 OR %3$I IS NULL THEN %4$s ELSE %3$I END gh_photo_year, 
        %5$I::text gh_inv, 
        %6$s gh_is_valid 
FROM %7$I.%8$I
WHERE %1$I::text != %9$L AND ($1 && %2$I) AND TT_SafeOverlaps($1, %2$I, %10$s, %9$L, %1$I, TRUE, FALSE, ''main loop'') ORDER BY gh_photo_year;',
      idColName, 
      geoColName,
      photoYearColName, 
      refYearBegin, 
      precedenceColName, 
      CASE WHEN validityColNames IS NULL THEN 'TRUE' ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, '::text,') || '::text])' END,
      schemaName, 
      tableName,
      poly_row_id,
      safeGridSize
    );

    IF debug_l2 THEN RAISE NOTICE E'000 3333 ovlpPolyQuery = \n%\n', ovlpPolyQuery;END IF;
    
    time = clock_timestamp();
    IF debug_l2 THEN RAISE NOTICE 'Setting diffCnt to 0...';END IF;
    diffCnt = 0;
    IF debug_l2 THEN RAISE NOTICE 'Setting ovlpCnt to 0...';END IF;
    ovlpCnt = 0;
    --safeDiff = FALSE;
    -- Here we loop until a satistactory set of historical polygon has been intersected first 
    -- using the unsafe version of ST_Difference() (diffCnt = 0) and the unsafe version of 
    -- ST_Overlaps() (ovlpCnt = 0) and then with safe versions of them (diffCnt = 1 or ovlpCnt = 1)
    IF (debug_l1 OR debug_l2) AND diffCnt = 0 THEN RAISE NOTICE '****************************************************************';END IF;
    IF debug_l1 OR debug_l2 THEN RAISE NOTICE '000 Processing main polygon with polyID %. photo_year=%', poly_row_id, poly_photo_year;END IF;
    WHILE diffCnt < 2 AND ovlpCnt < 2 LOOP
      IF debug_l1 OR debug_l2 THEN RAISE NOTICE '-------------- SAFE DIFF % | SAFE OVLP % ---------------', upper((diffCnt = 1)::text), upper((ovlpCnt = 1)::text);END IF;
      BEGIN
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
          valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
          RAISE NOTICE '000 Debug_poly = %', left(poly_type, 50);
          RETURN NEXT;
        END IF;

        -- LOOP over all overlapping polygons sorted by photoYear ASC
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'START looping over intersecting polygons...';END IF;
        FOR ovlpRow IN EXECUTE ovlpPolyQuery 
        USING poly_geom LOOP
          IF debug_l2 THEN RAISE NOTICE '  ---------------------------';END IF;
          IF debug_l1 OR debug_l2 THEN RAISE NOTICE '  Processing overlapping polygon %', ovlpRow.gh_row_id;END IF;
          IF debug_l2 THEN RAISE NOTICE '  111 ovlp poly id=%, py=%, inv=%, isvalid=%', ovlpRow.gh_row_id, ovlpRow.gh_photo_year, ovlpRow.gh_inv, ovlpRow.gh_is_valid;END IF;
          IF debug_l2 THEN RAISE NOTICE '  111 ovlp_area=%', ST_Area(ST_Intersection(poly_geom, ovlpRow.gh_geom));END IF;

          -----------------------------------------------------------
          -- CASE B - (A - B) RefYB -> RefYE (see logic table above)
          -----------------------------------------------------------
          IF debug_l2 THEN RAISE NOTICE E'  111 calling TT_HasPrecedence(''%'', ''%'', ''%'', ''%'', %, %)', poly_inv, poly_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id, 'true', 'true';END IF;
          hasPrecedence = TT_HasPrecedence(poly_inv, poly_row_id, ovlpRow.gh_inv, ovlpRow.gh_row_id, true, true);
          IF debug_l2 THEN RAISE NOTICE E'  111 hasPrecedence = %\n', hasPrecedence;END IF;
         
          IF (ovlpRow.gh_photo_year = poly_photo_year AND 
             ((hasPrecedence AND NOT poly_is_valid AND ovlpRow.gh_is_valid) OR
             (NOT hasPrecedence AND (NOT poly_is_valid OR (poly_is_valid AND ovlpRow.gh_is_valid))))) OR
             (ovlpRow.gh_photo_year < poly_photo_year AND NOT poly_is_valid AND ovlpRow.gh_is_valid) OR
             (ovlpRow.gh_photo_year > poly_photo_year AND NOT poly_is_valid) THEN
            IF debug_l2 THEN RAISE NOTICE '  AAA.1 CASE SAME YEAR: Remove ovlpPoly from prePoly. ovlp.py = %', ovlpRow.gh_photo_year;END IF;

            justBeforeSafeDiff = TRUE;
            preValidYearPoly = TT_SafeDifference(preValidYearPoly, ovlpRow.gh_geom, safeGridSize, 'preValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, diffCnt > 0, TRUE, 'case B1');
            justBeforeSafeDiff = FALSE;
            
            preValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(preValidYearPoly, 3), smallestPolyArea));
            IF debug_l2 THEN
              wkb_geometry = preValidYearPoly;
              poly_type = 'debug_' || debugID || '_preValid_666_same_year_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
              debugID = debugID + 1;
              valid_year_begin = refYearBegin;
              valid_year_end = preValidYearPolyYearEnd;
              valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
              RAISE NOTICE '  AAA.2 Debug_poly = %', left(poly_type, 50);
              RETURN NEXT;
            END IF;

            IF postValidYearPoly IS NOT NULL THEN
              justBeforeSafeDiff = TRUE;
              postValidYearPoly = TT_SafeDifference(postValidYearPoly, ovlpRow.gh_geom, safeGridSize, 'postValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, diffCnt > 0, TRUE, 'case B2');
              justBeforeSafeDiff = FALSE;

              postValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
              IF debug_l2 THEN
                wkb_geometry = postValidYearPoly;
                poly_type = 'debug_' || debugID || '_postValid_666_same_year_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
                debugID = debugID + 1;
                valid_year_begin = postValidYearPolyYearBegin;
                valid_year_end = refYearEnd;
                valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
                RAISE NOTICE '  AAA.3 Debug_poly = %', left(poly_type, 50);
                RETURN NEXT;
              END IF;
            END IF;

            IF debug_l2 THEN RAISE NOTICE '  AAA CASE SAME YEAR Done';END IF;

          -----------------------------------------------------------
          -- CASE C - (A - B) RefYB -> AY - 1 and A AY -> RefYE (see logic table above)
          -----------------------------------------------------------
          ELSIF ovlpRow.gh_photo_year < poly_photo_year AND poly_is_valid AND ovlpRow.gh_is_valid THEN
            IF debug_l2 THEN RAISE NOTICE '  CCC CASE 2: Initialize postPoly and remove ovlpPoly from prePoly. ovlp.py = %', ovlpRow.gh_photo_year;END IF;

            postValidYearPoly = coalesce(postValidYearPoly, preValidYearPoly);
            postValidYearPolyYearBegin = poly_photo_year;

            justBeforeSafeDiff = TRUE;
            preValidYearPoly = TT_SafeDifference(preValidYearPoly, ovlpRow.gh_geom, safeGridSize, 'preValidYearPoly from ' || poly_row_id, ovlpRow.gh_row_id, diffCnt > 0, TRUE, 'case C');
            justBeforeSafeDiff = FALSE;

            preValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(preValidYearPoly, 3), smallestPolyArea));
            IF (poly_photo_year - 1) < refYearBegin THEN RAISE NOTICE 'TT_PolygonGeoHistory() - WARNING: Case C would have set preValidYearPolyYearEnd to a value smaller than refYearBegin. You might consider setting refYearBegin to a smaller value...';END IF;
            preValidYearPolyYearEnd = greatest(poly_photo_year - 1, refYearBegin);
            
            IF debug_l2 THEN
              wkb_geometry = preValidYearPoly;
              poly_type = 'debug_' || debugID || '_preValid_777_case_2_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
              debugID = debugID + 1;
              valid_year_begin = refYearBegin;
              valid_year_end = preValidYearPolyYearEnd;
              valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
              RAISE NOTICE '  CCC Debug_poly = %', left(poly_type, 50);
              RETURN NEXT;
            END IF;
            IF debug_l2 THEN RAISE NOTICE '  CCC CASE 2 Done';END IF;
          -----------------------------------------------------------
          -- CASE D - A RefYB -> BY - 1 and (A - B) BY -> RefYE (see logic table above)
          -----------------------------------------------------------
          ELSIF ovlpRow.gh_photo_year > poly_photo_year AND poly_is_valid AND ovlpRow.gh_is_valid THEN
            IF debug_l2 THEN RAISE NOTICE '  DDD CASE 3: Return intermediate postPoly and set the next one by removing ovlpPoly. ovlp.ph = %', ovlpRow.gh_photo_year;END IF;

            -- Make sure the last computed polygon still intersect with ovlpPoly
            justBeforeSafeOvlp = TRUE;
            --IF TT_GeoHistoryOverlaps(ovlpRow.gh_geom, coalesce(postValidYearPoly, preValidYearPoly)) THEN
            IF TT_SafeOverlaps(ovlpRow.gh_geom, coalesce(postValidYearPoly, preValidYearPoly), safeGridSize, 'coalesce(postValidYearPoly, preValidYearPoly) from ' || poly_row_id, ovlpRow.gh_row_id, ovlpCnt > 0, TRUE, 'case D') THEN
              justBeforeSafeOvlp = FALSE;
              IF debug_l2 THEN RAISE NOTICE '  DDD: TT_SafeOverlaps() worked...';END IF;
              IF oldOvlpPolyYear IS NOT NULL AND oldOvlpPolyYear != ovlpRow.gh_photo_year AND postValidYearPoly IS NOT NULL THEN
                poly_id = poly_id + 1;
                wkb_geometry = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
                IF wkb_geometry IS NOT NULL AND NOT ST_IsEmpty(wkb_geometry) AND ST_Area(wkb_geometry) > smallestPolyArea THEN
                  poly_type = '2_post_1';
                  valid_year_begin = postValidYearPolyYearBegin;
                  
                  IF (ovlpRow.gh_photo_year - 1) < refYearBegin THEN RAISE NOTICE 'TT_PolygonGeoHistory() - WARNING: Case D would have set valid_year_end to a value smaller than refYearBegin. You might consider setting refYearBegin to a smaller value...';END IF;
                  valid_year_end = greatest(ovlpRow.gh_photo_year - 1, refYearBegin);

                  valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
                  IF debug_l2 THEN RAISE NOTICE '  ---------';END IF;
                  IF debug_l2 THEN RAISE NOTICE '  RETURNING INTERMEDIATE postPoly valid_time_id=%', valid_time_id;END IF;
                  IF debug_l2 THEN RAISE NOTICE '  ---------';END IF;
                  RETURN NEXT;
                ELSE
                  IF debug_l2 THEN RAISE NOTICE '  DDD: postPoly is too small. No INTERMEDIATE postPoly RETURNED';END IF;
                END IF;
              ELSE
                IF debug_l2 THEN RAISE NOTICE '  DDD: (oldOvlpPolyYear IS NULL) = %', oldOvlpPolyYear IS NULL;END IF;
                IF debug_l2 THEN RAISE NOTICE '  DDD: (oldOvlpPolyYear = ovlpRow.gh_photo_year) = %', oldOvlpPolyYear = ovlpRow.gh_photo_year;END IF;
                IF debug_l2 THEN RAISE NOTICE '  DDD: (postValidYearPoly IS NULL) = %', postValidYearPoly IS NULL;END IF;
                IF debug_l2 THEN RAISE NOTICE '  DDD: No INTERMEDIATE postPoly RETURNED';END IF;
              END IF;
              justBeforeSafeOvlp = FALSE;

              justBeforeSafeDiff = TRUE;
              postValidYearPoly = TT_SafeDifference(coalesce(postValidYearPoly, preValidYearPoly), ovlpRow.gh_geom, safeGridSize, 'coalesce(postValidYearPoly, preValidYearPoly) from ' || poly_row_id, ovlpRow.gh_row_id, diffCnt > 0, TRUE, 'case D');
              justBeforeSafeDiff = FALSE;

              postValidYearPoly = ST_Multi(TT_TrimSubPolygons(ST_CollectionExtract(postValidYearPoly, 3), smallestPolyArea));
              
              postValidYearPolyYearBegin = ovlpRow.gh_photo_year;
              IF debug_l2 THEN
                wkb_geometry = postValidYearPoly;
                poly_type = 'debug_' || debugID || '_postValid_888_case_3_' || CASE WHEN wkb_geometry IS NULL THEN 'NULL' WHEN ST_IsEmpty(wkb_geometry) THEN 'EMPTY' ELSE ST_AsText(wkb_geometry) END;
                debugID = debugID + 1;
                valid_year_begin = postValidYearPolyYearBegin;
                valid_year_end = refYearEnd;
                valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
                RAISE NOTICE '  DDD: Debug_poly = %', left(poly_type, 50);
                RETURN NEXT;
              END IF;
              
              IF (ovlpRow.gh_photo_year - 1) < refYearBegin THEN RAISE NOTICE 'TT_PolygonGeoHistory() - WARNING: Case D would have set preValidYearPolyYearEnd to a value smaller than refYearBegin. You might consider setting refYearBegin to a smaller value...';END IF;
              preValidYearPolyYearEnd = least(preValidYearPolyYearEnd, greatest(ovlpRow.gh_photo_year - 1, refYearBegin));
            ELSE
              IF debug_l2 THEN RAISE NOTICE '  DDD: TT_GeoHistoryOverlaps() is FALSE';END IF;
            END IF;
            IF debug_l2 THEN RAISE NOTICE '  DDD CASE 3 Done';END IF;
          ELSE
            IF debug_l2 THEN RAISE NOTICE '  EEE Overlapping polygon does not have precedence. Done';END IF;
          END IF;
          oldOvlpPolyYear = ovlpRow.gh_photo_year;
        END LOOP;
        IF debug_l1 OR debug_l2 THEN RAISE NOTICE '  Everything went fine. Setting diffCnt and ovlpCnt to 2 to end the loop...';END IF;
        diffCnt = 2;
        ovlpCnt = 2;
      EXCEPTION WHEN OTHERS THEN
        IF justBeforeSafeDiff THEN
          -- Stop if it's the second attempt with the safe version of the difference function
          IF diffCnt = 1 THEN RAISE EXCEPTION 'TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on %...', poly_row_id;END IF;
          IF debug_l1 OR debug_l2 THEN RAISE NOTICE '  Setting diffCnt to 1...';END IF;
          diffCnt = 1;
          --safeDiff = TRUE;
        ELSIF justBeforeSafeOvlp THEN
          -- Stop if it's the second attempt with the safe version of the overlaps function
          IF ovlpCnt = 1 THEN RAISE EXCEPTION 'TT_PolygonGeoHistory() ERROR: TT_SafeOverlaps() failed on %...', poly_row_id;END IF;
          IF debug_l1 OR debug_l2 THEN RAISE NOTICE '  Setting ovlpCnt to 1...';END IF;
          ovlpCnt = 1;
          --safeOvlp = TRUE;
        ELSE
          RAISE EXCEPTION 'TT_PolygonGeoHistory() FATAL ERROR: Unknown error %', SQLERRM;
        END IF;
      END;
    END LOOP; -- WHILE
    IF debug_l1 OR debug_l2 THEN RAISE NOTICE 'END looping over intersecting polygons...';END IF;
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
        valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
        IF debug_l2 THEN RAISE NOTICE 'RETURNING FINAL postPoly valid_time_id=%', valid_time_id;END IF;
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
        valid_time_id = id || '_' || valid_year_begin || '-' || valid_year_end;
        IF debug_l2 THEN RAISE NOTICE 'RETURNING prePoly valid_time_id=%', valid_time_id;END IF;
        RETURN NEXT;
      END IF;
    END IF;
    IF debug_l1 OR debug_l2 THEN RAISE NOTICE  'TOOK % SECONDS', EXTRACT(EPOCH FROM clock_timestamp() - time);END IF;
  END
$$ LANGUAGE plpgsql VOLATILE;
------------------------------------------------------------------------------

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
               valid_time_id text) AS $$
 SELECT TT_PolygonGeoHistory(poly_inv, poly_row_id, 1930, TRUE, poly_geom, schemaName, tableName, idColName, geoColName, photoYearColName, precedenceColName, validityColNames);
$$ LANGUAGE sql VOLATILE;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_TableGeoHistory()
--
-- Generate the geohistory table for an arbitrary table.
-- TT_ProduceInvGeoHistory() and TT_ProduceInvGeoHistory2Steps() generate the 
-- table for a whole inventory.
------------------------------------------------------------------------------
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
               valid_time_id text) AS $$
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
    currentPolyQuery = format('
SELECT %1$I::text gh_inv, %2$I::text gh_row_id, %3$I gh_photo_year, %4$s gh_is_valid, %5$I gh_geom
FROM %6$I.%7$I' ||
--' WHERE ' || quote_ident(idColName) || '::text = ''NB01-xxxxxxxxxFOREST-xxxxxxxxxx-0000083722-0242567'' ' ||
' ORDER BY gh_photo_year DESC;
', precedenceColName, 
   idColName, 
   photoYearColName, 
   CASE WHEN validityColNames IS NULL THEN 'TRUE' 
        ELSE 'TT_RowIsValid(ARRAY[' || array_to_string(validityColNames, '::text,') || '::text])' 
   END,
   geoColName,
   schemaName,
   tableName
    );
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
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TT_GeoOblique()
--
-- Make a polygon look like it is stacked in 3D considering its beginning year of validity
------------------------------------------------------------------------------
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

------------------------------------------------------------------------------
-- TT_GeoHistoryOblique()
--
-- Make geo history polygons look like they are stacked in 3D considering their beginning year of validity
------------------------------------------------------------------------------
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
               valid_time_id text) AS $$
  SELECT id, 
          isvalid,
          TT_GeoOblique(wkb_geometry, valid_year_begin, z_factor, y_factor) wkb_geometry,
          poly_type,
          ref_year,
          valid_year_begin, 
          valid_year_end,
          valid_time_id
  FROM TT_TableGeoHistory(schemaName, tableName, idColName, geoColName, photoYearColName, precedenceColName, validityColNames);
$$ LANGUAGE sql IMMUTABLE;
------------------------------------------------------------------------------
