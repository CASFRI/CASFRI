#!/bin/bash -x

# This script loads the Tembec MB01 FRI into PostgreSQL

# The format of the source dataset is a shapefile

# The year of photography is included in the FRI_YR column

# Load into a target table in the schema defined in the config file.

# No unique id. Adding poly_id on loading

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=MB01
srcFileName=fml1_fri97
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.mb01
MB_subFolder=MB/$inventoryID/data/inventory/
########################################## Process ######################################

# Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
# will return an error which can be ignored.
# SQLite is needed to add the id based on rowid.
# Should be activated only at the first load otherwise it would brake the translation tables tests. 
# Only runs once, when flag file poly_id_added.txt does not exist.

if [ ! -e "$friDir/$MB_subFolder/poly_id_added.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE $srcFileName DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE $srcFileName ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath -dialect SQLite -sql "UPDATE $srcFileName set poly_id = rowid"

	echo " " > "$friDir/$MB_subFolder/poly_id_added.txt"
fi

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh
