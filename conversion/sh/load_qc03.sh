#!/bin/bash -x

# This script loads the Quebec (QC03) into PostgreSQL

# The format of the source dataset is a geodatabase comtaining 4 tables:
	# PEE_MAJ_PROV - this is the main table containing the geometries
	# META_MAJ_PROV - this table contains additional attributes required for translation
	# ETAGE_MAJ_PROV - this table contains species info with multiple species per row
	# ESSENCE_MAJ_PROV - this table also contains species info, but with one row per species

# The year of photography is included as the AN_PRO_SOU attribute in the META_MAJ_PROV table

# The PEE_MAJ_PROV, META_MAJ_PROV, and ETAGE_MAJ_PROV tables need to be loaded and joined on the
# GEOC_MAJ unique identifier. We prefer ETAGE_MAJ_PROV over ESSENCE_MAJ_PROV because we need source
# data with one row per polygon. The same info is contained in both tables so only one is needed.

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# QC03, QC04 and QC05 all use the same source inventory table. Here we filter the full table to only
# include rows where no_prg = '3'. These rows use the INI03 standard (see issue #429 for details).

######################################## Set variables #######################################

source ./common.sh

inventoryID=QC03
srcFileName=CARTE_ECO_MAJ_PROV_10
srcFullPath="$friDir/QC/$inventoryID/data/inventory/$srcFileName.gdb"

gdbFileName_poly=PEE_MAJ_PROV
gdbFileName_meta=META_MAJ_PROV
gdbFileName_etage=ETAGE_MAJ_PROV

fullTargetTableName=$targetFRISchema.qc03
tableName_poly=${fullTargetTableName}_poly
tableName_meta=${fullTargetTableName}_meta
tableName_etage=${fullTargetTableName}_etage
tableName_sup=${fullTargetTableName}_etage_sup
tableName_inf=${fullTargetTableName}_etage_inf
tableName_full=${fullTargetTableName}_full

########################################## Process ######################################

# Run ogr2ogr for polygons
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_poly" \
-nln $tableName_poly $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM '$gdbFileName_poly'" \
-progress $overwrite_tab

# Run ogr2ogr for meta table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_meta" \
-nln $tableName_meta $layer_creation_options $other_options \
-progress $overwrite_tab

# Run ogr2ogr for etage table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbFileName_etage" \
-nln $tableName_etage $layer_creation_options $other_options \
-progress $overwrite_tab

# Join META and ETAGE tables to polygons using the GEOC_MAJ attribute.
# The ogc_fid attributes are no longer unique identifiers after the 
# join so a new ogc_fid is created.
# Etage table has 2 rows per polygon in cases with 2 layers. This is
# stored as a SUP and an INF row in the etage column. Need to split these
# into two tables before joining. A SUP table and an INF table. Will 
# therefore be 4 table to join at the end. poly, meta, sup and inf.
# Original tables are deleted at the end.

"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON $tableName_poly (geoc_maj);

-- select all SUP rows
DROP TABLE IF EXISTS $tableName_sup;
CREATE TABLE $tableName_sup AS
SELECT geoc_maj sup_geoc_maj, 
etage sup_etage, 
ty_couv_et sup_ty_couv_et,
densite sup_densite,
hauteur sup_hauteur,
cl_age_et sup_cl_age_et,
eta_ess_pc sup_eta_ess_pc
FROM $tableName_etage 
WHERE etage = 'SUP';

-- select all INF rows
DROP TABLE IF EXISTS $tableName_inf;
CREATE TABLE $tableName_inf AS
SELECT geoc_maj inf_geoc_maj, 
etage inf_etage, 
ty_couv_et inf_ty_couv_et,
densite inf_densite,
hauteur inf_hauteur,
cl_age_et inf_cl_age_et,
eta_ess_pc inf_eta_ess_pc
FROM $tableName_etage 
WHERE etage = 'INF';

-- drop all ogr_fid columns
ALTER TABLE $tableName_poly DROP COLUMN IF EXISTS ogc_fid;
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- drop geometry columns from meta
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS wkb_geometry;

-- rename geoc_maj in meta
ALTER TABLE $tableName_meta RENAME COLUMN geoc_maj TO meta_geoc_maj;

-- join qc03_poly, qc03_meta, qc03_etage_sup, and qc03_etage_inf
DROP TABLE IF EXISTS $tableName_full;
CREATE TABLE $tableName_full AS
SELECT *
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  on poly.geoc_maj = meta.meta_geoc_maj
LEFT join $tableName_sup AS sup 
  on poly.geoc_maj = sup.sup_geoc_maj
LEFT join $tableName_inf AS inf 
  on poly.geoc_maj = inf.inf_geoc_maj;
  
-- filter by third inventory rows
DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
SELECT *
FROM $tableName_full
WHERE no_prg = '3';
  
--update ogc_fid
ALTER TABLE $fullTargetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $fullTargetTableName ADD COLUMN ogc_fid INT;
UPDATE $fullTargetTableName SET ogc_fid=temp_key;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS temp_key;

--drop extra geoc_maj attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS sup_geoc_maj;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS inf_geoc_maj;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geoc_maj;

--drop tables
DROP TABLE IF EXISTS $tableName_poly;
DROP TABLE IF EXISTS $tableName_meta;
DROP TABLE IF EXISTS $tableName_etage;
DROP TABLE IF EXISTS $tableName_sup;
DROP TABLE IF EXISTS $tableName_inf;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh