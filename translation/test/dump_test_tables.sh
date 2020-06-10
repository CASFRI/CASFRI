#!/bin/bash -x

# This script dumps the random test tables from the database.

# When test tables rightfully differ from original tables they have to be 
# dumped with this script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../conversion/sh/common.sh

#pgversion=${pgversion:=11}
pgversion=${pgversion:=12} 

# ########################################## Process ######################################

# Run ogr2ogr

rm ./data$pgversion/*.csv

"$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_all_test.csv" "$pg_connection_string" "casfri50_test.cas_all_new_ordered"

"$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_all_test.csv" "$pg_connection_string" "casfri50_test.dst_all_new_ordered" 

"$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_all_test.csv" "$pg_connection_string" "casfri50_test.eco_all_new_ordered" 

"$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_all_test.csv" "$pg_connection_string" "casfri50_test.lyr_all_new_ordered" 

"$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_all_test.csv" "$pg_connection_string" "casfri50_test.nfl_all_new_ordered" 
