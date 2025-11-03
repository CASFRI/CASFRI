#!/bin/bash -x

# This script loads the 1990 PEI forest inventory (PE01) into PostgreSQL

# This dataset is a single shapefile

# The KEY attribute is a unique identifier made up of the MAP and STAND values
# Note that there are 31 KEY_ entries that actually have 2 polygons. These look
# to be cases where the original polygon has been split into 2. For this reason we
# should have ogc_fid in the cas_id to ensure uniqueness.

######################################## Set variables #######################################

source ./common.sh

inventoryID=PE01
srcFileName='1990_ForestInventory'

srcFullPath="$friDir/PE/$inventoryID/data/inventory/$srcFileName.shp"
fullTargetTableName=$targetFRISchema.pe01

########################################## Process ######################################

# Load the shapefile
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-progress $overwrite_tab \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM \"$srcFileName\""

createSQLSpatialIndex=True

source ./common_postprocessing.sh