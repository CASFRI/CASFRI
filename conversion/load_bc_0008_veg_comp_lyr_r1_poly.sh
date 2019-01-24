#!/bin/bash

#The format of the source dataset is a geodatabase

#The year of photography is included in the attributes table (REFERENCE_YEAR)

#Load into a target table in a schema named 'bc'.


#CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID IF NEEDED. CHECK WITH STEVE.

#Source file location - make all paths relative to source
srcD=$(dirname $BASH_SOURCE)

#Create schema if it doesn't exist
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS test";

#Projection file. Canada Albers Equal Area Conic.
prjF=$srcD"/canadaAlbersEqualAreaConic.prj"

#Target table name
trgtT=test.BC_0001

#Source file path
srcF=$srcD"/../../../../../../../Temp/VEG_COMP_LYR_R1_POLY/VEG_COMP_LYR_R1_POLY.gdb"

#Filename field. This will be added as a column called src_filename and later used to create the cas_id field
fileName=VEG_COMP_LYR_R1_POLY

#Run ogr2ogr
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
-nln $trgtT \
-t_srs $prjF \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'"

#If later we need to filter, use:
#-sql "SELECT *, '$fileName' as src_filename FROM '$fileName' WHERE Inventory_Standard_CD='V'"

#Spatial index should be created automatically, if not, un-comment the ogrinfo line
#$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX BC_0008_spatial_index ON bc.BC_0008 USING GIST (wkb_geometry);"