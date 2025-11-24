#!/bin/bash -x

# This script loads the NWT FVI forest inventory (NT03) into PostgreSQL

# The format of the source dataset is a geodatabase with one table

# The year of photography is included in the REF_YEAR attribute

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable
# in the configuration file.
######################################## Set variables #######################################

source ./common.sh

srcInventoryID=NT03

srcFileName=CASFRI_DataShare_Feb242022
srcFullPath="$friDir/NT/$srcInventoryID/data/inventory/$srcFileName.gdb"

destInventoryID=NT04
gdbTableName=Buffalo2015_FORCOV
fullTargetTableName=$targetFRISchema.nt04


########################################## Process ######################################

# Run ogr2ogr to load all table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$destInventoryID' AS inventory_id FROM $gdbTableName" \
-progress $overwrite_tab

"$gdalFolder/ogrinfo" "$pg_connection_string" -sql  \
"UPDATE $fullTargetTableName SET mod1code = mod2code, mod2code = mod1code, mod1ext = mod2ext, mod2ext = mod1ext, mod1year = mod2year, mod2year = mod1year where mod1year > mod2year";