:: Sample configuration file for conversion batch files
:: Copy this file as config.bat and edit it according to your setup.

SET pgport=5432
SET pghost=localhost
SET pgdbname=CASFRI
SET pguser=postgres
SET pgpassword=postgres

SET targetFRISchema=rawfri
SET targetTranslationFileSchema=translation

SET friDir=I://Fris
SET gdalFolder=C:\Program Files\GDAL

SET overwriteFRI=True
SET overwriteTTables=True

