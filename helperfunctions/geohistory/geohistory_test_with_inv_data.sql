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
CREATE SCHEMA IF NOT EXISTS geohistory;
---------------------------------------------
-- Create a spatial table of sampling areas having two 
-- or more inventories with different photo_years
DROP TABLE IF EXISTS geohistory.sampling_areas;
CREATE TABLE geohistory.sampling_areas AS
SELECT 'NB1' id, 'NB01 (2009) and NB02 (2009)' description, ST_MakeEnvelope(2200000, 1200000, 2210000, 1210000, 900914) geometry
UNION ALL
SELECT 'NB2' id, 'NB01 (2004) and NB02 (2014)', ST_MakeEnvelope(2200000, 1100000, 2210000, 1110000, 900914) geometry
UNION ALL
SELECT 'NT1' id, 'NT01 (-9999) and NT02 (1970)', ST_MakeEnvelope(-1400000, 2600000, -1390000, 2610000, 900914) geometry
UNION ALL
SELECT 'NT2' id, 'NT01 (2003-2006) and NT02 (2003-2006)', ST_MakeEnvelope(-1200000, 2600000, -1190000, 2610000, 900914) geometry
UNION ALL
SELECT 'BC1' id, 'BC08 (2005-2015) and BC10 (2018)', ST_MakeEnvelope(-1940000, 1980000, -1930000, 1990000, 900914) geometry
UNION ALL
SELECT 'BC2' id, 'BC08 (1965-2015) and BC10 (2012-2017)', ST_MakeEnvelope(-1810000, 1800000, -1800000, 1810000, 900914) geometry
;

-- Display
SELECT * FROM geohistory.sampling_areas;
--------------------------------------------------------------------------------------
-- Sampling area NB1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS geohistory.sampling_area_nb1;
CREATE TABLE geohistory.sampling_area_nb1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, geohistory.sampling_areas s
WHERE s.id = 'NB1' AND ST_Intersects(cas.geometry, s.geometry);

CREATE INDEX sampling_area_nb1_geom_idx ON geohistory.sampling_area_nb1 USING gist(geometry);
CREATE INDEX sampling_area_nb1_casid_idx ON geohistory.sampling_area_nb1 USING btree(cas_id);

-- Display
SELECT * FROM geohistory.sampling_area_nb1;

-- Generate history table - ERROR
DROP TABLE IF EXISTS geohistory.sampling_area_nb1_history_new;
CREATE TABLE geohistory.sampling_area_nb1_history_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory('geohistory', 'sampling_area_nb1', 'cas_id', 'geometry', 'photo_year', 'inventory_id') --, ARRAY['att']);
      ORDER BY id, poly_id) foo;

-- Display
SELECT *, ST_Area(wkb_geometry) area, ST_GeomFromText(wkt_geometry) geom
FROM geohistory.sampling_area_nb1_history_new;

--------------------------------------------------------------------------------------
-- Sampling area NB2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS geohistory.sampling_area_nb2;
CREATE TABLE geohistory.sampling_area_nb2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, geohistory.sampling_areas s
WHERE s.id = 'NB2' AND ST_Intersects(cas.geometry, s.geometry);

CREATE INDEX sampling_area_nb2_geom_idx ON geohistory.sampling_area_nb2 USING gist(geometry);
CREATE INDEX sampling_area_nb2_casid_idx ON geohistory.sampling_area_nb2 USING btree(cas_id);

-- Display
SELECT * FROM geohistory.sampling_area_nb2;

-- Generate history table - 17m
DROP TABLE IF EXISTS geohistory.sampling_area_nb2_history_new;
CREATE TABLE geohistory.sampling_area_nb2_history_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory('geohistory', 'sampling_area_nb2', 'cas_id', 'geometry', 'photo_year', 'inventory_id') --, ARRAY['att']);
      ORDER BY id, poly_id) foo;

-- Display
SELECT *, ST_Area(ST_GeomFromText(wkt_geometry)) area, ST_GeomFromText(wkt_geometry) geom
FROM geohistory.sampling_area_nb2_history_new;
--------------------------------------------------------------------------------------
-- Sampling area 'NT1'
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS geohistory.sampling_area_nt1;
CREATE TABLE geohistory.sampling_area_nt1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, geohistory.sampling_areas s
WHERE s.id = 'NT1' AND ST_Intersects(cas.geometry, s.geometry);

CREATE INDEX sampling_area_nt1_geom_idx ON geohistory.sampling_area_nt1 USING gist(geometry);
CREATE INDEX sampling_area_nt1_casid_idx ON geohistory.sampling_area_nt1 USING btree(cas_id);

-- Display
SELECT * FROM geohistory.sampling_area_nt1;

-- Generate history table - 3m31
DROP TABLE IF EXISTS geohistory.sampling_area_nt1_history_new;
CREATE TABLE geohistory.sampling_area_nt1_history_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory('geohistory', 'sampling_area_nt1', 'cas_id', 'geometry', 'photo_year', 'inventory_id') --, ARRAY['att']);
      ORDER BY id, poly_id) foo;

-- Display
SELECT *, ST_Area(ST_GeomFromText(wkt_geometry)) area, ST_GeomFromText(wkt_geometry) geom
FROM geohistory.sampling_area_nt1_history_new;
--------------------------------------------------------------------------------------
-- Sampling area 'NT2'
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS geohistory.sampling_area_nt2;
CREATE TABLE geohistory.sampling_area_nt2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, geohistory.sampling_areas s
WHERE s.id = 'NT2' AND ST_Intersects(cas.geometry, s.geometry);

