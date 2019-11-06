#!/bin/bash -x

#This script loads the AB_0016 FRI data into PostgreSQL

#The format of the source dataset is ArcInfo Coverages divided into mapsheets.

# The FRI data is stored in the "forest" feature for each mapsheet.
# Script loops through each mapsheet and appends to the same target table in PostgreSQL.
# Done using the -append argument. 
# Note that -update is also needed in order to append in PostgreSQL. 
# -addfields is not needed here as columns match in all tables.

# The year of photography is included as a shapefile. 
# Photo year will be joined to the loaded table in PostgreSQL

# Load into the ab16 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=AB16
srcFullPath=$friDir/AB/$inventoryID

fullTargetTableName=$targetFRISchema.ab16

# PostgreSQL variables
ogrTab='PAL'

########################################## Process ######################################

# Loop through all mapsheets.
# For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append
# Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
# Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
# New fields will be added to the right of the table

ogr_options="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry $overwrite_tab"

for F in "$srcFullPath/t"* 
do
  "$gdalFolder/ogr2ogr" \
  -f PostgreSQL "$pg_connection_string" "$F/forest" \
  -nln $fullTargetTableName \
  -t_srs $prjFile \
  -sql "SELECT *, '${F##*/}' as src_filename, '$inventoryID' AS inventory_id, 'FOREST#' as 'forest_id_1', 'FOREST-ID' as 'forest_id_2' FROM $ogrTab" \
  $ogr_options

  ogr_options="-update -append"  
done