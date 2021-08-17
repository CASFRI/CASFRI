------------------------------------------------------------------------------
-- CASFRI - Geo history functions test script for CASFRI v5
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
CREATE SCHEMA IF NOT EXISTS casfri50_history_test;
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
-- Create a spatial table of sampling areas having two 
-- or more inventories with different photo_years
DROP TABLE IF EXISTS casfri50_history_test.sampling_areas;
CREATE TABLE casfri50_history_test.sampling_areas AS
SELECT 'NB1' id, 'NB01 (2009) and NB02 (2009)' description, ST_MakeEnvelope(2200000, 1200000, 2210000, 1210000, 900914) geometry
UNION ALL
SELECT 'NB2' id, 'NB01 (2004) and NB02 (2014)', ST_MakeEnvelope(2200000, 1100000, 2210000, 1110000, 900914) geometry
UNION ALL
SELECT 'NT1' id, 'NT01 (-9999) and NT03 (1970)', ST_MakeEnvelope(-1400000, 2600000, -1390000, 2610000, 900914) geometry
UNION ALL
SELECT 'NT2' id, 'NT01 (2003-2006) and NT03 (2003-2006)', ST_MakeEnvelope(-1200000, 2600000, -1190000, 2610000, 900914) geometry
UNION ALL
SELECT 'BC1' id, 'BC08 (2005-2015) and BC10 (2018)', ST_MakeEnvelope(-1940000, 1980000, -1930000, 1990000, 900914) geometry
UNION ALL
SELECT 'BC2' id, 'BC08 (1965-2015) and BC10 (2012-2017)', ST_MakeEnvelope(-1810000, 1800000, -1800000, 1810000, 900914) geometry
UNION ALL
SELECT 'SK1' id, 'SK01 (1971-2001) and SK02 (2004-2012)', ST_MakeEnvelope(-580000, 1500000, -570000, 1510000, 900914) geometry
UNION ALL
SELECT 'SK2' id, 'SK01 (1971-2001), SK04 (1998-2005) and SK05 (1998-2004)', ST_MakeEnvelope(-610000, 1570000, -600000, 1580000, 900914) geometry
UNION ALL
SELECT 'SK3' id, 'SK01 (1971-2001) and SK03 (2008-2008)', ST_MakeEnvelope(-802000, 1665000, -792000, 1675000, 900914) geometry
UNION ALL
SELECT 'SK4' id, 'SK01 (1971-2001) and SK06 (1994-2005)', ST_MakeEnvelope(-840000, 1800000, -830000, 1810000, 900914) geometry
;

/* Display
SELECT * FROM casfri50_history_test.sampling_areas;
*/
--------------------------------------------------------------------------------------
-- Sampling area NB1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb1;
CREATE TABLE casfri50_history_test.sampling_area_nb1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE s.id = 'NB1' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_nb1_geom_idx ON casfri50_history_test.sampling_area_nb1 USING gist(geometry);
CREATE INDEX sampling_area_nb1_casid_idx ON casfri50_history_test.sampling_area_nb1 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_nb1;
*/