CREATE INDEX sampling_area_nt2_geom_idx ON geohistory.sampling_area_nt2 USING gist(geometry);
CREATE INDEX sampling_area_nt2_casid_idx ON geohistory.sampling_area_nt2 USING btree(cas_id);

-- Display
SELECT * FROM geohistory.sampling_area_nt2;

-- Generate history table - 4m49
DROP TABLE IF EXISTS geohistory.sampling_area_nt2_history_new;
CREATE TABLE geohistory.sampling_area_nt2_history_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory('geohistory', 'sampling_area_nt2', 'cas_id', 'geometry', 'photo_year', 'inventory_id') --, ARRAY['att']);
      ORDER BY id, poly_id) foo;

-- Display
SELECT *, ST_Area(ST_GeomFromText(wkt_geometry)) area, ST_GeomFromText(wkt_geometry) geom
FROM geohistory.sampling_area_nt2_history_new;
--------------------------------------------------------------------------------------
-- Sampling area BC1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS geohistory.sampling_area_bc1;
CREATE TABLE geohistory.sampling_area_bc1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, geohistory.sampling_areas s
WHERE s.id = 'BC1' AND ST_Intersects(cas.geometry, s.geometry);

CREATE INDEX sampling_area_bc1_geom_idx ON geohistory.sampling_area_bc1 USING gist(geometry);
CREATE INDEX sampling_area_bc1_casid_idx ON geohistory.sampling_area_bc1 USING btree(cas_id);

-- Display
SELECT * FROM geohistory.sampling_area_bc1;

-- Generate history table - 4m18
DROP TABLE IF EXISTS geohistory.sampling_area_bc1_history_new;
CREATE TABLE geohistory.sampling_area_bc1_history_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory('geohistory', 'sampling_area_bc1', 'cas_id', 'geometry', 'photo_year', 'inventory_id') --, ARRAY['att']);
      ORDER BY id, poly_id) foo;

-- Display
SELECT *, ST_Area(ST_GeomFromText(wkt_geometry)) area, ST_GeomFromText(wkt_geometry) geom
FROM geohistory.sampling_area_bc1_history_new;
--------------------------------------------------------------------------------------
-- Sampling area BC2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS geohistory.sampling_area_bc2;
CREATE TABLE geohistory.sampling_area_bc2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, geohistory.sampling_areas s
WHERE s.id = 'BC2' AND ST_Intersects(cas.geometry, s.geometry);

CREATE INDEX sampling_area_bc2_geom_idx ON geohistory.sampling_area_bc2 USING gist(geometry);
CREATE INDEX sampling_area_bc2_casid_idx ON geohistory.sampling_area_bc2 USING btree(cas_id);

-- Display
SELECT * FROM geohistory.sampling_area_bc2;

-- Generate history table - 3m51
DROP TABLE IF EXISTS geohistory.sampling_area_bc2_history_new;
CREATE TABLE geohistory.sampling_area_bc2_history_new AS
SELECT (ROW_NUMBER() OVER() - 1)::int row_id, * 
FROM (SELECT id, poly_id, isvalid, ST_AsText(wkb_geometry) wkt_geometry, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time
      FROM TT_GeoHistory('geohistory', 'sampling_area_bc2', 'cas_id', 'geometry', 'photo_year', 'inventory_id') --, ARRAY['att']);
      ORDER BY id, poly_id) foo;

-- Display
SELECT *, ST_Area(ST_GeomFromText(wkt_geometry)) area, ST_GeomFromText(wkt_geometry) geom
FROM geohistory.sampling_area_bc2_history_new;

---------------------------------------------
-- Begin tests
---------------------------------------------
SELECT * FROM (
SELECT '1.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nb1_history_new" and "sampling_area_nb1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''sampling_area_nb1_history_new'', ''geohistory'' , ''sampling_area_nb1'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.sampling_area_nb1_history_new a 
      FULL OUTER JOIN geohistory.sampling_area_nb1 b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nb2_history_new" and "sampling_area_nb2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''sampling_area_nb2_history_new'', ''geohistory'' , ''sampling_area_nb2_history'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.sampling_area_nb2_history_new a 
      FULL OUTER JOIN geohistory.sampling_area_nb2_history b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nt1_history_new" and "sampling_area_nt1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''sampling_area_nt1_history_new'', ''geohistory'' , ''sampling_area_nt1_history'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.sampling_area_nt1_history_new a 
      FULL OUTER JOIN geohistory.sampling_area_nt1_history b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nt2_history_new" and "sampling_area_nt2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''sampling_area_nt2_history_new'', ''geohistory'' , ''sampling_area_nt2_history'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.sampling_area_nt2_history_new a 
      FULL OUTER JOIN geohistory.sampling_area_nt2_history b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_bc1_history_new" and "sampling_area_bc1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''sampling_area_bc1_history_new'', ''geohistory'' , ''sampling_area_bc1_history'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.sampling_area_bc1_history_new a 
      FULL OUTER JOIN geohistory.sampling_area_bc1_history b USING (row_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_bc2_history_new" and "sampling_area_bc2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''geohistory'' , ''sampling_area_bc2_history_new'', ''geohistory'' , ''sampling_area_bc2_history'', ''row_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM geohistory.sampling_area_bc2_history_new a 
      FULL OUTER JOIN geohistory.sampling_area_bc2_history b USING (row_id)) foo
---------------------------------------------------------
) foo WHERE NOT passed;
