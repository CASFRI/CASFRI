#!/bin/bash

# Common setting and command for all bash scripts
echo "######################## Begin common.sh ########################################"

# Determine the path to THIS script
thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load config variables from local config file
if [ -f $thisScriptDir/config.sh ]; then 
  echo Sourcing config.sh file...
  source $thisScriptDir/config.sh
else
  echo ERROR: No config.sh file. Please copy config_sample.sh to config.sh and edit it...
  exit 1
fi

if [ $overwriteFRI == True ]; then
  overwriteTable=-overwrite
else 
  overwriteTable=
fi

export PG_USE_COPY=YES
export PROJ_LIB="$gdalFolder/projlib"

gdalConnectionString="PG:host=$pghost port=$pgport dbname=${pgdbname} user=${pguser} password=${pgpassword}"
psqlConnectionString="-d $pgdbname -U $pguser -h $pghost -p $pgport"

gdalLco="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -lco FID=ogc_fid"

gdalOtherOptions="-t_srs ESRI:102001"

if [ "${leaveConversionShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseConversionShell="read -p 'Press enter close the command window...';"
  else
    dontCloseConversionShell="exec bash"
  fi
fi

if [ "${leaveTestShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseTestShell="read -p 'Press enter close the command window...';"
  else
    dontCloseTestShell="exec bash"
  fi
fi

if [ "${leaveTranslationShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseTranslationShell="read -p 'Press enter close the command window...';"
  else
    dontCloseTranslationShell="exec bash"
  fi
fi

if [ "${leaveGeoHistoryShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseGeoHistoryShell="read -p 'Press enter close the command window...';"
  else
    dontCloseGeoHistoryShell="exec bash"
  fi
fi

if [ "${leaveCoverageShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseCoverageShell="read -p 'Press enter close the command window...';"
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

echo "######################## End common.sh ########################################"
