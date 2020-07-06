#!/bin/bash -x

# This script loads the WBNP FRI data into PostgreSQL

# The format of the source dataset is a single shapefiles

# The year of photography is 1975 (based on the photo year used in cas04, I can't actually find 
# the photo year recorded in the documentation).

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# The 'class' attribute is a unique identifier

######################################## Set variables #######################################

source ./common.sh

inventoryID=PC02
srcFileName=WBNP_biophysical
srcFullPath="$friDir/PC/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.pc02

########################################## Process ######################################

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$srcFileName'" \
-progress $overwrite_tab

source ./common_postprocessing.sh