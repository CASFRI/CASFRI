#!/bin/bash -x

# This script loads the AB WEYERHAUSER dataset

# The format of the source dataset is a single shapefile named AVI.shp.
# avi_ is a unique id.

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL.

# AB Weyerhauser follow AVi 2.1 standard, although the field struc and struc_val were concatenated in this inventory
# into the filed structure. The loading process split appart those two components in order to follow the ab_AVI translation rules. 

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB24

srcFileName=AVI
srcFullPath="$friDir/AB/$inventoryID/data/inventory/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.ab24

########################################## Process ######################################

"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id, substr(structure,1,1) AS struc, 
		substr(structure,2,1) AS struc_val, substr(u_structur,1,1) AS ustruc, substr(u_structur,2,1) AS ustruc_val 
	FROM $srcFileName WHERE pid <>9000" \
-progress $overwrite_tab

source ./common_postprocessing.sh