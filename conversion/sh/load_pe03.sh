#!/bin/bash -x

# This script loads the 2000 PEI forest inventory (PE03) into PostgreSQL

# This dataset is a single shapefile

# The KEY attribute is a unique identifier made up of the MAP and STAND values
# Note that there are 31 KEY_ entries that actually have 2 polygons. These look
# to be cases where the original polygon has been split into 2. For this reason we
# should have ogc_fid in the cas_id to ensure uniqueness.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=PE03
srcFileName=PEI_CORPORATE_LANDUSE_INVENTORY_2000

peSubFolder="$friDir/PE/$inventoryID/data/inventory/"
srcFullPath="$peSubFolder/$srcFileName.shp"
fullTargetTableName=$targetFRISchema.pe03

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

if [ ! -e "$peSubFolder/poly_id_added.txt" ]; then

	# Waterbody
	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE \"$srcFileName\" DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE \"$srcFileName\" ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath -dialect SQLite -sql "UPDATE \"$srcFileName\" set poly_id = rowid+1"

	echo " " > "$peSubFolder/poly_id_added.txt"
fi
# load polygons
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-progress $overwriteTable \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id, 2000 as year_ FROM \"$srcFileName\""

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh