ECHO OFF
CALL ..\..\config.bat

SETLOCAL ENABLEDELAYEDEXPANSION

:: Inventories having between 200000 and 500000 rows
:: NT01	 281388
:: NT03	 320523
:: QC03  401188
:: SK05	 421977
:: SK06	 211482
:: YT02	 231137
:: MB07  219682
:: YT01  249636

FOR %%F IN (NT01 NT03 QC03 SK05 SK06 YT02 MB07 YT01) DO (
  START /max CMD /k ""%pgFolder%\bin\psql" -p %pgport% -U %pguser% -w -d %pgdbname% -P pager=off -f ./02_perInventory/02_%%F.sql"
)

ENDLOCAL