#!/bin/bash -x

# This script loads the Ontario FIM forest inventory (ON02) into PostgreSQL

# This dataset is split into 41 tables in a single geodatabase, each representing
# a different forest management unit.

# The year of photography is included in the attributes table (YRSOURCE)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# All tables have the same core attributes, but many have additional attributes.
# Load all tables using -addfields. This will add all columns from all tables.
# Then use -sql query to select only the columns specified in the FIM documentation. 
# Drop any rows with null polyid using the sql statement.

######################################## Set variables #######################################

source ./common.sh

inventoryID=ON02
srcFileName=ON_FRI_forest
srcFullPath="$friDir/ON/$inventoryID/data/inventory/$srcFileName.gdb"
fullTargetTableName=$targetFRISchema.on02
temp_table=$targetFRISchema.on02_all_attributes

overwrite_option="$overwrite_tab"

if [ $gdal_1_11_4 == True ]; then
  gdal_3_options=
else 
  gdal_3_options="-nlt CONVERT_TO_LINEAR --config OGR_SKIP FileGDB"
fi


########################################## Process ######################################

for F in AL_615_2D AP_451_2D ARF_110_2D BA_220_2D BSF_030_2D CF_175_2D CL_noFMU_2D CLF_NBI_2D CR_2D DF_535_2D DRM_177_2D ER_230_2D FSF_360_2D GCF_438_2D HF_601_2D KF_644_2D LF_796_2D LS_702_2D LSP_2D MAF_140_2D MB_851_067_370_2D MF_565_2D ML_2D NAG_390_2D NF_754_2D NSF_630_2D OF_796_2D PA_NA_2D PF_421_2D QPP_2D RL_840_2D SF_210_2D SPF_853_2D SUF_889_2D TF_898_2D TL_120_2D W_130_2D WAB_2D WJ_490_2D WRF_060_2D
do
    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$pg_connection_string" "$srcFullPath" \
    -nln $temp_table\
    -nlt PROMOTE_TO_MULTI \
    -progress \
    -sql "SELECT *, '$F' AS src_filename, '$inventoryID' AS inventory_id FROM $F" \
    $layer_creation_options $other_options \
    $overwrite_option

    overwrite_option="-update -append -addfields"
    layer_creation_options=""
done

# TMF_280_2D is missing PERIMETER value but has Shape_Leng we can use instead. Make PERIMETER attribute during loading.
for F in TMF_280_2D
do
    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$pg_connection_string" "$srcFullPath" \
    -nln $temp_table \
    -nlt PROMOTE_TO_MULTI \
    -progress \
    -sql "SELECT *, '$F' AS src_filename, '$inventoryID' AS inventory_id, shape_leng AS perimeter FROM $F" \
    $layer_creation_options $other_options \
    $overwrite_option
done

# Use sql to select inventory columns for final on02 table
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
DROP TABLE IF EXISTS $fullTargetTableName; 
CREATE TABLE $fullTargetTableName AS
SELECT wkb_geometry, ogc_fid, inventory_id, src_filename, area, perimeter, fmfobjid, polyid, polytype, yrsource, source, formod, devstage, yrdep, deptype,
       oyrorg, ospcomp, oleadspc, oage, oht, occlo, osi, osc, uyrorg, uspcomp, uleadspc, uage, uht, ucclo, usi, usc,
       incidspc, vert, horiz, pri_eco, sec_eco, access1, access2, mgmtcon1, mgmtcon2, mgmtcon3, verdate, sensitiv, bed
FROM $temp_table
WHERE polyid IS NOT NULL;

DROP TABLE IF EXISTS $temp_table;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh