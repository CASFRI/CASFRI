#!/bin/bash

#This script loads the AB_0016 FRI data into PostgreSQL

#The format of the source dataset is ArcInfo Coverages divided into mapsheets.

# The FRI data is stored in the "forest" feature for each mapsheet.
# Script loops through each mapsheet and appends to the same target table in PostgreSQL.
# Done using the -append argument. 
# Note that -update is also needed in order to append in PostgreSQL. 
# -addfields is not needed here as columns match in all tables.

# The year of photography is included as a shapefile. 
# Photo year will be joined to the loaded table in PostgreSQL

# Load into the ab16 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

# load config variables
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

srcFirstFileName=t059r04m6
srcFullPath=$friDir/AB/AB16

prjFile="./../canadaAlbersEqualAreaConic.prj"
fullTargetTableName=$targetFRISchema.ab16

# PostgreSQL variables
ogrTab='PAL'

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:host=$pghost port=$pgport dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

# Loop through all mapsheets.
# For first load, set -lco precision=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append
# Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
# Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
# New fields will be added to the right of the table

if [ $overwriteFRI == True ]; then
  update="-overwrite -lco precision=NO"
else 
  update="-lco precision=NO"
fi

for F in "$srcFullPath/t"* 
do	
	"$gdalFolder/ogr2ogr" \
	-f "PostgreSQL" "PG:host=$pghost port=$pgport dbname=$pgdbname user=$pguser password=$pgpassword" "$F/forest" \
	-nln $fullTargetTableName \
	-t_srs $prjFile \
	-sql "SELECT *, '${F##*/}' as src_filename, 'FOREST#' as 'forest_id_1', 'FOREST-ID' as 'forest_id_2' FROM $ogrTab" \
	-progress $update
	
	update="-update -append"  
done