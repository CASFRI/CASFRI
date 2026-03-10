# Sample configuration file for conversion batch files
# Copy this file as config.sh and edit it according to your setup.

#################################################################
# Path to base folder of all source inventories
#################################################################
friDir=E:/FRIs

#################################################################
# PostgreSQL configuration
#################################################################
pgport=5432
pghost=localhost
pguser=postgres
pgpassword=postgres

# Target PostgreSQL database
pgdbname=cas

# Target schema where raw source inventories should be loaded
targetFRISchema=rawfri

# Target schema where translation tables should be loaded
targetTranslationFileSchema=translation

#################################################################
# Parallel processing configuration
#################################################################

# Maximum number of conversions to run in parallel
maxConversionInParallel=8

# Maximum number of tests to run in parallel
maxTestsInParallel=30

# Maximum number of translations to run in parallel
maxTranslationsInParallel=36

# Maximum number of translations to run in parallel
maxGeoHistoryInParallel=12

#################################################################
# When True, launch the produce geohistory process and the merge process
# When False, launch the merge process only because the geohistory was completed
#################################################################
createGeoHistory=True

#################################################################
# When True, launch the produce geohistory process and the merge process
# When False, launch the merge process only because the geohistory was completed
#################################################################
geoHistoryInSeparateTables=False

#################################################################
# Set to True if you want conversion, test and/or translation 
# command windows to stay open after completion
leaveConversionShellOpen=False
leaveTestShellOpen=False
leaveTranslationShellOpen=False
leaveGeoHistoryShellOpen=False
leaveCoverageShellOpen=False

closeWithEnter=False # otherwise close by closing the window

#################################################################
# Set to true if you want loaded inventories to overwrite already loaded ones
overwriteFRI=True

# Set to true if you want loaded translation tables to overwrite already loaded ones
overwriteTTables=True

#################################################################
# Set to true if you want to perform post processing (index creation, display statistics, etc...)
postProcessing=True

#################################################################
# List of source tables to load and translate with convert_allall.sh
#
# You can either let convert_all.sh build the list or inventories to 
# load from the inventory_metadata table or define your own custom 
# inventory lists below.
#
# Defining your own list is useful when you want to load only
# certain inventories (e.g. for testing purpose or because they
# failed to load automatically the first time).
#
# The only thing you have to do to let convert_all.sh build the list
# itself is to set which column determines the inventories to 
# load in the inventory_metadata table. Most importantly, you must
# also leave the "fullList" variable undefined below.
#################################################################

# Extra, non inventory tables to load (not translate) in either cases.
photoYearList=(ab_photoyear nl01_photoyear nl02_photoyear)

#----------------------------------------------------------------

# Set which column determines the inventories to load in the 
# inventory_metadata table. Possible values are:
metadataTableLoadingColumn=TRANSLATED_BY_CFS
#metadataTableLoadingColumn=TRANSLATED_BY_ULAVAL

# You can also add your own custom column in the inventory_metadata table if you don't mind editing it.
#metadataTableLoadingColumn=TRANSLATED_BY_ME

#----------------------------------------------------------------
# Otherwise you can define your own list from here.

# Inventories are ordered by jurisdiction (provinces) and size. All inventories
# listed in the same invListX variable are loaded in parallel. Over time, the 
# list defined here might get different than the one in the inventory_metadata.

# IMPORTANT: Biggest inventories (having the biggest number of rows) should be 
# listed last in their own variable (e.g. invList2) because the next series in 
# the next variable (e.g. invList3) will start only after the last inventory is 
# done loading. This prevents subsequent series from starting before previous 
# ones are finished.

invList1=(BC08 BC10 BC12 BC13 BC14 BC15 BC16 BC17 BC18 BC11)
invList2=(QC03 QC04 QC08 QC09 QC10 QC05)
invList3=(NL02 PE01 PE02 PE03 PE04 MB06 MB07 ON02)
invList4=(NB02 NB03 NB04 NB05 NB06 NB07 NB08 SK07)
invList5=(AB29 AB30 NT03 NT04 YT03 YT04 NS03 NS04)

# CFS only inventory lists
invListCFSOnly=(MB03 MB10 MB11 MB12 MB13)

# ULaval only inventory lists
invListULavalOnly1=(BC04 QC07 NL01 ON01 MB01 MB02 MB04 MB05 MB08 NB01 QC02 QC06 QC01)
invListULavalOnly2=(NT01 YT01 YT02 NS01 NS02 PC01 PC02 SK02 SK03 SK04 SK05 SK06 SK01)
invListULavalOnly3=(AB03 AB06 AB07 AB08 AB10 AB11 AB16 AB21 AB24 AB25 AB27 AB31 AB34 AB32)

# Additionnal disturbances (raster and vector, ULaval only)
invListULavalOnly4=(DS01 DS02 DS03 DS04 DS05)

# Merge all inventory lists into a list of list. Leave fullList undefined is you 
# are using the automatic method.
#fullList=("${invList1[@]}" "${invList2[@]}" "${invList3[@]}" "${invList4[@]}" "${invList5[@]}" "${invListCFSOnly[@]}")
#fullList=("${invList1[@]}" "${invList2[@]}" "${invList3[@]}" "${invList4[@]}" "${invList5[@]}" "${invListULavalOnly1[@]}" "${invListULavalOnly2[@]}" "${invListULavalOnly3[@]}" "${invListULavalOnly4[@]}")

#----------------------------------------------------------------

# Here is a shorter list for when some inventories failed during the first
# attempt at loading everything. Just drop the failed tables from the database,
# list them here and execute convert_all.sh. Leave fullList undefined is you 
# are using the automatic method.
extraList1=()
extraList2=()
#fullList=("${extraList1[@]}" "${extraList2[@]}")

#################################################################
# GDAL executables folder
#################################################################
# with miniconda
#gdalFolder="C:/ProgramData/Miniconda3/Library/bin/"

# without miniconda
gdalFolder="C:/Program Files/GDAL"

ogrCmd=$gdalFolder/ogr2ogr

# Set this to true if using GDAL version 1.11.4
gdal_1_11_4=False

#################################################################
# GDAL python executable folder (gdal_calc.py and gdal_polygonize.py)
#################################################################
# with miniconda
#gdalPyFolder="C:/ProgramData/Miniconda3/Scripts/"

# without miniconda
gdalPyFolder="$gdalFolder"

#################################################################
# Python installation folder
#################################################################
# with miniconda
#pythonPath="C:/ProgramData/miniconda3"

# without miniconda
pythonPath="C:/Python311"

#################################################################
# Bash executable path
#################################################################
bashCmd="C:/Program Files/Git/git-bash.exe"

#################################################################
# Set some default values
#################################################################

##############################
# Set pgversion if your version of PostgreSQL is different than 13
# pgversion=11

if ! [[ -v pgversion ]]; then
  pgversion=13
fi
pgFolder="/c/PROGRA~1/PostgreSQL/$pgversion"
psqlCmd="$pgFolder/bin/psql"

##############################
# Set bashCmd if your bash command is different from the standard Linux bash command
if ! [[ -v bashCmd ]]; then
  bashCmd="/bin/bash"
fi

