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
photoFullPath=${srcFullPath}photoyear_per_mapsheet.csv

tempTable=${fullTargetTableName}_temp
tempPhoto=${fullTargetTableName}_photo
tempAttributes=${fullTargetTableName}_attributes
tempPolygons=${fullTargetTableName}_polygons

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
    -nln $tempTable \
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
    -nln $tempTable \
    -sql "SELECT *, '${F##*/}' AS src_filename, '$inventoryID' AS inventory_id FROM $ogrTab" \
    -progress \
    $layer_creation_options $other_options \
    $overwrite_option
done

# Load the photo year table to join
"$gdalFolder/ogr2ogr" \
-f PostgreSQL "$pg_connection_string" "$photoFullPath" \
-nln $tempPhoto \
-progress \
$overwrite_option

# Union on geocode to merge polygons that were split by mapsheet grid
# Sum area during union.
# Join photo year table on FCA_NO

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE UNIQUE INDEX IF NOT EXISTS qc01_photoyear_idx
ON $tempPhoto (FCA_NO);

DROP TABLE IF EXISTS $tempAttributes;
CREATE TABLE $tempAttributes AS
SELECT 
  DISTINCT ON(geocode) geocode, ogc_fid, c08peefd_, c08peefd_i, fca_no, pee_dt_mjg, pee_sp_pee, pee_gc_ori, pee_no_maj, prg_no, uco_no_uco, pee_no_auc, pee_dt_mju, toponyme, tco_co,
  ges_co, psc_co, cde_co, cha_co, per_co_ori, per_an_ori, cag_co, per_co_moy, pee_nb_int, per_an_moy, clp_co, ter_co, dsu_co, cdr_co, tec_co_tec,
  pee_dt_mjd, ppr_co_ppr, pee_dh_tra, prb_co_prb, pee_va_app, pee_dc_meo, phc_co_phc, ser_co_ser, pee_dc_aut, tvs_no, no_id, nog, indicatif, pee_dh_cre, pee_dh_maj,
  txl_no_txl, met_no, tme_co, prs_co, prs_an_sou, mst_co_mst, eti_in_gen, src_filename, inventory_id
FROM $tempTable;

DROP TABLE IF EXISTS $tempPolygons;
CREATE TABLE $tempPolygons AS
SELECT geocode, ST_Union(wkb_geometry) wkb_geometry, sum(area) area
FROM $tempTable
GROUP BY(geocode);

DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
SELECT polys.wkb_geometry, polys.area, atts.*, ph.photoyear
FROM $tempPolygons polys
LEFT JOIN $tempAttributes atts
  ON polys.geocode = atts.geocode
LEFT JOIN $tempPhoto ph
  ON atts.fca_no = ph.fca_no;

DROP TABLE $tempTable;
DROP TABLE $tempPhoto;
DROP TABLE $tempPolygons;
DROP TABLE $tempAttributes;
"

source ./common_postprocessing.sh
