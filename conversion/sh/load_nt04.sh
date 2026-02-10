#!/bin/bash -x

# This script loads the NWT FVI forest inventory (NT04) into PostgreSQL.

# The format of the source dataset is a geodatabase with one table.

# Contrary to precedent NT inventories, the year of photography is NOT in 
# the REF_YEAR attribute.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

srcInventoryID=NT04

srcFileName=CASFRI_DataShare_Feb242022
srcFullPath="$friDir/NT/$srcInventoryID/data/inventory/$srcFileName.gdb"

gdbTableName=Buffalo2015_FORCOV
fullTargetTableName=$targetFRISchema.nt04

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Run ogr2ogr to load all table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName' AS src_filename, '$srcInventoryID' AS inventory_id FROM $gdbTableName" \
-progress $overwriteTable

"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql " \
UPDATE $fullTargetTableName 
SET mod1code = mod2code, 
    mod2code = mod1code, 
    mod1ext = mod2ext, 
    mod2ext = mod1ext, 
    mod1year = mod2year, 
    mod2year = mod1year 
WHERE mod1year > mod2year;
";

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh