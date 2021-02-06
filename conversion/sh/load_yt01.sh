#!/bin/bash -x

# This script loads the Yukon (YK01) into PostgreSQL

# The format of the source dataset is a shapefile

# The year of photography is included in the attribute REF_YEAR

# There is no unique identifier. Add poly_id on loading.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=YT01
srcFileName=INVENTORY_POLY_40K
srcFullPath="$friDir/YT/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.yt01

########################################## Process ######################################

# Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
# will return an error which can be ignored.
# SQLite is needed to add the id based on rowid.
# Should be activated only at the first load otherwise it would brake the translation tables tests. 
# Only runs once, when flag file poly_id_added.txt does not exist.

if [ ! -e "$friDir/YT/$inventoryID/data/inventory/poly_id_added.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE $srcFileName DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE $srcFileName ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath -dialect SQLite -sql "UPDATE $srcFileName set poly_id = rowid"

	echo " " > "$friDir/YT/$inventoryID/data/inventory/poly_id_added.txt"
fi

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh