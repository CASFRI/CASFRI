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

-------------------------------------------------------
-------------------------------------------------------
-- Create 200 random rows views on each source inventory
-------------------------------------------------------
-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.ab06 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.ab06;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.ab06_test_200;
CREATE OR REPLACE VIEW rawfri.ab06_test_200 AS
SELECT src_filename, ogc_fid, wkb_geometry, shape_area, area, perimeter, poly_num, 
       trm, moist_reg, density, height, 
       sp1, sp1_per, sp2, sp2_per, sp3, sp3_per, sp4, sp4_per, sp5, sp5_per, 
       struc, struc_val, origin, tpr, nfl, nfl_per, nat_non, anth_veg, anth_non, 
       mod1, mod1_ext, mod1_yr, mod2, mod2_ext, mod2_yr, trm_1
FROM rawfri.ab06 TABLESAMPLE SYSTEM (300.0*100/11484) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.ab06_test_200;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.ab16 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.ab16;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.ab16_test_200;
CREATE OR REPLACE VIEW rawfri.ab16_test_200 AS
SELECT ogc_fid, wkb_geometry, area, perimeter,
       stand_age, age_class, cc_update, moisture, crownclose, height, 
       sp1, sp1_percnt, sp2, sp2_percnt, sp3, sp3_percnt, sp4, sp4_percnt, sp5, sp5_percnt, 
       std_struct, origin, tpr, modcon1, modext1, modyear1, modcon2, modext2, modyear2, 
       nonfor_veg, nonforvecl, anthro_veg, anth_noveg, nat_nonveg, 
       us_moist, us_crown, us_height, 
       us_sp1, us_sp1perc, us_sp2, us_sp2perc, us_sp3, us_sp3perc, us_sp4, us_sp4perc, us_sp5, us_sp5perc, 
       us_struc, us_origin, us_tpr, us_int_trp, 
       modcon1us, modext1us, modyr1us, modcon2us, modext2us, modyr2us, 
       nonforvegu, nforvegclu, us_anthveg, us_annoveg, us_natnveg, 
       src_filename, forest_id_2
FROM rawfri.ab16 TABLESAMPLE SYSTEM (300.0*100/120476) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.ab16_test_200;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- have a look at one of the source inventory table
SELECT * FROM rawfri.nb01 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.nb01;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nb01_test_200;
CREATE OR REPLACE VIEW rawfri.nb01_test_200 AS
SELECT ogc_fid, wkb_geometry, water_code, shape_area, shape_len, src_filename, stdlab, datayr, 
       wc, wri, im, vt, fst, 
       l1trti, l1orig, l1estyr, l1trt, l1trtyr, 
       l1s1, l1ds1, l1pr1, l1s2, l1ds2, l1pr2, 
       l1s3, l1ds3, l1pr3, l1s4, l1ds4, l1pr4, 
       l1s5, l1ds5, l1pr5, l1ds, l1cci, l1cc, 
       l1stock, l1vs, l1ht, l1acs, l1dc, l1sc, l1funa, 
       l2trti, l2orig, l2estyr, l2trt, l2trtyr, 
       l2s1, l2ds1, l2pr1, l2s2, l2ds2, l2pr2, 
       l2s3, l2ds3, l2pr3, l2s4, l2ds4, l2pr4, 
       l2s5, l2ds5, l2pr5, l2ds, l2cci, l2cc, 
       l2stock, l2vs, l2ht, l2acs, l2dc, l2sc, l2funa
FROM rawfri.nb01 TABLESAMPLE SYSTEM (300.0*100/927177) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.nb01_test_200;
-------------------------------------------------------
-- NB02
-------------------------------------------------------
-- have a look at one of the source inventory table
SELECT * FROM rawfri.nb02 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.nb02;

