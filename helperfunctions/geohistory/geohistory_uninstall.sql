------------------------------------------------------------------------------
-- CASFRI - Geo history functions uninstallation script for CASFRI v5
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
-- DROP GeoHistory functions
--------------------------------------------
DROP FUNCTION IF EXISTS TT_TableGeoHistory(name, name, name, name, name, name, name[]);
DROP FUNCTION IF EXISTS TT_PolygonGeoHistory(text, text, geometry, name, name, name, name, name, name, name[]);
DROP FUNCTION IF EXISTS TT_PolygonGeoHistory(text, text, int, boolean, geometry, name, name, name, name, name, name, name[]);
DROP FUNCTION IF EXISTS TT_RowIsValid(text[]);
DROP FUNCTION IF EXISTS TT_HasPrecedence(text, text, text, text, boolean, boolean);
DROP FUNCTION IF EXISTS TT_GeoHistoryOblique(name, name, name, name, name, text, text[], double precision, double precision);
DROP FUNCTION IF EXISTS TT_GeoOblique(geometry, int, double precision, double precision);
DROP AGGREGATE IF EXISTS TT_ValidYearUnion(geometry, int, int);
DROP FUNCTION IF EXISTS TT_ValidYearUnionStateFct(geomlowuppval[], geometry, int, int);
DROP FUNCTION IF EXISTS TT_SafeDifference(geometry, geometry, double precision, text, text, boolean);
DROP FUNCTION IF EXISTS TT_GeoHistoryOverlaps(geometry, geometry, boolean, double precision);
DROP FUNCTION IF EXISTS TT_SplitByGrid(geometry, double precision, double precision, double precision, double precision);
DROP FUNCTION IF EXISTS TT_PrintMessage(text);
DROP FUNCTION IF EXISTS TT_BufferedSmooth(geometry, double precision);
DROP FUNCTION IF EXISTS TT_RemoveHoles(geometry, double precision);
DROP FUNCTION IF EXISTS TT_TrimSubPolygons(geometry, double precision);
DROP FUNCTION IF EXISTS TT_SuperUnion(name, name, name, text);
DROP FUNCTION IF EXISTS TT_ProduceDerivedCoverages(text, geometry, double precision, boolean, double precision);
DROP FUNCTION IF EXISTS TT_ProduceInvGeoHistory(text, boolean, boolean);
DROP FUNCTION IF EXISTS TT_AreasForSignificantYearsDebugQuery(name, boolean);
DROP FUNCTION IF EXISTS TT_AreasForSignificantYears(name, boolean, double precision);
DROP FUNCTION IF EXISTS TT_SigDigits(anyelement, int);
DROP AGGREGATE IF EXISTS TT_SplitAgg(geometry, geometry, double precision);
DROP AGGREGATE IF EXISTS TT_SplitAgg(geometry, geometry);
DROP FUNCTION IF EXISTS TT_SplitAgg_StateFN(geometry[], geometry, geometry);
DROP FUNCTION IF EXISTS TT_SplitAgg_StateFN(geometry[], geometry, geometry, double precision);
DROP FUNCTION IF EXISTS TT_ProgressMsg(bigint, int, timestamptz);
DROP FUNCTION IF EXISTS TT_IntersectingArea(geometry, geometry, double precision);
DROP FUNCTION IF EXISTS TT_RandomPoints(geometry, integer, numeric);

DROP FUNCTION IF EXISTS TT_UnnestValidYearUnion(geomlowuppval[]);
DROP TYPE IF EXISTS geomlowuppval;


