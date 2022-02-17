#!/bin/bash -x

# This script loads the Alpac avi data (AB31) into PostgreSQL

# The format of the source dataset is a geodtabase divided into mapsheets.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL. 
# Photo year will be joined to the loaded table in PostgreSQL

# Load into the ab31 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB31
srcFileName=Approved_avi_nad83
gdbTableName=avi_poly_nad83_csrs
srcFullPath=$friDir/AB/$inventoryID/data/inventory/$srcFileName.gdb

fullTargetTableName=$targetFRISchema.ab31

alpacFileName=Alpac_aviPhotoYear
alpacFullPath=$friDir/AB/$inventoryID/data/photoyear/$alpacFileName.shp
alpacTableName=$targetFRISchema.ab_alpac_photoYear

overwrite_option="$overwrite_tab"


########################################## Process ######################################

# Loop through all mapsheets.
# For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append
# Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
# Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
# New fields will be added to the right of the table

# Run ogr2ogr to load FRIs
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName" \
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