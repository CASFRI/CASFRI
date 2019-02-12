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

# PostgreSQL variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
schema=test
trgtT=test.NB_0001 #Target table name
srcF="../../../../../../../Temp/nb_source" #Source folder path
srcWater=$srcF"/Waterbody.shp"
fileWater=Waterbody
srcNonForest=$srcF"/Non Forest.shp"
fileNonForest=NonForest
srcWetland=$srcF"/wetland.shp"
fileWetland=wetland
srcForest=$srcF"/Forest.shp"
fileForest=Forest

# path variables
ogrinfo="/../../../../../../../program files/gdal/ogrinfo.exe"
ogr2ogr="/../../../../../../../program files/gdal/ogr2ogr.exe"
prjF="canadaAlbersEqualAreaConic.prj"
##########################################################################################


############################ Script - shouldn't need editing #############################

#Create schema if it doesn't exist
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

### FILE 1 ###
#Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
#Solution is to load the Waterbody table first with -lco precision=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.

echo "1"
#Run ogr2ogr
ogr2ogr \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcWater \
-lco precision=NO \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileWater' as src_filename FROM '$fileWater'" \
-overwrite

### FILE 2 ###
#APPEND SECOND TABLE - note table name is provided explicitly in -sql statement. This was done so the space can be removed. We don't want spaces in cas_id.
echo "2"
ogr2ogr \
-update -append -addfields \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" "$srcNonForest" \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileNonForest' as src_filename FROM 'Non Forest'"

echo "3"
### FILE 3 ###
ogr2ogr \
-update -append -addfields \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcWetland \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileWetland' as src_filename FROM '$fileWetland'"

echo "4"
## File 4 ###
ogr2ogr \
-update -append -addfields \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcForest \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileForest' as src_filename FROM '$fileForest'"