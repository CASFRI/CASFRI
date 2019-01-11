# Conversion
Scripts for converting and loading source files into the database.

## Requirements
* One script per inventory
* One target table in PostgreSQL per inventory
  * If source FRI has multiple files, the script should append them all into the same target table in PostgreSQL
* One script and target table per photo year shapefile when present 
* Must add a new column containing the source filename during loading
* Must add spatial index when loading into PostgreSQL (using ogrinfo?).

## Bash
* Scripts should be written in Bash so they are useable on clients Linux systems
* Windows 10 Linux app should facilitate this
 * Use Notepad++ with Linux encoding to write scripts, then run scripts from Git Bash or from Windows 10 Ubuutu app.
* ISSUE: cannot get bash to recognize ogr2ogr.
 * Setting up ogr2ogr in Batch file until I get it working. Will then convert to Bash.


## Useful links
* Adding filename column
 * https://gis.stackexchange.com/questions/22175/how-to-add-field-with-filename-when-merging-shapefiles-with-ogr2ogr
 * http://trac.osgeo.org/gdal/wiki/FAQVector
* Using Windows 10 Ubuuntu app
 * https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/
 * https://www.howtogeek.com/261591/how-to-create-and-run-bash-shell-scripts-on-windows-10/
