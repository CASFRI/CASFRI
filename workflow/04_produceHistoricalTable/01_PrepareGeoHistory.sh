#!/bin/bash -x

source ../../conversion/sh/common.sh

# Load shapefile of Canada provinces limits
"$gdalFolder/ogr2ogr" -f "PostgreSQL" "$pg_connection_string" canada_provinces.shp \
-nln casfri50_coverage.canada_provinces $layer_creation_options $other_options \
-progress $overwrite_tab

"$pgFolder/bin/psql" -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./01_PrepareGeoHistory.sql

