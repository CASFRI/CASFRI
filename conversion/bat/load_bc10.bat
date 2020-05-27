:: This script loads the British Columbia VRI forest inventory (BC10) into PostgreSQL

:: This dataset is split into 3 geodatabases, layer 1, layer 2, and a dead layer

:: The year of photography is included in the attributes table (REFERENCE_YEAR)

:: Load into a target table in the schema defined in the config file.

:: If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
:: in the configuration file.

:: All three source tables have the same attributes, and the same polygons.
:: There are therefore 3 records per polygon.
:: We need a flat source table with one attribute per row.
:: Load the three tables into PostgreSQL, prefix attribute  names
:: to have the prefix L1_, L2_ or D_. This way all tables will have unique attribute.
:: The first 97 attributes have identical values in all three datasets, i.e. they are
:: polygon level attributes. Only need to load these once with no prefix.
:: Then merge the three tables into one final source table using ogrinfo and -sql.

:: ######################################## Set variables #######################################

SETLOCAL

CALL .\common.bat

SET inventoryID=BC10

SET srcFileName=VEG_COMP_LYR

SET srcFileName_L1=%srcFileName%_L1_POLY
SET srcFullPath_L1="%friDir%\BC\%inventoryID%\data\inventory\%srcFileName_L1%.gdb"

SET srcFileName_L2=%srcFileName%_L2_POLY
SET srcFullPath_L2="%friDir%\BC\%inventoryID%\data\inventory\%srcFileName_L2%.gdb"

SET fullTargetTableName=%targetFRISchema%.bc10
SET tableName_L1=%fullTargetTableName%_layer_1
SET tableName_L2=%fullTargetTableName%_layer_2

:: ########################################## Process ######################################

:: Define query joining layer 1 and layer 2 into the final table

