#!/bin/bash -x

# This script loads the British Columbia VRI forest inventory BC04 into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attributes table (REFERENCE_YEAR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=BC04
srcFileName=VEG_COMP_LYR_R1_POLY
gdbFileName=VEG_COMP_LYR_R1_POLY
srcFullPath="$friDir/BC/$inventoryID/data/inventory/$srcFileName.gdb"

fullTargetTableName=$targetFRISchema.bc04

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options -makevalid \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh


