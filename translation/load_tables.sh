#!/bin/bash

# Batch file for loading translation tables into PostgreSQL

# Input tables are format csv

# User provides the path to a folder, all csv files in the folder are loaded 

# If overwrite=True any existing tables will be replaced
# If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

#################################### Set variables ######################################

source ../common.sh

files_to_load=$@

# Folders containing translation files to be loaded
#load_folders=(./ tables/)

#####################################################################################################################################################################

source ../metadata/load_metadata.sh

# Make schema if it doesn't exist
"$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "CREATE SCHEMA IF NOT EXISTS $targetTranslationFileSchema";

if [ ${files_to_load}x == x ]; then
  # Load all files in the folder
  #for load_folder in "${load_folders[@]}"
  #do
  #if [ -d "$load_folder" ]; then
  echo "Loading all CSV files from the \"table\"..."
  for file_name in ./tables/*.csv
  do
    x=${file_name##*/} # gets file name with .csv
    table_name=${x%%.csv} # removes .csv

    echo "Loading $table_name..."
    "$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" ./tables/${table_name}.csv \
    -nln $targetTranslationFileSchema.$table_name $overwriteTable
  done
  #fi
  #done
else
  # Load files passed as parameter
  for file_name in $files_to_load
  do
    table_name=${file_name%%.csv} # removes .csv
    #load_folder=${load_folders[1]} # gets folder path

    # Change source folder only for layer_metadata.csv
    #if [[ "$table_name" == "layer_metadata" ]]; then
    #    load_folder=${load_folders[0]}
    #fi

    echo "Loading $table_name..."

    "$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" ./tables/${table_name}.csv \
    -nln $targetTranslationFileSchema.$table_name $overwriteTable
  done
fi
