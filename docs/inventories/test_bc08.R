library(sf)
library(plyr)
library(readxl)
library(rpostgis)
library(mapview)
library(tidyverse)
library(summarytools)

# Connect to database# and get geometry and attributes for 9 mapsheets in northeast BC
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")
fri_cols = c("map_id", "feature_id", "inventory_standard_cd", "soil_moisture_regime_1", "crown_closure", "proj_height_1", "layer_id", "species_cd_1", "species_pct_1", "species_cd_2", "site_index", "est_site_index_source_cd", "proj_age_1", "non_veg_cover_type_1", "non_veg_cover_pct_1", "land_cover_class_cd_1", "land_cover_class_cd_2", "land_cover_class_cd_3", "bclcs_level_1", "bclcs_level_2", "bclcs_level_3", "bclcs_level_4", "bclcs_level_5", "non_forest_descriptor", "non_productive_descriptor_cd", "non_productive_cd", "for_mgmt_land_base_ind", "line_5_vegetation_cover", "line_7b_disturbance_history", "reference_year", "projected_date", "reference_date", "shape_length", "shape_area")
x = st_as_sf(pgGetGeom(con, c("rawfri","bc08"), geom="wkb_geometry", other.cols=fri_cols, clauses="WHERE map_id IN ('094O081','094O082','094O083','094O071','094O072','094O073','094O061','094O062','094O063')"))
dbDisconnect(con)
