#!/bin/bash -x

# This script loads the New Brunswick FRI data into PostgreSQL
# This is for holder id 16

# Workflow is to load the first table normally, then append the others
# Use -nlt PROMOTE_TO_MULTI to take care of any mixed single and multi part geometries

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=NB07
fileInventoryID=NB06
NB_subFolder=NB/$fileInventoryID/data/inventory/

srcFilename=NB_Landbase_2024
srcLayerName=LandBase2024v1
srcFileFullPath="$friDir/$NB_subFolder$srcFilename.gdb"
fullTargetTableName=$targetFRISchema.$inventoryID

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFileFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI -nlt CONVERT_TO_LINEAR \
-emptyStrAsNull \
-sql "SELECT *, '$srcFilename' AS src_filename, '$inventoryID' AS inventory_id FROM $srcLayerName WHERE holder = 16" \
-progress $overwriteTable

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "ALTER TABLE $fullTargetTableName ALTER COLUMN stdlab TYPE TEXT; UPDATE $fullTargetTableName SET stdlab = '' WHERE stdlab IS NULL; UPDATE $fullTargetTableName SET slu = NULL WHERE trim(slu) = '';"

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh
