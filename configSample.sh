# Sample configuration file for conversion batch files
# Copy this file as config.bat and edit it according to your setup.

pgport=5432
pghost=localhost
pgdbname=cas
pguser=postgres
pgpassword=postgres
pgversion=11

targetFRISchema=rawfri
targetTranslationFileSchema=translation

friDir=E:/FRIs
gdalFolder="C:/Program Files/GDAL"
gdal_1_11_4=False

overwriteFRI=True
overwriteTTables=True

