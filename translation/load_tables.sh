#!/bin/bash

# Batch file for loading translation tables into PostgreSQL

# Input tables are format csv

# User provides the path to a folder, all csv files in the folder are loaded 

# If overwrite=True any existing tables will be replaced
# If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

#################################### Set variables ######################################
# Load config variables from local config file
if [ -f ../config.sh ]; then 
  source ../config.sh
else
  echo ERROR: NO config.sh FILE
  exit 1
fi

# Folder containing translation files to be loaded:
load_folders='tables/ tables/lookup ../docs/'

#####################################################################################################################################################################

# do not edit...

# set overwrite argument
if [ $overwriteTTables == True ]; then
  overwrite_tab="-overwrite"
else 
  overwrite_tab=
fi

# make schema if it doesn't exist
"$gdalFolder/ogrinfo" "PG:host=$pghost port=$pgport dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $targetTranslationFileSchema";

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
			-f "PostgreSQL" "PG:host=$pghost port=$pgport dbname=$pgdbname user=$pguser password=$pgpassword" $i \
			-nln $targetTranslationFileSchema.$tab_name \
			-progress $overwrite_tab
			done
	fi
done
