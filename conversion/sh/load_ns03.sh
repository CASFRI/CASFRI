#!/bin/bash -x

# This script loads the Nova Scotia forest inventory (NS03) into PostgreSQL

# This dataset is split into 20 shapefiles, each representing
# a different county.

# The year of photography is included in the attributes table (PHOTOYR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# All tables have the same core attributes, but some have additional wetland attributes.
# Annapolis.shp also has AGE and MATURITY.
# Load Annapolis.shp first since it has the most columns.

# The combination of FOREST_ and FOREST_ID is a unique identifier across all counties (FOREST_ 
# a unique ID in all counties except Halifax_West and Hants).
######################################## Set variables #######################################

source ./common.sh

inventoryID=NS03
#srcFileName=ON_FRI_forest
#srcFullPath="$friDir/ON/$inventoryID/data/inventory/$srcFileName.gdb"
srcFolder="$friDir/NS/$inventoryID/data/inventory/"
fullTargetTableName=$targetFRISchema.ns03

for F in Annapolis Antigonish Cape_Breton Colchester Cumberland Digby Guyborough Halifax_East Halifax_West Hants Inverness Kings Lunenburg Pictou Queens Richmond Shelburne St_Marys Victoria Yarmouth
do
	srcFullPath="$srcFolder$F.shp"
	
	"$gdalFolder/ogr2ogr" \
	-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
	-nln $fullTargetTableName $layer_creation_option \
	-nlt PROMOTE_TO_MULTI \
	-sql "SELECT *, CONCAT(CAST(FOREST_ AS character(5)), '-', CAST(FOREST_ID AS character(4))) AS poly_id, '$F' AS src_filename, '$inventoryID' AS inventory_id FROM '$F'" \
	-progress $overwrite_tab

done

createSQLSpatialIndex=True

source ./common_postprocessing.sh