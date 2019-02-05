# Moving tables from one server to another

Dumping a table (database: cas, schema: bc, table: vri9)

> pg_dump -U postgres -d cas -t bc.vri9 > vri9.sql

Restore table with schema into another server

> psql -d cas -h localhost -U postgres < vri9.sql
