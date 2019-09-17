#!/bin/bash

# This script loads the NWT FVI forest inventory (NT02) into PostgreSQL

# The format of the source dataset is a geodatabase, which contains three files that
# need to be joined: geometries, attributes, photo year.

# 719 geometry polygons have FC_ID values of 1000000 and do not have any associated attributes.
# These are slivers are were removed before loading in cas03.

# 2,573 geometry polygons contain duplicate FC_ID values. We assume these are cases where a single
# polygon has been split into multiple polygons during processing.

# 31,617 rows in the attributes table have duplicate FC_IDs. Some of these appear to be errors where
# the same data is duplicated in multiple rows. In other cases the rows have different values.

# 31,547 rows in the attribute table have no FC_ID value.




# The year of photography is included the Inventory_Extent table in the gdb.

# Load into a target table in the schema defined in the config file.

# Load the geometries, attributes, and Inventory_Extent tables separately.
# Then use ogrinfo to join them using the FC_ID attribute and a left join.
# Add a new unique ogc_fid column
# Finally delete the attributes, geometries and Inventory_Extent tables from the database.

# Some polygons have multiple attributes rows in the attributes table, this
# results in duplication of these polygons after the join is complete.
# In some case multiple polygons have the same fc_id value that matches only
# one row in the attributes table. In these cases the attributes are duplicated
# accross each polygon.

# If the tables already exists, they can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

# Load config variables from local config file
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

srcFileName=NT_FORCOV
gdbFileName_geometry=$srcFileName
gdbFileName_attributes=NT_FORCOV_ATT
gdbFileName_photoyear=Inventory_Extents
srcFullPath="$friDir/NT/SourceDataset/v.00.04/NT_FORCOV.gdb"

prjFile="./../canadaAlbersEqualAreaConic.prj"
geometryTableName=$targetFRISchema.nt02geometry
attributeTableName=$targetFRISchema.nt02attributes
photoyearTableName=$targetFRISchema.nt02photoyear
targetTableName=$targetFRISchema.nt02

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

#Run ogr2ogr for geometries
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcFullPath" "$gdbFileName_geometry" \
-nln $geometryTableName \
-t_srs $prjFile \
-sql "SELECT *, '$srcFileName' as src_filename FROM '$gdbFileName_geometry'" \
-progress $overwrite_tab

#Run ogr2ogr for attributes
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcFullPath" "$gdbFileName_attributes" \
-nln $attributeTableName \
-progress $overwrite_tab

#Run ogr2ogr for photo year
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcFullPath" "$gdbFileName_photoyear" \
-nln $photoyearTableName \
-t_srs $prjFile \
-progress $overwrite_tab

# join attributes and photo year tables to geometries
# some columns need to be dropped before joining
# the ogc_fid attributes are no longer unique identifiers after the join so a new ogc_fid is created
# original tables are deleted
"$gdalFolder/ogrinfo" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" \
-sql "
ALTER TABLE $attributeTableName DROP COLUMN ogc_fid;
ALTER TABLE $attributeTableName DROP COLUMN invproj_id;
ALTER TABLE $attributeTableName DROP COLUMN seam_id;
ALTER TABLE $geometryTableName DROP COLUMN ogc_fid;

DROP TABLE IF EXISTS $targetTableName; 
CREATE TABLE $targetTableName AS
SELECT *
FROM $geometryTableName a
LEFT JOIN (SELECT project_id, project_label FROM $photoyearTableName) b ON a.invproj_id=b.project_id
LEFT JOIN $attributeTableName USING (FC_ID);

ALTER TABLE $targetTableName ADD COLUMN temp_key BIGSERIAL PRIMARY KEY;
ALTER TABLE $targetTableName ADD COLUMN ogc_fid INT;
UPDATE $targetTableName SET ogc_fid=temp_key;
ALTER TABLE $targetTableName DROP column temp_key;

DROP TABLE $attributeTableName;
DROP TABLE $photoyearTableName;
DROP TABLE $geometryTableName;
";






