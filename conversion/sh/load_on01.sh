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
tempPoly=$targetFRISchema.on01_poly
tempForAtt=$targetFRISchema.on01_forest_att
tempNonForAtt=$targetFRISchema.on01_nonfor_att

overwrite_option="$overwrite_tab"

########################################## Process ######################################
# drop any temp tables from previous loads
"$gdalFolder\ogrinfo" "$pg_connection_string" \
-sql "
DROP TABLE IF EXISTS $tempPoly;
DROP TABLE IF EXISTS $tempForAtt;
DROP TABLE IF EXISTS $tempNonForAtt;
"

# Load 130 first to establish the right format for the area field
for F in 130 012 030 040 060 067 120 140 150 175 177 178 210 220 230 260 280 350 360 370 375 390 405 415 421 438 444 451 490 509 535 565 601 615 644 680 702 754 780 796 840 851 853 889 898 930 970 993
do
  shpName='mu'$F'l'
  mdbName='shape_data_mu'$F'.mdb'
  mdbForTableName='tbl_forest_'$F
  mdbNonForTableName='tbl_nonfor_'$F

# Load shapefile
  "$gdalFolder/ogr2ogr" \
  -f PostgreSQL "$pg_connection_string" "$srcFolder/mu$F/$shpName.shp" \
  -nln $tempPoly \
  -nlt PROMOTE_TO_MULTI \
  -progress \
  -sql "SELECT *, '$F' AS src_filename, '$inventoryID' AS inventory_id FROM $shpName" \
  $layer_creation_options $other_options \
  $overwrite_option

# Load forest info from the .mdb using the ODBC driver
  "$gdalFolder/ogr2ogr" \
  -f PostgreSQL "$pg_connection_string" "$srcFolder/mu$F/$mdbName" \
  -nln $tempForAtt\
  -progress \
  -sql "SELECT *, Switch(area = 0, ha, area <> 0, area) AS fixed_area, '$F' AS src_filename, '$inventoryID' AS inventory_id FROM $mdbForTableName" \
  $overwrite_option

# Load non forest info from the .mdb using the ODBC driver
  "$gdalFolder/ogr2ogr" \
  -f PostgreSQL "$pg_connection_string" "$srcFolder/mu$F/$mdbName" \
  -nln $tempNonForAtt \
  -progress \
  -sql "SELECT *, Switch(area = 0, ha, area <> 0, area) AS fixed_area, '$F' AS src_filename, '$inventoryID' AS inventory_id FROM $mdbNonForTableName" \
  $layer_creation_options \
  $overwrite_option

  overwrite_option="-update -append -addfields"
  layer_creation_options=""
done



"$gdalFolder\ogrinfo" "$pg_connection_string" \
-sql "
CREATE INDEX ON $tempForAtt USING btree(src_filename);
CREATE INDEX ON $tempForAtt USING btree(recno);
CREATE INDEX ON $tempNonForAtt USING btree(src_filename);
CREATE INDEX ON $tempNonForAtt USING btree(recno);
DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
WITH non_forested_distinct AS (
  SELECT DISTINCT ON (src_filename, recno) *
  FROM $tempNonForAtt
  ORDER BY src_filename, recno, fixed_area DESC
)
SELECT a.ogc_fid, a.area_meter, a.perimeter_, a.polyid, a.polytype, a.owner, a.age, a.hectares,
       a.recno, a.provid, a.x, a.y, a.src_filename, a.inventory_id, a.wkb_geometry, a.area, a.perimeter,
       a.type mutype, a.polyid_1, a.mnrcode, a.geognum,
       coalesce(b.fixed_area, c.fixed_area) fixed_area,
       coalesce(b.site_region, c.site_region) site_region,
       coalesce(b.type::numeric, c.type) AS type,
       coalesce(b.mnr_code, c.mnr_code) mnr_code,
       coalesce(b.ha, c.ha) ha,
       coalesce(b.forreg, c.forreg) forreg,
       coalesce(b.sitedist, c.sitedist) sitedist,
       coalesce(b.watershed, c.watershed) watershed,
       b.source, b.avail, b.formod, b.access1, b.devstage, b.mgmtcon1, b.agestr, b.silvsys,
       b.wg, b.ht, b.stkg, b.sc, b.yrdep, b.deptype, b.yrupd, b.yrorg, b.ecosite1, b.ecopct1, b.ags, b.ugs,
       b.ags_class, b.ugs_class, b.uspcomp, b.uyrorg, b.ustkg, b.usc, b.submu, b.fu, b.planfu, b.defer,
       b.mgmtstg, b.si, b.sisrc, b.sfmmkey, b.udf1, b.udf2, b.udf3, b.udf4, b.sfu, b.pft, b.hu, b.ecosite_calc,
       b.ecosite_seral, b.afu, b.cfu1, b.cfu2, b.slope_avg, b.slope_diff, b.dtm_avg, b.dtm_diff, b.oli_prim_mat,
       b.oli_exbed, b.oli_texture, b.oli_moisture, b.oli_depth, b.noeg_geomorph, b.noeg_landform, b.noeg_material,
       b.noeg_relief, b.noeg_drainage, b.noeg_variety, b.error, b.errorsp, b.badrec,
       b.fixed, b.spcomp, b.pw, b.pr, b.pj, b.sb, b.sw, b.bf, b.ce, b.la, b.he, b.po, b.pl, b.pb, b.bw, b.yb, b.mh,
       b.ms, b.ab, b.aw, b.bd, b.be, b.ch, b.ew, b.iw, b.qr, b.ob, b.ow, b.oh, b.oc, b.bugdep, b.bugdepgtv,
       b.bugdepcai, b.distrd, b.distrds, b.distrdp
FROM (rawfri.on01_poly a
LEFT JOIN $tempForAtt b ON (a.src_filename = b.src_filename AND a.recno::int = b.recno::int))
LEFT JOIN non_forested_distinct c ON (a.src_filename = c.src_filename AND a.recno::int = c.recno::int);
DROP TABLE IF EXISTS $tempPoly;
DROP TABLE IF EXISTS $tempForAtt;
DROP TABLE IF EXISTS $tempNonForAtt;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh