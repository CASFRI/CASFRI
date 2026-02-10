#!/bin/bash -x

# This script loads the 2010 PEI forest inventory (PE02) into PostgreSQL

# This dataset is a single shapefile

# The KEY attribute is a unique identifier made up of the MAP and STAND values
# Note that there are 31 KEY_ entries that actually have 2 polygons. These look
# to be cases where the original polygon has been split into 2. For this reason we
# should have ogc_fid in the cas_id to ensure uniqueness.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=PE02
srcFileName=Corporate_Landuse_Inventory_2010

srcFullPath="$friDir/PE/$inventoryID/data/inventory/$srcFileName.shp"
fullTargetTableName=$targetFRISchema.pe02

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Load the shapefile
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-progress $overwriteTable \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM \"$srcFileName\""

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh