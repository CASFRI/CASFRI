source ./common.sh

inventoryID=PE04


srcFileName=CorporateLandUseInventory2020
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
-nln $fullTargetTableName \
-nlt PROMOTE_TO_MULTI \
$layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName" \
-progress $overwrite_tab

"$gdalFolder/ogrinfo" \
 "$pg_connection_string" "$fullTargetTableName" -sql "UPDATE $fullTargetTableName set history1 = history2, history2 = history1 where left(history1, 2) = 'PN' and left(history2, 2) = 'PN' and right(history1, 2)::int < 50  and length(history1) = 5  and length(history2) = 5  and right(history1, 2)::int > right(history2,2)::int"
"$gdalFolder/ogrinfo" \
 "$pg_connection_string" "$fullTargetTableName" -sql "UPDATE $fullTargetTableName set history1 = history2, history2 = history1 WHERE history1 IS NULL and history2 IS NOT NULL"

createSQLSpatialIndex=True

source ./common_postprocessing.sh