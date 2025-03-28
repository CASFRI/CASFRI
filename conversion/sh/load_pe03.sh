source ./common.sh

inventoryID=PE03


srcFileName=PEI_CORPORATE_LANDUSE_INVENTORY_2000
srcName="$srcFileName"
srcFullPath="$friDir/PE/$inventoryID/data/inventory/$srcFileName.shp"
peSubFolder="$friDir/PE/$inventoryID/data/inventory/"
fullTargetTableName=$targetFRISchema.pe03


########################################## Process ######################################


if [ ! -e "$peSubFolder/poly_id_added.txt" ]; then

	# Waterbody
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
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id, 2000 as year_ FROM $srcName" \
-progress $overwrite_tab

createSQLSpatialIndex=True

source ./common_postprocessing.sh