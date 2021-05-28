# Sample configuration file for conversion batch files
# Copy this file as config.bat and edit it according to your setup.

pgport=5432
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
pgversion=11

# Target schema where raw csource inventories should be loaded
targetFRISchema=rawfri

# Target schema where translation tables should be loaded
targetTranslationFileSchema=translation

# Extra, non inventory tables to load (not translate)
photoYearList=(ab_photoyear nl_photoyear)

# First series of inventories having more than 2000000 rows. Longest one should be last.
invList1=(BC08 BC10 ON01 QC04 QC05 QC01)

# Second series of inventories having more than 2000000 rows. Longest one should be last.
invList2=(BC11 BC12 QC02 QC06 ON02)

# Inventories having between 500000 and 2000000 rows. Longest one should be last.
invList3=(AB25 AB29 NB01 NB02 NS01 NS02 NS03 SK01 SK04 NL01 MB05)

# Inventories having between 200000 and 500000 rows. Longest one should be last.
invList4=(MB07 NT01 NT03 QC03 YT01 YT02 SK06 SK05)

# Inventories having less than 200000 rows
invList5=(AB03 AB06 AB07 AB08 AB10 AB11 AB16 AB30 MB01 MB02 MB04 MB06 PC01 PC02 PE01 QC07 SK02 SK03 YT03)

# Merge all inventory lists into a list of list
fullList=(invList1 invList2 invList3 invList4 invList5)

friDir=E:/FRIs
gdalFolder="C:/Program Files/GDAL"
gdal_1_11_4=False

# Set to True if you want conversion command windows to stay open after completion
leaveConvShellOpen=False

# Set to true if you want loaded inventories to overwrite already loaded ones
overwriteFRI=True

# Set to true if you want loaded translation tables to overwrite already loaded ones
overwriteTTables=True

if [ ${pgversion}x == x ]; then
pgversion=11
fi
pgFolder="/c/PROGRA~1/PostgreSQL/$pgversion"
