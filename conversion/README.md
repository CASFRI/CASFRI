# Conversion
Scripts for converting and loading source files into the database.

## Requirements
* One script per inventory
* One target table in PostgreSQL per inventory
  * If source FRI has multiple files, the script should append them all into the same target table in PostgreSQL
* One script and target table per photo year shapefile when present 
* Must add a new column containing the source filename during loading
  * https://gis.stackexchange.com/questions/22175/how-to-add-field-with-filename-when-merging-shapefiles-with-ogr2ogr
  * http://trac.osgeo.org/gdal/wiki/FAQVector
* Spatial indexing when loading into PostgreSQL - haven't figured this out yet.

## Bash
* Scripts should be written in Bash so they are useable on clients Linux systems
* Windows 10 Linux app should facilitate this:
  * https://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/
  * https://www.howtogeek.com/261591/how-to-create-and-run-bash-shell-scripts-on-windows-10/
  * Using the Linux text editor accessible through the app should ensure scripts will transfer between our Windows system and the clients Linux system
* Or use Notepad++ with Linuc encoding, then run scripts from Git Bash.
