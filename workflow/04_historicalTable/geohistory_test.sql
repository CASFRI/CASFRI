-- Create a test table
DROP TABLE IF EXISTS test_geohistory CASCADE;
CREATE TABLE test_geohistory AS
SELECT 0 id, 1998 valid_year, ST_GeomFromText('POLYGON((24 13, 24 23, 34 23, 34 13, 24 13))') geom
UNION ALL
SELECT 1 id, 2000 valid_year, ST_GeomFromText('POLYGON((13 13, 13 23, 23 23, 23 13, 13 13))') geom
UNION ALL
SELECT 2 id, 2010 valid_year, ST_GeomFromText('POLYGON((9 19, 9 21, 11 21, 11 19, 9 19))') geom
UNION ALL
SELECT 3 id, 2010 valid_year, ST_GeomFromText('POLYGON((10 10, 10 20, 20 20, 20 10, 10 10))') geom
UNION ALL
SELECT 4 id, 2020 valid_year, ST_GeomFromText('POLYGON((7 7, 7 17, 17 17, 17 7, 7 7))') geom
UNION ALL
SELECT 5 id, 1998 valid_year, ST_GeomFromText('POLYGON((26 15, 26 21, 32 21, 32 15, 26 15))') geom
UNION ALL
SELECT 6 id, 1998 valid_year, ST_GeomFromText('POLYGON((25 14, 25 22, 33 22, 33 14, 25 14))') geom
;

CREATE VIEW test_geohistory_0 AS
SELECT * FROM test_geohistory
WHERE id = 0;

CREATE VIEW test_geohistory_1_3 AS
SELECT * FROM test_geohistory
WHERE id = 1 OR id = 3;

CREATE VIEW test_geohistory_2_3 AS
SELECT * FROM test_geohistory
WHERE id = 2 OR id = 3;

CREATE VIEW test_geohistory_0_5 AS
SELECT * FROM test_geohistory
WHERE id = 0 OR id = 5;

CREATE VIEW test_geohistory_5_6 AS
SELECT * FROM test_geohistory
WHERE id = 5 OR id = 6;


SELECT '17.1'::text number,
       'TT_GeoHistory'::text function_tested,
       'One polygon'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13))' AND
        ref_year = 1998 AND
        valid_year_begin = 1990 AND 
        valid_year_end = 3000 passed
FROM TT_GeoHistory('public', 'test_geohistory_0', 'id', 'geom', 'valid_year')
---------------------------------------------------------
UNION ALL
SELECT '17.2'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((13 20,13 23,23 23,23 13,20 13,20 20,13 20)), POLYGON((13 13,13 23,23 23,23 13,13 13))' AND
        string_agg(ref_year::text, ', ') = '2000, 2000' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed
FROM TT_GeoHistory('public', 'test_geohistory_1_3', 'id', 'geom', 'valid_year')
WHERE id = '1'
---------------------------------------------------------
UNION ALL
SELECT '17.3'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two overlapping polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10)), POLYGON((10 10,10 20,13 20,13 13,20 13,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010, 2010' AND
        string_agg(valid_year_begin::text, ', ') = '2010, 1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000, 2009' passed
FROM TT_GeoHistory('public', 'test_geohistory_1_3', 'id', 'geom', 'valid_year')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '17.4'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 1)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((9 19,9 21,11 21,11 20,10 20,10 19,9 19))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_2_3', 'id', 'geom', 'valid_year')
WHERE id = '2'
---------------------------------------------------------
UNION ALL
SELECT '17.5'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons (polygon 2)'::text description,
        string_agg(ST_AsText(wkb_geometry), ', ') = 'POLYGON((10 10,10 20,20 20,20 10,10 10))' AND
        string_agg(ref_year::text, ', ') = '2010' AND
        string_agg(valid_year_begin::text, ', ') = '1990' AND 
        string_agg(valid_year_end::text, ', ') = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_2_3', 'id', 'geom', 'valid_year')
WHERE id = '3'
---------------------------------------------------------
UNION ALL
SELECT '17.6'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 1)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((24 13,24 23,34 23,34 13,24 13),(26 15,32 15,32 21,26 21,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_0_5', 'id', 'geom', 'valid_year')
WHERE id = '0'
---------------------------------------------------------
UNION ALL
SELECT '17.7'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one completely inside the other (polygon 2)'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((26 15,26 21,32 21,32 15,26 15))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_0_5', 'id', 'geom', 'valid_year')
WHERE id = '5'
---------------------------------------------------------
UNION ALL
SELECT '17.8'::text number,
       'TT_GeoHistory'::text function_tested,
       'Two same year polygons one with lower priority completely inside the other'::text description,
        ST_AsText(wkb_geometry) = 'POLYGON((25 14,25 22,33 22,33 14,25 14))' AND
        ref_year::text = '1998' AND
        valid_year_begin::text = '1990' AND 
        valid_year_end::text = '3000' passed
FROM TT_GeoHistory('public', 'test_geohistory_5_6', 'id', 'geom', 'valid_year')
---------------------------------------------------------
;

