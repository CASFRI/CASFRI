#!/bin/bash

source ../../common.sh
source ../../define_invlist.sh

if [ $# -gt 0 ]; then
    fullList=("$@")
fi

echo "The list of inventory to produce geo history is ${fullList[@]}..."

# Translate inventories for each inventory in the list
tests_in_parallel=0

# Iterate over the list of inventory 
coverage_in_parallel=0
for invID in "${fullList[@]}"
do
  echo "######################################################################"
  sqlStatement="SELECT TT_ProduceDerivedCoverages(upper('${invID}'), TT_SuperUnionDebug('casfri50', 'geo_all', 'cas_id', 'geometry', 'left(cas_id, 4) = upper(''${invID}'')'));"
  echo "---------------------------------------------------------------------"
  echo "Executing $sqlStatement"

  "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"$sqlStatement\";$dontCloseCoverageShell" &
  
  ((coverage_in_parallel++))
  if ((coverage_in_parallel >= maxGeoHistoryInParallel)); then
    wait -n # wait for ANY job to finish
    ((coverage_in_parallel--))
  fi
done

wait

echo "---------------------------------------------------------------------"
echo "Comparing number of points in each coverage type for each inventory...
"

# Create a quoted list of inventory IDs for the SQL query
printf -v quoted_list "'%s', " "${fullList[@]}"
quoted_list=${quoted_list%, } # Remove the last comma and space

"$psqlCmd" $psqlConnectionString -c "
WITH inv_list AS (
  SELECT inventory_id inv
  FROM inventory_metadata
  WHERE upper(inventory_id) = ANY(SELECT upper(UNNEST(ARRAY[${quoted_list}])))
)
SELECT i.inv inventory_id, 
       CASE WHEN a.nb_points IS NULL THEN 'NOT PRODUCED' ELSE a.nb_points::text END nb_pts_detailed, 
       CASE WHEN b.nb_points IS NULL THEN 'NOT PRODUCED' ELSE b.nb_points::text END nb_pts_noholes, 
       CASE WHEN c.nb_points IS NULL THEN 'NOT PRODUCED' ELSE c.nb_points::text END nb_pts_noislands, 
       CASE WHEN d.nb_points IS NULL THEN 'NOT PRODUCED' ELSE d.nb_points::text END nb_pts_simplified, 
       CASE WHEN e.nb_points IS NULL THEN 'NOT PRODUCED' ELSE e.nb_points::text END nb_pts_smoothed
FROM inv_list i
LEFT JOIN casfri50_coverage.detailed a USING (inv)
LEFT JOIN casfri50_coverage.noholes b USING (inv)
LEFT JOIN casfri50_coverage.noislands c USING (inv)
LEFT JOIN casfri50_coverage.simplified d USING (inv)
LEFT JOIN casfri50_coverage.smoothed e USING (inv)
ORDER BY inv;
"
