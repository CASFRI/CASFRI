# Conversion
Scripts for converting and loading source files into the database.

## Requirements
* One script per inventory
* One target table in PostgreSQL per inventory
  * If source FRI has multiple files, the script should append them all into the same target table in PostgreSQL
* One script per photo year shapefile when present 
  * **WHAT ABOUT e.g. AB. SAME PHOTO YEAR SHP FOR ALL FRIs // LOAD ONCE OR EVERYTIME?**
* Must add a new column containing the source filename during loading
  * https://gis.stackexchange.com/questions/22175/how-to-add-field-with-filename-when-merging-shapefiles-with-ogr2ogr
  * http://trac.osgeo.org/gdal/wiki/FAQVector

