#!/bin/bash -x

# This script loads the SK UTM Government data (SK07) into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attribute SYR

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Mapsheets with values 0 in the CZONE attribute are not part of the inventory and should be 
# removed.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=SK07
srcFileName=UTM_Inventory_SaskSubmission_CASFRI
gdbTableName=UTM_Inventory
srcFullPath="$friDir/SK/$inventoryID/data/inventory/UTM_Inventory_SaskSubmission_CASFRI.gdb"

fullTargetTableName=$targetFRISchema.sk07

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName WHERE CZONE NOT LIKE '0'" \
-progress $overwriteTable

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh