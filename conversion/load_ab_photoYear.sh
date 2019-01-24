#!/bin/bash

#This script loads the Alberta photo year file into PostgreSQL

#The format of the source dataset is a single shapefile

#Load into a target table in a schema named 'ab'.

#Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
#Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

#Source file location - make all paths relative to source
srcD=$(dirname $BASH_SOURCE)

#Create schema if it doesn't exist
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS ab";

#Source file path
srcF=$srcD"/../../../../../../../Temp/AB_Photo_Year/PhotoYear_Update.shp"

#Target table name
trgtT=ab.AB_PhotoYear

#Projection file. Canada Albers Equal Area Conic. %~dp0 fetches the directory that contains the batch file.
prjF=$srcD"/canadaAlbersEqualAreaConic.prj"

#Run ogr2ogr
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
-nln $trgtT \
-t_srs $prjF \
-nlt PROMOTE_TO_MULTI

#Spatial index should be created automatically, if not, un-comment the ogrinfo line
#$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX AB_PhotoYear_spatial_index ON ab.AB_PhotoYear USING GIST (wkb_geometry);"