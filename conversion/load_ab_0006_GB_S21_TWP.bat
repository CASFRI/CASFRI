::This script loads the Alberta Gordon Buchanan Tolko FRI into PostgreSQL

::The format of the source dataset is a single .E00 file

::The year of photography is included as a shapefile. Photo year will be joined to the loaded table in PostgreSQL

::Load into a target table in a schema named 'ab'. Schema should be created manually in PostgreSQL before loading.



::Test - convert e00 to Binary Coverage using avcimport.exe downloaded from http://avce00.maptools.org/avce00/index.html. This is reported to be more reliable as gdal does not always do a good job of converting topology.
:: Also creates the attributes table whihc was getting lost when importing e00 directly.
::C:\Temp\avcimport.exe C:\Temp\GB_S21_TWP.E00 C:\Temp\GB_S21_TWP_avcimport\GB_S21_TWP_c
::C:\Temp\avcimport.exe C:\Temp\Porc_mountain.e00 C:\Temp\porcupine_cov\porc_cov TRIED A DIFFERENT E00. DIDN't WORK EITHER.
::Still doesn't load properly into postgis

::Source file location
SET srcF=C:\Temp\GB_S21_TWP_avcimport\GB_S21_TWP_c

::Filename field. This will be added as a column called src_filename and later used to create the cas_id field
SET fileName=GB_S21_TWP

::Target table name
SET trgtT=ab.AB_0006

::Target projection - Canada Albers Equal Area Conic
:: %~dp0 fetches the directory that contains the batch file. Use this to point to the prj file stored with the scripts
SET batchDir=%~dp0
SET prjF="%batchDir%canadaAlbersEqualAreaConic.prj"

::Run ogr2ogr
ogr2ogr ^
-f "PostgreSQL" "PG:host=localhost dbname=cas user=postgres password=postgres" %srcF% ^
-nln %trgtT%
-t_srs %prjF%


::ADDING FILENAME DOESNT'T WORK. FIX.
::-sql "SELECT *, '%fileName%' as src_filename FROM '%fileName%'"

::Attributes not loaded. Fix. ESRI tool splits into shp and .att attributes. If not possible to loads attributes directly, convert to temp shp or gdb first, then to postgis?

::Spatial index should be created automatically, if not, un-comment the ogrinfo line
::ogrinfo PG:"host=localhost dbname=cas user=postgres password=postgres" -sql "CREATE INDEX AB_0008_spatial_index ON ab.AB_0006 USING GIST (wkb_geometry);"




