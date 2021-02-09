#!/bin/bash -x

# This script loads the Yukon 5k YVI (YT03) into PostgreSQL

# The format of the source dataset is a gdb

# The year of photography is included in the attribute REF_YEAR

# unique_id is a unique identifier

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=YT03
srcFileName=Vegetation_Inventory_5k
srcFullPath="$friDir/YT/$inventoryID/data/inventory/$srcFileName.gdb"

fullTargetTableName=$targetFRISchema.yt03

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" "$srcFileName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh