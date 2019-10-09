#!/bin/bash

# This script loads the QC_01 FRI data into PostgreSQL

# The format of the source dataset is shapefiles divided into NTS tile names.

# Each tile name has a different folder, the data are contained in a shapefile
# named c08peefo.shp in each tile folder.

# Script loops through each tile and appends to the same target table in PostgreSQL.
# Done using the -append argument. 
# Note that -update is also needed in order to append in PostgreSQL. 
# -addfields is not needed here as columns match in all tables.

########################################################################################################
####### 13 tiles beginning in 11 have do not have matching attributes. Leaving these out for now #######
######################################################################################################## 

# The year of photography is included as a shapefile. 

# Load into the qc01 target table in the schema defined in the config file.

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

srcFullPath=$friDir/QC/QC01

prjFile="./../canadaAlbersEqualAreaConic.prj"
fullTargetTableName=$targetFRISchema.qc01

# PostgreSQL variables
ogrTab='c08peefo'

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:host=$pghost port=$pgport dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

# Loop through all tiles.
# For first load, set -lco precision=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append

if [ $overwriteFRI == True ]; then
  update="-overwrite -lco precision=NO"
else 
  update="-lco precision=NO"
fi

for F in "$srcFullPath/"* 
do	
	if ! [[ $F == *"/11"* ]]
		then
		echo $F
	
		"$gdalFolder/ogr2ogr" \
		-f "PostgreSQL" "PG:host=$pghost port=$pgport dbname=$pgdbname user=$pguser password=$pgpassword" "$F/$ogrTab.shp" \
		-nln $fullTargetTableName \
		-t_srs $prjFile \
		-sql "SELECT *, '${F##*/}' as src_filename FROM $ogrTab" \
		-progress $update
	
		update="-update -append"  
	fi
done