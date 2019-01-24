#!/bin/bash

#This script loads the New Brunswick FRI data into PostgreSQL

#The format of the source dataset is four shapefiles named Forest.shp, Non Forest.shp, Waterbody.shp, and wetland.shp
#These four files need to be combined into a single PostgreSQL table
#This can be done using the -append argument. Note that -update is also needed in order to append in PostgreSQL. -addfields is also needed because columns do not match between tables. 

#The year of photography is included in the attributes table (DATAYR)

#Load into a target table in a schema named 'nb'.

#Workflow is to load the first table normally, then append the others
#Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries

#Source file location - make all paths relative to source
srcD=$(dirname $BASH_SOURCE)

#Create schema if it doesn't exist
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS nb";

#Projection file. Canada Albers Equal Area Conic. %~dp0 fetches the directory that contains the batch file.
prjF=$srcD"/canadaAlbersEqualAreaConic.prj"

#Target table name
trgtT=nb.NB_0001


### FILE 1 ###
#Load Waterbody table first. SHAPE_AREA field has a value larger than the numeric type assigned in PostgreSQL. Returns error when loading. Unable to edit field precision on import.
#Solution is to load the Waterbody table first with -lco precision=NO. This changes the type from NUMERIC to DOUBLE. All other tables will be converted to DOUBLE when appended.

#Source file path
srcF=$srcD"/../../../../../../../Temp/NB_source/Waterbody.shp"

#Filename field. This will be added as a column called src_filename and later used to create the cas_id field
fileName=Waterbody
echo "1"
#Run ogr2ogr
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
-lco precision=NO \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'" \
-overwrite

### FILE 2 ###
#APPEND SECOND TABLE - note table name is provided explicitly in -sql statement. This was done so the space can be removed from %fileName%. We don't want spaces in cas_id.
srcF=$srcD"/../../../../../../../Temp/NB_source/Non Forest.shp"
fileName=NonForest
echo "2"
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-update -append -addfields \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" "$srcF" \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileName' as src_filename FROM 'Non Forest'"
echo "3"
### FILE 3 ###
srcF=$srcD"/../../../../../../../Temp/NB_source/wetland.shp"
fileName=wetland
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-update -append -addfields \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'"
echo "4"
## File 4 ###
srcF=$srcD"/../../../../../../../Temp/NB_source/Forest.shp"
fileName=Forest
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-update -append -addfields \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'"