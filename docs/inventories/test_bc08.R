library(sf)
library(plyr)
library(readxl)
library(rpostgis)
library(mapview)
library(tidyverse)
library(summarytools)

# Connect to database# and get geometry and attributes for 9 mapsheets in northeast BC
#con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")
#fri_cols = c("map_id", "feature_id", "inventory_standard_cd", "soil_moisture_regime_1", "crown_closure", "proj_height_1", "layer_id", "species_cd_1", "species_pct_1", "species_cd_2", "site_index", "est_site_index_source_cd", "proj_age_1", "non_veg_cover_type_1", "non_veg_cover_pct_1", "land_cover_class_cd_1", "land_cover_class_cd_2", "land_cover_class_cd_3", "bclcs_level_1", "bclcs_level_2", "bclcs_level_3", "bclcs_level_4", "bclcs_level_5", "non_forest_descriptor", "non_productive_descriptor_cd", "non_productive_cd", "for_mgmt_land_base_ind", "line_5_vegetation_cover", "line_7b_disturbance_history", "reference_year", "projected_date", "reference_date", "shape_length", "shape_area")
#x = st_as_sf(pgGetGeom(con, c("rawfri","bc08"), geom="wkb_geometry", other.cols=fri_cols, clauses="WHERE map_id IN ('094O081','094O082','094O083','094O071','094O072','094O073','094O061','094O062','094O063')"))
#dbDisconnect(con)

# $WetlandCodeUnProd = $NPdesc = non_productive_descriptor_cd
# $WetlandCodeNonFor = $Nfor_desc = non_forest_descriptor
# $landcoverCode = $LandCoverClassCode = land_cover_class_cd_1
# $SMR = $MoistReg = soil_moisture_regime_1


# ECO attributes
x = mutate(x, 

  # Initialize CAS attributes
  wetland_type="NULL_VALUE", wet_veg_cover="NULL_VALUE", wet_landform_mod="NULL_VALUE", wet_local_mod="NULL_VALUE",

  # Process where inventory_standard_cd=="F"
  ##########################################
  wetland = case_when(
    inventory_standard_cd=="F" & species_cd_1 %in% c("SF","CW","YC") & non_productive_descriptor_cd=="S" ~ "STNN",
    inventory_standard_cd=="F" & species_cd_1 %in% c("SF","CW","YC") & non_productive_descriptor_cd=="NP" ~ "STNN",
    inventory_standard_cd=="F" & non_forest_descriptor=="NPBR" ~ "STNN",
    inventory_standard_cd=="F" & non_forest_descriptor=="S" ~ "SONS",
    inventory_standard_cd=="F" & non_forest_descriptor=="MUSKEG" ~ "STNN",
    TRUE ~ "NULL_VALUE"),

  # Process where inventory_standard_cd = "V" or "I"
  ##################################################
  wetland = case_when(
    inventory_standard_cd %in% c("V","I") & land_cover_class_cd_1=="W" ~ "W---",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & species_cd_1=="SB" & species_pct_1==100 & crown_closure==50 & proj_height_1==12 ~ "BTNN",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & species_cd_1 %in% c("SB","LT") & species_pct_1==100 & crown_closure>=50 & proj_height_1>=12 ~ "STNN",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & species_cd_1 %in% c("SB","LT") & species_cd_2 %in% c("SB","LT") & crown_closure>=50 & proj_height_1>=12 ~ "STNN",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & species_cd_1 %in% c("EP","EA","CW","YR","PI") ~ "STNN",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & species_cd_1 %in% c("SB","LT") & species_cd_2 %in% c("SB","LT") & crown_closure<50 ~ "FTNN",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & species_cd_1=="LT" & species_pct_1==100 & proj_height_1<12 ~ "FTNN",
    TRUE ~ wetland),

  wetland = case_when(
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1 %in% c("ST","SL") ~ "SONS",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1 %in% c("HE","HF","HG") ~ "MONG",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1 %in% c("BY","BM") ~ "FONN", 
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1=="BL" ~ "BONN",
    inventory_standard_cd %in% c("V","I") & soil_moisture_regime_1 %in% c(7,8) & land_cover_class_cd_1=="MU" ~ "TMNN",
    TRUE ~ wetland),
  
  # Extract from wetland
  wetland_type = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,1,1)),
  wet_veg_cover = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,2,2)),
  wet_landform_mod = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,3,3)),
  wet_local_mod = if_else(wetland=="NULL_VALUE", "NULL_VALUE", substr(wetland,4,4))

)

print(dfSummary(x["wetland"], graph.col=FALSE))
print(dfSummary(x["wetland_type"], graph.col=FALSE))
print(dfSummary(x["wet_veg_cover"], graph.col=FALSE))
print(dfSummary(x["wet_landform_mod"], graph.col=FALSE))
print(dfSummary(x["wet_local_mod"], graph.col=FALSE))