-- Generate history table not taking attribute values validity into account - pg11: 1m51, 794 rows. pg13: 11s, 783 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb1_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nb1_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
--SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, wkb_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_nb1', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_nb1) foo
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nb1_history_new
ORDER BY id, valid_year_begin;
*/
-----------------------------------------
/*
-- Generate history table taking attribute values validity into account
SELECT * FROM casfri50_history_test.sampling_area_nb1 LIMIT 100;

SELECT unnest(TT_TableColumnNames('casfri50_history_test', 'sampling_area_nb1'));

-- Check if any rows can be considered not valid (all requested attributes values are NULL or empty)
SELECT * FROM casfri50_history_test.sampling_area_nb1
WHERE NOT TT_RowIsValid(ARRAY[lyr1_soil_moist_reg::text, lyr1_species_1::text, lyr1_species_2::text, lyr1_species_3::text, lyr1_species_4::text, lyr1_species_5::text, lyr1_species_6::text, 
                              lyr1_site_class::text, lyr1_site_index::text, 
                              lyr2_soil_moist_reg::text, lyr2_species_1::text, lyr2_species_2::text, lyr2_species_3::text, lyr2_species_4::text, lyr2_species_5::text, lyr2_species_6::text, 
                              lyr2_site_class::text, lyr2_site_index::text, 
                              nfl1_soil_moist_reg::text, nfl1_nat_non_veg::text, nfl1_non_for_anth::text, nfl1_non_for_veg::text, 
                              nfl2_soil_moist_reg::text, nfl2_nat_non_veg::text, nfl2_non_for_anth::text, nfl2_non_for_veg::text, 
                              dist_type_1::text, dist_year_1::text, dist_type_2::text, dist_year_2::text, dist_type_3::text, dist_year_3::text]);

DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb1_history_with_validity_new;
CREATE TABLE casfri50_history_test.sampling_area_nb1_history_with_validity_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM TT_TableGeoHistory('casfri50_history_test', 'sampling_area_nb1', 'cas_id', 'geometry', 
                        'photo_year', 'inventory_id', 
                        ARRAY['lyr1_soil_moist_reg', 'lyr1_species_1', 'lyr1_species_2', 'lyr1_species_3', 'lyr1_species_4', 'lyr1_species_5', 'lyr1_species_6', 
                        'lyr1_site_class', 'lyr1_site_index',
                        'lyr2_soil_moist_reg', 'lyr2_species_1', 'lyr2_species_2', 'lyr2_species_3', 'lyr2_species_4', 'lyr2_species_5', 'lyr2_species_6', 
                        'lyr2_site_class', 'lyr2_site_index', 
                        'nfl1_soil_moist_reg', 'nfl1_nat_non_veg', 'nfl1_non_for_anth', 'nfl1_non_for_veg', 
                        'nfl2_soil_moist_reg', 'nfl2_nat_non_veg', 'nfl2_non_for_anth', 'nfl2_non_for_veg', 
                        'dist_type_1', 'dist_year_1', 'dist_type_2', 'dist_year_2', 'dist_type_3', 'dist_year_3'])
ORDER BY id, poly_id;

-- Display
SELECT id, valid_year_begin, valid_year_end, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nb1_history_with_validity_new
ORDER BY id, valid_year_begin;

-----------------------------------------
SELECT * FROM casfri50_history_test.sampling_area_nb1
WHERE right(cas_id, 2)::int < 75;

-- Compare performance when searching in the whole flat table
-- Bug NB02-NBHN_0000_02_WB-xxxxxxxxxx-0000002071-0002071 took 9900 seconds!
SET tt.debug_l1 TO TRUE;
-- 60 57s
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb1_history_new2;
CREATE TABLE casfri50_history_test.sampling_area_nb1_history_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_nb1
WHERE right(cas_id, 2)::int < 72
ORDER BY id, poly_id;
*/
--------------------------------------------------------------------------------------
-- Sampling area NB2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb2;
CREATE TABLE casfri50_history_test.sampling_area_nb2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE s.id = 'NB2' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_nb2_geom_idx ON casfri50_history_test.sampling_area_nb2 USING gist(geometry);
CREATE INDEX sampling_area_nb2_casid_idx ON casfri50_history_test.sampling_area_nb2 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_nb2;
*/

-- Generate history table - pg11: 17m07, 6670 rows, pg13: 1m26, 6594 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb2_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nb2_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_nb2', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_nb2) foo
ORDER BY id, valid_year_begin;

/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nb2_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, very long time
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nb2_history_new2;
CREATE TABLE casfri50_history_test.sampling_area_nb2_history_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_nb2
ORDER BY id, poly_id;
*/
--------------------------------------------------------------------------------------
-- Sampling area 'NT1'
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt1;
CREATE TABLE casfri50_history_test.sampling_area_nt1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE s.id = 'NT1' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_nt1_geom_idx ON casfri50_history_test.sampling_area_nt1 USING gist(geometry);
CREATE INDEX sampling_area_nt1_casid_idx ON casfri50_history_test.sampling_area_nt1 USING btree(cas_id);

