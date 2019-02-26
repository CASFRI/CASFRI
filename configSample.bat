:: Sample configuration file for conversion batch files
:: Copy this file as config.bat and edit it according to your setup.

SET pghost=localhost
SET pgdbname=CASFRI
SET pguser=postgres
SET pgpassword=postgres

SET targetFRISchema=rawfri
SET targetTranslationFileSchema=translation

SET friDir=I://Fris
SET gdalFolder=C:\Program Files (x86)\GDAL

SET overwriteFRI=TRUE
SET overwriteTTables=TRUE

