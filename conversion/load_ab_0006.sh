#!/bin/bash

#This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

#The format of the source dataset is a E00 file

#The year of photography is included as a shapefile. Photo year will be joined to the loaded table in PostgreSQL

#Load into a target table in a schema named 'ab'. 

#Could not load E00 with attributes successfully without using ESRI tools.

#Converted E00 to geodatabase in ArcGIS. This script will load the geodatabase.

#Source file location - make all paths relative to source
srcD=$(dirname $BASH_SOURCE)

#Create schema if it doesn't exist
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS ab";

#Projection file. Canada Albers Equal Area Conic.
prjF=$srcD"/canadaAlbersEqualAreaConic.prj"

#Target table name
trgtT=ab.AB_0006

#Source file path
srcF=$srcD"/../../../../../../../Temp/GB_S21_TWP/geodatabase/GB_S21_TWP.gdb"

#Filename field. This will be added as a column called src_filename and later used to create the cas_id field
fileName=GB_S21_TWP

#Run ogr2ogr
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
-nln $trgtT \
-t_srs $prjF \
-sql "SELECT *, '$fileName' as src_filename FROM '$fileName'"

#Spatial index should be created automatically, if not, un-comment the ogrinfo line
#$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX BC_0008_spatial_index ON bc.BC_0008 USING GIST (wkb_geometry);"