/*  Display
SELECT * FROM casfri50_history_test.sampling_area_nt1;
*/

-- Generate history table - pg11: 6m14, 1183 rows, pg13: 22s, 1130 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt1_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nt1_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_nt1', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_nt1) foo
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nt1_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 9m46
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt1_history_new2;
CREATE TABLE casfri50_history_test.sampling_area_nt1_history_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_nt1
ORDER BY id, poly_id;
*/

--------------------------------------------------------------------------------------
-- Sampling area 'NT2'
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt2;
CREATE TABLE casfri50_history_test.sampling_area_nt2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE s.id = 'NT2' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_nt2_geom_idx ON casfri50_history_test.sampling_area_nt2 USING gist(geometry);
CREATE INDEX sampling_area_nt2_casid_idx ON casfri50_history_test.sampling_area_nt2 USING btree(cas_id);

/*  Display
SELECT * FROM casfri50_history_test.sampling_area_nt2;
*/

-- Generate history table - pg11: 4m50, 1028 rows, pg13: 13s, 520 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt2_history_new;
CREATE TABLE casfri50_history_test.sampling_area_nt2_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_nt2', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_nt2) foo
ORDER BY id, valid_year_begin;

/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_nt2_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 13m38
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_nt2_history_new2;
CREATE TABLE casfri50_history_test.sampling_area_nt2_history_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_nt2
ORDER BY id, poly_id;
*/
--------------------------------------------------------------------------------------
-- Sampling area BC1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc1;
CREATE TABLE casfri50_history_test.sampling_area_bc1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE s.id = 'BC1' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_bc1_geom_idx ON casfri50_history_test.sampling_area_bc1 USING gist(geometry);
CREATE INDEX sampling_area_bc1_casid_idx ON casfri50_history_test.sampling_area_bc1 USING btree(cas_id);

/*  Display
SELECT * FROM casfri50_history_test.sampling_area_bc1;
*/

-- Generate history table - pg11: 3m11, 4430 rows, pg13: 30s, 4409 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc1_history_new;
CREATE TABLE casfri50_history_test.sampling_area_bc1_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_bc1', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_bc1) foo
ORDER BY id, valid_year_begin;
 
/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_bc1_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 3m37
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc1_history_new2;
CREATE TABLE casfri50_history_test.sampling_area_bc1_history_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_bc1
ORDER BY id, poly_id;
*/
--------------------------------------------------------------------------------------
-- Sampling area BC2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc2;
CREATE TABLE casfri50_history_test.sampling_area_bc2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE s.id = 'BC2' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_bc2_geom_idx ON casfri50_history_test.sampling_area_bc2 USING gist(geometry);
CREATE INDEX sampling_area_bc2_casid_idx ON casfri50_history_test.sampling_area_bc2 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_bc2;
*/

-- Generate history table - pg11: xmx, xxxx rows, pg13: 1m41, 8888 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc2_history_new;
CREATE TABLE casfri50_history_test.sampling_area_bc2_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_bc2', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_bc2) foo
ORDER BY id, valid_year_begin;
 
/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_bc2_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 2m40
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_bc2_history_polyperpoly_new2;
CREATE TABLE casfri50_history_test.sampling_area_bc2_history_polyperpoly_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_bc2
ORDER BY id, poly_id;
*/

--------------------------------------------------------------------------------------
-- Sampling area SK1
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk1;
CREATE TABLE casfri50_history_test.sampling_area_sk1 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE lower(s.id) = 'sk1' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_sk1_geom_idx ON casfri50_history_test.sampling_area_sk1 USING gist(geometry);
CREATE INDEX sampling_area_sk1_casid_idx ON casfri50_history_test.sampling_area_sk1 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_sk1;
*/

-- Generate history table - pg11: 2m19, 3662 rows, pg13: 17s, 3653 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk1_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk1_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_sk1', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_sk1) foo
ORDER BY id, valid_year_begin;

/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk1_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 2m34
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk1_history_new2;
CREATE TABLE casfri50_history_test.sampling_area_sk1_history_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_sk1
ORDER BY id, poly_id;
*/

--------------------------------------------------------------------------------------
-- Sampling area SK2
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk2;
CREATE TABLE casfri50_history_test.sampling_area_sk2 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE lower(s.id) = 'sk2' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_sk2_geom_idx ON casfri50_history_test.sampling_area_sk2 USING gist(geometry);
CREATE INDEX sampling_area_sk2_casid_idx ON casfri50_history_test.sampling_area_sk2 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_sk2;
*/

-- Generate history table - pg11: 5m19, 4506 rows, pg13: 2m54, 4122 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk2_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk2_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_sk2', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_sk2) foo
ORDER BY id, valid_year_begin;

-- Display
/*
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk2_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 7m20
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk2_history_polyperpoly_new2;
CREATE TABLE casfri50_history_test.sampling_area_sk2_history_polyperpoly_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_sk2
ORDER BY id, poly_id;
*/
--------------------------------------------------------------------------------------
-- Sampling area SK3
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk3;
CREATE TABLE casfri50_history_test.sampling_area_sk3 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE lower(s.id) = 'sk3' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_sk3_geom_idx ON casfri50_history_test.sampling_area_sk3 USING gist(geometry);
CREATE INDEX sampling_area_sk3_casid_idx ON casfri50_history_test.sampling_area_sk3 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_sk3;
*/

-- Generate history table - pg11: 3m21, 3407 rows, pg13: 29s, 3390 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk3_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk3_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_sk3', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_sk3) foo
ORDER BY id, valid_year_begin;

/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk3_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 4m08
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk3_history_polyperpoly_new2;
CREATE TABLE casfri50_history_test.sampling_area_sk3_history_polyperpoly_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_sk3
ORDER BY id, poly_id;
*/
--------------------------------------------------------------------------------------
-- Sampling area SK4
--------------------------------------------------------------------------------------
-- Intersect with CASFRI
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk4;
CREATE TABLE casfri50_history_test.sampling_area_sk4 AS
SELECT CASE WHEN stand_photo_year < 1900 THEN NULL ELSE stand_photo_year END photo_year, cas.* 
FROM casfri50_flat.cas_flat_all_layers_same_row cas, casfri50_history_test.sampling_areas s
WHERE lower(s.id) = 'sk4' AND ST_Intersects(cas.geometry, s.geometry)
ORDER BY cas_id;

CREATE INDEX sampling_area_sk4_geom_idx ON casfri50_history_test.sampling_area_sk4 USING gist(geometry);
CREATE INDEX sampling_area_sk4_casid_idx ON casfri50_history_test.sampling_area_sk4 USING btree(cas_id);

/* Display
SELECT * FROM casfri50_history_test.sampling_area_sk4;
*/

-- Generate history table - pg11: 3m05, 4718 rows, pg13: 30s, 4670 rows
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk4_history_new;
CREATE TABLE casfri50_history_test.sampling_area_sk4_history_new AS
SELECT id, poly_id, poly_type, ref_year, valid_year_begin, valid_year_end, valid_time, ST_AsText(wkb_geometry) wkt_geometry
FROM (SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_history_test', 'sampling_area_sk4', 'cas_id', 'geometry', 'photo_year', 'inventory_id')).*
      FROM casfri50_history_test.sampling_area_sk4) foo
ORDER BY id, valid_year_begin;

/* Display
SELECT id, valid_year_begin, valid_year_end, ST_Area(wkt_geometry) area, wkt_geometry, ST_GeomFromText(wkt_geometry) geom
FROM casfri50_history_test.sampling_area_sk4_history_new
ORDER BY id, valid_year_begin;
*/

