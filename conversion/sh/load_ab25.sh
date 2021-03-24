#!/bin/bash -x

# This script loads the AB GOV dataset

# The format of the source dataset is one shapefiles named avi_crown.shp
# Note that the folder also contains two additional files: s7w11_n830.shp and p1_twp.shp
# These were copied from AB01 to cover two map units that were mistakenly dropped from AB25 when it was
# assembled and sent to the CASFRI project in 2012. CASFRI team added these two areas to avoid any gaps
# and dropped AB01 from the dataset.

# poly_num is a unique id.

# The year of photography is included as an attribute (PHOTO_YR).

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB25

srcName=avi_crown
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcName.shp"

fullTargetTableName=$targetFRISchema.ab25

########################################## Process ######################################

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcName' AS src_filename, '$inventoryID' AS inventory_id FROM $srcName" \
-progress $overwrite_tab

source ./common_postprocessing.sh