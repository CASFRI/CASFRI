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
CREATE SCHEMA casfri50;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all HDR tables into a common table
-- HDR tables only need one row per inventory, they
-- do not need to be made using translation, we can just
-- select the required row and columns from the
-- inventory_list_cas05 table.
-------------------------------------------------------
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50.hdr_all CASCADE;

CREATE TABLE casfri50.hdr_all AS -- 1 s
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id IN ('AB06', 'AB16', 'BC08', 'NB01', 'NB02');
------------------------
SELECT count(*) FROM casfri50.hdr_all; -- 5

ALTER TABLE casfri50.hdr_all ADD PRIMARY KEY (inventory_id);
-------------------------------------------------------
-------------------------------------------------------
-- Translate all CAS tables into a common table
-------------------------------------------------------
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_cas', '_ab06_cas');
SELECT TT_Prepare('translation', 'ab16_avi01_cas', '_ab16_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'nb01_nbi01_cas', '_nb01_cas', 'ab06_avi01_cas');
SELECT TT_Prepare('translation', 'bc08_vri01_cas', '_bc08_cas', 'ab06_avi01_cas');
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
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.cas_all; 

SELECT count(*) FROM casfri50.cas_all; -- 5736548

-- Add primary and foreign key constraints
ALTER TABLE casfri50.cas_all 
ADD PRIMARY KEY (cas_id);

ALTER TABLE casfri50.hdr_all
ADD FOREIGN KEY (inventory_id) REFERENCES casfri50.hdr_all (inventory_id) MATCH FULL;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all DST tables into a common table
-------------------------------------------------------
-------------------------------------------------------
-- Reuse nb01_nbi01_dst for dst layer 2
DROP TABLE IF EXISTS translation.nb01_nbi01_dst_layer2;

CREATE TABLE translation.nb01_nbi01_dst_layer2 WITH OIDS AS
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

SELECT * FROM TT_ShowLastLog('translation', 'nb02_nbi01_dst');
------------------------
INSERT INTO casfri50.dst_all -- 7h3m
SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_dst');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.dst_all; 

SELECT count(*) FROM casfri50.dst_all; -- 5736548

-- Add primary and foreign key constraints
ALTER TABLE casfri50.dst_all 
ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.dst_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all ECO tables into a common table
-------------------------------------------------------
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_eco', '_ab06_eco');
SELECT TT_Prepare('translation', 'ab16_avi01_eco', '_ab16_eco', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'nb01_nbi01_eco', '_nb01_eco', 'ab06_avi01_eco');
SELECT TT_Prepare('translation', 'bc08_vri01_eco', '_bc08_eco', 'ab06_avi01_eco');
------------------------
DROP TABLE IF EXISTS casfri50.eco_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.eco_all AS -- 36s
SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_eco');
------------------------
INSERT INTO casfri50.eco_all -- 6m2s
SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_eco');
------------------------
INSERT INTO casfri50.eco_all -- 1h27m
SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_eco');
------------------------
-- Reuse TT_Translate_nb01_eco() for NB02
INSERT INTO casfri50.eco_all -- 
SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb02', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi02_eco');
------------------------
INSERT INTO casfri50.eco_all -- 4h05m
SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_eco');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.eco_all; 

SELECT count(*) FROM casfri50.eco_all; -- 5736548

-- Add primary and foreign key constraints
ALTER TABLE casfri50.eco_all ADD PRIMARY KEY (cas_id);

ALTER TABLE casfri50.eco_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all LYR tables into a common table
-------------------------------------------------------
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
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06_lyr');
SELECT TT_Prepare('translation', 'ab16_avi01_lyr', '_ab16_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr', '_nb01_lyr', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr_layer2', '_nb01_lyr_layer2', 'ab06_avi01_lyr');
SELECT TT_Prepare('translation', 'bc08_vri01_lyr', '_bc08_lyr', 'ab06_avi01_lyr');
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
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb01_lyr_layer2('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr_layer2');
------------------------
-- Reuse TT_Translate_nb01_lyr() for NB02
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb02_lyr_layer1', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr');
------------------------
-- Reuse TT_Translate_nb01_lyr_layer2() for NB02
INSERT INTO casfri50.lyr_all -- 
SELECT * FROM TT_Translate_nb01_lyr_layer2('rawfri', 'nb02_lyr_layer2', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_lyr_layer2');
------------------------
INSERT INTO casfri50.lyr_all -- 30h19m
SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_lyr');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.lyr_all; 

SELECT count(*) FROM casfri50.lyr_all; -- 5736548

-- Add primary and foreign key constraints
ALTER TABLE casfri50.lyr_all ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.lyr_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all NFL tables into a common table
-------------------------------------------------------
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_nfl', '_ab06_nfl');
SELECT TT_Prepare('translation', 'ab16_avi01_nfl', '_ab16_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'nb01_nbi01_nfl', '_nb01_nfl', 'ab06_avi01_nfl');
SELECT TT_Prepare('translation', 'bc08_vri01_nfl', '_bc08_nfl', 'ab06_avi01_nfl');
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
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.nfl_all; 

SELECT count(*) FROM casfri50.nfl_all; -- 5736548

-- Add primary and foreign key constraints
ALTER TABLE casfri50.nfl_all ADD PRIMARY KEY (cas_id, layer);

ALTER TABLE casfri50.nfl_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
-------------------------------------------------------
-------------------------------------------------------
-- Translate all GEO tables into a common table
-------------------------------------------------------
-- Prepare the translation functions
SELECT TT_Prepare('translation', 'ab06_avi01_geo', '_ab06_geo');
SELECT TT_Prepare('translation', 'ab16_avi01_geo', '_ab16_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'nb01_nbi01_geo', '_nb01_geo', 'ab06_avi01_geo');
SELECT TT_Prepare('translation', 'bc08_vri01_geo', '_bc08_geo', 'ab06_avi01_geo');
------------------------
DROP TABLE IF EXISTS casfri50.geo_all CASCADE;
------------------------
-- Translate
CREATE TABLE casfri50.geo_all AS -- 54s
SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab06_avi01_geo');
------------------------
INSERT INTO casfri50.geo_all -- 7m30s
SELECT * FROM TT_Translate_ab16_geo('rawfri', 'ab16', 'ogc_fid'); 

SELECT * FROM TT_ShowLastLog('translation', 'ab16_avi01_geo');
------------------------
INSERT INTO casfri50.geo_all -- 48m52s
SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb01', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_geo');
------------------------
-- Reuse TT_Translate_nb01_geo() for NB02
INSERT INTO casfri50.geo_all -- 
SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb02', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'nb01_nbi01_geo');
------------------------
INSERT INTO casfri50.geo_all --4h59m
SELECT * FROM TT_Translate_bc08_geo('rawfri', 'bc08', 'ogc_fid');

SELECT * FROM TT_ShowLastLog('translation', 'bc08_vri01_geo');
------------------------
-- Check processed inventories and count
SELECT DISTINCT left(cas_id, 4) inv FROM casfri50.geo_all; 

SELECT count(*) FROM casfri50.geo_all; --5736548
SELECT count(*) FROM casfri50.geo_all WHERE geometry = '010300000000000000'; -- 0

-- Add primary and foreign key constraints
ALTER TABLE casfri50.geo_all ADD PRIMARY KEY (cas_id);

ALTER TABLE casfri50.geo_all
ADD FOREIGN KEY (cas_id) REFERENCES casfri50.cas_all (cas_id) MATCH FULL;
------------------------