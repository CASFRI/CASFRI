#!/bin/bash -x

# This script loads the AB GOV WELWOOD dataset

# The format of the source dataset is two shapefiles named ath.shp and ber.shp
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

inventoryID=AB11

srcName1=ath
srcFullPath1="$friDir/AB/$inventoryID/data/inventory/$srcName1.shp"

srcName2=ber
srcFullPath2="$friDir/AB/$inventoryID/data/inventory/$srcName2.shp"

fullTargetTableName=$targetFRISchema.ab11

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

### FILE 1 ###
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath1" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName1' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName1 WHERE poly_num > 0" \
-progress $overwriteTable

### FILE 2 ###
"$gdalFolder/ogr2ogr" \
-update -append -addfields \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath2" \
-nln $fullTargetTableName $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName2' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName2 WHERE poly_num > 0" \
-progress

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh