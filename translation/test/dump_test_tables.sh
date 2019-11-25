#!/bin/bash -x

# This script dumps the random test tables from the database.

# When test tables rightfully differ from original tables they have to be 
# dumped with this script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../conversion/sh/common.sh

# ########################################## Process ######################################

# Run ogr2ogr

rm ./data/*.csv

"$gdalFolder/ogr2ogr" -f "CSV" ".\data\cas_all_test.csv" "$pg_connection_string" "casfri50_test.cas_all_new_ordered"

"$gdalFolder/ogr2ogr" -f "CSV" ".\data\dst_all_test.csv" "$pg_connection_string" "casfri50_test.dst_all_new_ordered" 

"$gdalFolder/ogr2ogr" -f "CSV" ".\data\eco_all_test.csv" "$pg_connection_string" "casfri50_test.eco_all_new_ordered" 

"$gdalFolder/ogr2ogr" -f "CSV" ".\data\lyr_all_test.csv" "$pg_connection_string" "casfri50_test.lyr_all_new_ordered" 

"$gdalFolder/ogr2ogr" -f "CSV" ".\data\nfl_all_test.csv" "$pg_connection_string" "casfri50_test.nfl_all_new_ordered" 
