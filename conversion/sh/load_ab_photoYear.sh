#!/bin/bash -x

# This script loads the Alberta photo year file into PostgreSQL

# The format of the source dataset is a single shapefile

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Multipart and single part polygons are mixed in same file. This can be seen in arcgis by adding a count field and running !Shape!.partCount in the python field calculator. 
# Solution is to set the -nlt argument to PROMOTE_TO_MULTI. This auto converts all features to multipart features when loading.

######################################## Set variables #######################################

source ./common.sh

srcFileName=PhotoYear_Update
srcFullPath="$friDir/AB/AB06/data/photoyear/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.ab_photoYear

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-progress $overwrite_tab

# Fix it
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
DROP TABLE IF EXISTS ${targetFRISchema}.new_ab_photoyear;
CREATE TABLE ${targetFRISchema}.new_ab_photoyear AS
SELECT ST_MakeValid(wkb_geometry) AS wkb_geometry, photo_yr::int, ogc_fid
FROM ${fullTargetTableName}
WHERE photo_yr ~ '^^[0-9]{4}$';
DROP TABLE IF EXISTS ${fullTargetTableName};
ALTER TABLE ${targetFRISchema}.new_ab_photoyear RENAME TO ab_photoyear;
"
createSQLSpatialIndex=True

source ./common_postprocessing.sh
