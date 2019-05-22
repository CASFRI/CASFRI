# This file needs to be run once prior to rendering the markdown files
# 2019-05-22

library(plyr)
library(readxl)
library(rpostgis)
library(rmarkdown)
library(tidyverse)
library(summarytools)

abConnect = function(inv) {
    # Connect to current BC inventory
    con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")
    if (inv=="ab06") {
        # Select attributes from ab06 and save as a tibble
        x = as_tibble(dbGetQuery(con, "SELECT moist_reg, density, height, sp1, sp1_per, struc_val, tpr, mod1, origin, nfl, nat_non, anth_veg, anth_non FROM rawfri.ab06"))
    } else if (inv=="ab16") {
        # Select attributes from ab16 and save as a tibble
        x = as_tibble(dbGetQuery(con, "SELECT moisture, crownclose, height, sp1, sp1_percnt, std_struct, tpr, modcon1, origin, nonfor_veg, anthro_veg, anth_noveg, nat_nonveg FROM rawfri.ab16"))
    } else if (inv=="nb01") {
        x = as_tibble(dbGetQuery(con, "SELECT l1cc, l1ht, l1s1, l1pr1, l1estyr, l1trt, l1trtyr FROM rawfri.nb01"))
    } else {
        stop('Please select either "ab06" or "ab16"')
    }
    # Disconnect
    dbDisconnect(con)
}

abRender = function(inv) {
    if (inv=="ab06") {
        # Select attributes from ab06 and save as a tibble
        render("ab06.Rmd")
        render("ab06_hdr.Rmd")
    } else if (inv=="ab16") {
        # Select attributes from ab16 and save as a tibble
        render("ab16.Rmd")
        render("ab16_hdr.Rmd")
    } else if (inv=="nb01") {
        render("nb01.Rmd")
        render("nb01_hdr.Rmd")
    } else {
        stop('Please select either "ab06" or "ab16"')
    }
}

# abConnect("ab06")
# abRender("ab06")

# abConnect("ab16")
# abRender("ab16")