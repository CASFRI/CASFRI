#!/bin/bash

source ../../common.sh

set -x

time "$pgFolder/bin/psql" $psqlConnectionString -P pager=off -f ./01_PrepareGeoHistory.sql

# Load shapefile of Canada provinces limits
"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" canada_provinces.shp \
-nln casfri50_coverage.canada_provinces $gdalLco $gdalOtherOptions \
-progress $overwriteTable