#!/bin/bash

source ../../common.sh

set -x

"$pgFolder/bin/psql" -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./01_PrepareGeoHistory.sql

# Load shapefile of Canada provinces limits
"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" canada_provinces.shp \
-nln casfri50_coverage.canada_provinces $gdalLco $gdalOtherOptions \
-progress $overwriteTable