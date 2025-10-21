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
photoYearList=(ab_photoyear nl_photoyear nl02_photoyear)

# Inventories loading is ordered by province and size.
# IMPORTANT: Longest one should be last because the next series will start only after the last.
invList1=(BC04 BC08 BC10 BC12 BC13 BC11)
invList1CFS=(BC08 BC10 BC12 BC13 BC14 BC15 BC16 BC18 BC11)

invList2=(QC01 QC02 QC03 QC04 QC06 QC07 QC05)
invList2CFS=(QC03 QC04 QC08 QC09 QC10 QC05)

invList3=(NL01 NL02 ON02 ON01)
invList3CFS=(NL02 ON02)

invList4=(PE01 PE02 MB01 MB02 MB04 MB06 MB07 MB08 MB05)
invList4CFS=(PE01 PE02 MB03 MB06 MB07 MB10 MB11 MB12 MB13)

invList5=(PE03 PE04 NB01 NB02 SK02 SK03 SK04 SK05 SK06 SK01)
invList5CFS=(PE03 PE04 NB02 NB03)

invList6=(PC01 PC02 NT01 NT03 YT01 YT02 YT03 NS02 NS03 NS01)
invList6CFS=(NT03 NT04 YT03 YT04 NS03 NS04)

invList7=(AB03 AB06 AB07 AB08 AB10 AB11 AB16 AB21 AB24 AB25 AB27 AB29 AB30 AB31 AB34 AB32)
invList7CFS=(AB29 AB30)

# Additionnal disturbances (raster and vector)
invList8=(DS01 DS02 DS03 DS04 DS05)

# Merge all inventory lists into a list of list
fullList=(photoYearList invList1 invList2 invList3 invList4 invList5 invList6 invList7 invList8)
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

