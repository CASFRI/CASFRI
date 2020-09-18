#!/bin/bash -x

# This script loads the SK SFVI Mystic dataset (SK06) into PostgreSQL

# The format of the source dataset is a geodatabase
# Source data is is a single table.
# Standard is SFVI but the column names have been changed.

# The year of photography is currently unknown at the polygon level but varies from 1994 - 2005.
# See Issue #317. We will use 2000 as the photo year.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=SK06
srcFileName=MistikSFVI
fullTargetTableName=$targetFRISchema.sk06

gdbFileName=SFVI

srcFullPath="$friDir/SK/$inventoryID/data/inventory/$srcFileName.gdb"

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbFileName'" \
-progress $overwrite_tab

source ./common_postprocessing.sh
