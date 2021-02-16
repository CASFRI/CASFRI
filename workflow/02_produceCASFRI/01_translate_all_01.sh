#!/bin/bash -x

source ../../config.sh

# Inventories having more than 2000000 rows
# BC08 4677411
# BC10 5151772
# ON02 3629073
# QC04 2487519
# QC05 6768074

for F in BC08 BC10 ON02 QC04 QC05
do
  "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./02_perInventory/02_$F.sql" &
done
