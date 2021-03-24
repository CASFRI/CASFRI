# Test to see if area is correctly represented (hectares)
# PV 2021-03-16

library(rpostgis)
library(tidyverse)

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

# Connect and extract area attributes
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname=dbname, host=host, port=port, user=user, password=password)
x = RPostgreSQL::dbGetQuery(con, 'SELECT cas_id, inventory_id, casfri_area, casfri_perimeter, src_inv_area FROM casfri50.cas_all')
dbDisconnect(con)
invids = sort(unique(x$inventory_id))

z = tibble(inventory=invids, src_area=0, src_area_8888=0, src_area_8887=0, src_area_8886=0, src_area_9997=0, cas_area=0, cas_perim=0, area_diff=0) 
for (i in 1:length(invids)) {
    cat(invids[i],'...\n'); flush.console()
    casids = x$cas_id[x$inventory_id==invids[i]]
    x1 = filter(x, cas_id %in% casids)
    z[i,'src_area'] = mean(x1$src_inv_area[x1$src_inv_area>0.01])
    z[i,'src_area_8888'] = mean(x1$src_inv_area[x1$src_inv_area==-8888])
    z[i,'src_area_8887'] = mean(x1$src_inv_area[x1$src_inv_area==-8887])
    z[i,'src_area_8886'] = mean(x1$src_inv_area[x1$src_inv_area==-8886])
    z[i,'src_area_9997'] = mean(x1$src_inv_area[x1$src_inv_area==-9997])
    z[i,'cas_area'] = mean(x1$casfri_area[x1$casfri_area>0.01])
    #z[i,'cas_perim'] = mean(x1$casfri_perimeter[x1$casfri_perimeter>0.01])
}

z$area_diff = round((z$src_area - z$cas_area)/z$src_area*100,3)
write_csv(z, 'poly_area.csv')
