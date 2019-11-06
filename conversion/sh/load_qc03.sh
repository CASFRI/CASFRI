#!/bin/bash -x

# This script loads the Quebec (QC03) into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is in a photo year shapefile that needs to loaded separately

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC03
srcFileName=PEE_MAJ_PROV
srcFullPath="$friDir/QC/$inventoryID/CARTE_ECO_MAJ_PROV_10.gdb"

fullTargetTableName=$targetFRISchema.qc03

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_option \
-sql "SELECT *, '$srcFileName' as src_filename, '$inventoryID' AS inventory_id FROM '$srcFileName'" \
-progress $overwrite_tab