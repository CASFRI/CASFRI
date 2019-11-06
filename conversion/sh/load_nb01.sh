#!/bin/bash -x

# This script loads the New Brunswick FRI data into PostgreSQL

# The format of the source dataset is four shapefiles named 
# Forest.shp, Non Forest.shp, Waterbody.shp, and wetland.shp

# These four files are combined into a single PostgreSQL table
# This is done using the -append argument. Note that -update is also 
# needed in order to append in PostgreSQL. -addfields is also needed 
# because columns do not match between tables.

# The year of photography is included in the attributes table (DATAYR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Workflow is to load the first table normally, then append the others
# Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries

# stdlab attribute needed to make cas id. Only present in forest.shp.
# add as attribute with 0 for other files
######################################## Set variables #######################################

source ./common.sh

inventoryID=NB01
NB_subFolder=NB/NB01/

srcNameWater=Waterbody
ogrTabWater=$srcNameWater
srcWaterFullPath="$friDir/$NB_subFolder$ogrTabWater.shp"

srcNameNonForest=NonForest
ogrTabNonForest="Non Forest"
srcNonForestFullPath="$friDir/$NB_subFolder$ogrTabNonForest.shp"

srcNameWetland=wetland
ogrTabWetland=$srcNameWetland
srcWetlandFullPath="$friDir/$NB_subFolder$ogrTabWetland.shp"

srcNameForest=Forest
ogrTabForest=$srcNameForest
srcForestFullPath="$friDir/$NB_subFolder$ogrTabForest.shp"

fullTargetTableName=$targetFRISchema.nb01

########################################## Process ######################################

### FILE 1 ###
#Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
#Solution is to load the Waterbody table first with -lco PRECISION=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcWaterFullPath" \
-nln $fullTargetTableName $layer_creation_option \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWater' as src_filename, '$inventoryID' AS inventory_id, 0 as stdlab FROM '$ogrTabWater'" \
-progress $overwrite_tab

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcNonForestFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameNonForest' as src_filename, '$inventoryID' AS inventory_id, 0 as stdlab FROM '$ogrTabNonForest'" \
-progress

### FILE 3 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcWetlandFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWetland' as src_filename, '$inventoryID' AS inventory_id, 0 as stdlab FROM '$ogrTabWetland'" \
-progress

## File 4 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcForestFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameForest' as src_filename, '$inventoryID' AS inventory_id FROM '$ogrTabForest'" \
-progress