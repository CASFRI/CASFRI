------------------------------------------------------------------------------
-- CASFRI Historical table production script for CASFRI v5 beta
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
------------------------------------------------------------------------------
-- Compute each inventory
SELECT TT_ProduceInvGeoHistory('AB03'); --   61633, pg11: , pg13: 11m04
SELECT TT_ProduceInvGeoHistory('AB06'); --   11484, pg11: , pg13:  2m13
SELECT TT_ProduceInvGeoHistory('AB07'); --   23268, pg11: , pg13:  3m48
SELECT TT_ProduceInvGeoHistory('AB08'); --   34474, pg11: , pg13:  6m33
SELECT TT_ProduceInvGeoHistory('AB10'); --  194696, pg11: , pg13: 40m04 
SELECT TT_ProduceInvGeoHistory('AB11'); --  118624, pg11: , pg13: 14m21
SELECT TT_ProduceInvGeoHistory('AB16'); --  120476, pg11: , pg13: 15m39 
SELECT TT_ProduceInvGeoHistory('AB25'); --  527038, pg11: , pg13:  2h03
SELECT TT_ProduceInvGeoHistory('AB29'); --  620944, pg11: , pg13:  2h12
SELECT TT_ProduceInvGeoHistory('AB30'); --    4555, pg11: , pg13:  2m13
SELECT TT_ProduceInvGeoHistory('BC08'); -- 4677411, pg11: , pg13: 24h38
SELECT TT_ProduceInvGeoHistory('BC10'); -- 5151772, pg11: , pg13: 20h00
SELECT TT_ProduceInvGeoHistory('BC11'); -- 5419596, pg11: , pg13: 32h46
SELECT TT_ProduceInvGeoHistory('BC12'); -- 4861240, pg11: , pg13: 32h00
SELECT TT_ProduceInvGeoHistory('MB01'); --  134790, pg11: , pg13: 35m55
SELECT TT_ProduceInvGeoHistory('MB02'); --   60370, pg11: , pg13: 28m00
SELECT TT_ProduceInvGeoHistory('MB04'); --   27221, pg11: , pg13: 14m02
SELECT TT_ProduceInvGeoHistory('MB05'); --  514157, pg11: , pg13: 18h32
SELECT TT_ProduceInvGeoHistory('MB06'); --  160218, pg11: , pg13: 35m44
SELECT TT_ProduceInvGeoHistory('MB07'); --  219682, pg11: , pg13:  1h13
SELECT TT_ProduceInvGeoHistory('NB01'); --  927177, pg11: , pg13:  3h32
SELECT TT_ProduceInvGeoHistory('NB02'); -- 1123893, pg11: , pg13:  3h27
SELECT TT_ProduceInvGeoHistory('NL01'); -- 1863664, pg11: , pg13:  4h46
SELECT TT_ProduceInvGeoHistory('NS01'); -- 1127926, pg11: , pg13:  4h15
SELECT TT_ProduceInvGeoHistory('NS02'); -- 1090671, pg11: , pg13:  4h39
SELECT TT_ProduceInvGeoHistory('NS03'); --  995886, pg11: , pg13:  4h53
SELECT TT_ProduceInvGeoHistory('NT01'); --  281388, pg11: , pg13:  1h40
SELECT TT_ProduceInvGeoHistory('NT03'); --  320944, pg11: , pg13:  1h44
SELECT TT_ProduceInvGeoHistory('ON01'); -- 4106417, pg11: , pg13: ERROR:  TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on ON01-xxxxxxxxxxxx565-xxxxxxx565-x565048172-2713932...
SELECT TT_ProduceInvGeoHistory('ON02'); -- 3629072, pg11: , pg13: 21h14
SELECT TT_ProduceInvGeoHistory('PC01'); --    8094, pg11: , pg13:  2m08
SELECT TT_ProduceInvGeoHistory('PC02'); --    1053, pg11: , pg13: 13m36
SELECT TT_ProduceInvGeoHistory('PE01'); --  107220, pg11: , pg13: 12m41
SELECT TT_ProduceInvGeoHistory('QC01'); -- 5563194, pg11: , pg13: ERROR:  TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on QC01-xxxxxxxx32B04NO-7548550850-xxxxxx1319-xxxxxxx...
SELECT TT_ProduceInvGeoHistory('QC02'); -- 2876326, pg11: , pg13: xxhxx
SELECT TT_ProduceInvGeoHistory('QC03'); --  401188, pg11: , pg13:  1h56
SELECT TT_ProduceInvGeoHistory('QC04'); -- 2487519, pg11: , pg13:  5h35
SELECT TT_ProduceInvGeoHistory('QC05'); -- 6768074, pg11: , pg13: 21h23
SELECT TT_ProduceInvGeoHistory('QC06'); -- 4809274, pg11: , pg13: xxhxx
SELECT TT_ProduceInvGeoHistory('QC07'); --   85057, pg11: , pg13: 19m27
SELECT TT_ProduceInvGeoHistory('SK01'); -- 1501667, pg11: , pg13: ERROR:  TT_PolygonGeoHistory() ERROR: TT_SafeDifference() failed on SK01-xxxxxxxxxxxxUTM-xxxxxxxxxx-1269593033-1035665...
SELECT TT_ProduceInvGeoHistory('SK02'); --   27312, pg11: , pg13:  6m37
SELECT TT_ProduceInvGeoHistory('SK03'); --    8964, pg11: , pg13:  3m27
SELECT TT_ProduceInvGeoHistory('SK04'); --  633522, pg11: , pg13:  3h22
SELECT TT_ProduceInvGeoHistory('SK05'); --  421977, pg11: , pg13:  2h07
SELECT TT_ProduceInvGeoHistory('SK06'); --  211482, pg11: , pg13:  1h09
SELECT TT_ProduceInvGeoHistory('YT01'); --  249636, pg11: , pg13:  2h04
SELECT TT_ProduceInvGeoHistory('YT02'); --  231137, pg11: , pg13:  3h26 
SELECT TT_ProduceInvGeoHistory('YT03'); --   71073, pg11: , pg13: 22m35

-- Check counts
SELECT left(cas_id, 4) inv, count(*) cnt
FROM casfri50_history.geo_history
GROUP BY left(cas_id, 4)
ORDER BY inv;

--      new   old
-- AB03 62411 62387
-- AB06 62411 11730
-- AB07 23399 23350
-- AB08 35904 35727
-- AB10 195544 199788
-- AB11 119187 119597
-- AB16 121438 121865
-- AB25 108814 555261 x
-- AB29 665823 680556
-- AB30 4578 5771
-- BC08 718161 none x
-- BC10 251926 2321009 x
-- BC11 4161067 7414767 x
-- BC12 7728795 7396987
-- MB01 12246 129146 x
-- MB02 1291 53238 x
-- MB04 1798 24606 x
-- MB05 1653948 1750651
-- MB06 165438 167290
-- MB07 220548 362612 x
-- NB01 925337 1511925 x
-- NB02 1343646 1781853 x
-- NL01 1866227 1866027 
-- NS01 209986 404950 x
-- NS02 871378 1578368 x
-- NS03 1049044 1598055 x
-- NT01 216519 392327 x
-- NT03 332209 506328 x
-- ON01 4931335 7172675 x
-- ON02 3787142 5874657 x
-- PC01 9153 9168
-- PC02 1122 1123
-- PE01 107220 107220
-- QC01 8028744 8028744
-- QC02 2664318 7465256 x
-- QC03 495795 775261 x
-- QC04 388340 3580706 x
-- QC05 6690961 8696597 x
-- QC06 4906274 10695008 x
-- QC07 86018 155130 x
-- SK01 1577892 1577892
-- SK02 30105 44871 x
-- SK03 9365 14731 x
-- SK04 674385 1050281 x
-- SK05 21437 604611 x
-- SK06 219239 344279 x
-- YT01 6135 262130 x
-- YT02 248539 244944
-- YT03 71173 79560

-- Create some indexes - 13m
CREATE INDEX ON casfri50_history.geo_history USING btree(left(cas_id, 4));
CREATE INDEX ON casfri50_history.geo_history USING gist(geom);

/* Display
SELECT *
FROM casfri50_history.geo_history
WHERE left(cas_id, 4) = 'BC08';
*/

----------------------------------------------------------------
-- Check for overlaps for random buffers in each inventory
----------------------------------------------------------------

-- Create randoms buffers
DROP TABLE IF EXISTS casfri50_history_test.geo_history_test_buffers;
CREATE TABLE casfri50_history_test.geo_history_test_buffers AS
WITH provinces AS (
  SELECT left(inv, 2) prov, 
         ST_Union(geom) geom
  FROM casfri50_coverage.smoothed
  GROUP BY left(inv, 2)
), buffer_nb_params AS (
  SELECT max(ST_Area(geom)) max_area, min(ST_Area(geom)) min_area
  FROM provinces
), buffers AS (
  SELECT prov, 
         -- the number of buffer per province is proportional to the province area. min is 10, max is 100
         ST_Buffer(ST_RandomPoints(geom, round(10 + (ST_Area(geom) - min_area) * (100 - 10) / (max_area - min_area))::int, 1), 1000) geom
  FROM provinces, buffer_nb_params
)
SELECT prov, (row_number() OVER(PARTITION BY prov)) buffer_id, geom
FROM buffers
ORDER BY prov, buffer_id;

