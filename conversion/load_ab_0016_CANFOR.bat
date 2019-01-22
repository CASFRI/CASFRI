::This script loads the AB_0016 FRI data into PostgreSQL

::The format of the source dataset is ArcInfo Coverages divided into mapsheets.
::The FRI data is stored in the "forest/polygon" feature for each mapsheet.
::Script needs to loop through each mapsheet and append to the same target table in PostgreSQL.
::This can be done using the -append argument. Note that -update also needed in order to append in PostgreSQL. -addfields not needed as columns match in all tables.

::Load into a target table in a schema named 'ab'. 

::Workflow as recommended here: https://trac.osgeo.org/gdal/wiki/FAQVector#FAQ-Vector
::load the first table normally, then delete all the data. This serves as a template
::then loop through all Coverages and append to the template table

::Variables:
::srcF - Source file location
::fileName - Filename field. This will be added as a column called src_filename and later used to create the cas_id field
::trgtT - Target table name in PostgreSQL
::prjF - Target projection - Canada Albers Equal Area Conic. %~dp0 fetches the directory that contains the batch file. Use this to point to the prj file stored with the scripts

::Create schema if it doesn't exist
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE SCHEMA IF NOT EXISTS ab";

SET batchDir=%~dp0
SET prjF="%batchDir%canadaAlbersEqualAreaConic.prj"
SET trgtT=ab.AB_0016

::1.::make table template
::load first mapsheet. Using precision=NO because the FOREST-ID field is set to NUMERIC(5,0) when imported but data have 6 digits.
ogr2ogr ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" C:\Temp\Canfor_temp\t059r04m6\forest ^
-nln %trgtT% ^
-t_srs %prjF% ^
-lco precision=NO ^
-sql "SELECT *, '%fileName%' as src_filename FROM 'PAL'"

::delete rows but not table
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "delete  from %trgtT%"

::Two fields (FOREST# and FOREST-ID) don't load correctly because field names are not valid in PostgreSQL. Create two new columns (forest_id_1 and forest_id_2) with valid field names to hold these variables.
::Original columns will be loaded as forest_ and forest_id, they will be NULL because ogr2ogr cannot append the values from the invalid field names.
::New fields will be added to the right of the table
::Using ogrinfo - add two new integer columns to hold the FOREST# and FOREST-ID integers. Name them forest_id_1 and forest_id_2.
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "ALTER TABLE %trgtT% ADD forest_id_1 integer;"
ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "ALTER TABLE %trgtT% ADD forest_id_2 integer;"

::2::loop through all mapsheets. Note - can't easily set variables inside loops.
:: /D is used for accessing folder paths in for loop. Only grabs folders beginning with t.
:: -sql statement adds new columns with the values of the invalid columns
for /D %%F IN (C:\Temp\Canfor\t*) DO (
	ogr2ogr ^
	-update -append ^
	-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %%F\forest ^
	-nln %trgtT% ^
	-t_srs %prjF% ^
	-sql "SELECT *, '%%~nF' as src_filename, 'FOREST#' as 'forest_id_1', 'FOREST-ID' as 'forest_id_2' FROM 'PAL'"
)


