#!/bin/bash

#This script loads the AB_0016 FRI data into PostgreSQL

#The format of the source dataset is ArcInfo Coverages divided into mapsheets.
#The FRI data is stored in the "forest" feature for each mapsheet.
#Script needs to loop through each mapsheet and append to the same target table in PostgreSQL.
#This can be done using the -append argument. Note that -update is also needed in order to append in PostgreSQL. -addfields is not needed here as columns match in all tables.

#The year of photography is included as a shapefile. Photo year will be joined to the loaded table in PostgreSQL

#Load into a target table in a schema named 'ab'. 

#Workflow as recommended here: https://trac.osgeo.org/gdal/wiki/FAQVector#FAQ-Vector
#Load the first table normally, then delete all the data. This serves as a template
#Then loop through all Coverages and append to the template table

#Source file location - make all paths relative to source
srcD=$(dirname $BASH_SOURCE)

#Create schema if it doesn't exist
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS ab";

#Projection file. Canada Albers Equal Area Conic. %~dp0 fetches the directory that contains the batch file.
prjF=$srcD"/canadaAlbersEqualAreaConic.prj"

#Target table name
trgtT=ab.AB_0016
echo "1."
## 1. ##
#make table template
#load first mapsheet. Using precision=NO because the FOREST-ID field is set to NUMERIC(5,0) when imported but data have 6 digits. Causes error.
$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcD"/../../../../../../../Temp/Canfor/t059r04m6/forest" \
-nln $trgtT \
-t_srs $prjF \
-lco precision=NO \
-sql "SELECT *, '$fileName' as src_filename FROM 'PAL'" \
-overwrite

#delete rows but not table
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "delete  from $trgtT"

#Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
#Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
#New fields will be added to the right of the table
#Using ogrinfo - add two new integer columns to hold the FOREST# and FOREST-ID integers. Name them forest_id_1 and forest_id_2.
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "ALTER TABLE $trgtT ADD forest_id_1 integer;"
$srcD"/../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "ALTER TABLE $trgtT ADD forest_id_2 integer;"
echo "2."
## 2. ##
#loop through all mapsheets and append to template.
# -sql statement adds new columns with the values of the invalid columns
for F in $srcD/../../../../../../../Temp/Canfor/t* 
do
	echo "F: " $F
	srcF=$F/forest
	filename=${F##*/}
	echo "srcF: " $srcF
	echo "filename: " $filename
	
	$srcD"/../../../../../../../program files/gdal/ogr2ogr.exe" \
	-update -append \
	-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $srcF \
	-nln $trgtT \
	-t_srs $prjF \
	-sql "SELECT *, '$filename' as src_filename, 'FOREST#' as 'forest_id_1', 'FOREST-ID' as 'forest_id_2' FROM 'PAL'"
done