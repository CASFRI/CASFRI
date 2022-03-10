#!/bin/bash -x

# This script loads the Alpac avi data (AB31) into PostgreSQL.

# The format of the source dataset is two geodatabases. Poly_id is the unique identifier in table Approved_avi_nad83, while 
# POLY_NUM is the unique identifier in table AVI_nad27_missing_maps. Poly_id is missing in AVI_nad27_missing_maps. During 
# the upload, we use poly_num from AVI_nad27_missing_maps to fill poly_id, which will become the unique identifier.

# Only polygons having inventory attributes (MER >0) are loaded. 

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL. 

# Load into the ab31 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB31
srcFileNameMain=Approved_avi_nad83
gdbTableNameMain=avi_poly_nad83_csrs
srcFullPathMain=$friDir/AB/$inventoryID/data/inventory/$srcFileNameMain.gdb

srcFileNameMissing=AVI_nad27_missing_maps
gdbTableNameMissing=AVI_nad27_missing_maps
srcFullPathMissing=$friDir/AB/$inventoryID/data/inventory/$srcFileNameMissing.gdb

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
-f PostgreSQL "$pg_connection_string" "$srcFullPathMain" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileNameMain' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableNameMain WHERE MER <> 0" \
-progress $overwrite_tab

# Load missing part
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$pg_connection_string" "$srcFullPathMissing" \
-nln $fullTargetTableName $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileNameMissing' AS src_filename, '$inventoryID' AS inventory_id, '$poly_num' AS poly_id FROM $gdbTableNameMissing WHERE MER <> 0" \
-progress


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