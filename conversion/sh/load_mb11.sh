#!/bin/bash -x

# This script loads the MB FRI 2 forest inventory (MB11) into PostgreSQL

# The format of the source dataset is a geodatabase with one table

# The year of photography is included in the photo_year attribute

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable
# in the configuration file.
######################################## Set variables #######################################

source ./common.sh

srcInventoryID=MB10

srcFileName=FRIFLI_FiveYearReports_2010_2016_2021
srcFullPath="$friDir/MB/$srcInventoryID/data/inventory/$srcFileName.gdb"

destInventoryID=MB11
gdbTableName=MB_FRIFLI_Updatedto2016_v12_20112016Rpt
fullTargetTableName=$targetFRISchema.mb11
MB_subFolder=MB/$inventoryID/data/inventory/

########################################## Process ######################################


# Run ogr2ogr to load all table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $fullTargetTableName $layer_creation_options $other_options \
-nlt PROMOTE_TO_MULTI -nlt CONVERT_TO_LINEAR \
-emptyStrAsNull \
-sql "SELECT *, '$srcFileName' AS src_filename, '$destInventoryID' AS inventory_id, mu_id AS poly_id,
      yearphoto as fri_yr, mu_id as tile, shape_area as area, cc_frifli as crown10,
      productivity as subtype, ht_sum as height, spp_sum as species, origin_sum as year_org
      FROM $gdbTableName WHERE fri_fli = 'FRI'" \
-progress $overwrite_tab

# ~200 features have a period in their species string, remove it
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "UPDATE $fullTargetTableName SET species = REPLACE(species, '.', '') where species like '%.%'";
