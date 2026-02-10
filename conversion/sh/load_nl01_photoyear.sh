#!/bin/bash -x

# This script loads the Newfoundland and Labrador photo year file into PostgreSQL

# The format of the source dataset is a single shapefile

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=NL01

srcFileName=photoyear
srcFullPath="$friDir/NL/$inventoryID/data/photoyear/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.nl01_photoYear

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-progress $overwriteTable

# Fix it
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
DROP TABLE IF EXISTS ${targetFRISchema}.new_nl01_photoyear CASCADE;

CREATE TABLE ${targetFRISchema}.new_nl01_photoyear AS
SELECT ST_MakeValid(wkb_geometry) AS wkb_geometry, photoyear, ogc_fid
FROM ${fullTargetTableName};

DROP TABLE IF EXISTS ${fullTargetTableName} CASCADE;

ALTER TABLE ${targetFRISchema}.new_nl01_photoyear RENAME TO nl01_photoyear;
"
createSQLSpatialIndex=True

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh
