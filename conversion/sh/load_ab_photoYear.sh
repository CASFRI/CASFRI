#!/bin/bash

#This script loads the Alberta photo year file into PostgreSQL

#The format of the source dataset is a single shapefile

#Load into a target table in a schema named 'ab'.

#Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
#Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

######################################## variables #######################################

# PostgreSQL variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
schema=test
trgtT=test.AB_photoyear #Target table name
srcF="../../../../../../../../Temp/AB_Photo_Year/PhotoYear_Update.shp" #Source folder path

# path variables
ogrinfo="../../../../../../../../program files/gdal/ogrinfo.exe"
ogr2ogr="../../../../../../../../program files/gdal/ogr2ogr.exe"
prjF="canadaAlbersEqualAreaConic.prj"
##########################################################################################


############################ Script - shouldn't need editing #############################

#Create schema if it doesn't exist
"$ogrinfo" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

#Run ogr2ogr
"$ogr2ogr" \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcF \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI