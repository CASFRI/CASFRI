#!/bin/bash

source ../../common.sh
source ../../define_invlist.sh

if [ $# -gt 0 ]; then
    echo "Using inventory list provided as arguments: ${@^^}"
    fullList=("${@^^}")
fi

maxProcessInParallel=${maxGeoHistoryInParallel}
leaveShellOpen=${leaveGeoHistoryShellOpen}
processName="ProduceGeoHistory"
source ../../confirm_config.sh

# Translate inventories for each inventory in the list
tests_in_parallel=0

# Iterate over the list of inventory 
translation_in_parallel=0
for invID in "${fullList[@]}"
do
  echo "######################################################################"
  sqlStatement="CALL TT_ProduceInvGeoHistory2Steps('$invID', ${createGeoHistory}, ${geoHistoryInSeparateTables}, TRUE);"
  echo "---------------------------------------------------------------------"
  echo "Executing $sqlStatement"

  "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"$sqlStatement\";$dontCloseGeoHistoryShell" &
  
  ((geohistory_in_parallel++))
  if ((geohistory_in_parallel >= maxGeoHistoryInParallel)); then
    wait -n # wait for ANY job to finish
    ((geohistory_in_parallel--))
  fi
done

wait

# Turn ON echo in order to display the exact command being executed below
set -x

echo "---------------------------------------------------------------------"
echo "Creating index on jurisdiction left(cas_id, 2)..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS geo_history_jurisdiction_idx ON casfri50_history.geo_history USING btree(left(cas_id, 2));\";$dontCloseGeoHistoryShell" &

echo "Creating index on inventory_id left(cas_id, 4)..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS geo_history_inventory_id_idx ON casfri50_history.geo_history USING btree(left(cas_id, 4));\";$dontCloseGeoHistoryShell" &

echo "Creating index on cas_id..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS geo_history_cas_id_idx ON casfri50_history.geo_history USING btree(cas_id);\";$dontCloseGeoHistoryShell" &

echo "Creating spatial index on geom..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS geo_history_geom_idx ON casfri50_history.geo_history USING gist(geom);\";$dontCloseGeoHistoryShell" &

# Wait for all index creation processes to finish before proceeding
wait

# Turn OFF echo
{ set +x; } 2>/dev/null

# Create a quoted list of inventory IDs for the SQL query
printf -v quoted_list "'%s', " "${fullList[@]}"
quoted_list=${quoted_list%, } # Remove the last comma and space

echo "---------------------------------------------------------------------"
echo "Comparing number of rows from casfri50_flat.cas_flat_all_layers_same_row 
with the number of rows in the geo history table for fullList = ${quoted_list}...
"

"$psqlCmd" $psqlConnectionString -P pager=off -c "SELECT * FROM TT_GeoHistoryRowCount(ARRAY[${quoted_list}]);"
