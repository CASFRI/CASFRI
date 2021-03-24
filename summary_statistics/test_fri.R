library(rpostgis)
library(tidyverse)
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

# BC HEIGHT
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname=dbname, host=host, port=port, user=user, password=password)
x = RPostgreSQL::dbGetQuery(con, 'SELECT l1_proj_height_1, l2_proj_height_1, l1_proj_height_2, l2_proj_height_2 FROM rawfri.bc10') # ORDER BY random() LIMIT 1000;')
dbDisconnect(con)
sort(unique(x$l1_proj_height_1))
sort(unique(x$l2_proj_height_1))
sort(unique(x$l1_proj_height_2))
sort(unique(x$l2_proj_height_2))

# NT SITE_INDEX
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname=dbname, host=host, port=port, user=user, password=password)
x = RPostgreSQL::dbGetQuery(con, 'SELECT si_50 FROM rawfri.nt03') # ORDER BY random() LIMIT 1000;')
dbDisconnect(con)
sort(unique(x$si_50))