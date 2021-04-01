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
SELECT TT_ProduceDerivedCoverages('AB03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB03''')); --   61633, pg11:  1m45, pg13:   28s
SELECT TT_ProduceDerivedCoverages('AB06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB06''')); --   11484, pg11:  1m45, pg13:   21s
SELECT TT_ProduceDerivedCoverages('AB07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB07''')); --   23268, pg11:  xmxx, pg13:   21s
SELECT TT_ProduceDerivedCoverages('AB08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB08''')); --   34474, pg11:  xmxx, pg13:  1m31
SELECT TT_ProduceDerivedCoverages('AB10', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB10''')); --  194696, pg11:  xmxx, pg13: 10m22
SELECT TT_ProduceDerivedCoverages('AB11', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB11''')); --  118624, pg11:  xmxx, pg13:  2m45
SELECT TT_ProduceDerivedCoverages('AB16', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB16''')); --  120476, pg11:  9m50, pg13:  3m05
SELECT TT_ProduceDerivedCoverages('AB25', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB25''')); --  527038, pg11:  xmxx, pg13: 15m03
SELECT TT_ProduceDerivedCoverages('AB29', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB29''')); --  620944, pg11:  xmxx, pg13: 20m50
SELECT TT_ProduceDerivedCoverages('AB30', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''AB30'''), 10000 ,TRUE); -- 4555, pg11:  xmxx, pg13:   56s
SELECT TT_ProduceDerivedCoverages('BC08', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC08''')); -- 4677411, pg11:  5h21, pg13:  2h26
SELECT TT_ProduceDerivedCoverages('BC10', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC10''')); -- 5151772, pg11:  6h13, pg13:  3h01
SELECT TT_ProduceDerivedCoverages('BC11', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC11''')); -- 5419596, pg11:  xhxx, pg13:  xhxx
SELECT TT_ProduceDerivedCoverages('BC12', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''BC12''')); -- 4861240, pg11:  xhxx, pg13:  xhxx
SELECT TT_ProduceDerivedCoverages('MB01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB01''')); --  134790, pg11:  xmxx, pg13:  3m38
SELECT TT_ProduceDerivedCoverages('MB02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB02''')); --   60370, pg11:  xmxx, pg13:  2m46
SELECT TT_ProduceDerivedCoverages('MB04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB04''')); --   27221, pg11:  xmxx, pg13:  1m20
SELECT TT_ProduceDerivedCoverages('MB05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB05''')); --  514157, pg11:  3h06, pg13: 45m38
SELECT TT_ProduceDerivedCoverages('MB06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB06''')); --  160218, pg11: 43m28, pg13:  6m44
SELECT TT_ProduceDerivedCoverages('MB07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''MB07''')); --  219682, pg11:  xmxx, pg13: 14m00
SELECT TT_ProduceDerivedCoverages('NB01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NB01''')); --  927177, pg11:   BUG, pg13: 33m51
SELECT TT_ProduceDerivedCoverages('NB02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NB02''')); -- 1123893, pg11:  BUG, infinite time, pg13: 31m48
SELECT TT_ProduceDerivedCoverages('NL01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NL01''')); -- 1863664, pg11:     ?, pg13: 49m23
SELECT TT_ProduceDerivedCoverages('NS01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS01''')); --  995886, pg11:  xmxx, pg13: 35m48
SELECT TT_ProduceDerivedCoverages('NS02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS02''')); --  281388, pg11:  xmxx, pg13: 26m16
SELECT TT_ProduceDerivedCoverages('NS03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NS03''')); --  320944, pg11:  1h11, pg13: 24m55
SELECT TT_ProduceDerivedCoverages('NT01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NT01''')); -- 1127926, pg11: 27m38, pg13:  7m36
SELECT TT_ProduceDerivedCoverages('NT03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''NT03''')); -- 1090671, pg11: 39m24, pg13: 13m10
SELECT TT_ProduceDerivedCoverages('ON01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''ON01''')); -- 4106417, pg11:  xhxx, pg13:  xhxx
SELECT TT_ProduceDerivedCoverages('ON02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''ON02''')); -- 3629072, pg11: BUG ERROR, pg13: 4h45
SELECT TT_ProduceDerivedCoverages('PC01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PC01''')); --    8094, pg11:  xmxx, pg13:   14s
SELECT TT_ProduceDerivedCoverages('PC02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PC02''')); --    1053, pg11:  xmxx, pg13:   11s
SELECT TT_ProduceDerivedCoverages('PE01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''PE01''')); --  107220, pg11:  4m23, pg13:  3m32
SELECT TT_ProduceDerivedCoverages('QC01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC01''')); -- 5563194, pg11:  xhxx, pg13:  xhxx
SELECT TT_ProduceDerivedCoverages('QC02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC02''')); -- 2876326, pg11:  xhxx, pg13:  xhxx
SELECT TT_ProduceDerivedCoverages('QC03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC03''')); --  401188, pg11:      , pg13:  8m45
SELECT TT_ProduceDerivedCoverages('QC04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC04''')); -- 2487519, pg11:     ?, pg13: 59m12
SELECT TT_ProduceDerivedCoverages('QC05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC05''')); -- 6768074, pg11:     ?, pg13:  2h07
SELECT TT_ProduceDerivedCoverages('QC06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC06''')); -- 2487519, pg11:     ?, pg13:  2h07
SELECT TT_ProduceDerivedCoverages('QC07', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''QC07''')); --   85057, pg11:  xhxx, pg13:  xhxx
SELECT TT_ProduceDerivedCoverages('SK01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK01''')); -- 1501667, pg11:  3h13, pg13: 41m53
SELECT TT_ProduceDerivedCoverages('SK02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK02''')); --   27312, pg11:  2m03, pg13:   49s
SELECT TT_ProduceDerivedCoverages('SK03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK03''')); --    8964, pg11:   49s, pg13:   23s
SELECT TT_ProduceDerivedCoverages('SK04', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK04''')); --  633522, pg11:  2h11, pg13: 31m33
SELECT TT_ProduceDerivedCoverages('SK05', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK05''')); --  421977, pg11:  1h13, pg13: 16m55 
SELECT TT_ProduceDerivedCoverages('SK06', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''SK06''')); --  211482, pg11: 40m04, pg13: 11m08
SELECT TT_ProduceDerivedCoverages('YT01', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT01''')); --  249636, pg11:  xmxx, pg13:  9m03
SELECT TT_ProduceDerivedCoverages('YT02', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT02''')); --  231137, pg11: 25m11, pg13:  9m07
SELECT TT_ProduceDerivedCoverages('YT03', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''YT03''')); --   71073, pg11:  xhxx, pg13:  xhxx

-- Recompute derived only if needed
SELECT TT_ProduceDerivedCoverages('SK03', (SELECT geom FROM casfri50_coverage.detailed WHERE inv = 'SK03'));

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
CREATE OR REPLACE FUNCTION sig_digits(n anyelement, digits int) 
RETURNS numeric
AS $$
    SELECT round(n::numeric, digits - 1 - floor(log(abs(n)))::int)
$$ LANGUAGE sql IMMUTABLE STRICT;

--SELECT sig_digits(0.0000372537::double precision, 3)
--SELECT sig_digits(12353263256525, 5)

DROP TABLE IF EXISTS casfri50_coverage.intersections;
CREATE TABLE casfri50_coverage.intersections AS
WITH unnested AS (
  SELECT a.inv, unnest(ST_SplitAgg(a.geom, b.geom, 0.00001)) geom
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
       sig_digits(ST_Area(geom), 8) area,
       min(geom)::geometry geom
FROM unnested
GROUP BY sig_digits(ST_Area(geom), 8)
HAVING count(*) > 1
ORDER BY area DESC;

-- Display
SELECT * FROM casfri50_coverage.intersections;
