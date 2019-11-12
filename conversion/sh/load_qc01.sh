#!/bin/bash

# This script loads the QC_01 FRI data into PostgreSQL

# The format of the source dataset is shapefiles divided into NTS tile names.

# Each tile name has a different folder, the data are contained in a shapefile
# named c08peefo.shp in each tile folder.

# Script loops through each tile and appends to the same target table in PostgreSQL.
# Done using the -append argument. 
# Note that -update is also needed in order to append in PostgreSQL. 
# -addfields is not needed here as columns match in all tables.

# Sheets starting with '11' do not have all matching attributes. They are loaded as 
# a second step. 

# The year of photography is included as a shapefile. 

# Load into the qc01 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC01
srcFullPath=$friDir/QC/$inventoryID
fullTargetTableName=$targetFRISchema.qc01

# PostgreSQL variables
ogrTab='c08peefo'

########################################## Process ######################################

# Loop through all tiles.
# For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append

ogr_options="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry $overwrite_tab"

for F in "$srcFullPath/"*
do
  if ! [[ ${F##*/} == 11* ]]
    then
    echo '***********************************************************************'
    echo '*********************** Loading '${F##*/}'... ***********************'
    echo ' '

    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$pg_connection_string" "$F/$ogrTab.shp" \
    -nln $fullTargetTableName \
    -t_srs $prjFile \
    -sql "SELECT *, '${F##*/}' as src_filename, '$inventoryID' AS inventory_id FROM $ogrTab" \
    -progress $ogr_options

    ogr_options="-update -append"
  else
    echo '***********************************************************************'
    echo '*********************** Skipping '${F##*/}'... ****************************'
    echo ' '
  fi
done

for F in "$srcFullPath/"11*
do
    echo '***********************************************************************'
    echo '*********************** Loading '${F##*/}'... ***********************'
    echo ' '

    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$pg_connection_string" "$F/$ogrTab.shp" \
    -nln $fullTargetTableName \
    -t_srs $prjFile \
    -sql "SELECT *, '${F##*/}' as src_filename, '$inventoryID' AS inventory_id FROM $ogrTab" \
    -progress $ogr_options
done
