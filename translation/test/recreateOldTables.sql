DROP TABLE IF EXISTS casfri50_test.cas_all_new CASCADE;
CREATE TABLE casfri50_test.cas_all_new AS
SELECT * FROM casfri50_test.cas_ab_new
UNION ALL
SELECT * FROM casfri50_test.cas_bc_new
UNION ALL
SELECT * FROM casfri50_test.cas_ds_new
UNION ALL
SELECT * FROM casfri50_test.cas_mb_new
UNION ALL
SELECT * FROM casfri50_test.cas_nb_new
UNION ALL
SELECT * FROM casfri50_test.cas_nl_new
UNION ALL
SELECT * FROM casfri50_test.cas_ns_new
UNION ALL
SELECT * FROM casfri50_test.cas_nt_new
UNION ALL
SELECT * FROM casfri50_test.cas_on_new
UNION ALL
SELECT * FROM casfri50_test.cas_pc_new
UNION ALL
SELECT * FROM casfri50_test.cas_pe_new
UNION ALL
SELECT * FROM casfri50_test.cas_qc_new
UNION ALL
SELECT * FROM casfri50_test.cas_sk_new
UNION ALL
SELECT * FROM casfri50_test.cas_yt_new;
------------------------
-- Create an ordered VIEW on the CAS table
CREATE OR REPLACE VIEW casfri50_test.cas_all_new_ordered AS
SELECT * FROM casfri50_test.cas_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, inventory_id, orig_stand_id, stand_structure, 
         num_of_layers, map_sheet_id, casfri_area, 
         casfri_perimeter, src_inv_area, stand_photo_year; 
------------------------
DROP TABLE IF EXISTS casfri50_test.dst_all_new CASCADE;
CREATE TABLE casfri50_test.dst_all_new AS
SELECT * FROM casfri50_test.dst_ab_new
UNION ALL
SELECT * FROM casfri50_test.dst_bc_new
UNION ALL
SELECT * FROM casfri50_test.dst_ds_new
UNION ALL
SELECT * FROM casfri50_test.dst_mb_new
UNION ALL
SELECT * FROM casfri50_test.dst_nb_new
UNION ALL
SELECT * FROM casfri50_test.dst_nl_new
UNION ALL
SELECT * FROM casfri50_test.dst_ns_new
UNION ALL
SELECT * FROM casfri50_test.dst_nt_new
UNION ALL
SELECT * FROM casfri50_test.dst_on_new
UNION ALL
SELECT * FROM casfri50_test.dst_pc_new
UNION ALL
SELECT * FROM casfri50_test.dst_pe_new
UNION ALL
SELECT * FROM casfri50_test.dst_qc_new
UNION ALL
SELECT * FROM casfri50_test.dst_sk_new
UNION ALL
SELECT * FROM casfri50_test.dst_yt_new;
------------------------
-- Create an ordered VIEW on the DST table
CREATE OR REPLACE VIEW casfri50_test.dst_all_new_ordered AS
SELECT * FROM casfri50_test.dst_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1,
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2,
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3;
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50_test.eco_all_new CASCADE;
CREATE TABLE casfri50_test.eco_all_new AS
SELECT * FROM casfri50_test.eco_ab_new
UNION ALL
SELECT * FROM casfri50_test.eco_bc_new
--UNION ALL
--SELECT * FROM casfri50_test.eco_ds_new
UNION ALL
SELECT * FROM casfri50_test.eco_mb_new
UNION ALL
SELECT * FROM casfri50_test.eco_nb_new
UNION ALL
SELECT * FROM casfri50_test.eco_nl_new
UNION ALL
SELECT * FROM casfri50_test.eco_ns_new
UNION ALL
SELECT * FROM casfri50_test.eco_nt_new
UNION ALL
SELECT * FROM casfri50_test.eco_on_new
UNION ALL
SELECT * FROM casfri50_test.eco_pc_new
UNION ALL
SELECT * FROM casfri50_test.eco_pe_new
UNION ALL
SELECT * FROM casfri50_test.eco_qc_new
UNION ALL
SELECT * FROM casfri50_test.eco_sk_new
UNION ALL
SELECT * FROM casfri50_test.eco_yt_new;
------------------------
-- Create an ordered VIEW on the ECO table
CREATE OR REPLACE VIEW casfri50_test.eco_all_new_ordered AS
SELECT * FROM casfri50_test.eco_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, eco_site, layer;
-------------------------------------------------------
DROP TABLE IF EXISTS casfri50_test.lyr_all_new CASCADE;
CREATE TABLE casfri50_test.lyr_all_new AS
SELECT * FROM casfri50_test.lyr_ab_new
UNION ALL
SELECT * FROM casfri50_test.lyr_bc_new
--UNION ALL
--SELECT * FROM casfri50_test.lyr_ds_new
UNION ALL
SELECT * FROM casfri50_test.lyr_mb_new
UNION ALL
SELECT * FROM casfri50_test.lyr_nb_new
UNION ALL
SELECT * FROM casfri50_test.lyr_nl_new
UNION ALL
SELECT * FROM casfri50_test.lyr_ns_new
UNION ALL
SELECT * FROM casfri50_test.lyr_nt_new
UNION ALL
SELECT * FROM casfri50_test.lyr_on_new
UNION ALL
SELECT * FROM casfri50_test.lyr_pc_new
UNION ALL
SELECT * FROM casfri50_test.lyr_pe_new
UNION ALL
SELECT * FROM casfri50_test.lyr_qc_new
UNION ALL
SELECT * FROM casfri50_test.lyr_sk_new
UNION ALL
SELECT * FROM casfri50_test.lyr_yt_new;
------------------------
-- Create an ordered VIEW on the LYR table
CREATE OR REPLACE VIEW casfri50_test.lyr_all_new_ordered AS
SELECT * FROM casfri50_test.lyr_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index;
---------------------------------------------------------
DROP TABLE IF EXISTS casfri50_test.nfl_all_new CASCADE;
CREATE TABLE casfri50_test.nfl_all_new AS
SELECT * FROM casfri50_test.nfl_ab_new
UNION ALL
SELECT * FROM casfri50_test.nfl_bc_new
UNION ALL
SELECT * FROM casfri50_test.nfl_ds_new
UNION ALL
SELECT * FROM casfri50_test.nfl_mb_new
UNION ALL
SELECT * FROM casfri50_test.nfl_nb_new
UNION ALL
SELECT * FROM casfri50_test.nfl_nl_new
UNION ALL
SELECT * FROM casfri50_test.nfl_ns_new
UNION ALL
SELECT * FROM casfri50_test.nfl_nt_new
UNION ALL
SELECT * FROM casfri50_test.nfl_on_new
UNION ALL
SELECT * FROM casfri50_test.nfl_pc_new
UNION ALL
SELECT * FROM casfri50_test.nfl_pe_new
UNION ALL
SELECT * FROM casfri50_test.nfl_qc_new
UNION ALL
SELECT * FROM casfri50_test.nfl_sk_new
UNION ALL
SELECT * FROM casfri50_test.nfl_yt_new;
------------------------
-- Create an ordered VIEW on the NFL table
CREATE OR REPLACE VIEW casfri50_test.nfl_all_new_ordered AS
SELECT * FROM casfri50_test.nfl_all_new
-- ORDER BY all columns to ensure that only identical row can be intermixed
ORDER BY cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg;
---------------------------------------------------------
