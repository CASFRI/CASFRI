#!/bin/bash

#This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

#The format of the source dataset is a E00 file

#The year of photography is included as a shapefile. Photo year will be joined to the loaded table in PostgreSQL

#Load into a target table in a schema named 'ab'. 

#If table already exists it will be overwritten.

#Could not load E00 with attributes successfully without using ESRI tools.

#Converted E00 to geodatabase in ArcGIS. This script will load the geodatabase.

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
trgtT=ab_0006 #Target table name

srcF="$friDir/ab_0006.gdb"
srcName=ab_0006
ogrTab=ab_0006

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
-sql "SELECT *, '$srcName' as src_filename FROM '$ogrTab'" \
-progress -overwrite