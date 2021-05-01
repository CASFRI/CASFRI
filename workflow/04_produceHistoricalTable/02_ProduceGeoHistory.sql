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
GROUP BY left(cas_id, 4);

-- AB03 62387
-- AB06 11730
-- AB07 23350
-- AB08 35727
-- AB10 199788
-- AB11 119597
-- AB16 121865
-- AB25 555261
-- AB29 680556
-- AB30 5771
-- BC08 no polygons retained
-- BC10 2321009
-- BC11 7414767
-- BC12 7396987
-- MB01 129146
-- MB02 53238
-- MB04 24606
-- MB05 1750651
-- MB06 167290
-- MB07 362612
-- NB01 1511925
-- NB02 1781853
-- NL01 1866027
-- NS01 404950
-- NS02 1578368
-- NS03 1598055
-- NT01 392327
-- NT03 506328
-- ON01 7172675
-- ON02 5874657
-- PC01 9168
-- PC02 1123
-- PE01 107220
-- QC01 TBD
-- QC02 7465256
-- QC03 775261
-- QC04 3580706
-- QC05 8696597
-- QC06 10695008
-- QC07 155130
-- SK02 44871
-- SK03 14731
-- SK04 1050281
-- SK05 604611
-- SK06 344279
-- YT01 262130
-- YT02 244944
-- YT03 79560
