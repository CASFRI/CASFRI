#!/bin/bash -x

# This script loads the Alpac updated avi data (savi 2001-2011) into PostgreSQL

# The format of the source dataset is a geodtabase.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL. 
# Drop polygons where poly_num = 0, these have no data.
# Once poly_num = 0 are removed, poly_num is unique. 

# Load into the ab32 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB32
srcFileName=savi_data_fma_121214
gdbTableName=forest
srcFullPath=$friDir/AB/$inventoryID/data/inventory/$srcFileName.gdb

fullTargetTableName=$targetFRISchema.ab32

alpacFileName=savi_photo_yr
alpacFullPath=$friDir/AB/$inventoryID/data/photoyear/$alpacFileName.shp
alpacTableName=$targetFRISchema.ab_alpac_updated_photoYear

overwrite_option="$overwrite_tab"


########################################## Process ######################################

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
DROP TABLE IF EXISTS ${targetFRISchema}.new_ab_alpac_updated_photoYear;
CREATE TABLE ${targetFRISchema}.new_ab_alpac_updated_photoYear AS
SELECT ST_MakeValid(wkb_geometry) AS wkb_geometry, photo_year::int, ogc_fid
FROM ${alpacTableName};
DROP TABLE IF EXISTS ${alpacTableName};
ALTER TABLE ${targetFRISchema}.new_ab_alpac_updated_photoYear RENAME TO ab_alpac_updated_photoYear;
"
createSQLSpatialIndex=True  

source ./common_postprocessing.sh