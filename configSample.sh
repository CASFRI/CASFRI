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
# List of source tables to load and translate
#################################################################

# Extra, non inventory tables to load (not translate)
photoYearList=(ab_photoyear nl_photoyear)

# First series of inventories having more than 2000000 rows. Longest one should be last.
invList1=(BC11 QC05 QC01)
invList1CFS=(BC11 BC16 QC08 QC09 QC10)

# Second series of inventories having more than 2000000 rows. Longest one should be last.
invList2=(BC08 QC06 BC12 BC10)
invList2CFS=(BC08 QC04 QC05 BC12 BC10)

# Third series of inventories having more than 2000000 rows. Longest one should be last.
invList3=(QC04 QC02 ON01 ON02)
invList3CFS=(ON02 BC13 BC14 BC15)

# Inventories having between 800000 and 2000000 rows. Longest one should be last.
invList4=(NB01 NB02 NS01 NS02 NS03 SK01 NL01 MB05)
invList4CFS=(NB02 NB03 NS03 NS04)

# Inventories having between 240000 and 800000 rows. Longest one should be last.
invList5=(AB25 AB29 SK04 NT01 NT03 QC03 YT01 SK05)
invList5CFS=(AB29 NT03 NT04 QC03)

# Inventories having less than 200000 rows
invList6=(MB06 MB07 PC01 PC02 PE01 QC07 SK02 SK03 SK06 YT02 YT03)
invList6CFS=(MB06 MB07 MB10 MB11 MB12 MB13 PE01 PE02 PE03 PE04 YT03 YT04)

# Inventories having less than 200000 rows
invList7=(AB03 AB06 AB07 AB08 AB10 AB11 AB16 AB30 MB01 MB02 MB04)
invList7CFS=(AB30 MB03)

# Additionnal disturbances (raster and vector)
invList8=(DS01 DS02 DS03 DS04 DS05)

# Merge all inventory lists into a list of list
fullList=(invList1 invList2 invList3 invList4 invList5 invList6 invList7 invList8)
#fullList=(invList1CFS invList2CFS invList3CFS invList4CFS invList5 iCFSt6 invList7CFS)

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

