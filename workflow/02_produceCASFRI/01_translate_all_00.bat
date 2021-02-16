ECHO OFF
CALL ..\..\config.bat

start /wait CMD /c ""%pgFolder%\bin\psql" -p %pgport% -U %pguser% -w -d %pgdbname% -P pager=off -f 01_hdr.sql"
start /wait CMD /c ""%pgFolder%\bin\psql" -p %pgport% -U %pguser% -w -d %pgdbname% -P pager=off -f ./02_perInventory/01_createTables.sql"

