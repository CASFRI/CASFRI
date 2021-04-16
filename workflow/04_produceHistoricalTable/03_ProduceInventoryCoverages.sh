#!/bin/bash -x

source ../../conversion/sh/common.sh

declare -n L

# Iterate over the list of list always making the last command a waiting one (the following ones wait for it to finish before proceeding)
for L in "${fullList[@]}"; do
  for F in "${L[@]}"; do
    if [ $F == ${L[-1]} ]; then
      "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"SELECT TT_ProduceDerivedCoverages('${F}', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''${F}'''));\""
    else
      "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"SELECT TT_ProduceDerivedCoverages('${F}', TT_SuperUnion('casfri50', 'geo_all', 'geometry', 'left(cas_id, 4) = ''${F}'''));\"" &
    fi
  done
done

