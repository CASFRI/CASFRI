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
CREATE SCHEMA IF NOT EXISTS casfri50_history;

DROP TABLE IF EXISTS casfri50_history.nb_history;
CREATE TABLE casfri50_history.nb_history AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, CASE WHEN stand_photo_year < 1 THEN 1930 ELSE stand_photo_year END, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_flat.cas_flat_all_layers_same_row cas
WHERE left(cas_id, 2) = 'NB'
ORDER BY id, poly_id;

DROP TABLE IF EXISTS casfri50_history.nt_history;
CREATE TABLE casfri50_history.nt_history AS
SELECT (TT_PolygonGeoHistory(inventory_id, cas_id, CASE WHEN stand_photo_year < 1 THEN 1930 ELSE stand_photo_year END, TRUE, geometry,
                             'casfri50_flat', 'cas_flat_all_layers_same_row', 'cas_id', 'geometry', 'stand_photo_year', 'inventory_id')).*
FROM casfri50_flat.cas_flat_all_layers_same_row cas
WHERE left(cas_id, 2) = 'NT'
ORDER BY id, poly_id;



