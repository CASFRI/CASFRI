#!/bin/bash -x

# This script loads the AB GOV CROWN dataset

# The format of the source dataset is a table in a geodatabase.
# poly_num is a unique id.

# The year of photography is included as an attribute (PHOTO_YR).

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB29

srcFileName=AlbertaVegetationInventoryCrown
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcFileName.gdb"
gdbTableName=AVICrown

AB_subFolder="$friDir/AB/AB29/data/inventory/"
fullTargetTableName=$targetFRISchema.ab29

########################################## Process ######################################

# Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
# will return an error which can be ignored.
# SQLite is needed to add the id based on rowid.
# Should be activated only at the first load otherwise it would brake the translation tables tests. 
# Only runs once, when flag file poly_id_added.txt does not exist.

if [ ! -e "$AB_subFolder/poly_id_added_AVICrown.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -dialect SQLite -sql "UPDATE $gdbTableName set poly_id = rowid"

	echo " " > "$AB_subFolder/poly_id_added_AVICrown.txt"
fi

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbTableName'" \
-progress $overwrite_tab

source ./common_postprocessing.sh