-- create a 200 rows test inventory table
--DROP VIEW IF EXISTS rawfri.nb02_test_200;
CREATE OR REPLACE VIEW rawfri.nb02_test_200 AS
SELECT ogc_fid, wkb_geometry, water_code, shape_area, shape_leng, src_filename, stdlab, datayr, 
       lc, wc, wri, im, vt, fst, sitei, voli, origin, trt, trtyr, 
       h1, h1yr, h2, h2yr, h3, h3yr, h4, h4yr, rf, rfyr, 
       si, siyr, untreati, lpriority, 
       l1datasrc, l1datayr, l1funa, l1estabyr, l1aryr, 
       l1s1, l1ds1, l1pr1, l1s2, l1ds2, l1pr2, l1s3, l1ds3, l1pr3, 
       l1s4, l1ds4, l1pr4, l1s5, l1ds5, l1pr5, 
       l1ds, l1cci, l1cc, l1vol, l1ba, l1pstock, 
       l1vs, l1ht, l1dc, l1sc, l2datasrc, l2datayr, l2funa, l2estabyr, l2aryr, 
       l2s1, l2ds1, l2pr1, l2s2, l2ds2, l2pr2, l2s3, l2ds3, l2pr3, 
       l2s4, l2ds4, l2pr4, l2s5, l2ds5, l2pr5, 
       l2ds, l2cci, l2cc, l2pstock, l2nstock, l2vs, l2ht, l2dc 
FROM rawfri.nb02 TABLESAMPLE SYSTEM (300.0*100/1123893) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.nb02_test_200;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.bc08 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.bc08;

-- create a 200 rows test inventory table
CREATE OR REPLACE VIEW rawfri.bc08_test_200 AS
SELECT ogc_fid, wkb_geometry, feature_id, map_id, inventory_standard_cd, non_productive_descriptor_cd, 
       bclcs_level_1, bclcs_level_2, bclcs_level_3, bclcs_level_4, bclcs_level_5, 
       reference_year, for_mgmt_land_base_ind, projected_date, 
       shrub_height, shrub_crown_closure, shrub_cover_pattern, 
       herb_cover_type, herb_cover_pattern, herb_cover_pct, bryoid_cover_pct, 
       non_veg_cover_pattern_1, non_veg_cover_pct_1, non_veg_cover_type_1, 
       non_veg_cover_pattern_2, non_veg_cover_pct_2, non_veg_cover_type_2, 
       non_veg_cover_pattern_3, non_veg_cover_pct_3, non_veg_cover_type_3, 
       land_cover_class_cd_1, est_coverage_pct_1, soil_moisture_regime_1, 
       land_cover_class_cd_2, est_coverage_pct_2, soil_moisture_regime_2, 
       land_cover_class_cd_3, est_coverage_pct_3, soil_moisture_regime_3, 
       earliest_nonlogging_dist_type, earliest_nonlogging_dist_date, 
       layer_id, for_cover_rank_cd, non_forest_descriptor, 
       est_site_index_species_cd, est_site_index, est_site_index_source_cd, 
       crown_closure, crown_closure_class_cd, reference_date, site_index, 
       tree_cover_pattern, vertical_complexity, 
       species_cd_1, species_pct_1, species_cd_2, species_pct_2, 
       species_cd_3, species_pct_3, species_cd_4, species_pct_4, 
       species_cd_5, species_pct_5, species_cd_6, species_pct_6, 
       proj_age_1, proj_age_class_cd_1, proj_age_2, proj_age_class_cd_2, 
       proj_height_1, proj_height_class_cd_1, proj_height_2, proj_height_class_cd_2, 
       geometry_length, geometry_area, line_7b_disturbance_history, src_filename
FROM rawfri.bc08 TABLESAMPLE SYSTEM (300.0*100/4677411) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.bc08_test_200;

-------------------------------------------------------
-- BC09
-------------------------------------------------------
-- display one of the source inventory table
SELECT * FROM rawfri.bc09 LIMIT 10;

