------------------------------------------------------------------------------
-- CASFRI Inventory coverage production script for CASFRI v5 beta
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
-- Union by grid with a single query - 49s
SELECT TT_ProduceDerivedCoverages('AB03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB03''')); --   61633,   28s
SELECT TT_ProduceDerivedCoverages('AB06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB06''')); --   11484,   21s
SELECT TT_ProduceDerivedCoverages('AB07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB07''')); --   23268,   21s
SELECT TT_ProduceDerivedCoverages('AB08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB08''')); --   34474,  1m31
SELECT TT_ProduceDerivedCoverages('AB10', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB10''')); --  194696, 10m22
SELECT TT_ProduceDerivedCoverages('AB11', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB11''')); --  118624,  2m45
SELECT TT_ProduceDerivedCoverages('AB16', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB16''')); --  120476,  3m05
SELECT TT_ProduceDerivedCoverages('AB25', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB25''')); --  527038, 15m03
SELECT TT_ProduceDerivedCoverages('AB29', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB29''')); --  620944, 20m50
SELECT TT_ProduceDerivedCoverages('AB30', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB30'''), 10000 ,TRUE); -- 4555, 56s
SELECT TT_ProduceDerivedCoverages('BC08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC08''')); -- 4677411,  2h26
SELECT TT_ProduceDerivedCoverages('BC10', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC10''')); -- 5151772,  3h01
SELECT TT_ProduceDerivedCoverages('BC11', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC11''')); -- 5419596,  xhxx
SELECT TT_ProduceDerivedCoverages('BC12', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC12''')); -- 4861240,  xhxx
SELECT TT_ProduceDerivedCoverages('MB01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB01''')); --  134790,  3m38
SELECT TT_ProduceDerivedCoverages('MB02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB02''')); --   60370,  2m46
SELECT TT_ProduceDerivedCoverages('MB04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB04''')); --   27221,  1m20
SELECT TT_ProduceDerivedCoverages('MB05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB05''')); --  514157, 45m38
SELECT TT_ProduceDerivedCoverages('MB06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB06''')); --  160218,  6m44
SELECT TT_ProduceDerivedCoverages('MB07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB07''')); --  219682, 14m00
SELECT TT_ProduceDerivedCoverages('NB01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NB01''')); --  927177, 33m51
SELECT TT_ProduceDerivedCoverages('NB02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NB02''')); -- 1123893, 31m48
SELECT TT_ProduceDerivedCoverages('NL01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NL01''')); -- 1863664, 49m23
SELECT TT_ProduceDerivedCoverages('NS01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS01''')); --  995886, 35m48
SELECT TT_ProduceDerivedCoverages('NS02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS02''')); --  281388, 26m16
SELECT TT_ProduceDerivedCoverages('NS03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS03''')); --  320944, 24m55
SELECT TT_ProduceDerivedCoverages('NT01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NT01''')); -- 1127926,  7m36
SELECT TT_ProduceDerivedCoverages('NT03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NT03''')); -- 1090671, 13m10
SELECT TT_ProduceDerivedCoverages('ON01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''ON01''')); -- 4106417,  xhxx
SELECT TT_ProduceDerivedCoverages('ON02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''ON02''')); -- 3629072,  4h45
SELECT TT_ProduceDerivedCoverages('PC01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PC01''')); --    8094,   14s
SELECT TT_ProduceDerivedCoverages('PC02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PC02''')); --    1053,   11s
SELECT TT_ProduceDerivedCoverages('PE01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PE01''')); --  107220,  3m32
SELECT TT_ProduceDerivedCoverages('QC01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC01''')); -- 5563194,  xhxx
SELECT TT_ProduceDerivedCoverages('QC02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC02''')); -- 2876326,  xhxx
SELECT TT_ProduceDerivedCoverages('QC03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC03''')); --  401188,  8m45
SELECT TT_ProduceDerivedCoverages('QC04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC04''')); -- 2487519, 59m12
SELECT TT_ProduceDerivedCoverages('QC05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC05''')); -- 6768074,  2h07
SELECT TT_ProduceDerivedCoverages('QC06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC06''')); -- 2487519,  2h07
SELECT TT_ProduceDerivedCoverages('QC07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC07''')); --   85057,  xhxx
SELECT TT_ProduceDerivedCoverages('SK01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK01''')); -- 1501667, 41m53
SELECT TT_ProduceDerivedCoverages('SK02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK02''')); --   27312,   49s
SELECT TT_ProduceDerivedCoverages('SK03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK03''')); --    8964,   23s
SELECT TT_ProduceDerivedCoverages('SK04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK04''')); --  633522, 31m33
SELECT TT_ProduceDerivedCoverages('SK05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK05''')); --  421977, 16m55 
SELECT TT_ProduceDerivedCoverages('SK06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK06''')); --  211482, 11m08
SELECT TT_ProduceDerivedCoverages('YT01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT01''')); --  249636,  9m03
SELECT TT_ProduceDerivedCoverages('YT02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT02''')); --  231137,  9m07
SELECT TT_ProduceDerivedCoverages('YT03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT03''')); --   71073,  xhxx

-- Display the difference in terms of number of points
SELECT a.inv, 
       a.nb_points nb_pts_detailed, 
       b.nb_points nb_pts_noholes, 
       c.nb_points nb_pts_noislands, 
       d.nb_points nb_pts_simplified, 
       e.nb_points nb_pts_smoothed
FROM casfri50_coverage.detailed a
LEFT JOIN casfri50_coverage.noholes b USING (inv)
LEFT JOIN casfri50_coverage.noislands c USING (inv)
LEFT JOIN casfri50_coverage.simplified d USING (inv)
LEFT JOIN casfri50_coverage.smoothed e USING (inv)
ORDER BY inv;

-- Make sure every coverage was build succesfully (49 polygons)
SELECT inv, nb_polys, nb_points, ST_IsValid(geom) isvalid
FROM casfri50_coverage.smoothed 
ORDER BY inv;

-- Recompute derived only if needed
SELECT TT_ProduceDerivedCoverages('AB30', (SELECT geom FROM casfri50_coverage.detailed WHERE inv = 'AB30'));

-- Display 
SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.detailed 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.noholes 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.noislands 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.simplified 
ORDER BY nb_polys;

SELECT inv, nb_polys, nb_points --, geom
FROM casfri50_coverage.smoothed 
ORDER BY nb_polys;

-- Create a table of all intersection in the coverages
DROP TABLE IF EXISTS casfri50_coverage.intersections;
CREATE TABLE casfri50_coverage.intersections AS
WITH unnested AS (
  SELECT a.inv, unnest(TT_SplitAgg(a.geom, b.geom, 0.001)) geom
  FROM casfri50_coverage.simplified a,
       casfri50_coverage.simplified b
  WHERE ST_Equals(a.geom, b.geom) OR
        ST_Contains(a.geom, b.geom) OR
        ST_Contains(b.geom, a.geom) OR
        ST_Overlaps(a.geom, b.geom)
  GROUP BY a.inv, ST_AsEWKB(a.geom)
)
SELECT string_agg(inv, '-') invs, 
       count(*) nb, 
       TT_SigDigits(ST_Area(geom), 8) area,
       min(geom)::geometry geom
FROM unnested
GROUP BY TT_SigDigits(ST_Area(geom), 8)
HAVING count(*) > 1
ORDER BY area DESC;

-- Display
SELECT * FROM casfri50_coverage.intersections;
