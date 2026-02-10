#!/bin/bash -x

# This script loads the Nova Scotia cas03 data (NS01) into PostgreSQL

# The format of the source dataset is a shapefile

# The year of photography is included in the attribute PHOTOYR

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# The combination of FOREST_, FOREST_ID, and MAPSHEET is a unique identifier across all counties 
# and should be used in the cas_id.
######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=NS01
srcFileName=NS_FRI
srcFullPath="$friDir/NS/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.ns01

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwriteTable

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh