#!/bin/bash -x

# This script loads the Yukon (YK02) into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attribute REF_YEAR

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# The projection of the source data (NAD82/Yukon Albers) is either in a format unknown to PostGIS, 
# or it is incorrectly identified by PostGIS. For this reason the proj4 string of the source data
# projection needs to be defined using the s_srs option.

######################################## Set variables #######################################

source ./common.sh

inventoryID=YT02
srcFileName=YTVegInventory
srcFullPath="$friDir/YT/$inventoryID/data/inventory/YukonVegInventory.gdb"

fullTargetTableName=$targetFRISchema.yt02

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" "$srcFileName" \
-nln $fullTargetTableName $layer_creation_option \
-s_srs '+proj=aea +lat_1=61.66666666666666 +lat_2=68 +lat_0=59 +lon_0=-132.5 +x_0=500000 +y_0=500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs' \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$srcFileName'" \
-progress $overwrite_tab

source ./common_postprocessing.sh