SET query=CREATE INDEX ON %tableName_L2% (feature_id); ^
DROP TABLE IF EXISTS %fullTargetTableName%; ^
CREATE TABLE %fullTargetTableName% AS ^
SELECT '%srcFileName%' AS src_filename, ^
'%inventoryID%' AS inventory_id, ^
t1.wkb_geometry, ^
t1.ogc_fid, ^
t1.map_id, ^
t1.polygon_id, ^
t1.feature_id, ^
t1.opening_ind, ^
t1.opening_source, ^
t1.opening_number, ^
t1.feature_class_skey, ^
t1.inventory_standard_cd, ^
t1.polygon_area, ^
t1.non_productive_descriptor_cd, ^
t1.non_productive_cd, ^
t1.input_date, ^
t1.coast_interior_cd, ^
t1.surface_expression, ^
t1.modifying_process, ^
t1.site_position_meso, ^
t1.alpine_designation, ^
t1.soil_nutrient_regime, ^
t1.ecosys_class_data_src_cd, ^
t1.bclcs_level_1, ^
t1.bclcs_level_2, ^
t1.bclcs_level_3, ^
t1.bclcs_level_4, ^
t1.bclcs_level_5, ^
t1.interpreter, ^
t1.interpretation_date, ^
t1.project, ^
t1.reference_year, ^
t1.special_cruise_number, ^
t1.special_cruise_number_cd, ^
t1.inventory_region, ^
t1.compartment, ^
t1.compartment_letter, ^
t1.fiz_cd, ^
t1.for_mgmt_land_base_ind, ^
t1.attribution_base_date, ^
t1.projected_date, ^
t1.shrub_height, ^
t1.shrub_crown_closure, ^
t1.shrub_cover_pattern, ^
t1.herb_cover_type, ^
t1.herb_cover_pattern, ^
t1.herb_cover_pct, ^
t1.bryoid_cover_pct, ^
t1.non_veg_cover_pattern_1, ^
t1.non_veg_cover_pct_1, ^
t1.non_veg_cover_type_1, ^
t1.non_veg_cover_pattern_2, ^
t1.non_veg_cover_pct_2, ^
t1.non_veg_cover_type_2, ^
t1.non_veg_cover_pattern_3, ^
t1.non_veg_cover_pct_3, ^
t1.non_veg_cover_type_3, ^
t1.land_cover_class_cd_1, ^
t1.est_coverage_pct_1, ^
t1.soil_moisture_regime_1, ^
t1.land_cover_class_cd_2, ^
t1.est_coverage_pct_2, ^
t1.soil_moisture_regime_2, ^
t1.land_cover_class_cd_3, ^
t1.est_coverage_pct_3, ^
t1.soil_moisture_regime_3, ^
t1.avail_label_height, ^
t1.avail_label_width, ^
t1.full_label, ^
t1.label_centre_x, ^
t1.label_centre_y, ^
t1.label_height, ^
t1.label_width, ^
t1.line_1_opening_number, ^
t1.line_1_opening_symbol_cd, ^
t1.line_2_polygon_id, ^
t1.line_3_tree_species, ^
t1.line_4_classes_indexes, ^
t1.line_5_vegetation_cover, ^
t1.line_6_site_prep_history, ^
t1.line_7_activity_hist_symbol, ^
t1.line_7a_stand_tending_history, ^
t1.line_7b_disturbance_history, ^
t1.line_8_planting_history, ^
t1.printable_ind, ^
t1.small_label, ^
t1.opening_id, ^
t1.org_unit_no, ^
t1.org_unit_code, ^
t1.adjusted_ind, ^
t1.bec_zone_code, ^
t1.bec_subzone, ^
t1.bec_variant, ^
t1.bec_phase, ^
t1.earliest_nonlogging_dist_type, ^
t1.earliest_nonlogging_dist_date, ^
t1.stand_percentage_dead, ^
t1.free_to_grow_ind, ^
t1.harvest_date, ^
t1.feature_area_sqm, ^
t1.feature_length_m, ^
t1.layer_id AS l1_layer_id, ^
t1.for_cover_rank_cd AS l1_for_cover_rank_cd, ^
t1.non_forest_descriptor AS l1_non_forest_descriptor, ^
t1.interpreted_data_src_cd AS l1_interpreted_data_src_cd, ^
t1.est_site_index_species_cd AS l1_est_site_index_species_cd, ^
t1.est_site_index AS l1_est_site_index, ^
t1.est_site_index_source_cd AS l1_est_site_index_source_cd, ^
t1.crown_closure AS l1_crown_closure, ^
t1.crown_closure_class_cd AS l1_crown_closure_class_cd, ^
t1.reference_date AS l1_reference_date, ^
t1.site_index AS l1_site_index, ^
t1.vri_live_stems_per_ha AS l1_vri_live_stems_per_ha, ^
t1.data_src_vri_live_stem_ha_cd AS l1_data_src_vri_live_stem_ha_cd, ^
t1.vri_dead_stems_per_ha AS l1_vri_dead_stems_per_ha, ^
t1.tree_cover_pattern AS l1_tree_cover_pattern, ^
t1.vertical_complexity AS l1_vertical_complexity, ^
t1.species_cd_1 AS l1_species_cd_1, ^
t1.species_pct_1 AS l1_species_pct_1, ^
t1.species_cd_2 AS l1_species_cd_2, ^
t1.species_pct_2 AS l1_species_pct_2, ^
t1.species_cd_3 AS l1_species_cd_3, ^
t1.species_pct_3 AS l1_species_pct_3, ^
t1.species_cd_4 AS l1_species_cd_4, ^
t1.species_pct_4 AS l1_species_pct_4, ^
t1.species_cd_5 AS l1_species_cd_5, ^
t1.species_pct_5 AS l1_species_pct_5, ^
t1.species_cd_6 AS l1_species_cd_6, ^
t1.species_pct_6 AS l1_species_pct_6, ^
t1.proj_age_1 AS l1_proj_age_1, ^
t1.proj_age_class_cd_1 AS l1_proj_age_class_cd_1, ^
t1.proj_age_2 AS l1_proj_age_2, ^
t1.proj_age_class_cd_2 AS l1_proj_age_class_cd_2, ^
t1.data_source_age_cd AS l1_data_source_age_cd, ^
t1.proj_height_1 AS l1_proj_height_1, ^
t1.proj_height_class_cd_1 AS l1_proj_height_class_cd_1, ^
t1.proj_height_2 AS l1_proj_height_2, ^
t1.proj_height_class_cd_2 AS l1_proj_height_class_cd_2, ^
t1.data_source_height_cd AS l1_data_source_height_cd, ^
t1.geometry_len AS l1_geometry_len, ^
t1.geometry_area AS l1_geometry_area, ^
t2.layer_id AS l2_layer_id, ^
t2.for_cover_rank_cd AS l2_for_cover_rank_cd, ^
t2.non_forest_descriptor AS l2_non_forest_descriptor, ^
t2.interpreted_data_src_cd AS l2_interpreted_data_src_cd, ^
t2.est_site_index_species_cd AS l2_est_site_index_species_cd, ^
t2.est_site_index AS l2_est_site_index, ^
t2.est_site_index_source_cd AS l2_est_site_index_source_cd, ^
t2.crown_closure AS l2_crown_closure, ^
t2.crown_closure_class_cd AS l2_crown_closure_class_cd, ^
t2.reference_date AS l2_reference_date, ^
t2.site_index AS l2_site_index, ^
t2.vri_live_stems_per_ha AS l2_vri_live_stems_per_ha, ^
t2.data_src_vri_live_stem_ha_cd AS l2_data_src_vri_live_stem_ha_cd, ^
t2.vri_dead_stems_per_ha AS l2_vri_dead_stems_per_ha, ^
t2.tree_cover_pattern AS l2_tree_cover_pattern, ^
t2.vertical_complexity AS l2_vertical_complexity, ^
t2.species_cd_1 AS l2_species_cd_1, ^
t2.species_pct_1 AS l2_species_pct_1, ^
t2.species_cd_2 AS l2_species_cd_2, ^
t2.species_pct_2 AS l2_species_pct_2, ^
t2.species_cd_3 AS l2_species_cd_3, ^
t2.species_pct_3 AS l2_species_pct_3, ^
t2.species_cd_4 AS l2_species_cd_4, ^
t2.species_pct_4 AS l2_species_pct_4, ^
t2.species_cd_5 AS l2_species_cd_5, ^
t2.species_pct_5 AS l2_species_pct_5, ^
t2.species_cd_6 AS l2_species_cd_6, ^
t2.species_pct_6 AS l2_species_pct_6, ^
t2.proj_age_1 AS l2_proj_age_1, ^
t2.proj_age_class_cd_1 AS l2_proj_age_class_cd_1, ^
t2.proj_age_2 AS l2_proj_age_2, ^
t2.proj_age_class_cd_2 AS l2_proj_age_class_cd_2, ^
t2.data_source_age_cd AS l2_data_source_age_cd, ^
t2.proj_height_1 AS l2_proj_height_1, ^
t2.proj_height_class_cd_1 AS l2_proj_height_class_cd_1, ^
t2.proj_height_2 AS l2_proj_height_2, ^
t2.proj_height_class_cd_2 AS l2_proj_height_class_cd_2, ^
t2.data_source_height_cd AS l2_data_source_height_cd ^
FROM %tableName_L1% t1 ^
LEFT OUTER JOIN %tableName_L2% t2 USING (feature_id); ^
DROP TABLE IF EXISTS %tableName_L1%; ^
DROP TABLE IF EXISTS %tableName_L2%;

:: Run ogr2ogr to load the two tables

"%gdalFolder%\ogr2ogr" ^
-f PostgreSQL %pg_connection_string% %srcFullPath_L1% ^
-nln %tableName_L1% %layer_creation_option% ^
-progress %overwrite_tab%

"%gdalFolder%\ogr2ogr" ^
-f PostgreSQL %pg_connection_string% %srcFullPath_L2% ^
-nln %tableName_L2% %layer_creation_option% ^
-progress %overwrite_tab%

::  Join loaded tables

"%gdalFolder%\ogrinfo" %pg_connection_string% -sql "%query%"

SET createSQLSpatialIndex=True

CALL .\common_postprocessing.bat

ENDLOCAL