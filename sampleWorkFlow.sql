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


-- 1) In a PostgreSQL query window, install PostGIS in your database:
--    CREATE EXTENSION postgis;
--
-- 2) In a operating system command window, load the necessary inventories 
--    using the proper conversion scripts located in the conversion folder. You 
--    must copy and edit the configSample (.bat or .sh) file to match your 
--    system configuration.
--
-- 3) In a operating system command window, load the translation files using the 
--    load_tables (.bat or .sh) script located in the translation folder. You 
--    must copy and edit the configSample (.bat or .sh) file to match your 
--    system configuration.
--
-- 4) In a PostgreSQL query window, run, in this order:
--    a) the postTranslationEngine/engine.sql file,
--    b) the postTranslationEngine/helperFunctions.sql file,
--    c) the helperFunctionsTest.sql file. All test should pass.
--    c) the engineTest.sql file. All test should pass.
--
--    You can desinstall all the functions by running the 
--    helperFunctionsUninstall.sql and the engineUninstall.sql files.
--
-- 5) You are now ready to start translating the inventories following
--    the rest of this file instructions...
   
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-------------------------------------------------------
-------------------------------------------------------
-- Work on source inventory
-------------------------------------------------------
-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- Have a look at one of the source inventory table
SELECT * FROM rawfri.ab06 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.ab06;

-- Create a smaller test inventory table
-- DROP TABLE IF EXISTS rawfri.ab06_test;
CREATE TABLE rawfri.ab06_test AS
SELECT * FROM rawfri.ab06
--WHERE ogc_fid = 811451038
LIMIT 200;

-- Display
SELECT src_filename, trm_1, poly_num, ogc_fid, density, height, sp1, sp1_per
FROM rawfri.ab06_test;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- Have a look at one of the source inventory table
SELECT * FROM rawfri.ab16 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.ab16;

-- Create a smaller test inventory table
-- DROP TABLE IF EXISTS rawfri.ab16_test;
CREATE TABLE rawfri.ab16_test AS
SELECT * FROM rawfri.ab16
--WHERE ogc_fid = 811451038
LIMIT 200;

-- Display
SELECT src_filename, forest_id, ogc_fid, crownclose, height, sp1, sp1_percnt
FROM rawfri.ab16_test;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- Have a look at one of the source inventory table
SELECT * FROM rawfri.bc08 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.bc08;

-- Create a smaller test inventory table
-- DROP TABLE IF EXISTS rawfri.bc08_test;
CREATE TABLE rawfri.bc08_test AS
SELECT * FROM rawfri.bc08
WHERE crown_closure > 0
--WHERE ogc_fid = 424344
LIMIT 200;

-- Display
SELECT src_filename, map_id, feature_id, ogc_fid, crown_closure, proj_height_1, species_cd_1, species_pct_1
FROM rawfri.bc08_test;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- Have a look at one of the source inventory table
SELECT * FROM rawfri.nb01 LIMIT 10;

-- Count the number of rows
SELECT count(*)
FROM rawfri.nb01;

-- Create a smaller test inventory table
-- DROP TABLE IF EXISTS rawfri.nb01_test;
CREATE TABLE rawfri.nb01_test AS
SELECT * FROM rawfri.nb01 
WHERE stdlab > 0
--WHERE ogc_fid = 811451038
LIMIT 200;

-- Display
SELECT src_filename, stdlab, ogc_fid, l1cc, l1ht, l1s1, l1pr1
FROM rawfri.nb01_test;
-------------------------------------------------------
-------------------------------------------------------
-- Work on translation file
-------------------------------------------------------
-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- Display the translation table of interest
SELECT * FROM translation.ab06_avi01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.ab06_avi01_lyr_test;
CREATE TABLE translation.ab06_avi01_lyr_test AS
SELECT * FROM translation.ab06_avi01_lyr
WHERE ogc_fid = 1 OR 
ogc_fid = 2 OR ogc_fid = 3 OR 
ogc_fid = 4 OR ogc_fid = 5 OR 
ogc_fid = 6 OR ogc_fid = 7;

-- Display
SELECT * FROM translation.ab06_avi01_lyr_test;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- Display the translation table of interest
SELECT * FROM translation.ab16_avi01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.ab16_avi01_lyr_test;
CREATE TABLE translation.ab16_avi01_lyr_test AS
SELECT * FROM translation.ab16_avi01_lyr
WHERE ogc_fid = 1 OR 
ogc_fid = 2 OR ogc_fid = 3 OR 
ogc_fid = 4 OR ogc_fid = 5 OR
ogc_fid = 6 OR ogc_fid = 7;

-- Display
SELECT * FROM translation.ab16_avi01_lyr_test;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- Display the translation table of interest
SELECT * FROM translation.bc08_vri01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.bc08_vri01_lyr_test;
CREATE TABLE translation.bc08_vri01_lyr_test AS
SELECT * FROM translation.bc08_vri01_lyr
WHERE ogc_fid = 1 OR 
ogc_fid = 2 OR ogc_fid = 3 OR 
ogc_fid = 4 OR ogc_fid = 5 OR
ogc_fid = 6 OR ogc_fid = 7;

-- Display
SELECT * FROM translation.bc08_vri01_lyr_test;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- Display the translation table of interest
SELECT * FROM translation.nb01_nbi01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.nb01_nbi01_lyr_test;
CREATE TABLE translation.nb01_nbi01_lyr_test AS
SELECT * FROM translation.nb01_nbi01_lyr
WHERE ogc_fid = 1 OR 
ogc_fid = 2 OR ogc_fid = 3 OR 
ogc_fid = 4 OR ogc_fid = 5 OR
ogc_fid = 6 OR ogc_fid = 7;

-- Display
SELECT * FROM translation.nb01_nbi01_lyr_test;

-------------------------------------------------------
-------------------------------------------------------
-- Translate the sample table!
-------------------------------------------------------
-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- Create translation function
SELECT TT_Prepare('translation', 'ab06_avi01_lyr_test', '_ab06');

-- Translate the sample!
SELECT * FROM TT_Translate_ab06('rawfri', 'ab06_test', 'translation', 'ab06_avi01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, trm_1, poly_num, ogc_fid, cas_id, 
       density, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_per, species_per_1
FROM TT_Translate_ab06('rawfri', 'ab06_test', 'translation', 'ab06_avi01_lyr_test'), rawfri.ab06_test
WHERE poly_num = substr(cas_id, 33, 10)::int;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- Create translation function
SELECT TT_Prepare('translation', 'ab16_avi01_lyr_test', '_ab16');

-- Translate the sample!
SELECT * FROM TT_Translate_ab16('rawfri', 'ab16_test', 'translation', 'ab16_avi01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, forest_id, ogc_fid, cas_id, 
       crownclose, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_percnt, species_per_1
FROM TT_Translate_ab16('rawfri', 'ab16_test', 'translation', 'ab16_avi01_lyr_test'), rawfri.ab16_test
WHERE ogc_fid = right(cas_id, 7)::int;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- Create translation function
SELECT TT_Prepare('translation', 'bc08_vri01_lyr_test', '_bc08');

-- Translate the sample!
SELECT * FROM TT_Translate_bc08('rawfri', 'bc08_test', 'translation', 'bc08_vri01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, map_id, ogc_fid, cas_id, 
       crown_closure, crown_closure_lower, crown_closure_upper, 
       proj_height_1, height_upper, height_lower,
       species_cd_1, species_1,
       species_pct_1, species_per_1
FROM TT_Translate_bc08('rawfri', 'bc08_test', 'translation', 'bc08_vri01_lyr_test'), rawfri.bc08_test
WHERE ogc_fid = right(cas_id, 7)::int;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- Create translation function
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr_test', '_nb01');

-- Translate the sample!
SELECT * FROM TT_Translate_nb01('rawfri', 'nb01_test', 'translation', 'nb01_nbi01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, stdlab, ogc_fid, cas_id, 
       l1cc, crown_closure_lower, crown_closure_upper, 
       l1ht, height_upper, height_lower, 
       l1s1, species_1,
       l1pr1, species_per_1
FROM TT_Translate_nb01('rawfri', 'nb01_test', 'translation', 'nb01_nbi01_lyr_test'), rawfri.nb01_test
WHERE ogc_fid = right(cas_id, 7)::int;

-------------------------------------------------------
-------------------------------------------------------
-- Translate the big thing!
-------------------------------------------------------
-------------------------------------------------------
CREATE SCHEMA casfri50;
-------------------------------------------------------
-- AB06 - 55 seconds
-------------------------------------------------------
--DROP TABLE IF EXISTS casfri50.ab06;
CREATE TABLE casfri50.ab06 AS
SELECT * FROM TT_Translate_ab06('rawfri', 'ab06', 'translation', 'ab06_avi01_lyr_test');

SELECT * FROM casfri50.ab06;

-------------------------------------------------------
-- AB16 - 14 minutes
-------------------------------------------------------
--DROP TABLE IF EXISTS casfri50.ab16;
CREATE TABLE casfri50.ab16 AS
SELECT * FROM TT_Translate_ab16('rawfri', 'ab16', 'translation', 'ab16_avi01_lyr_test');

SELECT * FROM casfri50.ab16;

-------------------------------------------------------
-- BC08 - XX minutes
-------------------------------------------------------
--DROP TABLE IF EXISTS casfri50.ab16;
CREATE TABLE casfri50.bc08 AS
SELECT * FROM TT_Translate_bc08('rawfri', 'bc08', 'translation', 'bc08_vri01_lyr_test');

SELECT * FROM casfri50.bc08;

-------------------------------------------------------
-- NB01 - XX minutes
-------------------------------------------------------
--DROP TABLE IF EXISTS casfri50.nb01;
CREATE TABLE casfri50.nb01 AS
SELECT * FROM TT_Translate_nb01('rawfri', 'nb01', 'translation', 'nb01_nbi01_lyr_test');

SELECT * FROM casfri50.nb01;



