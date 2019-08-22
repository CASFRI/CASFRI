#!/bin/bash

# This script loads the British Columbia VRI forest inventory BC09 into PostgreSQL

# The format of the source dataset is a geodatabase

# The year of photography is included in the attributes table (REFERENCE_YEAR)

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

######################################## Set variables #######################################

# Load config variables from local config file
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

srcFileName=VEG_COMP_LYR_R1_POLY
gdbFileName=WHSE_FOREST_VEGETATION_2018_VEG_COMP_LYR_R1_POLY
srcFullPath="$friDir/BC/BC09/$srcFileName.gdb"

prjFile="./../canadaAlbersEqualAreaConic.prj"
fullTargetTableName=$targetFRISchema.bc09

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

#Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:port=$pgport host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword port=$pgport" "$srcFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-sql "SELECT *, '$srcFileName' as src_filename FROM '$gdbFileName'" \
-progress $overwrite_tab