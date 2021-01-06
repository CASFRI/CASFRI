#!/bin/bash -x

# This script loads the AB GOV TOLKO dataset

# The format of the source dataset is 5 shapefiles named f2h_5830.shp, f5h_5830.shp, f7h_5830.shp,
# s19_twp.shp, weyersl.shp
# poly_num is not a unique id so we create source_id on loading using each files own id column.
# Combination of src_filename and source_id is a unique id.
# Drop polygons where poly_num = 0, these have no data.

# These files are combined into a single PostgreSQL table
# This is done using the -append argument. Note that -update is also 
# needed in order to append in PostgreSQL. -addfields is also needed 
# because columns do not all match between tables.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB10

srcName1=f2h_5830
srcFullPath1="$friDir/AB/$inventoryID/data/inventory/$srcName1.shp"

srcName2=f5h_5830
srcFullPath2="$friDir/AB/$inventoryID/data/inventory/$srcName2.shp"

srcName3=f7h_5830
srcFullPath3="$friDir/AB/$inventoryID/data/inventory/$srcName3.shp"

srcName4=s19_twp
srcFullPath4="$friDir/AB/$inventoryID/data/inventory/$srcName4.shp"

srcName5=weyersl
srcFullPath5="$friDir/AB/$inventoryID/data/inventory/$srcName5.shp"

fullTargetTableName=$targetFRISchema.ab10

########################################## Process ######################################

### FILE 1 ###
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath1" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName1' AS src_filename, '$inventoryID' AS inventory_id, f2h_5830_ AS source_id FROM '$srcName1' WHERE poly_num > 0" \
-progress $overwrite_tab

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPath2" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName2' AS src_filename, '$inventoryID' AS inventory_id, f5h_5830_ AS source_id FROM '$srcName2' WHERE poly_num > 0" \
-progress

### FILE 3 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPath3" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName3' AS src_filename, '$inventoryID' AS inventory_id, f7h_5830_ AS source_id FROM '$srcName3' WHERE poly_num > 0" \
-progress

### FILE 4 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPath4" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName4' AS src_filename, '$inventoryID' AS inventory_id, s19_twp_ AS source_id FROM '$srcName4' WHERE poly_num > 0" \
-progress

### FILE 5 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPath5" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName5' AS src_filename, '$inventoryID' AS inventory_id, weyersl_ AS source_id FROM '$srcName5' WHERE poly_num > 0" \
-progress
	
source ./common_postprocessing.sh