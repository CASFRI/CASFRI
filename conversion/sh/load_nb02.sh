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

# load config variables
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

NB_subFolder=NB/NB02/

srcNameWater=NBHN_0000_02_Wb
srcWaterFullPath="$friDir/$NB_subFolder$srcNameWater.shp"

srcNameNonForest=geonb_nonforest-nonforet
srcNonForestFullPath="$friDir/$NB_subFolder$srcNameNonForest.shp"

srcNameWetland=NBHN_0000_03_wl
srcWetlandFullPath="$friDir/$NB_subFolder$srcNameWetland.shp"

srcNameForest=geonb_forest-foret
srcForestFullPath="$friDir/$NB_subFolder$srcNameForest.shp"

prjFile="./../canadaAlbersEqualAreaConic.prj"
fullTargetTableName=$targetFRISchema.nb02

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

### FILE 1 ###
#Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
#Solution is to load the Waterbody table first with -lco PRECISION=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcWaterFullPath" \
-nln $fullTargetTableName \
-lco PRECISION=NO \
-lco GEOMETRY_NAME=wkb_geometry \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWater' as src_filename, 0 as stdlab FROM '$srcNameWater'" \
-progress $overwrite_tab

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcNonForestFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameNonForest' as src_filename, 0 as stdlab FROM '$srcNameNonForest'" \
-progress

### FILE 3 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcWetlandFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWetland' as src_filename, 0 as stdlab FROM '$srcNameWetland'" \
-progress

## File 4 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcForestFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameForest' as src_filename FROM '$srcNameForest'" \
-progress