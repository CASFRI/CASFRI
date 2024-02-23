#!/bin/bash -x

# This is a disturbance(fire) shapefile

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=DS01

srcFileName=NFDB_poly_20210707
srcFullPath="$friDir/DS/$inventoryID/data/inventory/NFDB_poly/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.${inventoryID,,}

########################################## Process ######################################

### FILE 1 ###
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI -dim XY \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh
