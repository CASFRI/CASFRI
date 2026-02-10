#!/bin/bash -x

#This script loads the NL01 FRI data into PostgreSQL

#The format of the source dataset is ArcInfo Coverages divided into mapsheets.

# The FRI data is stored in the "lcovxxx" feature for each mapsheet where xxx is 
# the mapsheet number. Script loops through each mapsheet folder, gets the 
# mapsheet number, and appends the lcov table to the target table in PostgreSQL
# using the -append argument.

# Note that -update is also needed in order to append in PostgreSQL. 
# -addfields is not needed here as columns match in all tables.

# Note that many mapsheet folders do not contain any data and will return an error.
# I don't think it is possible to skip these folders without inspecting them using
# the ESRI driver. i.e. using 'if file exists' loop would not work.
# Those mapsheets are: ms17, ms21, ms37-38, ms122-125, ms128-129, ms135-143, 
# ms148-151, etc...

# The year of photography is included as a shapefile. 
# Photo year will be joined to the loaded table in PostgreSQL

# The combination of inventory_id, src_filename, stand_id and lcov_id_1 in the 
# loaded dataset makes a unique identifier that links back to a single row in 
# the source data. These attributes should be used in the cas_id.

# Load into the nl01 target table in the schema defined in the config file.

# If the table already exists, it can be overwritten by setting the "overwriteFRI" 
# variable in the configuration file.

######################################## Set variables #######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../../common.sh

inventoryID=NL01
srcFullPath=$friDir/NL/$inventoryID/data/inventory

fullTargetTableName=$targetFRISchema.nl01

overwrite_option="$overwriteTable"

# PostgreSQL variables
ogrTab=PAL

########################################## Process ######################################

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../pre_conversion.sh

# Loop through all mapsheets.
# For first load, set -lco PRECISION=NO to avoid type errors on import. Remove for following loads.
# Set -overwrite for first load if requested in config
# After first load, remove -overwrite and add -update -append
# Two fields (LCOVxxx# and LCOVxxx-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (lcov_id_1 and lcov_id_2) with valid field names to hold these variables.
# Original columns will be loaded as lcovxxx_ and lcovxxx_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
# New fields will be added to the right of the table
# Load mapsheets from the append_prod and append_prod_lab folders
# Skip the first mapsheet (001) in append_prod. It has no data and we need the first pass through our for loop to load some data. Otherwise the overwrite command never gets called.

for F in "$srcFullPath/append_prod/ms"* "$srcFullPath/append_prod_lab/ms"* 
do
  mapsheet=${F: -3} # last 3 characters of path is the mapsheet number
  
  if [ "$mapsheet" -ne "001" ] ; then

    lcov_column1='LCOV'$mapsheet'#'
    lcov_column2='LCOV'$mapsheet'-ID'
  
    "$gdalFolder/ogr2ogr" \
    -f PostgreSQL "$gdalConnectionString" "$F/lcov$mapsheet" \
    -nln $fullTargetTableName \
    -sql "SELECT *, 'ms$mapsheet' AS src_filename, '$inventoryID' AS inventory_id, '$lcov_column1' AS lcov_id_1, '$lcov_column2' AS lcov_id_2 FROM $ogrTab" \
    $gdalLco $gdalOtherOptions \
    $overwrite_option

    overwrite_option="-update -append"  
    gdalLco="" # layer creation options ignored when appending.
  fi
done
		
thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/../post_conversion.sh