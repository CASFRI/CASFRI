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

######################################## variables #######################################

# PostgreSQL variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
schema=test
trgtT=test.AB_0016 #Target table name
srcF="../../../../../../../Temp/Canfor_test" #Source folder path
firstfile=$srcF"/t059r04m6/forest"

# path variables
ogrinfo="/../../../../../../../program files/gdal/ogrinfo.exe"
ogr2ogr="/../../../../../../../program files/gdal/ogr2ogr.exe"
prjF="canadaAlbersEqualAreaConic.prj"
##########################################################################################


############################ Script - shouldn't need editing #############################

#Create schema if it doesn't exist
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

echo "1."
## 1. ##
#make table template
#load first mapsheet. Using precision=NO because the FOREST-ID field is set to NUMERIC(5,0) when imported but data have 6 digits. Causes error.
ogr2ogr \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $firstfile \
-nln $trgtT \
-t_srs $prjF \
-lco precision=NO \
-sql "SELECT *, 'placeholder' as src_filename FROM 'PAL'" \
-overwrite

#delete rows but not table
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "delete  from $trgtT"

#Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
#Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
#New fields will be added to the right of the table
#Using ogrinfo - add two new integer columns to hold the FOREST# and FOREST-ID integers. Name them forest_id_1 and forest_id_2.
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "ALTER TABLE $trgtT ADD forest_id_1 integer;"
ogrinfo "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "ALTER TABLE $trgtT ADD forest_id_2 integer;"

echo "2."
## 2. ##
#loop through all mapsheets and append to template.
# -sql statement adds new columns with the values of the invalid columns
for F in $srcF/t* 
do
	echo "F: " $F
	srcFF=$F/forest
	filename=${F##*/}
	echo "srcF: " $srcFF
	echo "filename: " $filename
	
	ogr2ogr \
	-update -append \
	-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $srcFF \
	-nln $trgtT \
	-t_srs $prjF \
	-sql "SELECT *, '$filename' as src_filename, 'FOREST#' as 'forest_id_1', 'FOREST-ID' as 'forest_id_2' FROM 'PAL'"
done