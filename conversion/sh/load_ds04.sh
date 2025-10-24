#!/bin/bash -x

# This is a disturbance(bead) shapefile

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=DS04

srcFileName=EC_borealdisturbance_polygonal_2008_2010_FINAL_ALBERS
disturbanceFullPath="$friDir/DS/$inventoryID/data/inventory/Boreal-ecosystem-anthropogenic-disturbance-vector-data-2008-2010/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.${inventoryID,,}

########################################## Process ######################################

### FILE 1 ###
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$disturbanceFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh