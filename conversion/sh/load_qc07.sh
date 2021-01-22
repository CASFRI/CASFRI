#!/bin/bash -x

# This script loads the Quebec (QC07) into PostgreSQL

# The format of the source dataset is a geodatabase
# Name of the db: PEE_MAJ_PROV.gdb
# Name of the table: DDE_20K_PEU_ECOFOR_MAJ_VUE_SE

# We also need to load the table DDE_META_MAJ_VUE from the gdb META_PROV.gdb to recover photoyear.
# Only field geocode, no_prg, ver_prg, an_pro_sou, an_saisie, an_pro_ori is needed. All others field relate to correction, acquisition and production methods. 
# Join field is GEOCODE.

# We also need to join the etage table: DDE_ETAGE_NAIPF_MAJ_VUE from ETAGE_NAIPF_PROV.gdb using join field GEOCODE.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# QC02, QC06 and QC07 all use the same source inventory table. Here we filter the full table to only
# include rows where ver_prg LIKE '%AIPF%'. 
# These rows use the IPF05 standard (see issue #429 for details).

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC07
srcFileName_poly=PEE_MAJ_PROV
srcFileName_meta=META_PROV
srcFileName_etage=ETAGE_NAIPF_PROV

srcFullPath_poly="$friDir/QC/$inventoryID/data/inventory/$srcFileName_poly.gdb"
srcFullPath_meta="$friDir/QC/$inventoryID/data/inventory/$srcFileName_meta.gdb"
srcFullPath_etage="$friDir/QC/$inventoryID/data/inventory/$srcFileName_etage.gdb"

gdbFileName_poly=DDE_20K_PEU_ECOFOR_MAJ_VUE_SE
gdbFileName_meta=DDE_META_MAJ_VUE
gdbFileName_etage=DDE_ETAGE_NAIPF_MAJ_VUE

fullTargetTableName=$targetFRISchema.qc07
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta
tableName_etage=${fullTargetTableName}_etage
tableName_sup=${fullTargetTableName}_etage_sup
tableName_inf=${fullTargetTableName}_etage_inf
tableName_full=${fullTargetTableName}_full

########################################## Process ######################################

# Run ogr2ogr for polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_poly" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName_poly' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg LIKE '%AIPF%'" \
-progress $overwrite_tab

# Run ogr2ogr for meta table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_meta" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-sql "SELECT geocode AS meta_geocode, no_prg AS meta_no_prg, ver_prg AS meta_ver_prg, an_pro_sou, an_saisie, an_pro_ori FROM $gdbFileName_meta WHERE ver_prg LIKE '%AIPF%'" \
-progress $overwrite_tab

# Run ogr2ogr for etage table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath_etage" "$gdbFileName_etage" \
-nln $tableName_etage $layer_creation_options $other_options \
-progress $overwrite_tab

# Join META and ETAGE tables to polygons using the GEOCODE attribute.
# The ogc_fid attributes are no longer unique identifiers after the 
# join so a new ogc_fid is created.
# Etage table has 2 rows per polygon in cases with 2 layers. This is
# stored as a SUP and an INF row in the etage column. Need to split these
# into two tables before joining. A SUP table and an INF table. Will 
# therefore be 4 table to join at the end. poly, meta, sup and inf.
# Original tables are deleted at the end.

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON $tableName_poly (geocode);

-- select all SUP rows
DROP TABLE IF EXISTS $tableName_sup;
CREATE TABLE $tableName_sup AS
SELECT geocode sup_geocode, 
etage sup_etage, 
type_couv sup_type_couv,
cl_dens sup_cl_dens,
cl_haut sup_cl_haut,
cl_age sup_cl_age,
eta_ess_pc sup_eta_ess_pc
FROM $tableName_etage 
WHERE etage = 'SUP';

-- select all INF rows
DROP TABLE IF EXISTS $tableName_inf;
CREATE TABLE $tableName_inf AS
SELECT geocode inf_geocode, 
etage inf_etage, 
type_couv inf_type_couv,
cl_dens inf_cl_dens,
cl_haut inf_cl_haut,
cl_age inf_cl_age,
eta_ess_pc inf_eta_ess_pc
FROM $tableName_etage 
WHERE etage = 'INF';

-- drop all ogc_fid columns
ALTER TABLE $tableName_poly DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- join qc07_poly, qc07_meta, qc07_etage_sup, and qc07_etage_inf
DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
SELECT *
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  on poly.geocode = meta.meta_geocode
LEFT join $tableName_sup AS sup 
  on poly.geocode = sup.sup_geocode
LEFT join $tableName_inf AS inf 
  on poly.geocode = inf.inf_geocode;
    
--update ogc_fid
ALTER TABLE $fullTargetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $fullTargetTableName ADD COLUMN ogc_fid INT;
UPDATE $fullTargetTableName SET ogc_fid=temp_key;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS temp_key;

--drop extra geocode attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS sup_geocode;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS inf_geocode;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geocode;

--drop tables
DROP TABLE IF EXISTS $tableName_poly;
DROP TABLE IF EXISTS $tableName_meta;
DROP TABLE IF EXISTS $tableName_etage;
DROP TABLE IF EXISTS $tableName_sup;
DROP TABLE IF EXISTS $tableName_inf;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh