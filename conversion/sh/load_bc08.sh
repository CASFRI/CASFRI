#!/bin/bash -x

# This script loads the British Columbia VRI forest inventory (BC08) into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attributes table (REFERENCE_YEAR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.


# CURRENTLY SET TO LOAD ENTIRE DATABASE. CAN CHANGE THIS TO FILTER ON INVENTORY_STANDARD_ID 
# IF NEEDED USING -sql "SELECT *, '$fileName' as src_filename FROM '$fileName' WHERE Inventory_Standard_CD='V'"

######################################## Set variables #######################################

source ./common.sh

srcFileName=VEG_COMP_LYR_R1_POLY
srcFullPath="$friDir/BC/BC08/$srcFileName.gdb"

fullTargetTableName=$targetFRISchema.bc08

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_option \
-sql "SELECT *, '$srcFileName' as src_filename FROM '$srcFileName'" \
-progress $overwrite_tab