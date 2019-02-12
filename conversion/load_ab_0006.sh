#!/bin/bash

#This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

#The format of the source dataset is a E00 file

#The year of photography is included as a shapefile. Photo year will be joined to the loaded table in PostgreSQL

#Load into a target table in a schema named 'ab'. 

#Could not load E00 with attributes successfully without using ESRI tools.

#Converted E00 to geodatabase in ArcGIS. This script will load the geodatabase.

######################################## variables #######################################

# PostgreSQL variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
schema=test
trgtT=test.AB_0006 #Target table name
srcF="../../../../../../../Temp/ab_0006.gdb" #Source file path
fileName=ab_0006 #Filename field. This will be added as a column called src_filename and later used to create the cas_id field. Must match source filename.

# path variables
ogrinfo="/../../../../../../../program files/gdal/ogrinfo.exe"
ogr2ogr="/../../../../../../../program files/gdal/ogr2ogr.exe"
prjF="canadaAlbersEqualAreaConic.prj"
##########################################################################################


############################ Script - shouldn't need editing #############################

#Create schema if it doesn't exist
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

#Run ogr2ogr
ogr2ogr \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcF \
-nln $trgtT \
-t_srs $prjF \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'"

#Spatial index should be created automatically, if not, un-comment the ogrinfo line
#ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE INDEX ab_0006_spatial_index ON ab.ab_0008 USING GIST (wkb_geometry);"