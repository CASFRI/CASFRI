#!/bin/bash -x

# Common setting and command for all bash scripts

# Load config variables from local config file
if [ -f ../../config.sh ]; then 
  source ../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

prjFile="./../canadaAlbersEqualAreaConic.prj"

pg_connection_string="PG:host=$pghost port=$pgport dbname=${pgdbname} user=${pguser} password=${pgpassword}"

layer_creation_option="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -t_srs $prjFile"

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";
