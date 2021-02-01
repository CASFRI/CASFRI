#!/bin/bash -x

# This script loads the Tembec MB01 FRI into PostgreSQL

# The format of the source dataset is a shapefile

# The year of photography is included in the FRI_YR column

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=MB01
srcFileName=fml1_fri97
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.mb01

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh
