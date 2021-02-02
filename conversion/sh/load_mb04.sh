#!/bin/bash -x

# This script loads the Manitoba LouisianaPacific Procupine_mountain data into PostgreSQL

# The data is an E00 file which has been converted to a geodatabase for loading.
# There is a polygon file and 6 layers of attributes that need to be joined.

# The year of photography is 2000 for the entire inventory (according to CAS04 code)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# The combination of porc_mountain_ and forestkey makes a unique id that can be traced back
# to the source data. Note that forestkey can have 11 characters for some rows, even when removing
# the last character in the cas_id (limit is 10 characters), the id is still unique.

# Load each table then join
######################################## Set variables #######################################

source ./common.sh

inventoryID=MB04

srcFileName=MB_LP
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
poly_tab="porc_mountain"
layer1_tab="porc_mountain_os"
layer2_tab="porc_mountain_us2"
layer3_tab="porc_mountain_us3"
layer4_tab="porc_mountain_us4"

poly_temp=$targetFRISchema.poly_tab
layer1_temp=$targetFRISchema.layer1_tab
layer2_temp=$targetFRISchema.layer2_tab
layer3_temp=$targetFRISchema.layer3_tab
layer4_temp=$targetFRISchema.layer4_tab
fullTargetTableName=$targetFRISchema.mb04

########################################## Process ######################################

# load polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$poly_tab" \
-nln $poly_temp $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $poly_tab" \
-progress $overwrite_tab

# load attributes
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$layer1_tab" \
-nln $layer1_temp $layer_creation_options $other_options \
-sql "SELECT *, forestkey AS forestkey_lyr1 FROM $layer1_tab" \
-progress $overwrite_tab

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$layer2_tab" \
-nln $layer2_temp $layer_creation_options $other_options \
-sql "SELECT *, forestkey AS forestkey_lyr2 FROM $layer2_tab" \
-progress $overwrite_tab

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$layer3_tab" \
-nln $layer3_temp $layer_creation_options $other_options \
-sql "SELECT *, forestkey AS forestkey_lyr3 FROM $layer3_tab" \
-progress $overwrite_tab

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$layer4_tab" \
-nln $layer4_temp $layer_creation_options $other_options \
-sql "SELECT *, forestkey AS forestkey_lyr4 FROM $layer4_tab" \
-progress $overwrite_tab

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
-- delete ogc_fid, id, mapsheet, polynum, mer, twp, rge, forestkey. Joins don't work with matching names.
ALTER TABLE $layer1_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey;
ALTER TABLE $layer2_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;
ALTER TABLE $layer3_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;
ALTER TABLE $layer4_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;

-- Join
DROP TABLE IF EXISTS $fullTargetTableName; 
CREATE TABLE $fullTargetTableName AS
SELECT *
  FROM $poly_temp A 
    LEFT JOIN $layer1_temp B ON A.forestkey = B.forestkey_lyr1
    LEFT JOIN $layer2_temp C ON A.forestkey = C.forestkey_lyr2
	LEFT JOIN $layer3_temp D ON A.forestkey = D.forestkey_lyr3
	LEFT JOIN $layer4_temp E ON A.forestkey = E.forestkey_lyr4;

-- Drop tables
DROP TABLE IF EXISTS $poly_temp;
DROP TABLE IF EXISTS $layer1_temp;
DROP TABLE IF EXISTS $layer2_temp;
DROP TABLE IF EXISTS $layer3_temp; 
DROP TABLE IF EXISTS $layer4_temp;

-- Drop duplicate poly_ids
ALTER TABLE $fullTargetTableName 
  DROP COLUMN forestkey_lyr1, 
  DROP COLUMN forestkey_lyr2, 
  DROP COLUMN forestkey_lyr3, 
  DROP COLUMN forestkey_lyr4;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh