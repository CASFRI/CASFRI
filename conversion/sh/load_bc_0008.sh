#!/bin/bash

#This script loads the British Columbia VRI data into PostgreSQL

#The format of the source dataset is a geodatabase

#The year of photography is included in the attributes table (REFERENCE_YEAR)

#Load into a target table in a schema named 'bc'.


#CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID IF NEEDED. CHECK WITH STEVE.

######################################## variables #######################################

# PostgreSQL variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
schema=test
trgtT=test.BC_0008 #Target table name
srcF="../../../../../../../../Temp/bc_test.gdb" #Source file path
fileName=bc_test #Filename field. This will be added as a column called src_filename and later used to create the cas_id field

# path variables
ogrinfo="../../../../../../../../program files/gdal/ogrinfo.exe"
ogr2ogr="../../../../../../../../program files/gdal/ogr2ogr.exe"
prjF="canadaAlbersEqualAreaConic.prj"
##########################################################################################


############################ Script - shouldn't need editing #############################

#Create schema if it doesn't exist
$ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS "$schema;

#Run ogr2ogr
$ogr2ogr \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcF \
-nln $trgtT \
-t_srs $prjF \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'"

#If later we need to filter, use:
#-sql "SELECT *, '$fileName' as src_filename FROM '$fileName' WHERE Inventory_Standard_CD='V'"

#Spatial index should be created automatically, if not, un-comment the ogrinfo line
#ogrinfo PG:"host="$pghost "dbname="$pgdbname "user="$pguser "password="$pgpassword -sql "CREATE INDEX BC_0008_spatial_index ON bc.BC_0008 USING GIST (wkb_geometry);"
##########################################################################################