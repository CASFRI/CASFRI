#!/bin/bash

# This script loads the Alberta photo year file into PostgreSQL

# The format of the source dataset is a single shapefile

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
# Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

######################################## Set variables #######################################

# load config variables
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

srcFileName=PhotoYear_Update
srcFullPath="$friDir/AB/PhotoYear/$srcFileName.shp"

prjFile="../canadaAlbersEqualAreaConic.prj"
fullTargetTableName=$targetFRISchema.ab_photoYear

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

#Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcFullPath" \
-nln $fullTargetTableName \
-lco GEOMETRY_NAME="wkb_geometry" \
-t_srs $prjFile \
-nlt PROMOTE_TO_MULTI \
-progress $overwrite_tab