-- count the number of rows
SELECT count(*)
FROM rawfri.bc09;

-- create a 200 rows test inventory table
CREATE OR REPLACE VIEW rawfri.bc09_test_200 AS
SELECT ogc_fid, wkb_geometry, feature_id, map_id, inventory_standard_cd, non_productive_descriptor_cd, 
bclcs_level_1, bclcs_level_2, bclcs_level_3, bclcs_level_4, bclcs_level_5, 
reference_year, for_mgmt_land_base_ind, projected_date, 
shrub_height, shrub_crown_closure, shrub_cover_pattern, 
herb_cover_type, herb_cover_pattern, herb_cover_pct, bryoid_cover_pct, 
non_veg_cover_pattern_1, non_veg_cover_pct_1, non_veg_cover_type_1, 
non_veg_cover_pattern_2, non_veg_cover_pct_2, non_veg_cover_type_2, 
non_veg_cover_pattern_3, non_veg_cover_pct_3, non_veg_cover_type_3, 
land_cover_class_cd_1, est_coverage_pct_1, soil_moisture_regime_1, 
land_cover_class_cd_2, est_coverage_pct_2, soil_moisture_regime_2, 
land_cover_class_cd_3, est_coverage_pct_3, soil_moisture_regime_3, 
earliest_nonlogging_dist_type, earliest_nonlogging_dist_date, 
layer_id, for_cover_rank_cd, non_forest_descriptor, 
est_site_index_species_cd, est_site_index, est_site_index_source_cd, 
crown_closure, crown_closure_class_cd, reference_date, site_index, 
tree_cover_pattern, vertical_complexity, 
species_cd_1, species_pct_1, species_cd_2, species_pct_2, 
species_cd_3, species_pct_3, species_cd_4, species_pct_4, 
species_cd_5, species_pct_5, species_cd_6, species_pct_6, 
proj_age_1, proj_age_class_cd_1, proj_age_2, proj_age_class_cd_2, 
proj_height_1, proj_height_class_cd_1, proj_height_2, proj_height_class_cd_2, 
feature_area_sqm, feature_length_m, src_filename
FROM rawfri.bc09 TABLESAMPLE SYSTEM (300.0*100/5151772) REPEATABLE (1.0)
--WHERE ogc_fid = 2
LIMIT 200;

-- display
SELECT * FROM rawfri.bc09_test_200;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Create test translation tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE SCHEMA translation_test;

-------------------------------------------------------
-- AB06
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.ab06_avi01_cas; 
SELECT * FROM translation.ab06_avi01_dst; 
SELECT * FROM translation.ab06_avi01_eco; 
SELECT * FROM translation.ab06_avi01_lyr; 
SELECT * FROM translation.ab06_avi01_nfl;
SELECT * FROM translation.ab06_avi01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab06_avi01_cas_test;
CREATE TABLE translation_test.ab06_avi01_cas_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_cas
--WHERE rule_id::int = 10
;
-- display
SELECT * FROM translation_test.ab06_avi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.ab06_avi01_dst_test;
CREATE TABLE translation_test.ab06_avi01_dst_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.ab06_avi01_eco_test;
CREATE TABLE translation_test.ab06_avi01_eco_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.ab06_avi01_lyr_test;
CREATE TABLE translation_test.ab06_avi01_lyr_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.ab06_avi01_nfl_test;
CREATE TABLE translation_test.ab06_avi01_nfl_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab06_avi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.ab06_avi01_geo_test;
CREATE TABLE translation_test.ab06_avi01_geo_test WITH OIDS AS
SELECT * FROM translation.ab06_avi01_geo
--WHERE rule_id::int = 2
;
-- display
SELECT * FROM translation_test.ab06_avi01_geo_test;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.ab16_avi01_cas; 
SELECT * FROM translation.ab16_avi01_dst; 
SELECT * FROM translation.ab16_avi01_eco; 
SELECT * FROM translation.ab16_avi01_lyr; 
SELECT * FROM translation.ab16_avi01_nfl;
SELECT * FROM translation.ab16_avi01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.ab16_avi01_cas_test;
CREATE TABLE translation_test.ab16_avi01_cas_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.ab16_avi01_dst_test;
CREATE TABLE translation_test.ab16_avi01_dst_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.ab16_avi01_eco_test;
CREATE TABLE translation_test.ab16_avi01_eco_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.ab16_avi01_lyr_test;
CREATE TABLE translation_test.ab16_avi01_lyr_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.ab16_avi01_nfl_test;
CREATE TABLE translation_test.ab16_avi01_nfl_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.ab16_avi01_geo_test;
CREATE TABLE translation_test.ab16_avi01_geo_test WITH OIDS AS
SELECT * FROM translation.ab16_avi01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.ab16_avi01_geo_test;

-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.nb01_nbi01_cas; 
SELECT * FROM translation.nb01_nbi01_dst; 
SELECT * FROM translation.nb01_nbi01_eco; 
SELECT * FROM translation.nb01_nbi01_lyr; 
SELECT * FROM translation.nb01_nbi01_nfl;
SELECT * FROM translation.nb01_nbi01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.nb01_nbi01_cas_test;
CREATE TABLE translation_test.nb01_nbi01_cas_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.nb01_nbi01_dst_test;
CREATE TABLE translation_test.nb01_nbi01_dst_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.nb01_nbi01_eco_test;
CREATE TABLE translation_test.nb01_nbi01_eco_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.nb01_nbi01_lyr_test;
CREATE TABLE translation_test.nb01_nbi01_lyr_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.nb01_nbi01_nfl_test;
CREATE TABLE translation_test.nb01_nbi01_nfl_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.nb01_nbi01_geo_test;
CREATE TABLE translation_test.nb01_nbi01_geo_test WITH OIDS AS
SELECT * FROM translation.nb01_nbi01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.nb01_nbi01_geo_test;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.bc08_vri01_cas; 
SELECT * FROM translation.bc08_vri01_dst; 
SELECT * FROM translation.bc08_vri01_eco; 
SELECT * FROM translation.bc08_vri01_lyr; 
SELECT * FROM translation.bc08_vri01_nfl;
SELECT * FROM translation.bc08_vri01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.bc08_vri01_cas_test;
CREATE TABLE translation_test.bc08_vri01_cas_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.bc08_vri01_dst_test;
CREATE TABLE translation_test.bc08_vri01_dst_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.bc08_vri01_eco_test;
CREATE TABLE translation_test.bc08_vri01_eco_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.bc08_vri01_lyr_test;
CREATE TABLE translation_test.bc08_vri01_lyr_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_lyr
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.bc08_vri01_nfl_test;
CREATE TABLE translation_test.bc08_vri01_nfl_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.bc08_vri01_geo_test;
CREATE TABLE translation_test.bc08_vri01_geo_test WITH OIDS AS
SELECT * FROM translation.bc08_vri01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc08_vri01_geo_test;

