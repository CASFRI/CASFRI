#!/bin/bash -x

# Common setting and command for all bash scripts

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load config variables from local config file
if [ -f $scriptDir/../../config.sh ]; then 
  source $scriptDir/../../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

if [ $overwriteFRI == True ]; then
  overwrite_tab=-overwrite
else 
  overwrite_tab=
fi

export PG_USE_COPY=YES

prjFile="$scriptDir/../canadaAlbersEqualAreaConic.prj"

pg_connection_string="PG:host=$pghost port=$pgport dbname=${pgdbname} user=${pguser} password=${pgpassword}"

layer_creation_options="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry"

other_options="-t_srs $prjFile"

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";
