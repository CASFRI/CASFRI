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
# List of source tables to load and translate with load_all.sh
#################################################################

# Extra, non inventory tables to load (not translate)
photoYearList=(ab_photoyear nl_photoyear nl02_photoyear)

# Inventories are ordered by province and size. All inventories listed 
# in the same invListX variable are loaded in parallel.

# IMPORTANT: Biggest inventories (having the biggest number of rows) should be 
# listed last in their own variable (e.g. invList2) because the next series in 
# the next variable (e.g. invList3) will start only after the last inventory is 
# done loading. This prevents subsequent series from starting before previous 
# ones are finished.

invList1=(BC04 BC08 BC10 BC12 BC13 BC14 BC15 BC16 BC17 BC18 BC11)

invList2=(QC03 QC04 QC08 QC09 QC10 QC05)

invList3=(NL02 PE01 PE02 PE03 PE04 MB06 MB07 MB08 ON02)

invList4=(NB02 NB03 NB04 NB05 NB06 NB07 NB08 SK07)

invList5=(AB29 AB30 NT03 NT04 YT03 YT04 NS01 NS03 NS04)

# CFS only inventory lists
invListCFSOnly=(MB03 MB10 MB11 MB12 MB13)

# ULaval only inventory lists
invListULavalOnly1=(BC04 QC07 NL01 ON01 MB01 MB02 MB04 MB05 NB01 QC02 QC06 QC01)
invListULavalOnly2=(NT01 YT01 YT02 NS01 NS02 PC01 PC02 SK02 SK03 SK04 SK05 SK06 SK01)
invListULavalOnly3=(AB03 AB06 AB07 AB08 AB10 AB11 AB16 AB21 AB24 AB25 AB27 AB31 AB34 AB32)

# Additionnal disturbances (raster and vector, ULaval only)
invListULavalOnly4=(DS01 DS02 DS03 DS04 DS05)

# Merge all inventory lists into a list of list
fullList=(photoYearList invList1 invList2 invList3 invList4 invList5 invListCFSOnly)
#fullList=(photoYearList invList1 invList2 invList3 invList4 invList5 invListULavalOnly1 invListULavalOnly2 invListULavalOnly3 invListULavalOnly4)

# This is for when some inventories failed during the first attempt at loading everything
# Just drop the failed tables from the database, list them here and load_all.sh.
extraList1=()
extraList2=()
#fullList=(extraList1 extraList2)

#################################################################
# GDAL executable folder
#################################################################
# with miniconda
#gdalFolder="C:/ProgramData/Miniconda3/Library/bin/"

# without miniconda
gdalFolder="C:/Program Files/GDAL"

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
# Set to True if you want conversion and translation command windows to stay open after completion
leaveConvShellOpen=False

#################################################################
# Set to true if you want loaded inventories to overwrite already loaded ones
overwriteFRI=True

# Set to true if you want loaded translation tables to overwrite already loaded ones
overwriteTTables=True

#################################################################
# Set some default values
#################################################################

##############################
# Set pgversion if your version of PostgreSQL is different than 13
# pgversion=11

if [ -z ${pgversion+x} ]; then
pgversion=13
fi
pgFolder="/c/PROGRA~1/PostgreSQL/$pgversion"

##############################
# Set bashCmd if your bash command is different from the standard Linux bash command
# bashCmd="/c/program files/git/git-bash.exe"

if [ -z ${bashCmd+x} ]; then
bashCmd="/bin/bash"
fi

