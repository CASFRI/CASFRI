#!/bin/bash -x

# Batch file for loading translation tables into PostgreSQL

# Input tables are format csv

# User provides the path to a folder, all csv files in the folder are loaded 

# If overwrite=True any existing tables will be replaced
# If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

#################################### Set variables ######################################

source ../conversion/sh/common.sh

tables_to_load=$@

# Folder containing translation files to be loaded:
load_folders='tables/ tables/lookup ../documentation/'

#####################################################################################################################################################################

# make schema if it doesn't exist
"$gdalFolder/ogrinfo" "$pg_connection_string" -sql "CREATE SCHEMA IF NOT EXISTS $targetTranslationFileSchema";

if [ ${tables_to_load}x == x ]; then
  # load all files in the folder
  for t in $load_folders
  do
    echo $t
    if [ -d "$t" ]; then 
      for i in $t/*.csv
      do
        x=${i##*/} # gets file name with .csv
        tab_name=${x%%.csv} # removes .csv

        # load using ogr
        echo "loading..."$tab_name
        "$gdalFolder/ogr2ogr" \
        -f "PostgreSQL" "$pg_connection_string" $i \
        -nln $targetTranslationFileSchema.$tab_name \
        $overwrite_tab
      done
    fi
  done
else
  # load files passed as parameter
  for g in $tables_to_load
  do
    echo
    echo Loading ${g}.....
    
    tab_name=${g%%.csv} # removes .csv

    "$gdalFolder/ogr2ogr" \
    -f "PostgreSQL" "$pg_connection_string" tables/$g \
    -nln $targetTranslationFileSchema.$tab_name \
    $overwrite_tab
  done
fi
