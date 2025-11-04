#!/bin/bash -x

# This script loads the 2020 PEI forest inventory (PE04) into PostgreSQL

# This dataset is a single shapefile

# The KEY attribute is a unique identifier made up of the MAP and STAND values
# Note that there are 31 KEY_ entries that actually have 2 polygons. These look
# to be cases where the original polygon has been split into 2. For this reason we
# should have ogc_fid in the cas_id to ensure uniqueness.

######################################## Set variables #######################################

source ./common.sh

inventoryID=PE04
srcFileName=Corporate_Land_Use_Inventory_2020

srcName="$srcFileName"
srcFullPath="$friDir/PE/$inventoryID/data/inventory/$srcFileName.shp"
peSubFolder="$friDir/PE/$inventoryID/data/inventory/"
fullTargetTableName=$targetFRISchema.pe04

########################################## Process ######################################

if [ ! -e "$peSubFolder/poly_id_added.txt" ]; then

	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE \"$srcFileName\" DROP COLUMN poly_id"
	"$gdalFolder/ogrinfo" $srcFullPath -sql "ALTER TABLE \"$srcFileName\" ADD COLUMN poly_id integer"
	"$gdalFolder/ogrinfo" $srcFullPath -dialect SQLite -sql "UPDATE \"$srcFileName\" set poly_id = rowid+1"

	echo " " > "$peSubFolder/poly_id_added.txt"
fi

# load polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-progress $overwrite_tab \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM \"$srcFileName\""

"$gdalFolder/ogrinfo" \
 "$pg_connection_string" "$fullTargetTableName" -sql "UPDATE $fullTargetTableName set history1 = history2, history2 = history1 where left(history1, 2) = 'PN' and left(history2, 2) = 'PN' and right(history1, 2)::int < 50  and length(history1) = 5  and length(history2) = 5  and right(history1, 2)::int > right(history2,2)::int"
"$gdalFolder/ogrinfo" \
 "$pg_connection_string" "$fullTargetTableName" -sql "UPDATE $fullTargetTableName set history1 = history2, history2 = history1 WHERE history1 IS NULL and history2 IS NOT NULL"

createSQLSpatialIndex=True

source ./common_postprocessing.sh