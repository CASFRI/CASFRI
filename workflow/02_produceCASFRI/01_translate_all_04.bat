ECHO OFF
CALL ..\..\config.bat

SETLOCAL ENABLEDELAYEDEXPANSION

:: Inventories having less than 200000 rows
:: AB03   61633
:: AB06   11484
:: AB07   23268
:: AB08   34474
:: AB10  194696
:: AB11  118624
:: AB16	 120476
:: AB30    4555
:: MB06  163064
:: PC01    8094
:: PC02    1053
:: PE01  107220
:: SK02	  27312
:: SK03	   8964

FOR %%F IN (AB03 AB06 AB07 AB08 AB10 AB11 AB16 AB30 MB06 PC01 PC02 PE01 SK02 SK03) DO (
  START /max CMD /k ""%pgFolder%\bin\psql" -p %pgport% -U %pguser% -w -d %pgdbname% -P pager=off -f ./02_perInventory/02_%%F.sql"
)

ENDLOCAL