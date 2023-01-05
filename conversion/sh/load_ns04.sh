#!/bin/bash -x

# This script loads the Nova Scotia forest inventory (NS04) into PostgreSQL

# This dataset is a single shapefile, representing

# The year of photography is included in the attributes table (PHOTOYR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable
# in the configuration file.

# The combination of FOREST_, FOREST_ID, MAPSHEET and SRC_FILENAME is a unique identifier across all counties prior to
# 2007. All four are needed to create the unique id. After 2007 the field ID_EFOREST provides a unique identifier across
# the province
# and should be used in the cas_id.
######################################## Set variables #######################################

source ./common.sh

inventoryID=NS04
src_filename=FOR_Forest_PL_UT83
srcFolder="$friDir/NS/$inventoryID/data/inventory"
srcFullPath="$srcFolder/$src_filename.shp"
fullTargetTableName=$targetFRISchema.ns04

overwrite_option="$overwrite_tab"

# load polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName \
-nlt PROMOTE_TO_MULTI \
$layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $src_filename" \
-progress $overwrite_tab

createSQLSpatialIndex=True

source ./common_postprocessing.sh
