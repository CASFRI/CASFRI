#!/bin/bash

# Common setting and command for all bash scripts
#echo "######################## Begin common.sh ########################################"

# Determine the path to THIS script
thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load config variables from local config file
if [ -f $thisScriptDir/config.sh ]; then 
  #echo Sourcing config.sh file...
  source $thisScriptDir/config.sh
else
  echo ERROR: No config.sh file. Please copy config_sample.sh to config.sh and edit it...
  exit 1
fi

# Derive tool paths from the installation selected in config.sh.
# Export makes variables available to external programs and child shells;
# ordinary shell variables are visible only within the current shell.
# GDAL_DRIVER_PATH: folder containing optional GDAL driver plugins, including
# the PostgreSQL driver. GDAL reads it to discover those plugins.
# GDAL_DATA: folder containing GDAL resource files (schemas and other data).
# PROJ_DATA: folder containing PROJ's proj.db coordinate-system database and
# transformation resources, used by GDAL when reprojecting geometries.
# These three variables must be exported because GDAL/PROJ read them from
# the process environment, not from Bash variables or config.sh directly.
if [ "${useMiniconda:-False}" = True ]; then
  if [ -z "${miniCondaFolder:-}" ] ||
     [ ! -d "$miniCondaFolder/conda-meta" ] ||
     [ ! -f "$miniCondaFolder/python.exe" ] ||
     [ ! -f "$miniCondaFolder/Library/bin/ogr2ogr.exe" ]; then
    printf '%s\n' \
      "ERROR: useMiniconda=True, but the configured environment is missing or incomplete." \
      "Configured folder: ${miniCondaFolder:-not set}" \
      "Expected: conda-meta, python.exe, and Library/bin/ogr2ogr.exe." \
      "Correct miniCondaFolder, install the missing software, or set useMiniconda=False." >&2
    exit 1
  fi

  gdalFolder="$miniCondaFolder/Library/bin"
  gdalPyFolder="$miniCondaFolder/Scripts"
  pythonPath="$miniCondaFolder"
  export GDAL_DRIVER_PATH="$miniCondaFolder/Library/lib/gdalplugins"
  export GDAL_DATA="$miniCondaFolder/Library/share/gdal"
  export PROJ_DATA="$miniCondaFolder/Library/share/proj"
else
  gdalPyFolder="${gdalPyFolder:-$gdalFolder}"
  export GDAL_DRIVER_PATH="${GDAL_DRIVER_PATH:-$gdalFolder/gdalplugins}"
  export GDAL_DATA="${GDAL_DATA:-$gdalFolder/gdal-data}"
  export PROJ_DATA="${PROJ_DATA:-${PROJ_LIB:-$gdalFolder/projlib}}"
fi

ogrCmd="$gdalFolder/ogr2ogr"
# PROJ_DATA replaces the legacy variable and prevents conflicting paths.
unset PROJ_LIB
# PATH controls executable lookup and, on Windows, helps locate companion
# DLLs. Export it so child programs and shells inherit these tool folders.
export PATH="$gdalFolder:$pythonPath:$gdalPyFolder:$PATH"

if [ $overwriteFRI == True ]; then
  overwriteTable=-overwrite
else 
  overwriteTable=
fi

# Ask GDAL's PostgreSQL driver to use COPY for faster bulk loading when
# possible. Export it because the driver runs inside the external GDAL process.
export PG_USE_COPY=YES

gdalConnectionString="PG:host=$pghost port=$pgport dbname=${pgdbname} user=${pguser} password=${pgpassword}"
psqlConnectionString="-d $pgdbname -U $pguser -h $pghost -p $pgport"

gdalLco="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -lco FID=ogc_fid"

gdalOtherOptions="-t_srs ESRI:102001"

closeMsg="read -p 'Press enter close this shell...';"

if [ "${leaveConversionShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseConversionShell="$closeMsg"
  else
    dontCloseConversionShell="exec bash"
  fi
fi

if [ "${leaveTestShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseTestShell="$closeMsg"
  else
    dontCloseTestShell="exec bash"
  fi
fi

if [ "${leaveTranslationShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseTranslationShell="$closeMsg"
  else
    dontCloseTranslationShell="exec bash"
  fi
fi

if [ "${leaveGeoHistoryShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseGeoHistoryShell="$closeMsg"
  else
    dontCloseGeoHistoryShell="exec bash"
  fi
fi

if [ "${leaveCoverageShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseCoverageShell="$closeMsg"
  else
    dontCloseCoverageShell="exec bash"
  fi
fi

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

#echo "######################## End common.sh ########################################"