-------------------------------------------------------
-- BC09
-------------------------------------------------------
-- display translation tables
SELECT * FROM translation.bc09_vri01_cas; 
SELECT * FROM translation.bc09_vri01_dst; 
SELECT * FROM translation.bc09_vri01_eco; 
SELECT * FROM translation.bc09_vri01_lyr; 
SELECT * FROM translation.bc09_vri01_nfl;
SELECT * FROM translation.bc09_vri01_geo;
----------------------------
-- create subsets of translation tables if necessary
----------------------------
-- cas
DROP TABLE IF EXISTS translation_test.bc09_vri01_cas_test;
CREATE TABLE translation_test.bc09_vri01_cas_test WITH OIDS AS
SELECT * FROM translation.bc09_vri01_cas
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc09_vri01_cas_test;
----------------------------
-- dst
DROP TABLE IF EXISTS translation_test.bc09_vri01_dst_test;
CREATE TABLE translation_test.bc09_vri01_dst_test WITH OIDS AS
SELECT * FROM translation.bc09_vri01_dst
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc09_vri01_dst_test;
----------------------------
-- eco
DROP TABLE IF EXISTS translation_test.bc09_vri01_eco_test;
CREATE TABLE translation_test.bc09_vri01_eco_test WITH OIDS AS
SELECT * FROM translation.bc09_vri01_eco
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc09_vri01_eco_test;
----------------------------
-- lyr
DROP TABLE IF EXISTS translation_test.bc09_vri01_lyr_test;
CREATE TABLE translation_test.bc09_vri01_lyr_test WITH OIDS AS
SELECT * FROM translation.bc09_vri01_lyr
--WHERE rule_id::int = 34
;
-- display
SELECT * FROM translation_test.bc09_vri01_lyr_test;
----------------------------
-- nfl
DROP TABLE IF EXISTS translation_test.bc09_vri01_nfl_test;
CREATE TABLE translation_test.bc09_vri01_nfl_test WITH OIDS AS
SELECT * FROM translation.bc09_vri01_nfl
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc09_vri01_nfl_test;
----------------------------
-- geo
DROP TABLE IF EXISTS translation_test.bc09_vri01_geo_test;
CREATE TABLE translation_test.bc09_vri01_geo_test WITH OIDS AS
SELECT * FROM translation.bc09_vri01_geo
--WHERE rule_id::int = 1
;
-- display
SELECT * FROM translation_test.bc09_vri01_geo_test;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Validate dependency tables
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_avi01_species_validation', '_ab_species_val');
SELECT * FROM TT_Translate_ab_species_val('translation', 'ab_avi01_species');

-------------------------------------------------------
-- BC species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'bc_vri01_species_validation', '_bc_species_val');
SELECT * FROM TT_Translate_bc_species_val('translation', 'bc_vri01_species');

-------------------------------------------------------
-- NB species table
-------------------------------------------------------
SELECT TT_Prepare('translation', 'nb_nbi01_species_validation', '_nb_species_val');
SELECT * FROM TT_Translate_nb_species_val('translation', 'nb_nbi01_species');

-------------------------------------------------------
-- AB photo year
-------------------------------------------------------
SELECT TT_Prepare('translation', 'ab_photoyear_validation', '_ab_photo_val');
SELECT * FROM TT_Translate_ab_photo_val('rawfri', 'ab_photoyear'); -- 5s

-- make table valid and subset by rows with valid photo years
CREATE TABLE rawfri.new_photo_year AS
SELECT TT_GeoMakeValid(wkb_geometry) as wkb_geometry, photo_yr
FROM rawfri.ab_photoyear
WHERE TT_IsInt(photo_yr);

CREATE INDEX ab_photoyear_idx 
 ON rawfri.new_photo_year
 USING GIST(wkb_geometry);

DROP TABLE rawfri.ab_photoyear;
ALTER TABLE rawfri.new_photo_year RENAME TO ab_photoyear;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Translate the sample table
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- AB06
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'ab06_avi01_cas_test', '_ab06_cas');
SELECT TT_Prepare('translation_test', 'ab06_avi01_dst_test', '_ab06_dst');
SELECT TT_Prepare('translation_test', 'ab06_avi01_eco_test', '_ab06_eco');
SELECT TT_Prepare('translation_test', 'ab06_avi01_lyr_test', '_ab06_lyr');
SELECT TT_Prepare('translation_test', 'ab06_avi01_nfl_test', '_ab06_nfl');
SELECT TT_Prepare('translation_test', 'ab06_avi01_geo_test', '_ab06_geo');

-- translate the samples (5 sec.)
SELECT * FROM TT_Translate_ab06_cas('rawfri', 'ab06_test_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_cas_test');

SELECT * FROM TT_Translate_ab06_dst('rawfri', 'ab06_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_dst_test');

SELECT * FROM TT_Translate_ab06_eco('rawfri', 'ab06_test_200', 'ogc_fid'); -- 1 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_eco_test');

SELECT * FROM TT_Translate_ab06_lyr('rawfri', 'ab06_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_lyr_test');

SELECT * FROM TT_Translate_ab06_nfl('rawfri', 'ab06_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_nfl_test');

SELECT * FROM TT_Translate_ab06_geo('rawfri', 'ab06_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab06_avi01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, trm_1, poly_num, cas_id, 
       density, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_per, species_per_1
FROM TT_Translate_ab06_lyr('rawfri', 'ab06_test_200'), rawfri.ab06_test_200
WHERE poly_num = substr(cas_id, 33, 10)::int;

-------------------------------------------------------
-- AB16
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'ab16_avi01_cas_test', '_ab16_cas');
SELECT TT_Prepare('translation_test', 'ab16_avi01_dst_test', '_ab16_dst');
SELECT TT_Prepare('translation_test', 'ab16_avi01_eco_test', '_ab16_eco');
SELECT TT_Prepare('translation_test', 'ab16_avi01_lyr_test', '_ab16_lyr');
SELECT TT_Prepare('translation_test', 'ab16_avi01_nfl_test', '_ab16_nfl');
SELECT TT_Prepare('translation_test', 'ab16_avi01_geo_test', '_ab16_geo');

-- translate the samples
SELECT * FROM TT_Translate_ab16_cas('rawfri', 'ab16_test_200', 'ogc_fid'); -- 6 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_cas_test');

SELECT * FROM TT_Translate_ab16_dst('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_dst_test');

SELECT * FROM TT_Translate_ab16_eco('rawfri', 'ab16_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_eco_test');

SELECT * FROM TT_Translate_ab16_lyr('rawfri', 'ab16_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_lyr_test');

SELECT * FROM TT_Translate_ab16_nfl('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_nfl_test');

SELECT * FROM TT_Translate_ab16_geo('rawfri', 'ab16_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'ab16_avi01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, forest_id, ogc_fid, cas_id, 
       crownclose, crown_closure_lower, crown_closure_upper, 
       height, height_upper, height_lower,
       sp1, species_1,
       sp1_percnt, species_per_1
FROM TT_Translate_ab16_lyr('rawfri', 'ab16_test_200'), rawfri.ab16_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;
-------------------------------------------------------
-- NB01
-------------------------------------------------------
-- create translation function
SELECT TT_Prepare('translation_test', 'nb01_nbi01_cas_test', '_nb01_cas');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_dst_test', '_nb01_dst');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_eco_test', '_nb01_eco');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_lyr_test', '_nb01_lyr');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_nfl_test', '_nb01_nfl');
SELECT TT_Prepare('translation_test', 'nb01_nbi01_geo_test', '_nb01_geo');

-- translate the samples
SELECT * FROM TT_Translate_nb01_cas('rawfri', 'nb01_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_cas_test');

SELECT * FROM TT_Translate_nb01_dst('rawfri', 'nb01_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_dst_test');

SELECT * FROM TT_Translate_nb01_eco('rawfri', 'nb01_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_eco_test');

SELECT * FROM TT_Translate_nb01_lyr('rawfri', 'nb01_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_lyr_test');

SELECT * FROM TT_Translate_nb01_nfl('rawfri', 'nb01_test_200', 'ogc_fid'); -- 3 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_nfl_test');

