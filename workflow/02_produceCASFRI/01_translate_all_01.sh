#!/bin/bash -x

source ../../config.sh

declare -n L

# Iterate over the list of list always making the last command a waiting one (the following ones wait for it to finish before proceeding)
for L in "${fullList[@]}"; do
  for F in "${L[@]}"; do
    if [ $F == ${L[-1]} ]; then
      "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./02_perInventory/02_$F.sql"
    else
      "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./02_perInventory/02_$F.sql" &
    fi
  done
done

