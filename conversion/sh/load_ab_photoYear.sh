#!/bin/bash

#This script loads the Alberta photo year file into PostgreSQL

#The format of the source dataset is a single shapefile

#Load into a target table in a schema named 'ab'.

#If table already exists it will be overwritten.

#Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
#Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

######################################## variables #######################################

# load config variables
if [ -f ./config.sh ]; then 
  source ./config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

# PostgreSQL variables
schema=test
trgtT=ab_photoyear

srcF="$friDir/PhotoYear_Update.shp"

##########################################################################################


############################ Script - shouldn't need editing #############################

#Set schema.table
schTab=$schema.$trgtT

#Create schema if it doesn't exist
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

#Run ogr2ogr
ogr2ogr \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" "$srcF" \
-nln $schTab \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI \
-progress -overwrite