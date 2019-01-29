#!/bin/bash

# Bash script for loading translation tables into PostgreSQL

# Input tables are format csv

# Two options for loading tables:
	# 1. User can provide an array of csv table paths to be loaded. 
	# 2. Or user can provide the file path to a folder in which case all csv files in the folder are loaded 
	# One or both of these options can be provided.
# If table already exists, loading will fail and move on to the next table. To overwrite existing tables, un-comment the -overwrite line in the ogr2ogr call.

#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################################################################################################################################
# Provide either...

#### 1. #### a manual list of files:
#declare -a file_list=("tables/ab_0006_rules_lyr.csv" "tables/nb_0001_species.csv")

# And/Or

#### 2. #### a folder containing csv's to be loaded:
load_folder="tables/"

# target schema name
target_schema=translation_tables

# gdal folder path
gdal_path="../../../../../../../program files/gdal"
#####################################################################################################################################################################
#####################################################################################################################################################################
#####################################################################################################################################################################

# make schema if it doesn't exist
"$gdal_path/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS $target_schema";

#### 1. ####
# if the file_list variable exists, load the files in the manual list
if [ -n "$file_list" ]; then 
	for i in "${file_list[@]}"
	do
		x=${i##*/} # gets file name with .csv
		tab_name=${x%%.csv} # removes .csv
		schema_tab=$target_schema.$tab_name # combines table name and schema name
		
		# load using ogr
		echo "loading..."$schema_tab
		"$gdal_path/ogr2ogr.exe" \
		-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $i \
		-nln $schema_tab #-overwrite
	done
fi

#### 2. ####
# if the load_folder variable exists, load all files in the folder
if [ -n "$load_folder" ]; then 
	for i in $load_folder/*.csv
	do
		x=${i##*/} # gets file name with .csv
		tab_name=${x%%.csv} # removes .csv
		schema_tab=$target_schema.$tab_name # combines table name and schema name
		
		# load using ogr
		echo "loading..."$schema_tab
		"$gdal_path/ogr2ogr.exe" \
		-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $i \
		-nln $schema_tab #-overwrite
	done
fi
