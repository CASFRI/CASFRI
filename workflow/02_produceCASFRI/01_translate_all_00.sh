#!/bin/bash -x

source ../../config.sh

"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f 01_hdr.sql" &

"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./02_perInventory/01_createTables.sql" &
