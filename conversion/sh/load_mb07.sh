#!/bin/bash -x

# This script loads the Manitoba High Rock data into PostgreSQL

# The data is a single table in a geodatabase.

# The year of photography included in the YEARPHOTO column

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# There is no id information. Add a poly_id during loading

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=MB07

srcFileName=LCV_MB_FLI_HIGHROCK_20072009
gdbTableName=$srcFileName
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
fullTargetTableName=$targetFRISchema.mb07
MB_subFolder=MB/$inventoryID/data/inventory/

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

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
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName" \
-progress $overwriteTable

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh