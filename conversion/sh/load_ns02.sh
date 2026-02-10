#!/bin/bash -x

# This script loads the Nova Scotia forest inventory from cas04 (NS02) into PostgreSQL

# This dataset is split into 20 shapefiles, each representing
# a different county.

# The year of photography is included in the attributes table (PHOTOYR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# All tables have the same core attributes, but some have additional wetland attributes.
# Load Antigonish.shp first since it has the wetland attributes.

# The combination of FOREST_, FOREST_ID, and MAPSHEET is a unique identifier across all counties 
# and should be used in the cas_id.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=NS02
srcFolder="$friDir/NS/$inventoryID/data/inventory/"
fullTargetTableName=$targetFRISchema.ns02

overwrite_option="$overwriteTable"

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Loop through each county shapefile and load
for F in Antigonish Annapolis 'Cape Breton' Colchester Cumberland Digby Guyborough 'Halifax East' 'Halifax West' Hants Inverness Kings Lunenburg Pictou Queens Richmond Shelburne 'St. Marys' Victoria Yarmouth
do
    srcFullPath="$srcFolder$F/forest.shp"

    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
    -nln $fullTargetTableName \
    -nlt PROMOTE_TO_MULTI \
    -sql "SELECT *, '$F' AS src_filename, '$inventoryID' AS inventory_id FROM forest" \
    -progress \
    $gdalLco $gdalOtherOptions \
    $overwrite_option 
	
    overwrite_option="-update -append"
    gdalLco=""
done

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh