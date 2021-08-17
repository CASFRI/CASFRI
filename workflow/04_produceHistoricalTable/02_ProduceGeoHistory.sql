------------------------------------------------------------------------------
-- CASFRI - Historical table production script for CASFRI v5
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

--	inv	cnt_old	cnt_530	diff_530-old	cnt_531a	diff_531a_530	cnt_531b	diff_531a_531b
--	AB03	62387	62411	24	62411	0	62411	0
--	AB06	11730	11730	0	11794	64	11794	0
--	AB07	23350	23399	49	23397	-2	23401	4
--	AB08	35727	35904	177	35903	-1	35904	1
--	AB10	199788	195544	-4244	195546	2	195546	0
--	AB11	119597	119187	-410	119187	0	119187	0
--	AB16	121865	121438	-427	121437	-1	121438	1
--	AB25	555261	108814	-446447	108812	-2	108817	5
--	AB29	680556	665823	-14733	665821	-2	665822	1
--	AB30	5771	4578	-1193	4579	1	4578	-1
--	BC08	0	718161	718161	718183	22	718226	43
--	BC10	2321009	251926	-2069083	251997	71	252072	75
--	BC11	7414767	4161067	-3253700	4161011	-56	4161041	30
--	BC12	7396987	7728795	331808	7728855	60	7728800	-55
--	MB01	129146	12246	-116900	12243	-3	12244	1
--	MB02	53238	1291	-51947	1291	0	1291	0
--	MB04	24606	1798	-22808	1797	-1	1798	1
--	MB05	1750651	1653948	-96703	1653948	0	1653948	0
--	MB06	167290	165438	-1852	165438	0	165438	0
--	MB07	362612	220548	-142064	220548	0	220549	1
--	NB01	1511925	925337	-586588	925353	16	925380	27
--	NB02	1781853	1343646	-438207	1343642	-4	1343654	12
--	NL01	1866027	1866227	200	1866227	0	1866227	0
--	NS01	404950	209986	-194964	209985	-1	209988	3
--	NS02	1578368	871378	-706990	871370	-8	871287	-83
--	NS03	1598055	1049044	-549011	1049035	-9	1049000	-35
--	NT01	392327	216519	-175808	216521	2	216520	-1
--	NT03	506328	332209	-174119	332207	-2	332206	-1
--	ON01	7172675	4931335	-2241340	4931332	-3	4931337	5
--	ON02	5874657	3787142	-2087515	3787140	-2	3787143	3
--	PC01	9168	9153	-15	9149	-4	9150	1
--	PC02	1123	1122	-1	1122	0	1122	0
--	PE01	107220	107220	0	107220	0	107220	0
--	QC01	8028744	8028744	0	8029296	552	8029249	-47
--	QC02	7465256	2664318	-4800938	2664253	-65	2664289	36
--	QC03	775261	495795	-279466	495795	0	495795	0
--	QC04	3580706	388340	-3192366		-388,340	388316	388316
--	QC05	8696597	6690961	-2005636	6690962	1	6690955	-7
--	QC06	10695008	4906274	-5788734	4906188	-86	4906161	-27
--	QC07	155130	86018	-69112	86018	0	86018	0
--	SK01	1577892	1577892	0	1577873	-19	1577878	5
--	SK02	44871	30105	-14766	30105	0	30105	0
--	SK03	14731	9365	-5366	9365	0	9365	0
--	SK04	1050281	674385	-375896	674388	3	674383	-5
--	SK05	604611	21437	-583174	21440	3	21459	19
--	SK06	344279	219239	-125040	219239	0	219239	0
--	YT01	262130	6135	-255995	6132	-3	6134	2
--	YT02	244944	248539	3595	248539	0	248539	0
--	YT03	79560	71173	-8387	71173	0	71173	0


-- Create some indexes - 13m
CREATE INDEX ON casfri50_history.geo_history USING btree(left(cas_id, 2));
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
         ST_Buffer(TT_RandomPoints(geom, round(10 + (ST_Area(geom) - min_area) * (100 - 10) / (max_area - min_area))::int, 1), 1000) geom
  FROM provinces, buffer_nb_params
)
SELECT prov, (row_number() OVER(PARTITION BY prov)) buffer_id, geom
FROM buffers
ORDER BY prov, buffer_id;

-- Display
SELECT * FROM casfri50_history_test.geo_history_test_buffers;

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
