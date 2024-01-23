#!/bin/bash -x

# This script loads the British Columbia VRI forest inventory BC13 into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attributes table (REFERENCE_YEAR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=BC13
srcFileName=VRI2002_VEG_COMP_LYR_R1_POLY_FINAL_DELIVERYV4
gdbFileName=VEG_COMP_LYR_R1_POLY_FINALV4
srcFullPath="$friDir/BC/$inventoryID/data/inventory/$srcFileName.gdb"

fullTargetTableName=$targetFRISchema.bc13

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName" \
-progress $overwrite_tab

source ./common_postprocessing.sh


