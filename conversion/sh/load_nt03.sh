#!/bin/bash -x

# This script loads the NWT FVI forest inventory (NT03) into PostgreSQL

# The format of the source dataset is a geodatabase with one table

# The year of photography is included in the REF_YEAR attribute

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# NT03 has many polygons with duplicate fc_id values.
# These fall into 3 categories:
# Case 1 - Original polygon is intersected by grid. Resulting polygons have same fc_id.
#          Each polygon is assigned it's area after the intersect (i.e. it's true area). 
#          All attributes except area and geometry are duplicated so we need to union the polygons
#          by fc_id and sum the areas.
# Case 2 - Same as case 1 but the area values are for the full polygon before it was split by the grid.
#          In this case we want to union by fc_id but keep the original area.
# Case 3 - Many polygons are duplicated. The geometries and fc_id values are the same, but other attributes
#          are different without much logic. For example many cases have a sp3 percent value, but no other
#          species info. Some rows have DST info which we should maintain. No rows have sp1 info. Many have NFL
#          class. We should the row with the DST info if any is available. Otherwise the row selected should not
#          influence the translation.
######################################## Set variables #######################################

source ./common.sh

inventoryID=NT03

srcFileName=NT_Forcov_
srcFullPath="$friDir/NT/$inventoryID/data/inventory/$srcFileName.gdb"

gdbTableName=NT_FORCOV_ATT
fullTargetTableName=$targetFRISchema.nt03
polyTargetTableName=${fullTargetTableName}_poly

########################################## Process ######################################

# Run ogr2ogr to load all table
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$pg_connection_string" "$srcFullPath" "$gdbTableName" \
-nln $polyTargetTableName $layer_creation_options $other_options \
-sql "SELECT *, '$srcFileName' AS src_filename, '$inventoryID' AS inventory_id FROM $gdbTableName" \
-progress $overwrite_tab

# Fix case 3, then case 2, then case1
"$gdalFolder/ogrinfo" "$pg_connection_string" \
-sql "
DROP TABLE IF EXISTS rawfri.nt03_case3;
CREATE TABLE rawfri.nt03_case3 AS
WITH tab AS (SELECT * FROM ${fullTargetTableName}_poly ORDER BY wkb_geometry, fc_id, areaha, dis1code)
SELECT DISTINCT ON(wkb_geometry, fc_id, areaha) * FROM tab;

-- merge polygons where everything except geometry matches, dont sum area (case 2 in issue)
DROP TABLE IF EXISTS rawfri.nt03_case2;
CREATE TABLE rawfri.nt03_case2 AS
SELECT min(ogc_fid) ogc_fid, ST_Union(wkb_geometry) wkb_geometry, fc_id, areaha, invproj_id, seam_id, landbase, landcov, landpos, typeclas, densitycls, structur, strc_per, mesopos, moisture, sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, height, crownclos, origin, siteclass, wetland, ref_year, landuse, dis1code, dis1ext, dis1year, mintypeclas, minmoist, minsp1, minsp1per, minsp2, minsp2per, minsp3, minsp3per, minsp4, minsp4per, minheight, mincrownclos, minorigin, minsiteclass, si_50, src_filename, inventory_id
FROM rawfri.nt03_case3
GROUP BY(fc_id, areaha, invproj_id, seam_id, landbase, landcov, landpos, typeclas, densitycls, structur, strc_per, mesopos, moisture, sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, height, crownclos, origin, siteclass, wetland, ref_year, landuse, dis1code, dis1ext, dis1year, mintypeclas, minmoist, minsp1, minsp1per, minsp2, minsp2per, minsp3, minsp3per, minsp4, minsp4per, minheight, mincrownclos, minorigin, minsiteclass, si_50, src_filename, inventory_id);
  
-- merge polygons where everything except geometry and areas match, sum areas (case 1 in issue)
DROP TABLE IF EXISTS $fullTargetTableName;
CREATE TABLE $fullTargetTableName AS
SELECT min(ogc_fid) ogc_fid, ST_Union(wkb_geometry) wkb_geometry, fc_id, sum(areaha) areaha, invproj_id, seam_id, landbase, landcov, landpos, typeclas, densitycls, structur, strc_per, mesopos, moisture, sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, height, crownclos, origin, siteclass, wetland, ref_year, landuse, dis1code, dis1ext, dis1year, mintypeclas, minmoist, minsp1, minsp1per, minsp2, minsp2per, minsp3, minsp3per, minsp4, minsp4per, minheight, mincrownclos, minorigin, minsiteclass, si_50, src_filename, inventory_id
FROM rawfri.nt03_case2
GROUP BY(fc_id, invproj_id, seam_id, landbase, landcov, landpos, typeclas, densitycls, structur, strc_per, mesopos, moisture, sp1, sp1_per, sp2, sp2per, sp3, sp3per, sp4, sp4per, height, crownclos, origin, siteclass, wetland, ref_year, landuse, dis1code, dis1ext, dis1year, mintypeclas, minmoist, minsp1, minsp1per, minsp2, minsp2per, minsp3, minsp3per, minsp4, minsp4per, minheight, mincrownclos, minorigin, minsiteclass, si_50, src_filename, inventory_id);

DROP TABLE ${fullTargetTableName}_poly;
DROP TABLE rawfri.nt03_case3;
DROP TABLE rawfri.nt03_case2;
"

createSQLSpatialIndex=True

source ./common_postprocessing.sh