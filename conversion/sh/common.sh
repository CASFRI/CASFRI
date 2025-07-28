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
export PROJ_LIB="$gdalFolder/projlib"

prjFile="$scriptDir/../canadaAlbersEqualAreaConic.prj"

pg_connection_string="PG:host=$pghost port=$pgport dbname=${pgdbname} user=${pguser} password=${pgpassword}"

layer_creation_options="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -lco FID=ogc_fid"

# other_options="-t_srs ESRI:102001"
other_options="-t_srs $prjFile"

# Compute script duration
pretty_time() {
    local total_seconds=$1
    printf "Script completed in "
    if (( total_seconds >= 3600 )); then
        printf "%dh %dm %ds\n" $((total_seconds/3600)) $(( (total_seconds%3600)/60 )) $((total_seconds%60))
    elif (( total_seconds >= 60 )); then
        printf "%dm %ds\n" $((total_seconds/60)) $((total_seconds%60))
    else
        printf "%ds\n" "$total_seconds"
    fi
}

SECONDS=0

#Create schema if it doesn't exist
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";
