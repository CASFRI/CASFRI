#!/bin/bash -x

# This script loads the AB GOV post inventory cutblocks dataset.
# This file was received along with the AB29 inventory data.

# The format of the source dataset is a table in a geodatabase.
# The data is stored in the AB29 folder.

# There is no unique id so we will add poly_id before loading.

# Year of photography is unknown.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB30

srcFileName=AlbertaVegetationInventoryCrown
srcFullPath="$friDir/AB/AB29/data/inventory/$srcFileName.gdb"
gdbTableName=AVIPostInventoryCutblocks

AB_subFolder="$friDir/AB/AB29/data/inventory/"
fullTargetTableName=$targetFRISchema.ab30

########################################## Process ######################################

# Standard SQL code used to add and drop columns in gdbs. If column is not present the DROP command
# will return an error which can be ignored.
# SQLite is needed to add the id based on rowid.
# Should be activated only at the first load otherwise it would brake the translation tables tests. 
# Only runs once, when flag file poly_id_added.txt does not exist.

if [ ! -e "$AB_subFolder/poly_id_added_AVICrownPostInventoryCutblocks.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -sql "ALTER TABLE $gdbTableName ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath $gdbTableName -dialect SQLite -sql "UPDATE $gdbTableName set poly_id = rowid"

	echo " " > "$AB_subFolder/poly_id_added_AVICrownPostInventoryCutblocks.txt"
fi

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id, 2020 AS aquisition_year FROM '$gdbTableName'" \
-progress $overwrite_tab

source ./common_postprocessing.sh