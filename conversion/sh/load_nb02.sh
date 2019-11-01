#!/bin/bash -x

# This script loads the New Brunswick FRI data into PostgreSQL

# The format of the source dataset is four shapefiles named 
# geonb_forest-foret.shp, geonb_nonforest-nonforet.shp, NBHN_0000_02_Wb.shp, and NBHN_0000_03_wl.shp

# These four files are combined into a single PostgreSQL table
# This is done using the -append argument. Note that -update is also 
# needed in order to append in PostgreSQL. -addfields is also needed 
# because columns do not match between tables.

# The year of photography is included in the geonb_nonforest-nonforet.shp and NBHN_0000_03_wl.shp
# table as DATAYR, and in the geonb_forest-foret.shp table as L1DATAYR and L2DATAYR.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Workflow is to load the first table normally, then append the others
# Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries

# stdlab attribute needed to make cas id. Only present in forest.shp.
# add as attribute with 0 for other files
######################################## Set variables #######################################

source ./common.sh

NB_subFolder=NB/NB02/

srcNameWater=NBHN_0000_02_Wb
srcWaterFullPath="$friDir/$NB_subFolder$srcNameWater.shp"

srcNameNonForest=geonb_nonforest-nonforet
srcNonForestFullPath="$friDir/$NB_subFolder$srcNameNonForest.shp"

srcNameWetland=NBHN_0000_03_wl
srcWetlandFullPath="$friDir/$NB_subFolder$srcNameWetland.shp"

srcNameForest=geonb_forest-foret
srcForestFullPath="$friDir/$NB_subFolder$srcNameForest.shp"

fullTargetTableName=$targetFRISchema.nb02

########################################## Process ######################################

### FILE 1 ###
#Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
#Solution is to load the Waterbody table first with -lco PRECISION=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcWaterFullPath" \
-nln $fullTargetTableName $layer_creation_option \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWater' as src_filename, 0 as stdlab FROM '$srcNameWater'" \
-progress $overwrite_tab

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcNonForestFullPath" \
-nln $fullTargetTableName -t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameNonForest' as src_filename, 0 as stdlab FROM '$srcNameNonForest'" \
-progress

### FILE 3 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcWetlandFullPath" \
-nln $fullTargetTableName -t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWetland' as src_filename, 0 as stdlab FROM '$srcNameWetland'" \
-progress

## File 4 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcForestFullPath" \
-nln $fullTargetTableName -t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameForest' as src_filename FROM '$srcNameForest'" \
-progress