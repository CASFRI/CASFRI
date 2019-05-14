library(plyr)
library(readxl)
library(rpostgis)
library(tidyverse)
library(summarytools)

# Connect to current BC inventory and extract selected attributes as a tibble
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")
x = as_tibble(dbGetQuery(con, "SELECT map_id, feature_id, inventory_standard_cd, soil_moisture_regime_1, crown_closure, proj_height_1, layer_id, species_cd_1, species_pct_1, site_index, est_site_index_source_cd, proj_age_1, non_veg_cover_type_1, non_veg_cover_pct_1, land_cover_class_cd_1, land_cover_class_cd_2, land_cover_class_cd_3, bclcs_level_1, bclcs_level_2, bclcs_level_3, bclcs_level_4, bclcs_level_5, non_forest_descriptor, non_productive_descriptor_cd, non_productive_cd, for_mgmt_land_base_ind, line_5_vegetation_cover, line_6_site_prep_history, line_7b_disturbance_history, line_8_planting_history, reference_year, projected_date, reference_date, shape_length, shape_area, bec_zone_code, bec_subzone, bec_variant, bec_phase, site_position_meso FROM rawfri.bc08"))
dbDisconnect(con)

# Read BC inventories used in CAS04
#bc0456 = read_csv("data/bc08/cas04_vri.csv") # from file GDB
#bc07 = read_csv("data/bc08/tfl48_vri.csv") # from shapefile
#dbCreateTable(con, "bc07", bc07)
#dbGetQuery(con, "ALTER TABLE bc07 SET SCHEMA rawfri;")
#dbDisconnect(con)

# NFL attributes by inventory_standard_cd
nflTables = function() {
    sink("bc08/data/rawfri_bc08_nfl_by_inv.txt")
    cat("\nnon_veg_cover_type_1", " (F,V,I,L)\n", sep="")
    print(dfSummary(x$non_veg_cover_type_1, graph.col=FALSE, max.distinct.values=99))
    for (j in c("F","V","I","L")) {
      cat("\nnon_veg_cover_type_1", " (", j, ")\n", sep="")
      print(dfSummary(x$non_veg_cover_type_1[x$inventory_standard_cd==j], graph.col=FALSE, max.distinct.values=99))
    }
    cat("\nland_cover_class_cd_1", " (F,V,I,L)\n", sep="")
    print(dfSummary(x$land_cover_class_cd_1, graph.col=FALSE, max.distinct.values=99))
    for (j in c("F","V","I","L")) {
      cat("\nland_cover_class_cd_1", " (", j, ")\n", sep="")
      print(dfSummary(x$land_cover_class_cd_1[x$inventory_standard_cd==j], graph.col=FALSE, max.distinct.values=99))
    }
    cat("\nbclcs_level_4", " (F,V,I,L)\n", sep="")
    print(dfSummary(x$bclcs_level_4, graph.col=FALSE, max.distinct.values=99))
    for (j in c("F","V","I","L")) {
      cat("\nbclcs_level_4", " (", j, ")\n", sep="")
      print(dfSummary(x$bclcs_level_4[x$inventory_standard_cd==j], graph.col=FALSE, max.distinct.values=99))
    }
    cat("\nnon_productive_descriptor_cd", " (F,V,I,L)\n", sep="")
    print(dfSummary(x$non_productive_descriptor_cd, graph.col=FALSE, max.distinct.values=99))
    for (j in c("F","V","I","L")) {
      cat("\nnon_productive_descriptor_cd", " (", j, ")\n", sep="")
      print(dfSummary(x$non_productive_descriptor_cd[x$inventory_standard_cd==j], graph.col=FALSE, max.distinct.values=99))
    }
    cat("\nnon_forest_descriptor", " (F,V,I,L)\n", sep="")
    print(dfSummary(x$non_forest_descriptor, graph.col=FALSE, max.distinct.values=99))
    for (j in c("F","V","I","L")) {
      cat("\nnon_forest_descriptor", " (", j, ")\n", sep="")
      print(dfSummary(x$non_forest_descriptor[x$inventory_standard_cd==j], graph.col=FALSE, max.distinct.values=99))
    }
    sink()
}
#nflTables()