#!/bin/bash

# Batch file for loading translation tables into PostgreSQL

# Input tables are format csv

# User provides the path to a folder, all csv files in the folder are loaded 

# If overwrite=True any existing tables will be replaced
# If overwrite=False existing tables will not be replaced, loop will fail for any tables already loaded

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################################################################################################################################
# Variables
# target schema name
schema=translation_tables

# postgres variables
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres

# gdal folder path (relative path needed if running on Windows)
gdal_path="../../../../../../../program files/gdal"

# overwrite existing tables? True/False
overwrite=True

# a folder containing csv's to be loaded:
load_folder="tables/"


#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################################################################################################################################
# do not edit...

# make schema if it doesn't exist
"$gdal_path/ogrinfo.exe" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" -sql "CREATE SCHEMA IF NOT EXISTS $schema";

# set overwrite argument
if [ $overwrite == True ]; then
  overwrite_tab="-overwrite -progress"
else 
  overwrite_tab="-progress"
fi

# load all files in the folder
if [ -d "$load_folder" ]; then 
	for i in $load_folder/*.csv
	do
		x=${i##*/} # gets file name with .csv
		tab_name=${x%%.csv} # removes .csv
		schema_tab=$schema.$tab_name # combines table name and schema name
		
		# load using ogr
		echo "loading..."$schema_tab
		"$gdal_path/ogr2ogr.exe" \
		-f "PostgreSQL" "PG:host=$pghost dbname=$pgdbname user=$pguser password=$pgpassword" $i \
		-nln $schema_tab \
		$overwrite_tab
	done
else 
  echo "FOLDER DOESN'T EXIST: " $load_folder
fi
