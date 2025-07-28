#!/bin/bash -x

# This script loads the AB TOLKO dataset

# The format of the source dataset is a single shapefile named avi.shp.
# ID_FOREST is a unique id.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL.

# AB TOLKO follow AVI 2.1 standard.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB21

srcFileName=avi
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.ab21

########################################## Process ######################################

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName WHERE pid <> 9999" \
-progress $overwrite_tab

source ./common_postprocessing.sh