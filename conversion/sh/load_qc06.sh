#!/bin/bash -x

# This script loads the Quebec (QC06) into PostgreSQL

# The format of the source dataset is a geodatabase
# Name of the db: PEE_MAJ_PROV.gdb
# Name of the table: DDE_20K_PEU_ECOFOR_MAJ_VUE_SE

# We also need to load the table DDE_META_MAJ_VUE from the gdb META_PROV.gdb to recover photoyear.
# Only field geocode, no_prg, ver_prg, an_pro_sou, an_saisie, an_pro_ori is needed. All others field relate to correction, acquisition and production methods. 
# Join field is GEOCODE.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# QC02, QC06 and QC07 all use the same source inventory table. Here we filter the full table to only
# include rows where ver_prg NOT LIKE '%AIPF%'. 
# These rows use the INI04 standard (see issue #429 for details).

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC06
srcFileName_poly=PEE_MAJ_PROV
srcFileName_meta=META_PROV

srcFullPath_poly="$friDir/QC/$inventoryID/data/inventory/$srcFileName_poly.gdb"
srcFullPath_meta="$friDir/QC/$inventoryID/data/inventory/$srcFileName_meta.gdb"

gdbFileName_poly=DDE_20K_PEU_ECOFOR_MAJ_VUE_SE
gdbFileName_meta=DDE_META_MAJ_VUE

fullTargetTableName=$targetFRISchema.qc06
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta

########################################## Process ######################################

# Run ogr2ogr for polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_poly" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName_poly' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg NOT LIKE '%AIPF%'" \
-progress $overwrite_tab

# Run ogr2ogr for meta table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_meta" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-sql "SELECT geocode AS meta_geocode, no_prg AS meta_no_prg, ver_prg AS meta_ver_prg, an_pro_sou, an_saisie, an_pro_ori FROM $gdbFileName_meta WHERE ver_prg NOT LIKE '%AIPF%'" \
-progress $overwrite_tab

# Join META  tables to polygons using the GEOCODE attribute.
# The ogc_fid attributes are no longer unique identifiers after the 
# join so a new ogc_fid is created.
# Original tables are deleted at the end.

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON $tableName_poly (geocode);

-- drop all ogr_fid columns
ALTER TABLE $tableName_poly DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- join qc02_poly, qc02_meta
DROP TABLE IF EXISTS  $fullTargetTableName;
CREATE TABLE  $fullTargetTableName AS
SELECT *
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  on poly.geocode = meta.meta_geocode;
    
--update ogc_fid
ALTER TABLE $fullTargetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $fullTargetTableName ADD COLUMN ogc_fid INT;
UPDATE $fullTargetTableName SET ogc_fid=temp_key;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS temp_key;

--drop extra geocode attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geoc_maj;

--drop tables
DROP TABLE IF EXISTS $tableName_poly;
DROP TABLE IF EXISTS $tableName_meta;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh