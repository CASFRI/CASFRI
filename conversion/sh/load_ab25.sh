#!/bin/bash -x

# This script loads the AB GOV dataset

# The format of the source dataset is three shapefiles named avi_crown.shp, s7w11_n830.shp and p1_twp.shp
# poly_num is a unique id.

# These three files are combined into a single PostgreSQL table
# This is done using the -append argument. Note that -update is also 
# needed in order to append in PostgreSQL. -addfields is also needed 
# because columns do not all match between tables.

# The year of photography is included as an attribute (PHOTO_YR).

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB25

srcName1=avi_crown
srcFullPath1="$friDir/AB/$inventoryID/data/inventory/$srcName1.shp"

srcName2=s7w11_n830
srcFullPath2="$friDir/AB/$inventoryID/data/inventory/$srcName2.shp"

srcName3=p1_twp
srcFullPath3="$friDir/AB/$inventoryID/data/inventory/$srcName3.shp"

fullTargetTableName=$targetFRISchema.ab25

########################################## Process ######################################

### FILE 1 ###
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath1" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName1' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName1" \
-progress $overwrite_tab

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPath2" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName2' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName2" \
-progress

### FILE 3 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPath3" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName3' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName3" \
-progress

source ./common_postprocessing.sh