-- Display
SELECT * FROM casfri50_history_test.geo_history_test_buffers;

-- Create index for faster extraction of buffer samples from the geo_history table
CREATE INDEX ON casfri50_history.geo_history USING btree(left(cas_id, 2));

CREATE INDEX ON casfri50_history.geo_history USING gist(geom);

-- Extract buffer samples into a new table
DROP TABLE IF EXISTS casfri50_history_test.geo_history_test;
CREATE TABLE casfri50_history_test.geo_history_test AS
SELECT prov, buffer_id, cas_id, valid_year_begin, valid_year_end, 
       ST_Intersection(gh.geom, bufs.geom) geom,
       ST_Area(ST_Intersection(gh.geom, bufs.geom)) area
FROM casfri50_history_test.geo_history_test_buffers bufs, 
     casfri50_history.geo_history gh
WHERE left(cas_id, 2) = prov AND ST_Intersects(gh.geom, bufs.geom)
ORDER BY prov, buffer_id, valid_year_begin;

-- Display
SELECT * FROM casfri50_history_test.geo_history_test;

-- Extract CASFRI polygons for buffer samples into a new table
DROP TABLE IF EXISTS casfri50_history_test.geo_history_test_raw;
CREATE TABLE casfri50_history_test.geo_history_test_raw AS
SELECT prov, buffer_id, cas_id, stand_photo_year, 
       ST_Intersection(c.geometry, bufs.geom) geom,
       ST_Area(ST_Intersection(c.geometry, bufs.geom)) area
FROM casfri50_history_test.geo_history_test_buffers bufs, 
     casfri50_flat.cas_flat_all_layers_same_row c
WHERE left(cas_id, 2) = prov AND ST_Intersects(c.geometry, bufs.geom)
ORDER BY prov, buffer_id, stand_photo_year;

-- Display
SELECT * FROM casfri50_history_test.geo_history_test_raw;

-- Check sum of areas vs areas of unions
WITH all_significant_years AS (
  SELECT DISTINCT prov, buffer_id, syear
  FROM (
    SELECT DISTINCT prov, buffer_id, valid_year_begin syear
    FROM casfri50_history_test.geo_history_test
    UNION ALL
    SELECT DISTINCT prov, buffer_id, valid_year_end syear
    FROM casfri50_history_test.geo_history_test
  ) foo
  ORDER BY prov, buffer_id, syear
), sum_of_areas AS (
  SELECT h.prov, h.buffer_id, syear, 
         sum(area) sum_area
  FROM casfri50_history_test.geo_history_test h, all_significant_years sy
  WHERE h.prov = sy.prov AND h.buffer_id = sy.buffer_id AND 
        valid_year_begin <= syear AND syear <= valid_year_end
  GROUP BY h.prov, h.buffer_id, syear
  ORDER BY h.prov, h.buffer_id, syear
), area_of_union AS (
  SELECT h.prov, h.buffer_id, syear, 
         ST_Area(ST_Union(geom)) union_area
  FROM casfri50_history_test.geo_history_test h, all_significant_years sy
  WHERE h.prov = sy.prov AND h.buffer_id = sy.buffer_id AND 
        valid_year_begin <= syear AND syear <= valid_year_end
  GROUP BY h.prov, h.buffer_id, syear
  ORDER BY h.prov, h.buffer_id, syear
)
SELECT sa.prov, sa.buffer_id, sa.syear, sum_area, 
       union_area, 
       sum_area - union_area area_diff_in_sq_meters, 
       10000 * (sum_area - union_area) area_diff_in_sq_centimeters
FROM sum_of_areas sa, area_of_union au
WHERE sa.prov = au.prov AND 
      sa.buffer_id = au.buffer_id AND 
      sa.syear = au.syear AND 
      abs(sum_area - union_area) > 0.001
ORDER BY abs(sum_area - union_area) DESC, syear DESC;

-- Check coverage for one buffer for one year
SELECT * 
FROM casfri50_history_test.geo_history_test
WHERE prov = 'NS' AND buffer_id = 4 AND 
      valid_year_begin <= 2003 AND 2003 <= valid_year_end;

-- Compare with the ST_Union() (to check if some polygons were not included by ST_Union)
SELECT ST_Union(geom) geom
FROM casfri50_history_test.geo_history_test
WHERE prov = 'NS' AND buffer_id = 4 AND 
      valid_year_begin <= 2003 AND 2003 <= valid_year_end;

-- Compare with the raw polygons
SELECT * 
FROM casfri50_history_test.geo_history_test_raw
WHERE prov = 'NS' AND buffer_id = 4;
