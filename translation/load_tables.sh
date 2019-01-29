#!/bin/bash

# Bash script for loading translation tables into PostgreSQL

# Input tables are format csv

# Provide either a manual list of files:
declare -a file_list=("ab_0006/rules_lyr.csv" "bc_0008/species.csv")

# or, a folder containing csv's to be loaded:
#load_folder="ab_0016/"

# target schema name
target_schema=test

# make schema if it doesn't exist
"../../../../../../../program files/gdal/ogrinfo.exe" PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS test";

# if the load_folder variable exists, load all files in the folder
if [ -n "$load_folder" ]; then 
	for i in $load_folder*
	do
		x=${i##*/} # gets file name with .csv
		tab_name=${x%%.csv} # removes .csv
		schema_tab=$target_schema.$tab_name # combines table name and schema name
		
		# load using ogr
		"../../../../../../../program files/gdal/ogr2ogr.exe" \
		-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $i \
		-nln $schema_tab
	done
fi

# if the file_list variable exists, load the files in the manual list
if [ -n "$file_list" ]; then 
	for i in "${file_list[@]}"
	do
		x=${i##*/} # gets file name with .csv
		tab_name=${x%%.csv} # removes .csv
		schema_tab=$target_schema.$tab_name # combines table name and schema name
		
		# load using ogr
		"../../../../../../../program files/gdal/ogr2ogr.exe" \
		-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" $i \
		-nln $schema_tab
	done
fi