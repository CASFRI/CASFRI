#!/bin/bash -x

# This script dumps the random test tables from the database.

# When test tables rightfully differ from original tables they have to be 
# dumped with this script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../conversion/sh/common.sh

pgversion=${pgversion:=11} 

# ########################################## Process ######################################

# Run ogr2ogr

rm ./testtables$pgversion/*.csv

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_0_without_validity.csv" "$pg_connection_string" "geohistory.test_0_without_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_0_with_validity.csv"    "$pg_connection_string" "geohistory.test_0_with_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_2_without_validity.csv" "$pg_connection_string" "geohistory.test_2_without_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_2_with_validity.csv"    "$pg_connection_string" "geohistory.test_2_with_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_3_without_validity.csv" "$pg_connection_string" "geohistory.test_3_without_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_3_with_validity.csv"    "$pg_connection_string" "geohistory.test_3_with_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_4_without_validity.csv" "$pg_connection_string" "geohistory.test_4_without_validity_new"

"$gdalFolder/ogr2ogr" -f "CSV" ".\testtables$pgversion\test_4_with_validity.csv"    "$pg_connection_string" "geohistory.test_4_with_validity_new"
