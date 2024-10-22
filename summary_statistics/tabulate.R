# Tabulate layer attributes for each inventory
# PV 2021-03-14

library(rpostgis)
library(tidyverse)

################################################################################
# Select tables
cas_tables = c("cas", "eco", "lyr") # c("cas", "dst", "eco", "lyr", "nfl")
lyr_vars = c("soil_moist_reg", "structure_per", "structure_range", "layer", "layer_rank",
    "crown_closure_upper", "crown_closure_lower", "height_upper", "height_lower",
    "productivity", "productivity_type", "species_1", "species_per_1", "species_2",
    "species_per_2", "species_3", "species_per_3", "species_4", "species_per_4", "species_5",
    "species_per_5", "species_6", "species_per_6", "species_7", "species_per_7", "species_8",
    "species_per_8", "species_9", "species_per_9", "species_10", "species_per_10", 
    "origin_upper", "origin_lower", "site_class", "site_index")
nfl_vars = c("soil_moist_reg", "structure_per", "layer", "layer_rank",
    "crown_closure_upper", "crown_closure_lower", "height_upper", "height_lower",
    "nat_non_veg", "non_for_anth", "non_for_veg")
dst_vars = c("dist_type_1", "dist_year_1", "dist_ext_upper_1", "dist_ext_lower_1",
    "dist_type_2", "dist_year_2", "dist_ext_upper_2", "dist_ext_lower_2",
    "dist_type_3", "dist_year_3", "dist_ext_upper_3", "dist_ext_lower_3", "layer")
eco_vars = c("wetland_type", "wet_veg_cover", "wet_landform_mod", "wet_local_mod", "eco_site", "layer")
cas_vars = c("inventory_id", "stand_structure", "num_of_layers", "stand_photo_year") 
    #"orig_stand_id", "map_sheet_id", "casfri_area", "casfri_perimeter", "src_inv_area", 

################################################################################
# Read user config.sh file
cfg = readr::read_lines("../config.sh")
for (r in cfg) {
    if (startsWith(r, "pgdbname_pr")) {
        dbname = strsplit(r,"=")[[1]][2]
    } else if (startsWith(r, "pghost")) {
        host = strsplit(r,"=")[[1]][2]
    } else if (startsWith(r, "pgport_pr")) {
        port = strsplit(r,"=")[[1]][2]
    } else if (startsWith(r, "pguser")) {
        user = strsplit(r,"=")[[1]][2]
    } else if (startsWith(r, "pgpassword")) {
        password = strsplit(r,"=")[[1]][2]
    }
}

################################################################################
# Extract CAS IDs and Inventory IDs
if (!exists("y")) {
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname=dbname, host=host, port=port, user=user, password=password)
    y = RPostgreSQL::dbGetQuery(con, 'SELECT cas_id, inventory_id FROM casfri50.cas_all')
    dbDisconnect(con)
    invids = sort(unique(y$inventory_id))
}

for (fi in cas_tables) {
    xvars = unlist(mget(paste0(fi,'_vars')))
    names(xvars) = NULL
    for (j in 1:length(xvars)) {
        cat(xvars[j], '...\n'); flush.console()
        con = dbConnect(RPostgreSQL::PostgreSQL(), dbname=dbname, host=host, port=port, user=user, password=password)
        x = RPostgreSQL::dbGetQuery(con, paste0('SELECT cas_id, ',xvars[j],' FROM casfri50.',fi,'_all'))
        dbDisconnect(con)
        
        z = tibble(values=as.character(sort(unique(x[[xvars[j]]])))) 
        for (i in 1:length(invids)) {
            casids = y$cas_id[y$inventory_id==invids[i]]
            x1 = filter(x, cas_id %in% casids)
            if (nrow(x1)>0) {
                x2 = table(x1[xvars[j]])
                x3 = tibble(values=as.character(names(x2)), counts=as.integer(x2))
                z = left_join(z, x3) %>% rename(!!invids[i] := counts)
            } else {
                z = mutate(z, !!invids[i] := as.integer(NaN))
            }
        }
        write_csv(z, paste0('by_attribute/', fi,'_', xvars[j], '.csv'))
    }
}
