#!/bin/bash

source ../../common.sh
source ../../define_invlist.sh

if [ $# -gt 0 ]; then
    echo "Using inventory list provided as arguments: ${@^^}"
    fullList=("${@^^}")
fi

echo "The final list of inventory to produce geo history for is : ${fullList[@]}..."
echo "The number of parallel processes for producing geo history is set to ${maxGeoHistoryInParallel}..."
echo "Press any key to proceed or CTRL-C to cancel..."
read -n 1 -s

# Translate inventories for each inventory in the list
tests_in_parallel=0

createGeoHistoryBoolean="FALSE"
if [ "$createGeoHistory" = True ]; then
  createGeoHistoryBoolean="TRUE"
  echo "Creating geo history for inventories in the list..."
else
  echo "Skipping creation of geo history and proceeding to merge process only..."
fi

# Iterate over the list of inventory 
translation_in_parallel=0
for invID in "${fullList[@]}"
do
  echo "######################################################################"
  sqlStatement="CALL TT_ProduceInvGeoHistory2Steps('$invID', ${createGeoHistoryBoolean}, FALSE, TRUE);"
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

set -x

echo "---------------------------------------------------------------------"
echo "Creating index on left(cas_id, 2)..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS ON casfri50_history.geo_history USING btree(left(cas_id, 2));\";$dontCloseGeoHistoryShell" &

echo "Creating index on left(cas_id, 4)..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS ON casfri50_history.geo_history USING btree(left(cas_id, 4));\";$dontCloseGeoHistoryShell" &

echo "Creating spatial index on geom..."
"$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"
CREATE INDEX IF NOT EXISTS ON casfri50_history.geo_history USING gist(geom);\";$dontCloseGeoHistoryShell" &

wait

{ set +x; } 2>/dev/null

echo "---------------------------------------------------------------------"
echo "Comparing number of rows from casfr50.geo_all with the number of rows in the geo history table...
"

# Create a quoted list of inventory IDs for the SQL query
printf -v quoted_list "'%s', " "${fullList[@]}"
quoted_list=${quoted_list%, } # Remove the last comma and space

"$psqlCmd" $psqlConnectionString -c "
WITH inv_list AS (
  SELECT inventory_id, geo_row_cnt::int
  FROM inventory_metadata
  WHERE upper(inventory_id) = ANY(SELECT upper(UNNEST(ARRAY[${quoted_list}])))
), geohistocnt AS (
  SELECT left(cas_id, 4) inv, count(*) geo_history_cnt
  FROM casfri50_history.geo_history
  GROUP BY inv
)
SELECT coalesce(inventory_id, inv) inventory_id,
       coalesce(geo_row_cnt, 0) geo_row_cnt,
       coalesce(geo_history_cnt, 0) geo_history_cnt,
       coalesce(geo_history_cnt, 0) - coalesce(geo_row_cnt, 0) diff
FROM inv_list
FULL JOIN geohistocnt ON (inv = inventory_id)
ORDER BY inventory_id;
"