#!/bin/bash -x

# This script loads the Manitoba Nelson River data into PostgreSQL

# The data is a single table in a geodatabase.

# The year of photography included in the YEARPHOTO column

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# There is no id information. Add a poly_id during loading

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=MB08

srcFileName=LCV_MB_FLI_NELSONRIVER_20112013_PY_FINAL
gdbTableName=LCV_MB_FLI_NELSONRIVER_20112013_PY_v3
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
fullTargetTableName=$targetFRISchema.mb08
MB_subFolder=MB/$inventoryID/data/inventory

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

# Alter the geometry column to ensure it is 2D (MultiPolygon in SRID 102001)
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
UPDATE $fullTargetTableName
SET wkb_geometry = ST_Force2D(wkb_geometry)
WHERE ST_GeometryType(wkb_geometry) IN ('ST_Polygon', 'ST_MultiPolygon');
"

# Optionally, change column type if needed (ensure that the geometry column is of the correct type)
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
ALTER TABLE $fullTargetTableName
ALTER COLUMN wkb_geometry TYPE Geometry(MultiPolygon, 102001) 
USING ST_Force2D(wkb_geometry);
"

createSQLSpatialIndex=True

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh