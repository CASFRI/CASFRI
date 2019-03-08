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
SET tt.debug TO FALSE;

-------------------------------------------------------
-- Work on source inventory
-------------------------------------------------------

-- Have a look at one of the source inventory table
SELECT * FROM rawfri.ab06 LIMIT 10;

-- Create a smaller test inventory table to test before launching the 
-- complete translation process
-- DROP TABLE IF EXISTS rawfri.ab06_test;
CREATE TABLE rawfri.ab06_test AS
SELECT * FROM rawfri.ab06
--WHERE poly_num_1 = 811451038
LIMIT 10;

-- Display
SELECT src_filename, trm_1, poly_num, ogc_fid, density, height, sp1
FROM rawfri.ab06_test 

-------------------------------------------------------
-- Work on translation file
-------------------------------------------------------
-- Display the translation table of interest
SELECT * FROM translation.ab06_avi01_lyr; 

-- Create a subset translation table in case some rows are still not 
-- working well
-- DROP TABLE IF EXISTS translation.ab06_lyr_test;
CREATE TABLE translation.ab06_lyr_test AS
SELECT * FROM translation.ab06_avi01_lyr
WHERE ogc_fid = 1 OR 
ogc_fid = 2 OR 
ogc_fid = 3 OR 
ogc_fid = 4 OR 
ogc_fid = 5;

-- Display
SELECT * FROM translation.ab06_lyr_test;

-------------------------------------------------------
-- Translate!
-------------------------------------------------------

-- Create translation function
-- 1. schema of translation table. 2. translation table name. 3. suffix
SELECT TT_Prepare('translation', 'ab06_lyr_test');

-- Translate the sample!
SELECT * FROM TT_Translate('rawfri', 'ab06_test', 'translation', 'ab06_lyr_test');

-- Translate the big thing!
CREATE SCHEMA casfri50;

--DROP TABLE IF EXISTS casfri50.ab06;
CREATE TABLE casfri50.ab06 AS
SELECT * FROM TT_Translate('rawfri', 'ab06', 'translation', 'ab06_lyr_test');

SELECT * FROM casfri50.ab06;


