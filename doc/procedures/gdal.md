# GDAL/OGR

## Using ogr2ogr


  * ogr2ogr: https://www.gdal.org/ogr2ogr.html
  * Vector formats: https://www.gdal.org/ogr_formats.html

## Windows command line and script

Here a one liner for importing a file geodatabase (BC VRI) into a PostGIS database (db=cas, schema=bc, table=vri). It took about 10-15 minutes to run on the UofA Weasel computer. This line can be run at the command prompt directly or within a batch file (e.g., vri.bat). Just make sure the parameters are appropriate for your machine.

> ogr2ogr -f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" "C:\Users\pvernier\Desktop\GIS Projects\BC\VEG_COMP_LYR_R1_POLY.gdb" -nln bc.vri -overwrite

## Bash shell and script

This needs to be tested and updated.

  * If you installed git on Windows, you automatically have a Bash shell installed. Just right click inside a directory and select "Git Bash Here".
  * Make sure that GDAL and PostgreSQL are in the path.
  * Run bash command or script.

> Example here...
