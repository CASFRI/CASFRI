#!/bin/bash -x

# This script loads the Yukon 40k YVI (YT04) into PostgreSQL

# The format of the source dataset is a gdb

# The year of photography is included in the attribute REF_YEAR

# unique_id is a unique identifier

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=YT04
srcFileName=Vegetation_Inventory_40k
srcFullPath="$friDir/YT/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.yt04

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" "$srcFileName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id, OGR_GEOM_AREA as shape_area FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh