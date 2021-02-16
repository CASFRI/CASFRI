#!/bin/bash -x

source ../../config.sh

# Inventories having between 200000 and 500000 rows
# NT01	 281388
# NT02	 320944
# QC03   401188
# SK05	 421977
# SK06	 211482
# YT02	 231137

for F in NT01 NT02 QC03 SK05 SK06 YT02
do
  "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./02_perInventory/02_$F.sql" &
done
