ECHO OFF
CALL ..\..\config.bat

SETLOCAL ENABLEDELAYEDEXPANSION

:: Inventories having between 500000 and 2000000 rows
:: AB25  527038
:: AB29  620944
:: MB05 1644808
:: NB01  927177
:: NB02 1123893
:: NL01 1863664
:: NS03  995886
:: SK01 1501667
:: SK04  633522

FOR %%F IN (AB25 AB29 MB05 NB01 NB02 NL01 NS03 SK01 SK04) DO (
  START /max CMD /k ""%pgFolder%\bin\psql" -p %pgport% -U %pguser% -w -d %pgdbname% -P pager=off -f ./02_perInventory/02_%%F.sql"
)

ENDLOCAL