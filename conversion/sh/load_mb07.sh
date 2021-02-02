#!/bin/bash -x

# This script loads the Manitoba High Rock data into PostgreSQL

# The data is a single table in a geodatabase.

# The year of photography included in the YEARPHOTO column

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# There is no id information. Add a poly_id during loading

######################################## Set variables #######################################

source ./common.sh

inventoryID=MB07

srcFileName=LCV_MB_FLI_HIGHROCK_20072009
gdbTableName=$srcFileName
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
fullTargetTableName=$targetFRISchema.mb07
MB_subFolder=MB/$inventoryID/data/inventory/

########################################## Process ######################################

# Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
# will return an error which can be ignored.
# SQLite is needed to add the id based on rowid.
# Should be activated only at the first load otherwise it would brake the translation tables tests. 
# Only runs once, when flag file poly_id_added.txt does not exist.

if [ ! -e "$friDir/$MB_subFolder/poly_id_added.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -dialect SQLite -sql "UPDATE $gdbTableName set poly_id = rowid"

	echo " " > "$friDir/$MB_subFolder/poly_id_added.txt"
fi

# load polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName" \
-progress $overwrite_tab

createSQLSpatialIndex=True

source ./common_postprocessing.sh