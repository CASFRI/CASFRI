#!/bin/bash -x

# This script loads the SK UTM Government data (SK01) into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attribute SYR

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Mapsheets with values 0 in the CZONE attribute are not part of the inventory and should be 
# removed.

######################################## Set variables #######################################

source ./common.sh

inventoryID=SK01
srcFileName=UTM
gdbTableName=fpoly
srcFullPath="$friDir/SK/$inventoryID/data/inventory/UTM.gdb"

fullTargetTableName=$targetFRISchema.sk01

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName WHERE CZONE NOT LIKE '0'" \
-progress $overwrite_tab

source ./common_postprocessing.sh