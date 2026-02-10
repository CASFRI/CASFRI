#!/bin/bash -x

#This script loads the PC01 FRI data into PostgreSQL

#The format of the source dataset is a single ArcInfo Coverage.

# The year of photography is 1968. 

# Load into the pc01 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=PC01
srcFileName=fpoly
srcFullPath=$friDir/PC/$inventoryID/data/inventory/$srcFileName

fullTargetTableName=$targetFRISchema.pc01

# PostgreSQL variables
ogrTab='PAL'

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions $overwriteTable \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $ogrTab" \

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh