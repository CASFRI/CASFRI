#!/bin/bash

# This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

# The format of the source dataset is a E00 file

# The year of photography is included as a shapefile. Photo year will be joined to the 
# loaded table in PostgreSQL

# Load into a target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" variable 
# in the configuration file.

# Alberta Gordon Buchanan Tolko FRI was delivered as E00 which can not be loaded 
# successfully without using ESRI tools, so it was coverted to geodatabase in ArcGIS. This script 
# will load the resulting geodatabase.

######################################## Set variables #######################################

# load config variables
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

srcFileName=GB_S21_TWP
srcFullPath="$friDir/AB/SourceDataset/v00.04/CROWNFMA/GordonBuchananTolko/S21_Gordon_Buchanan_Tolko/GB_S21_TWP/gdb/$srcFileName.gdb"

prjFile="./canadaAlbersEqualAreaConic.prj"
fullTargetTableName=$targetFRISchema.ab06

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

########################################## Process ######################################

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";

#Run ogr2ogr
"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" "$srcFullPath" \
-nln $fullTargetTableName \
-t_srs $prjFile \
-sql "SELECT *, '$srcFileName' as src_filename FROM '$srcFileName'" \
-progress $overwrite_tab