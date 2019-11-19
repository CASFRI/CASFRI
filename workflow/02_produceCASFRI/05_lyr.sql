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
-- Translate all LYR tables into a common table
-------------------------------------------------------
-------------------------------------------------------

-------------------------------------------------------
-- NB01 prep
-- needs an edited translation table for layer 2
-- and a VIEW for layer 2
-------------------------------------------------------
-- Reuse the nb01_nbi01_lyr translation table for layer 2
DROP TABLE IF EXISTS translation.nb01_nbi01_lyr_layer2;

CREATE TABLE translation.nb01_nbi01_lyr_layer2 WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_lyr;

UPDATE translation.nb01_nbi01_lyr_layer2
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- NB01_lyr_layer2 mapping attributes related to layer 2 to attributes related to layer 1
CREATE OR REPLACE VIEW rawfri.nb01_lyr_layer2 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid,
l2estyr l1estyr,	
l2cc l1cc, l2ht l1ht,
l2s1 l1s1, l2pr1 l1pr1,
l2s2 l1s2, l2pr2 l1pr2,
l2s3 l1s3, l2pr3 l1pr3,
l2s4 l1s4, l2pr4 l1pr4,
l2s5 l1s5, l2pr5 l1pr5
FROM rawfri.nb01;

-------------------------------------------------------
-- NB02 prep
-------------------------------------------------------
-- Create a VIEW mapping NB02 attributes related to lyr layer 1 to NB01 attributes 
-- related to lyr layer 1 so we can reuse NB01 translation table
CREATE OR REPLACE VIEW rawfri.nb02_lyr_layer1 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid, l1cc, l1ht, l1s1, l1pr1, l1s2, l1pr2, 
l1s3, l1pr3, l1s4, l1pr4, l1s5, l1pr5,
l1estabyr l1estyr
FROM rawfri.nb02;

-- Create a VIEW mapping NB02 attributes related to lyr layer 2 to NB01 attributes 
-- related to layer 1 so we can reuse NB01 translation table
CREATE OR REPLACE VIEW rawfri.nb02_lyr_layer2 AS
SELECT src_filename, inventory_id, stdlab, ogc_fid, 
l2cc l1cc, l2ht l1ht, 
l2s1 l1s1, l2pr1 l1pr1, 
l2s2 l1s2, l2pr2 l1pr2, 
l2s3 l1s3, l2pr3 l1pr3, 
l2s4 l1s4, l2pr4 l1pr4, 
l2s5 l1s5, l2pr5 l1pr5,
l2estabyr l1estyr
FROM rawfri.nb02;

-------------------------------------------------------
-- NT01 prep
-- needs a modified translation table for layer 2.
-- and  VIEW for layer 2
-------------------------------------------------------
-- Reuse the nt01_fvi01_lyr translation table for layer 2
DROP TABLE IF EXISTS translation.nt01_fvi01_lyr_layer2;

CREATE TABLE translation.nt01_fvi01_lyr_layer2 WITH OIDS AS
SELECT * FROM translation.nt01_fvi01_lyr;

UPDATE translation.nt01_fvi01_lyr_layer2
SET translation_rules = 'copyInt(''2'')'
WHERE target_attribute = 'LAYER' OR target_attribute = 'LAYER_RANK';

-- Create a view mapping the nt01 lyr layer 2 attributes to the nt01 lyr attributes
DROP VIEW IF EXISTS rawfri.nt01_lyr_layer2;
CREATE OR REPLACE VIEW rawfri.nt01_lyr_layer2 AS
SELECT src_filename, inventory_id, invproj_id, fc_id_1, ogc_fid, strc_per, si_50,
minmoist moisture, mincrowncl crownclos, minheight height,
minsp1 sp1, minsp1per sp1_per,
minsp2 sp2, minsp2per sp2per,
minsp3 sp3, minsp3per sp3per,
minsp4 sp4, minsp4per sp4per,
minorigin origin, minsitecla siteclass
FROM rawfri.nt01;

-------------------------------------------------------
-- NT02 prep
-- can reuse the nt01 translation tables
-- needs a VIEW for both layer 1 and layer 2
-------------------------------------------------------
-- Create a view mapping the nt02 lyr attributes to the nt01 lyr attributes
DROP VIEW IF EXISTS rawfri.nt02_lyr;
CREATE OR REPLACE VIEW rawfri.nt02_lyr AS
SELECT src_filename, invproj_id, inventory_id, ogc_fid, wkb_geometry, 
moisture, strc_per, crownclos, height, 
sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per,
origin, siteclass, si_50,
fc_id fc_id_1 
FROM rawfri.nt02;

-- Create a view mapping the nt02 lyr layer 2 attributes to the nt01 lyr attributes
CREATE OR REPLACE VIEW rawfri.nt02_lyr_layer2 AS
SELECT src_filename, inventory_id, invproj_id, ogc_fid, strc_per, si_50,
minmoist moisture, mincrownclos crownclos, minheight height,
minsp1 sp1, minsp1per sp1_per,
minsp2 sp2, minsp2per sp2per,
minsp3 sp3, minsp3per sp3per,
minsp4 sp4, minsp4per sp4per,
minorigin origin, minsiteclass siteclass,
fc_id fc_id_1 
FROM rawfri.nt02;
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb_lyr', 'ab06_avi01_lyr'); -- can reuse same function for NB01 and NB02
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr_layer2', '_nb_lyr_layer2', 'ab06_avi01_lyr'); -- can reuse same function for NB01 and NB02 layer 2
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nt01_fvi01_lyr', '_nt_lyr', 'ab06_avi01_lyr'); -- can use same function for NT01 and NT02 layer 1
SELECT TT_Prepare('translation', 'nt01_fvi01_lyr_layer2', '_nt_lyr_layer2', 'ab06_avi01_lyr'); -- can use the same function for NT01 and NT02 layer 2
-------------------------
DROP TABLE IF EXISTS casfri50.lyr_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.lyr_all AS -- 4m41s
SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 46m20s
SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 5h32m
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr_layer2('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr_layer2');
------------------------
-- Reuse TT_Translate_nb01_lyr() for NB02
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr('rawfri', 'nb02_lyr_layer1', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
-- Reuse TT_Translate_nb01_lyr_layer2() for NB02
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb_lyr_layer2('rawfri', 'nb02_lyr_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr_layer2');
------------------------
INSERT INTO casfri50.lyr_all -- 30h19m
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nt_lyr_layer2('rawfri', 'nt01_lyr_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr_layer2');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nt_lyr('rawfri', 'nt02_lyr', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nt_lyr_layer2('rawfri', 'nt02_lyr_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nt01_fvi01_lyr_layer2');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.lyr_all;

SELECT left(cas_id, 4) inv, layer, count(*) nb
FROM casfri50.lyr_all
GROUP BY left(cas_id, 4), layer;

SELECT count(*) FROM casfri50.lyr_all; -- 8911511

-- Add primary and foreign key constraints
ALTER TABLE casfri50.lyr_all ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.lyr_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
