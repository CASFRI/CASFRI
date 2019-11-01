#!/bin/bash -x

# This script loads the NWT FVI forest inventory (NT01) into PostgreSQL

# For NT01 we load a pre-processed shapefile made for CAS03.

# The pre-processing was done as follows:

###
# Northwestern territory inventories are slipt into 2 file: SDW_NT_FORCOV and NT_Forcov_2003
# In SDW_NT_FORCOV inventory, the attributes are found in a .dbf table named SDW_NT_FORCOV_ATT
# Prior to the analysis, we join the attributes with their geometry in the shapefile
# To link the attributes of the shapefile to the .dbf table, we used the field "FC_ID"
# Photoyear also came for that inventory from a separate file
# Instead of intersecting the FI polygons with the photoyear shapefile, we decided to implement the script per PROJECT_ID
#
# Attributes and geometries were already merge into a single shapefile for NT_Forcov_2003
# Photoyear were known for each polygon
# However, PROJECT_ID 16 overlapped between SDW_NT_FORCOV and NT_Forcov_2003. We decided to remove PROJECT_ID 16 from SDW_NT_FORCOV to avoid duplicate
###

######################################## Set variables #######################################

source ./common.sh

srcFileName=NT_FORCOV_update2003
srcFullPath="$friDir/NT/NT01/$srcFileName.shp"

fullTargetTableName=$targetFRISchema.nt01

########################################## Process ######################################

# Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$srcFullPath" \
-nln $fullTargetTableName $layer_creation_option \
-nlt PROMOTE_TO_MULTI \
-sql "SELECT *, '$srcFileName' as src_filename FROM '$srcFileName'" \
-progress $overwrite_tab

