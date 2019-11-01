:: Common settings and commands for all batch scripts

:: Load config variables from local config file
IF EXIST "%~dp0\..\..\config.bat" ( 
  CALL "%~dp0\..\..\config.bat"
) ELSE (
  ECHO ERROR: NO config.bat FILE
  EXIT /b
)

IF %overwriteFRI% == True (
  SET overwrite_tab=-overwrite 
) ELSE (
  SET overwrite_tab=
)

SET prjFile="%~dp0\..\canadaAlbersEqualAreaConic.prj"

SET pg_connection_string=PG:"host=%pghost% port=%pgport% dbname=%pgdbname% user=%pguser% password=%pgpassword%"

SET layer_creation_option=-lco PRECISION=NO -lco GEOMETRY_NAME=wkb_geometry -t_srs %prjFile%

::Create schema if it doesn't exist
"%gdalFolder%/ogrinfo" %pg_connection_string% -sql "CREATE SCHEMA IF NOT EXISTS %targetFRISchema%";
