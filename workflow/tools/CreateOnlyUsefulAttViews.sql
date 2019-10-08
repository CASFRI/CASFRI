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
-- Create views on the source data with only the required attributes
-------------------------------------------------------
-------------------------------------------------------
-- AB06
-------------------------------------------------------
CREATE OR REPLACE VIEW rawfri.ab06_only_useful_att AS
SELECT src_filename, ogc_fid, wkb_geometry, shape_area, area, perimeter, poly_num, 
       trm, moist_reg, density, height, 
       sp1, sp1_per, sp2, sp2_per, sp3, sp3_per, sp4, sp4_per, sp5, sp5_per, 
       struc, struc_val, origin, tpr, nfl, nfl_per, nat_non, anth_veg, anth_non, 
       mod1, mod1_ext, mod1_yr, mod2, mod2_ext, mod2_yr, trm_1
FROM rawfri.ab06;
-------------------------------------------------------
-- AB16
-------------------------------------------------------
CREATE OR REPLACE VIEW rawfri.ab16_only_useful_att AS
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
FROM rawfri.ab16;
-------------------------------------------------------
-- NB01
-------------------------------------------------------
CREATE OR REPLACE VIEW rawfri.nb01_only_useful_att AS
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
FROM rawfri.nb01;
-------------------------------------------------------
-- NB02
-------------------------------------------------------
CREATE OR REPLACE VIEW rawfri.nb02_only_useful_att AS
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
FROM rawfri.nb02;
-------------------------------------------------------
-- BC08
-------------------------------------------------------
CREATE OR REPLACE VIEW rawfri.bc08_only_useful_att AS
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
FROM rawfri.bc08;
-------------------------------------------------------
-- BC09
-------------------------------------------------------
CREATE OR REPLACE VIEW rawfri.bc09_only_useful_att AS
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
FROM rawfri.bc09;
