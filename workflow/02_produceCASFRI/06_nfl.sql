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
-- Translate all NFL tables into a common table
-------------------------------------------------------
-------------------------------------------------------

-------------------------------------------------------
-- NT01 prep
-- needs a modified translation table for layer 2.
-- and  VIEW for layer 2
-------------------------------------------------------
-- Edit the nt01_fvi01_lyr translation table for layer 2
DROP TABLE IF EXISTS translation.nt01_fvi01_nfl_layer2;

CREATE TABLE translation.nt01_fvi01_nfl_layer2 WITH OIDS AS
SELECT * FROM translation.nt01_fvi01_nfl;

UPDATE translation.nt01_fvi01_nfl_layer2
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- Create a view mapping the nt01 nfl layer 2 attributes to the nt01 nfl attributes
CREATE OR REPLACE VIEW rawfri.nt01_nfl_layer2 AS
SELECT src_filename, inventory_id, invproj_id, fc_id_1, ogc_fid, strc_per,
minmoist moisture, mincrowncl crownclos, minheight height,
mintypecla typeclas
FROM rawfri.nt01;

-------------------------------------------------------
-- NT02 prep
-- can reuse the nt01 translation tables
-- needs a VIEW for both layer 1 and layer 2
-------------------------------------------------------
-- Create a view mapping the nt02 nfl attributes to the nt01 nfl attributes
DROP VIEW IF EXISTS rawfri.nt02_nfl;
CREATE OR REPLACE VIEW rawfri.nt02_nfl AS
SELECT src_filename, inventory_id, invproj_id, ogc_fid, strc_per,
moisture, crownclos, height, typeclas,
fc_id fc_id_1
FROM rawfri.nt02;

-- Create a view mapping the nt02 nfl layer 2 attributes to the nt01 nfl attributes
CREATE OR REPLACE VIEW rawfri.nt02_nfl_layer2 AS
SELECT src_filename, inventory_id, invproj_id, ogc_fid, strc_per,
minmoist moisture, mincrownclos crownclos, minheight height,
mintypeclas typeclas,
fc_id fc_id_1
FROM rawfri.nt02;

-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_nfl', '_ab06_nfl');
SELECT TT_Prepare('translation', 'ab16_avi01_nfl', '_ab16_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nb01_nbi01_nfl', '_nb01_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc08_vri01_nfl', '_bc08_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nt01_fvi01_nfl', '_nt_nfl', 'ab06_avi01_nfl'); -- can use same function for NT01 and NT02 layer 1
SELECT TT_Prepare('translation', 'nt01_fvi01_nfl_layer2', '_nt_nfl_layer2', 'ab06_avi01_lyr'); -- can use the same function for NT01 and NT02 layer 2
------------------------
DROP TABLE IF EXISTS casfri50.nfl_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.nfl_all AS -- 2m24s
SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 23m43s
SELECT * FROM TT_Translate_ab16_nfl('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 1h4m
SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_nfl');
------------------------
-- Reuse TT_Translate_nb01_nfl() for NB02
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb02', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 16h38m
SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl_layer2('rawfri', 'nt01_nfl_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_nfl_layer2');
------------------------
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl('rawfri', 'nt02_nfl', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_nfl');
------------------------
INSERT INTO casfri50.nfl_all -- 
SELECT * FROM TT_Translate_nt_nfl_layer2('rawfri', 'nt02_nfl_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_nfl_layer2');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.nfl_all;

SELECT count(*) FROM casfri50.nfl_all; -- 6860441

-- Add primary and foreign key constraints
ALTER TABLE casfri50.nfl_all ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.nfl_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
