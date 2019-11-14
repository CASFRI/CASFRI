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
-- Translate all DST tables into a common table
-------------------------------------------------------
-------------------------------------------------------
-- Reuse nb01_nbi01_dst for dst layer 2
DROP TABLE IF EXISTS translation.nb01_nbi01_dst_layer2;

CREATE TABLE translation.nb01_nbi01_dst_layer2 AS
SELECT * FROM translation.nb01_nbi01_dst;

UPDATE translation.nb01_nbi01_dst_layer2
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER';

SELECT * FROM translation.nb01_nbi01_dst_layer2;

-- Make a VIEW mapping some layer 2 attributes to layer 1 attributes
CREATE OR REPLACE VIEW rawfri.nb01_dst_layer2 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid,
l2trt l1trt,	
l2trtyr l1trtyr
FROM rawfri.nb01;
-------------------------------------------------------
-- Reuse the NB01 dst translation table for NB02. 
-- Make a VIEW mapping rawfri.nb02 dst attributes to 
-- rawfri.nb01 dst attributes.
CREATE OR REPLACE VIEW rawfri.nb02_dst AS
SELECT src_filename, inventory_id, stdlab, ogc_fid, 
trt l1trt,
trtyr l1trtyr
FROM rawfri.nb02;

-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_dst', '_ab06_dst');
SELECT TT_Prepare('translation', 'ab16_avi01_dst', '_ab16_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst', '_nb01_dst', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'nb01_nbi01_dst_layer2', '_nb01_dst_layer2', 'ab06_avi01_dst');
SELECT TT_Prepare('translation', 'bc08_vri01_dst', '_bc08_dst', 'ab06_avi01_dst');
------------------------
DROP TABLE IF EXISTS casfri50.dst_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.dst_all AS -- 2m12s
SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 24m46s
SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 1h32m
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 1h11m
SELECT * FROM TT_Translate_nb01_dst_layer2('rawfri', 'nb01_dst_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_dst_layer2');
------------------------
-- Reuse TT_Translate_nb01_dst() for NB02
INSERT INTO casfri50.dst_all -- 
SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb02_dst', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_dst');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.dst_all;

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.dst_all
GROUP BY left(cas_id, 4), layer;

SELECT count(*) FROM casfri50.dst_all; -- 7787618

-- Add primary and foreign key constraints
ALTER TABLE casfri50.dst_all 
ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.dst_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