/*
-- Compare performance when searching in the whole flat table, 4m24
DROP TABLE IF EXISTS casfri50_history_test.sampling_area_sk4_history_polyperpoly_new2;
CREATE TABLE casfri50_history_test.sampling_area_sk4_history_polyperpoly_new2 AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, photo_year, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_history_test.sampling_area_sk4
ORDER BY id, poly_id;
*/
---------------------------------------------
-- Begin tests
---------------------------------------------
--SELECT * FROM (
SELECT '1.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nb1_history_new" and "sampling_area_nb1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_nb1_history_new'', ''casfri50_history_test'' , ''sampling_area_nb1_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_nb1_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nb1_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '1.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nb1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nb1') check_query
FROM TT_AreasForSignificantYears('nb1')
---------------------------------------------------------
UNION ALL
SELECT '2.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nb2_history_new" and "sampling_area_nb2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_nb2_history_new'', ''casfri50_history_test'' , ''sampling_area_nb2_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_nb2_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nb2_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '2.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nb2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nb2') check_query
FROM TT_AreasForSignificantYears('nb2')
---------------------------------------------------------
UNION ALL
SELECT '3.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nt1_history_new" and "sampling_area_nt1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_nt1_history_new'', ''casfri50_history_test'' , ''sampling_area_nt1_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_nt1_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nt1_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '3.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nt1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nt1') check_query
FROM TT_AreasForSignificantYears('nt1')
---------------------------------------------------------
UNION ALL
SELECT '4.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_nt2_history_new" and "sampling_area_nt2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_nt2_history_new'', ''casfri50_history_test'' , ''sampling_area_nt2_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_nt2_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_nt2_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '4.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_nt2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('nt2') check_query
FROM TT_AreasForSignificantYears('nt2')
---------------------------------------------------------
UNION ALL
SELECT '5.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_bc1_history_new" and "sampling_area_bc1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_bc1_history_new'', ''casfri50_history_test'' , ''sampling_area_bc1_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_bc1_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_bc1_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '5.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_bc1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('bc1') check_query
FROM TT_AreasForSignificantYears('bc1')
---------------------------------------------------------
UNION ALL
SELECT '6.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_bc2_history_new" and "sampling_area_bc2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_bc2_history_new'', ''casfri50_history_test'' , ''sampling_area_bc2_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_bc2_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_bc2_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '6.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_bc2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('bc2') check_query
FROM TT_AreasForSignificantYears('bc2')
---------------------------------------------------------
UNION ALL
SELECT '7.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk1_history_new" and "sampling_area_sk1_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_sk1_history_new'', ''casfri50_history_test'' , ''sampling_area_sk1_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_sk1_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk1_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '7.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk1_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk1') check_query
FROM TT_AreasForSignificantYears('sk1')
---------------------------------------------------------
UNION ALL
SELECT '8.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk2_history_new" and "sampling_area_sk2_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_sk2_history_new'', ''casfri50_history_test'' , ''sampling_area_sk2_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_sk2_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk2_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '8.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk2_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk2') check_query
FROM TT_AreasForSignificantYears('sk2')
---------------------------------------------------------
UNION ALL
SELECT '9.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk3_history_new" and "sampling_area_sk3_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_sk3_history_new'', ''casfri50_history_test'' , ''sampling_area_sk3_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_sk3_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk3_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '9.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk3_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk3') check_query
FROM TT_AreasForSignificantYears('sk3')
---------------------------------------------------------
UNION ALL
SELECT '10.1'::text number,
       'TT_GeoHistory'::text function_tested, 
       'Compare "sampling_area_sk4_history_new" and "sampling_area_sk4_history"' description, 
       count(*) = 0 passed,
       'SELECT * FROM TT_CompareTables(''casfri50_history_test'' , ''sampling_area_sk4_history_new'', ''casfri50_history_test'' , ''sampling_area_sk4_history'', ''id, poly_id'', TRUE);' check_query
FROM (SELECT (TT_CompareRows(to_jsonb(a), to_jsonb(b))).*
      FROM casfri50_history_test.sampling_area_sk4_history_new a 
      FULL OUTER JOIN casfri50_history_test.sampling_area_sk4_history b USING (id, poly_id)) foo
---------------------------------------------------------
UNION ALL
SELECT '10.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Test for overlaps for significant years of sampling_area_sk4_gridded_history_new' description, 
       count(*) = 0 passed,
       TT_AreasForSignificantYearsDebugQuery('sk4') check_query
FROM TT_AreasForSignificantYears('sk4')
---------------------------------------------------------
--) foo WHERE NOT passed;
