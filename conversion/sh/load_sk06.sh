#!/bin/bash -x

# This script loads the SK SFVI Mystic dataset (SK06) into PostgreSQL

# The format of the source dataset is a geodatabase
# Source data is is a single table.
# Standard is SFVI but the column names have been changed.

# The year of photography is currently unknown at the polygon level but varies from 1994 - 2005.
# See Issue #317. 2000 will be used for the STAND_PHOTO_YEAR attribute set in layer_metadata.csv

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=SK06
srcFileName=MistikSFVI
fullTargetTableName=$targetFRISchema.sk06

gdbFileName=SFVI

srcFullPath="$friDir/SK/$inventoryID/data/inventory/$srcFileName.gdb"

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$gdbFileName" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName" \
-progress $overwriteTable

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh
