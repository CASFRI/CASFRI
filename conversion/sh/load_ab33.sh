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

source ./common.sh

inventoryID=AB33

srcFileName=Phase3_nad27
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.ab33

alpacFileName=Alpac_aviPhotoYear
alpacFullPath=$friDir/AB/$inventoryID/data/photoyear/$alpacFileName.shp
alpacTableName=$targetFRISchema.ab_alpac_photoYear

########################################## Process ######################################

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab


# Run ogr2ogr to load Alpac photoyear
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$alpacFullPath" \
-nln $alpacTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-progress $overwrite_tab

# Fix it
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
DROP TABLE IF EXISTS ${targetFRISchema}.new_alpac_photoyear;
CREATE TABLE ${targetFRISchema}.new_alpac_photoyear AS
SELECT ST_MakeValid(wkb_geometry) AS wkb_geometry, avi_year::int, ogc_fid
FROM ${alpacTableName};
DROP TABLE IF EXISTS ${alpacTableName};
ALTER TABLE ${targetFRISchema}.new_alpac_photoyear RENAME TO ab_alpac_photoyear;
"
createSQLSpatialIndex=True  

source ./common_postprocessing.sh