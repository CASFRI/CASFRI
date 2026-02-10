#!/bin/bash -x

# This script loads the AB Alpac AVI missing holes from AB31

# The format of the source dataset is a single shapefile named Phase3_nad27.shp.
# OBJECTID is a unique id.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=AB33

srcFileName=Phase3_nad27
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.ab33

alpacFileName=Alpac_aviPhotoYear
alpacFullPath=$friDir/AB/$inventoryID/data/photoyear/$alpacFileName.shp
alpacTableName=$targetFRISchema.ab_alpac_photoYear

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwriteTable

# Run ogr2ogr to load Alpac photoyear
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$alpacFullPath" \
-nln $alpacTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-progress $overwriteTable

# Fix it
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
DROP TABLE IF EXISTS ${targetFRISchema}.new_alpac_photoyear CASCADE;

CREATE TABLE ${targetFRISchema}.new_alpac_photoyear AS
SELECT ST_MakeValid(wkb_geometry) AS wkb_geometry, avi_year::int, ogc_fid
FROM ${alpacTableName};

DROP TABLE IF EXISTS ${alpacTableName} CASCADE;

ALTER TABLE ${targetFRISchema}.new_alpac_photoyear RENAME TO ab_alpac_photoyear;
"
createSQLSpatialIndex=True  

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh