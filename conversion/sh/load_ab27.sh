#!/bin/bash -x

# This script loads the AB27 dataset (Alpac).

# The format of the source dataset is two table in a geodatabase: FOREST1 that contains the geometry and AVI that 
# provides forest attributes.
# poly_num is a unique id.

# The year of photography is included as a shapefile (savi_photo_yr). Photo year will be joined to the 
# loaded table in PostgreSQL. 

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB27

srcFileName=avi_2012
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcFileName.gdb"
gdbFileName_poly=FOREST1
gdbFileName_avi=AVI

AB_subFolder="$friDir/AB/AB27/data/inventory/"
fullTargetTableName=$targetFRISchema.ab27
tableName_poly=${fullTargetTableName}_poly
tableName_avi=${fullTargetTableName}_avi

alpacFileName=savi_photo_yr
alpacFullPath=$friDir/AB/$inventoryID/data/photoyear/$alpacFileName.shp
alpacTableName=$targetFRISchema.ab_alpac_updated_photoYear

########################################## Process ######################################

# Run ogr2ogr for polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly" \
-progress $overwrite_tab

# Run ogr2ogr for avi table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_avi" \
-nln $tableName_avi $layer_creation_options $other_options \
-sql "SELECT * FROM $gdbFileName_avi" \
-progress $overwrite_tab

# Join AVI table to polygon using POLY_NUM attribute.
# The ogc_fid attributes are no longer unique identifiers after the 
# join so a new ogc_fid is created.
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
-- Alter ogc_fid, POLY_NUM. Joins don't work with matching names.
ALTER TABLE $tableName_avi DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $tableName_avi ADD COLUMN polynum INT;
UPDATE $tableName_avi SET polynum = POLY_NUM;
ALTER TABLE $tableName_avi DROP COLUMN IF EXISTS POLY_NUM;

-- Join
DROP TABLE IF EXISTS $fullTargetTableName; 
CREATE TABLE $fullTargetTableName AS
SELECT *
  FROM $tableName_poly A 
    LEFT JOIN $tableName_avi B ON A.POLY_NUM = B.polynum;

-- Drop tables
DROP TABLE IF EXISTS $tableName_poly;
DROP TABLE IF EXISTS $tableName_avi;
"

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