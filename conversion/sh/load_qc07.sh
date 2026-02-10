#!/bin/bash -x

# This script loads the Quebec (QC07) into PostgreSQL.

# The source dataset is a geodatabase.

# Name of the db: PEE_MAJ_PROV.gdb
# Name of the table: DDE_20K_PEU_ECOFOR_MAJ_VUE_SE

# We also load the DDE_META_MAJ_VUE table from META_PROV.gdb in order to recover
# photo years info. Only the GEOCODE, NO_PRG, VER_PRG, AN_PRO_SOU, AN_SAISIE and 
# AN_PRO_ORI attributes are required. All other attributes relate to correction, 
# acquisition and production methods.

# We also load the DDE_ETAGE_NAIPF_MAJ_VUE etage table from ETAGE_NAIPF_PROV.gdb 
# and join it using the GEOCODE attribute.

# All tables are joined using the GEOCODE attribute.

# Load into target schema and table defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI"
# variable in the configuration file.

# QC02, QC06 and QC07 all come from the same FRI. Here we filter the full table
# to rows where VER_PRG is LIKE '%AIPF%'. 
# These rows follow the IPF05 standard (see issue #429 for details).

######################################## Set variables #########################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

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

########################################## Process #############################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Load the polygon table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath_poly" "$gdbFileName_poly" \
-nln $tableName_poly $gdalLco $gdalOtherOptions \
-sql "SELECT *, '$srcFileName_poly' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbFileName_poly WHERE ver_prg LIKE '%AIPF%'" \
-progress $overwriteTable

# Load the attribute table (meta)
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath_meta" "$gdbFileName_meta" \
-nln $tableName_meta $gdalLco $gdalOtherOptions \
-sql "SELECT geocode AS meta_geocode, no_prg AS meta_no_prg, ver_prg AS meta_ver_prg, an_pro_sou, an_saisie, an_pro_ori FROM $gdbFileName_meta WHERE ver_prg LIKE '%AIPF%'" \
-progress $overwriteTable

# Load the etage table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" "$srcFullPath_etage" "$gdbFileName_etage" \
-nln $tableName_etage $gdalLco $gdalOtherOptions \
-progress $overwriteTable

# Join the POLY, META and ETAGE tables using the GEOCODE attribute.
# Only the POLY table's OGC_FID attribute is preserved for inclusion in CAS_ID.
# Etage table has two rows per polygon in cases with two layers. This is stored as a
# SUP and an INF row in the etage attribute. We split these into a SUP table and 
# a INF table before joining in order to preserve a 1 to 1 relationship. There 
# are therefore four tables to join at the end: poly, meta, sup and inf.
# We also split GEOCODE into two columns for use in cas_id.
# Intermediate tables are deleted at the end.

"$gdalFolder/ogrinfo" "$gdalConnectionString" \
-sql "
-- Create an intermediate table with SUP rows
DROP TABLE IF EXISTS $tableName_sup CASCADE;

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

-- Create an intermediate table with INF rows
DROP TABLE IF EXISTS $tableName_inf CASCADE;

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

-- Drop the meta table OGC_FID attribute as we only need the poly table one
ALTER TABLE $tableName_meta DROP COLUMN IF EXISTS ogc_fid;

-- Join qc07_poly, qc07_meta, qc07_etage_sup and qc07_etage_inf into qc07.
CREATE INDEX ON $tableName_meta (meta_geocode);
CREATE INDEX ON $tableName_sup (sup_geocode);
CREATE INDEX ON $tableName_inf (inf_geocode);

-- Drop the table if it exists
DROP TABLE IF EXISTS $fullTargetTableName CASCADE;

-- Join the three tables into the final table
CREATE TABLE $fullTargetTableName AS
SELECT *, substring(replace(poly.geocode, ',','.'), 1, 10) geocode_1_10,
          substring(replace(poly.geocode, ',','.'), 11, 10) geocode_11_20
FROM $tableName_poly AS poly
LEFT join $tableName_meta AS meta 
  ON poly.geocode = meta.meta_geocode
LEFT join $tableName_sup AS sup 
  ON poly.geocode = sup.sup_geocode
LEFT join $tableName_inf AS inf 
  ON poly.geocode = inf.inf_geocode;
    
-- Drop intermediate tables GEOCODE attributes
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS sup_geocode;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS inf_geocode;
ALTER TABLE $fullTargetTableName DROP COLUMN IF EXISTS meta_geocode;

-- Drop intermediate tables
DROP TABLE IF EXISTS $tableName_poly CASCADE;
DROP TABLE IF EXISTS $tableName_meta CASCADE;
DROP TABLE IF EXISTS $tableName_etage CASCADE;
DROP TABLE IF EXISTS $tableName_sup CASCADE;
DROP TABLE IF EXISTS $tableName_inf CASCADE;
"

createSQLSpatialIndex=True

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh