#!/bin/bash -x

# This script loads the NWT FVI forest inventory (NT03) into PostgreSQL

# The format of the source dataset is a geodatabase with one table

# The year of photography is included in the REF_YEAR attribute

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=NT03

srcFileName=NT_Forcov_
srcFullPath="$friDir/NT/$inventoryID/data/inventory/$srcFileName.gdb"

gdbTableName=NT_FORCOV_ATT
fullTargetTableName=$targetFRISchema.nt03

########################################## Process ######################################

# Run ogr2ogr to load all table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName" \
-progress $overwrite_tab

createSQLSpatialIndex=True

source ./common_postprocessing.sh