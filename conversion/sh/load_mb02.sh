#!/bin/bash -x

# This script loads the Manitoba LouisianaPacific Duck_mountain data into PostgreSQL

# The data is an E00 file which has been converted to a geodatabase for loading.
# There is a polygon file and 6 layers of attributes that need to be joined.

# The year of photography is 1998 for the entire inventory (according to CAS04 code)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# The combination of duck_mountain_ and forestkey makes a unique id that can be traced back
# to the source data. Note that forestkey can have 11 characters for some rows, even when removing
# the last character in the cas_id (limit is 10 characters), the id is still unique.

# Load each table then join
######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=MB02

srcFileName=MB_LP
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
poly_tab="duck_mountain"
layer1_tab="duck_mountain_os"
layer2_tab="duck_mountain_us2"
layer3_tab="duck_mountain_us3"
layer4_tab="duck_mountain_us4"
layer5_tab="duck_mountain_us5"

fullTargetTableName=$targetFRISchema.${inventoryID,,}
poly_temp=${fullTargetTableName}_poly_tab
layer1_temp=${fullTargetTableName}_layer1_tab
layer2_temp=${fullTargetTableName}_layer2_tab
layer3_temp=${fullTargetTableName}_layer3_tab
layer4_temp=${fullTargetTableName}_layer4_tab
layer5_temp=${fullTargetTableName}_layer5_tab

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# load polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$poly_tab" \
-nln $poly_temp $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $poly_tab" \
-progress $overwriteTable

# load attributes
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$layer1_tab" \
-nln $layer1_temp $gdalLco $gdalOtherOptions \
-sql "SELECT *, forestkey AS forestkey_lyr1 FROM $layer1_tab" \
-progress $overwriteTable

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$layer2_tab" \
-nln $layer2_temp $gdalLco $gdalOtherOptions \
-sql "SELECT *, forestkey AS forestkey_lyr2 FROM $layer2_tab" \
-progress $overwriteTable

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$layer3_tab" \
-nln $layer3_temp $gdalLco $gdalOtherOptions \
-sql "SELECT *, forestkey AS forestkey_lyr3 FROM $layer3_tab" \
-progress $overwriteTable

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$layer4_tab" \
-nln $layer4_temp $gdalLco $gdalOtherOptions \
-sql "SELECT *, forestkey AS forestkey_lyr4 FROM $layer4_tab" \
-progress $overwriteTable

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$layer5_tab" \
-sql "SELECT *, forestkey AS forestkey_lyr5 FROM $layer5_tab" \
-nln $layer5_temp $gdalLco $gdalOtherOptions \
-progress $overwriteTable

"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
-- delete ogc_fid, id, mapsheet, polynum, mer, twp, rge, forestkey. Joins don't work with matching names.
ALTER TABLE $layer1_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey;
ALTER TABLE $layer2_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;
ALTER TABLE $layer3_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;
ALTER TABLE $layer4_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;
ALTER TABLE $layer5_temp DROP COLUMN IF EXISTS ogc_fid, DROP COLUMN IF EXISTS mapsheet, DROP COLUMN IF EXISTS polynum, DROP COLUMN IF EXISTS mer, DROP COLUMN IF EXISTS twp, DROP COLUMN IF EXISTS rge, DROP COLUMN IF EXISTS forestkey, DROP COLUMN IF EXISTS id;

-- Join
DROP TABLE IF EXISTS $fullTargetTableName CASCADE;

CREATE TABLE $fullTargetTableName AS
SELECT *
  FROM $poly_temp A 
    LEFT JOIN $layer1_temp B ON A.forestkey = B.forestkey_lyr1
    LEFT JOIN $layer2_temp C ON A.forestkey = C.forestkey_lyr2
	LEFT JOIN $layer3_temp D ON A.forestkey = D.forestkey_lyr3
	LEFT JOIN $layer4_temp E ON A.forestkey = E.forestkey_lyr4
	LEFT JOIN $layer5_temp F ON A.forestkey = F.forestkey_lyr5;

-- Drop tables
DROP TABLE IF EXISTS $poly_temp CASCADE;
DROP TABLE IF EXISTS $layer1_temp CASCADE;
DROP TABLE IF EXISTS $layer2_temp CASCADE;
DROP TABLE IF EXISTS $layer3_temp CASCADE; 
DROP TABLE IF EXISTS $layer4_temp CASCADE;
DROP TABLE IF EXISTS $layer5_temp CASCADE;

-- Drop duplicate poly_ids
ALTER TABLE $fullTargetTableName 
  DROP COLUMN forestkey_lyr1, 
  DROP COLUMN forestkey_lyr2, 
  DROP COLUMN forestkey_lyr3, 
  DROP COLUMN forestkey_lyr4, 
  DROP COLUMN forestkey_lyr5 
"

createSQLSpatialIndex=True

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh