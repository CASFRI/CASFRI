#!/bin/bash -x

# This script loads the AB GOV BLUERIDGE dataset

# The format of the source dataset is two shapefiles named blueridge.shp and w2_utm11_n80.shp
# poly_num is a unique id.
# Drop polygons where poly_num = 0, these have no data.

# These two files are combined into a single PostgreSQL table
# This is done using the -append argument. Note that -update is also 
# needed in order to append in PostgreSQL. -addfields is also needed 
# because columns do not all match between tables.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=AB03

srcNameBlueridge=blueridge
srcBlueridgeFullPath="$friDir/AB/$inventoryID/data/inventory/$srcNameBlueridge.shp"

srcNameW2=w2_utm11_n80
srcW2FullPath="$friDir/AB/$inventoryID/data/inventory/$srcNameW2.shp"

fullTargetTableName=$targetFRISchema.ab03

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

### FILE 1 ###
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcBlueridgeFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameBlueridge' AS src_filename, '$inventoryID' AS inventory_id FROM $srcNameBlueridge WHERE poly_num > 0" \
-progress $overwriteTable

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$gdalConnectionString" "$srcW2FullPath" \
-nln $fullTargetTableName $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcNameW2' AS src_filename, '$inventoryID' AS inventory_id FROM $srcNameW2 WHERE poly_num > 0" \
-progress

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh