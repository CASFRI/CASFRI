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
   
-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the tables by appending all translated 
-- table to the same big table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS casfri50;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
-------------------------------------------------------

-------------------------------------------------------
-- NT02 prep
-- can reuse the nt01 translation tables
-- needs a VIEW for both layer 1 and layer 2
-------------------------------------------------------
-- Create a view mapping the nt02 cas attributes to the nt01 cas attributes
DROP VIEW IF EXISTS rawfri.nt02_cas;
CREATE OR REPLACE VIEW rawfri.nt02_cas AS
SELECT src_filename, invproj_id, inventory_id, ogc_fid, wkb_geometry, areaha, ref_year, structur, 
fc_id fc_id_1 
FROM rawfri.nt02;

-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_cas', '_ab06_cas');
SELECT TT_Prepare('translation', 'ab16_avi01_cas', '_ab16_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nb01_nbi01_cas', '_nb01_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc08_vri01_cas', '_bc08_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nt01_fvi01_cas', '_nt_cas', 'ab06_avi01_cas'); -- can use the same same function for NT01 and NT02
------------------------
DROP TABLE IF EXISTS casfri50.cas_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.cas_all AS -- 3m40s
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 37m35s
SELECT * FROM TT_Translate_ab16_cas('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 2h45m
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_cas');
------------------------
-- Reuse TT_Translate_nb01_cas() for NB02
INSERT INTO casfri50.cas_all -- 
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb02', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 12h16m
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 43m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_cas');
------------------------
INSERT INTO casfri50.cas_all -- 57m
SELECT * FROM TT_Translate_nt_cas('rawfri', 'nt02_cas', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_cas');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.cas_all; 

SELECT count(*) FROM casfri50.cas_all; -- 6860441

-- Add primary and foreign key constraints
ALTER TABLE casfri50.cas_all 
ADD PRIMARY KEY (cas_id);

ALTER TABLE casfri50.hdr_all
ADD FOREIGN KEY (inventory_id) REFERENCES casfri50.hdr_all (inventory_id) MATCH FULL;
-------------------------------------------------------
