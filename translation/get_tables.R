# Download translation worksheets from CASFRI workbooks
# PV 2019-02-08

library(googlesheets)
library(dplyr)

# Download rules from google docs
bc_gs = c("ab_0006","ab_0016","bc_0008","nb_0001")
for (bc in bc_gs) {
    gs = gs_title(bc)
    for (ws in gs_ws_ls(gs)) {
        gs_title(bc) %>% gs_download(ws=ws, to=paste0("tables/",substr(bc,1,7),"_rules_",ws,".csv"), overwrite=TRUE)
    }    
}
