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
srcFullPath=$friDir/QC/$inventoryID/data/inventory/
fullTargetTableName=$targetFRISchema.qc01
tempTargetTableName=${fullTargetTableName}_temp
photoFullPath=${srcFullPath}photoyear_per_mapsheet.csv
photoTargetTableName=${fullTargetTableName}_photo

overwrite_option="$overwrite_tab"

# PostgreSQL variables
ogrTab='c08peefo'

########################################## Process ######################################

# Loop through all tiles.
# For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append

for F in "$srcFullPath/"*
do
  if ! [[ ${F##*/} == 11* ]]
    then
    echo '***********************************************************************'
    echo '*********************** Loading '${F##*/}'... ***********************'
    echo ' '

    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$pg_connection_string" "$F/$ogrTab.shp" \
    -nln $tempTargetTableName \
    -sql "SELECT *, '${F##*/}' AS src_filename, '$inventoryID' AS inventory_id FROM $ogrTab" \
    -progress \
    $layer_creation_options $other_options \
    $overwrite_option

    overwrite_option="-update -append"
    layer_creation_options=""
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
    -nln $tempTargetTableName \
    -sql "SELECT *, '${F##*/}' AS src_filename, '$inventoryID' AS inventory_id FROM $ogrTab" \
    -progress \
    $layer_creation_options $other_options \
    $overwrite_option
done

# Load the photo year table to join
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$photoFullPath" \
-nln $photoTargetTableName \
-progress \
$overwrite_option

# Union on geocode to merge polygons that were split by mapsheet grid
# Sum area during union.
# Join photo year table on FCA_NO

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE UNIQUE INDEX IF NOT EXISTS qc01_photoyear_idx
ON $photoFullPath (FCA_NO)

DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
SELECT ST_Union(a.wkb_geometry) a.wkb_geometry, sum(a.superficie) superficie, a.*, b.*
FROM $tempTargetTableName a
LEFT JOIN $photoFullPath b
  ON a.FCA_NO = b.FCA_NO
GROUP BY(geocode);

--DROP TABLE $tempTargetTableName;
--DROP TABLE $photoTargetTableName;
"

source ./common_postprocessing.sh