SELECT * FROM TT_Translate_nb01_geo('rawfri', 'nb01_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'nb01_nbi01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, stdlab, ogc_fid, cas_id, 
       l1cc, crown_closure_lower, crown_closure_upper, 
       l1ht, height_upper, height_lower, 
       l1s1, species_1,
       l1pr1, species_per_1
FROM TT_Translate_nb01_lyr('rawfri', 'nb01_test_200'), rawfri.nb01_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

-------------------------------------------------------
-- BC08
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'bc08_vri01_cas_test', '_bc08_cas');
SELECT TT_Prepare('translation_test', 'bc08_vri01_dst_test', '_bc08_dst');
SELECT TT_Prepare('translation_test', 'bc08_vri01_eco_test', '_bc08_eco');
SELECT TT_Prepare('translation_test', 'bc08_vri01_lyr_test', '_bc08_lyr');
SELECT TT_Prepare('translation_test', 'bc08_vri01_nfl_test', '_bc08_nfl');
SELECT TT_Prepare('translation_test', 'bc08_vri01_geo_test', '_bc08_geo');

-- translate the samples
SELECT * FROM TT_Translate_bc08_cas('rawfri', 'bc08_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_cas_test');

SELECT * FROM TT_Translate_bc08_dst('rawfri', 'bc08_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_dst_test');

SELECT * FROM TT_Translate_bc08_eco('rawfri', 'bc08_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_eco_test');

SELECT * FROM TT_Translate_bc08_lyr('rawfri', 'bc08_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_lyr_test');

SELECT * FROM TT_Translate_bc08_nfl('rawfri', 'bc08_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_nfl_test');

SELECT * FROM TT_Translate_bc08_geo('rawfri', 'bc08_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc08_vri01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, map_id, ogc_fid, cas_id, 
       crown_closure, crown_closure_lower, crown_closure_upper, 
       proj_height_1, height_upper, height_lower,
       species_cd_1, species_1,
       species_pct_1, species_per_1
FROM TT_Translate_bc08_lyr('rawfri', 'bc08_test_200'), rawfri.bc08_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

-------------------------------------------------------
-- BC09
-------------------------------------------------------
-- create translation functions
SELECT TT_Prepare('translation_test', 'bc09_vri01_cas_test', '_bc09_cas');
SELECT TT_Prepare('translation_test', 'bc09_vri01_dst_test', '_bc09_dst');
SELECT TT_Prepare('translation_test', 'bc09_vri01_eco_test', '_bc09_eco');
SELECT TT_Prepare('translation_test', 'bc09_vri01_lyr_test', '_bc09_lyr');
SELECT TT_Prepare('translation_test', 'bc09_vri01_nfl_test', '_bc09_nfl');
SELECT TT_Prepare('translation_test', 'bc09_vri01_geo_test', '_bc09_geo');

-- translate the samples
SELECT * FROM TT_Translate_bc09_cas('rawfri', 'bc09_test_200', 'ogc_fid'); -- 5 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_cas_test');

SELECT * FROM TT_Translate_bc09_dst('rawfri', 'bc09_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_dst_test');

SELECT * FROM TT_Translate_bc09_eco('rawfri', 'bc09_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_eco_test');

SELECT * FROM TT_Translate_bc09_lyr('rawfri', 'bc09_test_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_lyr_test');

SELECT * FROM TT_Translate_bc09_nfl('rawfri', 'bc09_test_200', 'ogc_fid'); -- 4 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_nfl_test');

SELECT * FROM TT_Translate_bc09_geo('rawfri', 'bc09_test_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_test', 'bc09_vri01_geo_test');

-- display original values and translated values side-by-side to compare and debug the translation table
SELECT src_filename, map_id, ogc_fid, cas_id, 
       crown_closure, crown_closure_lower, crown_closure_upper, 
       proj_height_1, height_upper, height_lower,
       species_cd_1, species_1,
       species_pct_1, species_per_1
FROM TT_Translate_bc09_lyr('rawfri', 'bc09_test_200'), rawfri.bc09_test_200
WHERE ogc_fid::int = right(cas_id, 7)::int;

--------------------------------------------------------------------------
SELECT TT_DeleteAllLogs('translation_test');


