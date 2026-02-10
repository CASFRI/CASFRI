#!/bin/bash -x

# This script loads the Yukon 40k YVI (YT04) into PostgreSQL

# The format of the source dataset is a gdb

# The year of photography is included in the attribute REF_YEAR

# unique_id is a unique identifier

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable
# in the configuration file.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=YT04
srcFileName=Vegetation_Inventory_40k
srcFullPath="$friDir/YT/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.yt04

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$gdalConnectionString" "$srcFullPath" "$srcFileName" \
-nln $fullTargetTableName $gdalLco $gdalOtherOptions \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id, id as poly_no, OGR_GEOM_AREA as shape_area FROM $srcFileName" \
-progress $overwriteTable

# drop id
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS id;"

#remove comma from land_type and cov_cl_mod values to avoid weird parsing issues with TT_ParseString
"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "UPDATE $fullTargetTableName SET land_type = replace(land_type,',','')"

"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "UPDATE $fullTargetTableName SET cov_cl_mod = replace(cov_cl_mod,',','')"

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh