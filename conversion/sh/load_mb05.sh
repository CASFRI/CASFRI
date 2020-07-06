#!/bin/bash -x

# This script loads the Manitoba FRI forest inventory (MB05) into PostgreSQL

# Both MB05 and MB06 are stored in the same geodatabase table.
# MB05 uses the FRI standard and only includes the rows labelled FRI in the 
# FRI_FLI column. MB06 uses the FLI standard and includes the rows labelled
# FLI in the FRI_FLI column.

# The year of photography is included in the attributes table (YEARPHOTO)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=MB05

srcFileName=MFAGeodatabase
srcFullPath="$friDir/MB/$inventoryID/data/inventory/$srcFileName.gdb"
gdbTableName=MB_FRIFLI_Updatedto2010FINAL_v6
fullTargetTableName=$targetFRISchema.mb05

########################################## Process ######################################

# Run ogr2ogr to load all table

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcTableName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbTableName' WHERE FRI_FLI='FRI'" \
-progress $overwrite_tab

createSQLSpatialIndex=True

source ./common_postprocessing.sh

