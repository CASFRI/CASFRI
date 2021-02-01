#!/bin/bash -x

# This script loads the Ontario FRI-FIM forest inventory (ON01) into PostgreSQL

# This dataset is split into 48 folders, each representing a different forest management unit.
# Each folder contains a shapefile of geometries, a .mbd file of forest attributes and a .mbd file
# of non forest attributes.

# Append the geometries, forest attributes and non forest attributes into three different tables 
# then join into a final table.

# The year of photography is included in the attributes table (YRUPD) [I copied this info from cas04
# loading script. YRUPD is not in the specifications].

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

source ./common.sh

inventoryID=ON01
srcFolder="$friDir/ON/$inventoryID/data/inventory/"
fullTargetTableName=$targetFRISchema.on01
temp_poly=$targetFRISchema.on01_poly
temp_for=$targetFRISchema.on01_for
temp_nonfor=$targetFRISchema.on01_nonfor

overwrite_option="$overwrite_tab"

if [ $gdal_1_11_4 == True ]; then
  gdal_3_options=
else 
  gdal_3_options="-nlt CONVERT_TO_LINEAR --config OGR_SKIP FileGDB"
fi


########################################## Process ######################################
# 030 040 060 067 120 130 140 150 175 177 178 210 220 230 260 280 350 360 370 375 390 405 415 421 438 444 451 490 509 535 565 601 615 644 680 702 754 780 796 840 851 853 889 898 930 970 993
for F in 012
do
    mapUnit='mu'$F
	poly_file=$srcFolder$mapUnit'/for'$F'.shp'
	poly_tab=for$F
	meta_db=$srcFolder$mapUnit'/shape_data_mu'$F'.mdb'
	for_tab='tbl_forest_'$F
	nonfor_tab='tbl_nonfor_'$F
    
	# load polygons
	#"$gdalFolder/ogr2ogr" \
    #-f PostgreSQL "$pg_connection_string" "$poly_file" \
    #-nln $temp_poly \
    #-nlt PROMOTE_TO_MULTI \
	#-s_srs $prjFile \
    #-progress \
    #-sql "SELECT *, '$mapUnit' AS src_filename, '$inventoryID' AS inventory_id FROM $poly_tab" \
    #$layer_creation_options $other_options \
    #$overwrite_option

    "$gdalFolder/ogrinfo" "PGeo:$meta_db"
    # load for tables
	#"$gdalFolder/ogr2ogr" \
    #-f PostgreSQL "$pg_connection_string" "$meta_db" "$for_tab" \
    #-nln $temp_for\
    #-progress \
    #$layer_creation_options \
    #$overwrite_option

    # load nonfor tables
	#"$gdalFolder/ogr2ogr" \
    #-f PostgreSQL "$pg_connection_string" "$meta_db" "$nonfor_tab" \
    #-nln $temp_nonfor \
    #-progress \
    #$layer_creation_options \
    #$overwrite_option
	
    #overwrite_option="-update -append"
    #layer_creation_options=""
done