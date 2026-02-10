#!/bin/bash -x

# This script loads the 2020 PEI forest inventory (PE04) into PostgreSQL

# This dataset is a single shapefile

# The KEY attribute is a unique identifier made up of the MAP and STAND values
# Note that there are 31 KEY_ entries that actually have 2 polygons. These look
# to be cases where the original polygon has been split into 2. For this reason we
# should have ogc_fid in the cas_id to ensure uniqueness.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=PE04
srcFileName=Corporate_Land_Use_Inventory_2020

srcName="$srcFileName"
srcFullPath="$friDir/PE/$inventoryID/data/inventory/$srcFileName.shp"
peSubFolder="$friDir/PE/$inventoryID/data/inventory/"
fullTargetTableName=$targetFRISchema.pe04

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

if [ ! -e "$peSubFolder/poly_id_added.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE \"$srcFileName\" DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE \"$srcFileName\" ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath -dialect SQLite -sql "UPDATE \"$srcFileName\" set poly_id = rowid+1"

	echo " " > "$peSubFolder/poly_id_added.txt"
fi

# load polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-progress $overwriteTable \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM \"$srcFileName\""

"$gdalFolder/ogrinfo" \
 "$gdalConnectionString" "$fullTargetTableName" -sql "UPDATE $fullTargetTableName set history1 = history2, history2 = history1 where left(history1, 2) = 'PN' and left(history2, 2) = 'PN' and right(history1, 2)::int < 50  and length(history1) = 5  and length(history2) = 5  and right(history1, 2)::int > right(history2,2)::int"
"$gdalFolder/ogrinfo" \
 "$gdalConnectionString" "$fullTargetTableName" -sql "UPDATE $fullTargetTableName set history1 = history2, history2 = history1 WHERE history1 IS NULL and history2 IS NOT NULL"

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh