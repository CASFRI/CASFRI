#!/bin/bash

# Shared configuration and checks. Source this file; it never connects to the database.

# Locate configuration relative to this file, not the working directory.
thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Detect the tool layout used for defaults and derived paths.
case "$OSTYPE" in
  msys*|mingw*|cygwin*) casfriPlatform=Windows ;;
  linux*) casfriPlatform=Linux ;;
  *) echo "FAIL: Unsupported platform: $OSTYPE (expected Windows or Linux)." >&2; exit 1 ;;
esac
echo "SET: casfriPlatform=$casfriPlatform"

# Load local configuration into the calling shell; stop if configuration cannot be loaded.
if [ -f "$thisScriptDir/config.sh" ]; then
  if ! source "$thisScriptDir/config.sh"; then
    echo "FAIL: Load config.sh. Could not load configuration successfully." >&2
    exit 1
  fi
  echo "PASS: Load config.sh."
else
  echo "FAIL: Load config.sh. File missing; copy config_sample.sh to config.sh and configure it." >&2
  exit 1
fi

# Apply platform defaults only where configuration has not supplied a value.
pgversion="${pgversion:-13}"
if [ "$casfriPlatform" = Windows ]; then
  miniCondaFolder="${miniCondaFolder:-C:/ProgramData/Miniconda3}"
  gdalFolder="${gdalFolder:-C:/Program Files/GDAL}"
  pythonPath="${pythonPath:-C:/Python311}"
  bashCmd="${bashCmd:-C:/Program Files/Git/git-bash.exe}"
  pgFolder="${pgFolder:-/c/PROGRA~1/PostgreSQL/$pgversion}"
else
  miniCondaFolder="${miniCondaFolder:-$HOME/miniconda3}"
  gdalFolder="${gdalFolder:-/usr/bin}"
  pythonPath="${pythonPath:-/usr/bin}"
  bashCmd="${bashCmd:-/bin/bash}"
  pgFolder="${pgFolder:-/usr}"
fi
psqlCmd="${psqlCmd:-$pgFolder/bin/psql}"
echo "SET: miniCondaFolder=$miniCondaFolder"
echo "SET: bashCmd=$bashCmd"
echo "SET: pgversion=$pgversion"
echo "SET: pgFolder=$pgFolder"
echo "SET: psqlCmd=$psqlCmd"

# Explain which user setting controls a failed derived GDAL path or check.
gdal_config_help() {
  local setting="$1"
  echo "Configure your local config.sh; config_sample.sh lists the available overrides." >&2
  if [ "$useMiniconda" = True ]; then
    echo "Set miniCondaFolder to the environment root containing conda-meta, not its bin or Library folder." >&2
    echo "Examples: miniCondaFolder=\"C:/ProgramData/Miniconda3\" (Windows), miniCondaFolder=\"\$HOME/miniconda3/envs/casfri\" (Linux)." >&2
    echo "GDAL, Python and resource paths are derived from that root; install missing GDAL/PROJ packages in that environment." >&2
  else
    case "$setting" in
      gdalFolder)
        echo "Set gdalFolder to the directory containing ogr2ogr, ogrinfo and gdaltransform, not the installation's parent directory." >&2 ;;
      pythonPath)
        echo "Set pythonPath to the directory containing python.exe (Windows) or python3 (Linux)." >&2 ;;
      GDAL_DATA)
        echo "Set gdalFolder to the correct executable directory, or override GDAL_DATA with the directory containing GDAL resource files." >&2 ;;
      PROJ_DATA)
        echo "Set gdalFolder to the correct executable directory, or override PROJ_DATA with the directory containing a compatible proj.db." >&2 ;;
      GDAL_DRIVER_PATH)
        echo "Set gdalFolder to the correct executable directory, or override GDAL_DRIVER_PATH with the matching GDAL plugin directory." >&2
        echo "On Linux, leave GDAL_DRIVER_PATH unset for automatic discovery; PostgreSQL driver support must still be installed." >&2 ;;
    esac
  fi
}

# Report configuration errors together without exposing passwords.
validate_config() {
  # ${!variable:-} reads a named setting, defaulting to empty if missing.
  local variable condaPython condaOgr errors=0
  # Reject misspelled boolean values.
  for variable in useMiniconda overwriteFRI postProcessing postProcessingOnly; do
    case "${!variable:-}" in
      True|False) printf 'PASS: %s is True or False.\n' "$variable" ;;
      *) printf 'FAIL: %s must be True or False.\n' "$variable" >&2; errors=1 ;;
    esac
  done
  # Require connection and schema settings; no connection is attempted.
  for variable in pghost pgdbname pguser targetFRISchema targetTranslationFileSchema; do
    if [ -z "${!variable:-}" ]; then
      printf 'FAIL: %s must not be empty.\n' "$variable" >&2
      errors=1
    else
      printf 'PASS: %s is configured.\n' "$variable"
    fi
  done
  # Validate the port; 10# treats leading zeroes as decimal, not octal.
  if [[ ! "${pgport:-}" =~ ^[0-9]{1,5}$ ]]; then
    echo "FAIL: pgport must be an integer from 1 to 65535." >&2
    errors=1
  elif (( 10#$pgport < 1 || 10#$pgport > 65535 )); then
    echo "FAIL: pgport must be an integer from 1 to 65535." >&2
    errors=1
  else
    echo "PASS: pgport is an integer from 1 to 65535."
  fi
  # Require at least one parallel job.
  for variable in maxConversionInParallel maxTestsInParallel maxTranslationsInParallel maxGeoHistoryInParallel; do
    if [[ ! "${!variable:-}" =~ ^[1-9][0-9]*$ ]]; then
      printf 'FAIL: %s must be a positive integer without leading zeroes.\n' "$variable" >&2
      errors=1
    else
      printf 'PASS: %s is a positive integer without leading zeroes.\n' "$variable"
    fi
  done
  # Check the source root, not individual inventory files.
  if [ -z "${friDir:-}" ] || [ ! -d "$friDir" ]; then
    echo "FAIL: friDir must point to an existing source-inventory folder." >&2
    errors=1
  else
    echo "PASS: friDir source-inventory folder exists."
  fi
  # Verify the selected Conda environment without activating it.
  if [ "${useMiniconda:-}" = True ]; then
    if [ "$casfriPlatform" = Windows ]; then
      condaPython="${miniCondaFolder:-}/python.exe"
      condaOgr="${miniCondaFolder:-}/Library/bin/ogr2ogr.exe"
    else
      condaPython="${miniCondaFolder:-}/bin/python"
      condaOgr="${miniCondaFolder:-}/bin/ogr2ogr"
    fi
    if [ -z "${miniCondaFolder:-}" ] ||
       [ ! -d "$miniCondaFolder/conda-meta" ] ||
       [ ! -x "$condaPython" ] ||
       [ ! -x "$condaOgr" ]; then
      printf '%s\n' \
        "FAIL: Miniconda environment is missing or incomplete." \
        "Configured folder: ${miniCondaFolder:-not set}" \
        "Expected: conda-meta, $condaPython, and $condaOgr." \
        "Correct miniCondaFolder, install the missing software, or set useMiniconda=False." >&2
      gdal_config_help miniCondaFolder
      errors=1
    else
      echo "PASS: Miniconda environment contains conda-meta, Python and ogr2ogr."
    fi
  elif [ "${useMiniconda:-}" = False ]; then
    # Check standalone installation folders.
    for variable in gdalFolder pythonPath; do
      if [ -z "${!variable:-}" ] || [ ! -d "${!variable}" ]; then
        printf 'FAIL: %s must point to an existing installation folder.\n' "$variable" >&2
        gdal_config_help "$variable"
        errors=1
      else
        printf 'PASS: %s installation folder exists.\n' "$variable"
      fi
    done
  fi
  return "$errors"
}
validate_config || exit 1

# Derive installation paths. Export resources so external GDAL/PROJ tools can read them:
# GDAL_DRIVER_PATH: optional plugins, including PostgreSQL.
# GDAL_DATA: GDAL resource files and schemas.
# PROJ_DATA: proj.db and coordinate-transformation resources.
if [ "$useMiniconda" = True ]; then
  if [ "$casfriPlatform" = Windows ]; then
    gdalFolder="$miniCondaFolder/Library/bin"
    gdalPyFolder="$miniCondaFolder/Scripts"
    pythonPath="$miniCondaFolder"
    export GDAL_DRIVER_PATH="$miniCondaFolder/Library/lib/gdalplugins"
    export GDAL_DATA="$miniCondaFolder/Library/share/gdal"
    export PROJ_DATA="$miniCondaFolder/Library/share/proj"
  else
    gdalFolder="$miniCondaFolder/bin"
    gdalPyFolder="$miniCondaFolder/bin"
    pythonPath="$miniCondaFolder/bin"
    export GDAL_DATA="$miniCondaFolder/share/gdal"
    export PROJ_DATA="$miniCondaFolder/share/proj"
    # Let GDAL discover built-in drivers when no plugin package is installed.
    if [ -d "$miniCondaFolder/lib/gdalplugins" ]; then
      export GDAL_DRIVER_PATH="$miniCondaFolder/lib/gdalplugins"
    else
      unset GDAL_DRIVER_PATH
    fi
  fi
else
  # Preserve standalone overrides; accept legacy PROJ_LIB as a fallback.
  gdalPyFolder="${gdalPyFolder:-$gdalFolder}"
  if [ "$casfriPlatform" = Windows ]; then
    export GDAL_DRIVER_PATH="${GDAL_DRIVER_PATH:-$gdalFolder/gdalplugins}"
    export GDAL_DATA="${GDAL_DATA:-$gdalFolder/gdal-data}"
    export PROJ_DATA="${PROJ_DATA:-${PROJ_LIB:-$gdalFolder/projlib}}"
  else
    export GDAL_DATA="${GDAL_DATA:-${gdalFolder%/bin}/share/gdal}"
    export PROJ_DATA="${PROJ_DATA:-${PROJ_LIB:-${gdalFolder%/bin}/share/proj}}"
    # Linux packages may compile drivers in or use distribution-specific paths.
    if [ -n "${GDAL_DRIVER_PATH:-}" ]; then
      export GDAL_DRIVER_PATH
    fi
  fi
fi

# Report selected paths without dumping configuration or credentials.
echo "SET: gdalFolder=$gdalFolder"
echo "SET: gdalPyFolder=$gdalPyFolder"
echo "SET: pythonPath=$pythonPath"
echo "SET: GDAL_DATA=$GDAL_DATA"
echo "SET: PROJ_DATA=$PROJ_DATA"
echo "SET: GDAL_DRIVER_PATH=${GDAL_DRIVER_PATH:-automatic discovery}"

# Require resource folders and PROJ's coordinate-system database.
validate_gdal_resources() {
  local variable errors=0
  for variable in GDAL_DATA PROJ_DATA GDAL_DRIVER_PATH; do
    if [ "$variable" = GDAL_DRIVER_PATH ] && [ -z "${!variable:-}" ]; then
      echo "SKIP: GDAL plugin directory; using GDAL's built-in driver discovery."
      continue
    fi
    if [ ! -d "${!variable}" ]; then
      printf 'FAIL: %s directory does not exist: %s\n' "$variable" "${!variable}" >&2
      gdal_config_help "$variable"
      errors=1
    else
      printf 'PASS: %s directory exists.\n' "$variable"
    fi
  done
  if [ ! -f "$PROJ_DATA/proj.db" ]; then
    printf 'FAIL: PROJ coordinate-system database is missing: %s/proj.db\n' "$PROJ_DATA" >&2
    gdal_config_help PROJ_DATA
    errors=1
  else
    echo "PASS: PROJ coordinate-system database exists."
  fi
  return "$errors"
}
validate_gdal_resources || exit 1
unset -f validate_gdal_resources

# Executable used by conversion and metadata loaders.
ogrCmd="$gdalFolder/ogr2ogr"
# Raster loaders need the platform's Python executable name.
if [ "$casfriPlatform" = Windows ]; then
  pythonCmd="$pythonPath/python.exe"
elif [ "$useMiniconda" = True ]; then
  pythonCmd="$pythonPath/python"
else
  pythonCmd="$pythonPath/python3"
fi
echo "SET: ogrCmd=$ogrCmd"
echo "SET: pythonCmd=$pythonCmd"
# Avoid conflicting modern and legacy PROJ settings.
unset PROJ_LIB
# Export tool folders for executable/DLL lookup, without duplicate PATH entries.
add_tool_paths() {
  local folder normalized
  for folder in "$gdalPyFolder" "$pythonPath" "$gdalFolder"; do
    [ -n "$folder" ] || continue
    # Normalize C:/... to /c/... without changing the working directory.
    normalized="$(cd "$folder" 2>/dev/null && pwd)" || continue
    # Match complete PATH entries.
    case ":$PATH:" in
      *":$normalized:"*) ;;
      *) PATH="$normalized:$PATH"; echo "SET: PATH prepended with $normalized" ;;
    esac
  done
  export PATH
}
add_tool_paths
unset -f add_tool_paths

# Check selected executables and PostgreSQL driver loading, without connecting.
validate_gdal_tools() {
  local tool formats errors=0
  for tool in ogr2ogr ogrinfo gdaltransform; do
    if ! command -v "$gdalFolder/$tool" >/dev/null 2>&1; then
      printf 'FAIL: GDAL executable is unavailable: %s/%s\n' "$gdalFolder" "$tool" >&2
      gdal_config_help gdalFolder
      errors=1
    else
      printf 'PASS: %s executable is available.\n' "$tool"
    fi
  done
  [ "$errors" -eq 0 ] || return 1
  if ! formats=$("$gdalFolder/ogrinfo" --formats); then
    echo "FAIL: GDAL driver listing failed." >&2
    gdal_config_help GDAL_DRIVER_PATH
    echo "SKIP: PostgreSQL driver availability; driver listing failed." >&2
    return 1
  fi
  echo "PASS: GDAL driver listing."
  if ! grep -Eq '^[[:space:]]*PostgreSQL[[:space:]]' <<< "$formats"; then
    echo "FAIL: GDAL's PostgreSQL driver is unavailable. Check GDAL_DRIVER_PATH and the installed driver package." >&2
    gdal_config_help GDAL_DRIVER_PATH
    return 1
  fi
  echo "PASS: GDAL PostgreSQL driver is available."
}
# Run through the expensive-check guard below.

# Convert the overwrite flag to an ogr2ogr option.
if [ "$overwriteFRI" = True ]; then
  overwriteTable=-overwrite
else 
  overwriteTable=
fi
echo "SET: overwriteTable=${overwriteTable:-no overwrite}"

# Export COPY preference to GDAL's PostgreSQL driver for faster bulk loading.
export PG_USE_COPY=YES
echo "SET: PG_USE_COPY=$PG_USE_COPY"

# Build GDAL/psql connection arguments. Never print or trace the password-bearing string.
gdalConnectionString="PG:host=$pghost port=$pgport dbname=${pgdbname} user=${pguser} password=${pgpassword}"
psqlConnectionString="-d $pgdbname -U $pguser -h $pghost -p $pgport"
echo "SET: gdalConnectionString and psqlConnectionString (values hidden)."

# Avoid fixed numeric precision; standardize geometry and record-ID columns.
gdalLco="-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -lco FID=ogc_fid"
echo "SET: gdalLco=$gdalLco"

# Load geometries in CASFRI's Canada Albers projection.
gdalOtherOptions="-t_srs ESRI:102001"
echo "SET: gdalOtherOptions=$gdalOtherOptions"

# Transform a WGS 84 test point in memory. Check numeric output as well as status.
validate_gdal_projection() {
  local transformed x y z extra
  if ! transformed=$(printf '%s\n' '-115 54' |
      "$gdalFolder/gdaltransform" -s_srs EPSG:4326 $gdalOtherOptions); then
    echo "FAIL: Coordinate transformation to ESRI:102001. Check PROJ_DATA." >&2
    gdal_config_help PROJ_DATA
    return 1
  fi
  read -r x y z extra <<< "$transformed"
  if [[ ! "$x" =~ ^-?[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?$ ]] ||
     [[ ! "$y" =~ ^-?[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?$ ]]; then
    echo "FAIL: Coordinate transformation to ESRI:102001 returned no usable coordinates." >&2
    gdal_config_help PROJ_DATA
    return 1
  fi
  echo "PASS: Coordinate transformation to ESRI:102001 returned numeric coordinates."
}
# Cache successful GDAL checks per process and settings; rerun when either changes.
# Configuration, folder checks and shared variables still refresh on every source.
validate_gdal_expensive_checks() {
  local checkKey
  printf -v checkKey '%q ' "$BASHPID" "$gdalFolder" "${GDAL_DRIVER_PATH:-}" \
    "$GDAL_DATA" "$PROJ_DATA" "$PATH" "$gdalOtherOptions"
  if [ "${CASFRI_GDAL_CHECK_KEY:-}" = "$checkKey" ]; then
    echo "SKIP: GDAL executable, driver and projection checks; already passed for these settings in this process."
    return 0
  fi
  validate_gdal_tools || return 1
  validate_gdal_projection || return 1
  CASFRI_GDAL_CHECK_KEY="$checkKey"
  # Child shells must validate their own setup.
  export -n CASFRI_GDAL_CHECK_KEY
}
validate_gdal_expensive_checks || exit 1
unset -f validate_gdal_expensive_checks validate_gdal_tools validate_gdal_projection gdal_config_help

# Optional child-window behavior: wait for Enter or start interactive Bash.
# ${name,,} makes flag comparisons case-insensitive.
closeMsg="read -p 'Press enter close this shell...';"
echo "SET: closeMsg=$closeMsg"

if [ "${leaveConversionShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseConversionShell="$closeMsg"
  else
    dontCloseConversionShell="exec bash"
  fi
  echo "SET: dontCloseConversionShell=$dontCloseConversionShell"
fi

if [ "${leaveTestShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseTestShell="$closeMsg"
  else
    dontCloseTestShell="exec bash"
  fi
  echo "SET: dontCloseTestShell=$dontCloseTestShell"
fi

if [ "${leaveTranslationShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseTranslationShell="$closeMsg"
  else
    dontCloseTranslationShell="exec bash"
  fi
  echo "SET: dontCloseTranslationShell=$dontCloseTranslationShell"
fi

if [ "${leaveGeoHistoryShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseGeoHistoryShell="$closeMsg"
  else
    dontCloseGeoHistoryShell="exec bash"
  fi
  echo "SET: dontCloseGeoHistoryShell=$dontCloseGeoHistoryShell"
fi

if [ "${leaveCoverageShellOpen,,}" = "true" ]; then
  if [ "${closeWithEnter,,}" = "true" ]; then
    dontCloseCoverageShell="$closeMsg"
  else
    dontCloseCoverageShell="exec bash"
  fi
  echo "SET: dontCloseCoverageShell=$dontCloseCoverageShell"
fi

# Format elapsed seconds as hours, minutes and seconds.
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

# Reset Bash's elapsed-time counter on every source.
SECONDS=0
echo "SET: SECONDS=$SECONDS"
