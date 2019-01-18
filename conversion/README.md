# Conversion
The first step in building CASFRI v5 is to convert and load the source data. CASFRI 4 was made using the following steps:
* Conversion - Python and arcpy used to convert source files into shapefiles and csv tables containing attributes.
* Translation - translation rules implimented using Perl scripts
* Loading into PostgreSQL using shp2pgsql
* Topological correction inside database using PostGIS SQL scripts

This is an extract, transform, load procedure (ETL). CASFRI v5 will switch to an extract, load, transform model (ELT). This allows the bulk of the processing to be done inside the database using a single programming language that we already have expertise in. The new model will follow these steps:
* Conversion/loading
* Transformation
* Tological correaction and temporalization

Conversion and loading now happens at the same time and will be implimented using GDAL/OGR. This removes dependancies on Python and Arcpy. 

## Requirements
* One script per inventory
* One target table in PostgreSQL per inventory
  * If source FRI has multiple files, the script should append them all into the same target table in PostgreSQL
* One script and target table per photo year shapefile when present 
* Must add a new column containing the source filename during loading
* Must add spatial index when loading into PostgreSQL
* Must covert projection to Canada Albers Equal Area Conic
* Should be written in bash script so accessible on clients Linux system
 * **ISSUE: cannot get bash to run ogr2ogr correctly. File path issues.**
  * Setting up ogr2ogr in Batch file until I get it working. Will then convert to Bash.

## Bash
* Scripts should be written in Bash so they are useable on clients Linux systems
* Windows 10 Linux app should facilitate this
 * Use Notepad++ with Linux encoding to write scripts, then run scripts from Git Bash or from Windows 10 Ubuutu app.

## ogr2ogr
* Download GDAL 1.11.4 from gisinternals.com. Download core installer and FileGDB plugin.
* Add edit PATH using the tutorial here: https://sandbox.idre.ucla.edu/sandbox/tutorials/installing-gdal-for-windows
* See the scripts and https://www.gdal.org/ogr2ogr.html for functionality. The main components used are:
  * -f: the output format and access to database
  >-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" C:\Temp\VEG_COMP_LYR_R1_POLY\VEG_COMP_LYR_R1_POLY.gdb
  * -nln: name of the new layer
  >-nln bc.BC_0008
  * -t_srs: the required target projection. In our case all tables should be converted to Canada Albers Equal Area Conic.
  >-t_srs C:\Temp\canadaAlbersEqualAreaConic.prj
  * -sql: this allows tables to be edited with sql code. We use this for adding the filename as a column, but it can also be used to filter the table when loading, or any other data manipulations
  >-sql "SELECT *, 'VEG_COMP_LYR_R1_POLY' as src_filename FROM 'VEG_COMP_LYR_R1_POLY'"
  * -append: appends table into existing PostgreSQL table. Needs to be combined with -update when appending to PostgreSQL to ensure table is opened in update mode.
  >-append -update
  * -addfields: used when appending and the source and target table do not have identical fields.
  >-append -update -addfields

## Spatial index
* Spatial indexes are automatically created when loading
 * If spatial indexing is needed however, it can be added by adding the following line to the batch file:
 > ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX BC_0008_spatial_index ON bc.vri_sql_test USING GIST (wkb_geometry);"

## Projection
* Done in ogr2ogr using canadaAlbersEqualAreaConic.prj file saved in the conservsion folder. This file was downloaded from https://epsg.io/102001 using the OGC WKT option. This is the same projection used in cas04 except the prj file used in the python scripts was in the ESRI WKT format. 
  * SRID in PostgreSQL is set to 900914 after transforming. This is because our prj isn't recognized by PostGIS. **Check that CASFRI v4 also gets this SRID.**
  
## File types
#### Geodatabase
* No issues importing .gdb files.

#### Shapefile
* In many cases multi-part and single-part polygons are mixed in same file. This is considered bad practice but doesn't tend to cause issues when working in ArcGIS. This can be seen in ArcGIS by adding a count field and running !Shape!.partCount in the python field calculator. 
* PostGIS is more specific about standardizing input geometries, so errors will occur when importing.
* One solution is to set ` -nlt GEOMTRY` which will allow all the features to be loaded but will maintain a mix of multi- and single-part geometries which could cause issues later on.
* The recommended solution is to set ` -nlt PROMOTE_TO_MULTI` which converts all features to multi-part features to produce a standardized set of geometries in the table.

#### ESRI ArcInfo Workstation interchange file E00
* An old ESRI standrad. Not well documented or understood because ESRI maintains propriotory access to the format. Limits usefulness of open source tools with this format.
* Problems importing AB_0006 E00 file. Doesn't load attributes. Tried converting to Binary Coverage using avcimport then loading Binary Coverage. Still same issue. Will come back to this one.

#### ESRI Binary Coverage

## Useful links
* Adding filename column
 * https://gis.stackexchange.com/questions/22175/how-to-add-field-with-filename-when-merging-shapefiles-with-ogr2ogr
 * http://trac.osgeo.org/gdal/wiki/FAQVector
* Using Windows 10 Ubuuntu app
 * https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/
 * https://www.howtogeek.com/261591/how-to-create-and-run-bash-shell-scripts-on-windows-10/
* Troubleshooting shapefile imports
 * https://gis.stackexchange.com/questions/195172/import-a-shapefile-to-postgis-with-ogr2ogr-gives-unable-to-open-datasource/195223
