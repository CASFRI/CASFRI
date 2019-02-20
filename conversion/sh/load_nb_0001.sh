#!/bin/bash

#This script loads the New Brunswick FRI data into PostgreSQL

#The format of the source dataset is four shapefiles named Forest.shp, Non Forest.shp, Waterbody.shp, and wetland.shp
#These four files need to be combined into a single PostgreSQL table
#This can be done using the -append argument. Note that -update is also needed in order to append in PostgreSQL. -addfields is also needed because columns do not match between tables. 

#The year of photography is included in the attributes table (DATAYR)

#Load into a target table in a schema named 'nb'.

#Workflow is to load the first table normally, then append the others
#Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries


######################################## variables #######################################
# load config variables
if [ -f config.sh ]; then 
  source config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

# PostgreSQL variables
schema=test
trgtT=NB_0001

srcWater=$friDir/nb_test/Waterbody.shp
srcNameWater=Waterbody
ogrTabWater=Waterbody

srcNonForest="$friDir/nb_test/Non Forest.shp"
srcNameNonForest=NonForest
ogrTabNonForest='Non Forest'

srcWetland=$friDir/nb_test/wetland.shp
srcNameWetland=wetland
ogrTabWetland=wetland

srcForest=$friDir/nb_test/Forest.shp
srcNameForest=Forest
ogrTabForest=Forest


##########################################################################################


############################ Script - shouldn't need editing #############################

#Set schema.table
schTab=$schema.$trgtT

#Create schema if it doesn't exist
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

### FILE 1 ###
#Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
#Solution is to load the Waterbody table first with -lco precision=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.
ogr2ogr \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcWater \
-lco precision=NO \
-nln $schTab \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWater' as src_filename FROM '$ogrTabWater'" \
-progress

### FILE 2 ###
ogr2ogr \
-update -append -addfields \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" "$srcNonForest" \
-nln $schTab \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameNonForest' as src_filename FROM '$ogrTabNonForest'" \
-progress

### FILE 3 ###
ogr2ogr \
-update -append -addfields \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcWetland \
-nln $schTab \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameWetland' as src_filename FROM '$ogrTabWetland'" \
-progress

## File 4 ###
ogr2ogr \
-update -append -addfields \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcForest \
-nln $schTab \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameForest' as src_filename FROM '$ogrTabForest'" \
-progress