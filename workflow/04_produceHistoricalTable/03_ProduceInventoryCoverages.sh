#!/bin/bash

# Read the list of inventory to process from the command line
if [ $# -gt 0 ]; then 
  useCommandArgumentInvList=True
  echo "Using inventory list provided as arguments: ${@^^}"
  fullList=("$@")
fi

source ../../define_invlist.sh

maxProcessInParallel=${maxGeoHistoryInParallel}
leaveShellOpen=${leaveCoverageShellOpen}
processName="ProduceInventoryCoverage"
source ../../confirm_config.sh

if [ "$postProcessingOnly" = "False" ]; then

  if [ "$useCommandArgumentInvList" = "False" ]; then
    # Load shapefile of Canada provinces limits
    echo "Loading Canada province shapefile..."
    "$gdalFolder/ogr2ogr" -f "PostgreSQL" "$gdalConnectionString" canada_provinces.shp \
    -nln casfri50_coverage.canada_provinces $gdalLco $gdalOtherOptions \
    -progress $overwriteTable
  fi
  
  # Iterate over the list of inventory 
  coverage_in_parallel=0
  for invID in "${fullList[@]}"
  do
    echo "######################################################################"
    ##sqlStatement="SELECT TT_ProduceDerivedCoverages(upper('${invID}'), TT_SuperUnionDebug('casfri50', 'geo_all', 'cas_id', 'geometry', 'left(cas_id, 4) = upper(''${invID}'')'));"
    sqlStatement="CALL TT_ProduceDerivedCoverages(upper('${invID}'), TT_InvSuperUnion(upper('${invID}')));"
    echo "---------------------------------------------------------------------"
    echo "Executing $sqlStatement"

    "$bashCmd" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -c \"$sqlStatement\";$dontCloseCoverageShell" &
    
    ((coverage_in_parallel++))
    if ((coverage_in_parallel >= maxGeoHistoryInParallel)); then
      wait -n # wait for ANY job to finish
      ((coverage_in_parallel--))
    fi
  done
fi

if [[ "$postProcessing" = "True" || "$postProcessingOnly" = "True" ]]; then

  wait

  echo "---------------------------------------------------------------------"
  echo "Comparing number of vertexes in each coverage type for each inventory...
  "

  # Create a quoted list of inventory IDs for the SQL query
  printf -v quoted_list "'%s', " "${fullList[@]}"
  quoted_list=${quoted_list%, } # Remove the last comma and space

  "$psqlCmd" $psqlConnectionString -c "
WITH inv_list AS (
  SELECT inventory_id inv
  FROM inventory_metadata
  WHERE upper(inventory_id) = ANY(SELECT upper(UNNEST(ARRAY[${quoted_list}])))
), loaded_inv AS (
  SELECT DISTINCT(inventory_id) inv
  FROM casfri50.cas_all
)
SELECT i.inv inventory_id, 
       CASE WHEN l.inv IS NULL THEN FALSE ELSE TRUE END is_in_geo_all,
       CASE WHEN a.nb_points IS NULL THEN 0 ELSE a.nb_points END nb_pts_detailed, 
       CASE WHEN b.nb_points IS NULL THEN 0 ELSE b.nb_points END nb_pts_noholes, 
       CASE WHEN c.nb_points IS NULL THEN 0 ELSE c.nb_points END nb_pts_noislands, 
       CASE WHEN d.nb_points IS NULL THEN 0 ELSE d.nb_points END nb_pts_simplified, 
       CASE WHEN e.nb_points IS NULL THEN 0 ELSE e.nb_points END nb_pts_smoothed
FROM inv_list i
LEFT OUTER JOIN loaded_inv l USING (inv)
LEFT OUTER JOIN casfri50_coverage.detailed a USING (inv)
LEFT OUTER JOIN casfri50_coverage.noholes b USING (inv)
LEFT OUTER JOIN casfri50_coverage.noislands c USING (inv)
LEFT OUTER JOIN casfri50_coverage.simplified d USING (inv)
LEFT OUTER JOIN casfri50_coverage.smoothed e USING (inv)
ORDER BY inv;
"

  echo "---------------------------------------------------------------------"
  echo "List inventories for which the smoothed polygon has 0 vertexes...
  "

  "$psqlCmd" $psqlConnectionString -c "
WITH inv_list AS (
  SELECT inventory_id inv
  FROM inventory_metadata
  WHERE upper(inventory_id) = ANY(SELECT upper(UNNEST(ARRAY[${quoted_list}])))
)
SELECT string_agg(inv, ' ' ORDER BY inv)
FROM inv_list i
LEFT OUTER JOIN casfri50_coverage.detailed a USING (inv)
LEFT OUTER JOIN casfri50_coverage.noholes b USING (inv)
LEFT OUTER JOIN casfri50_coverage.noislands c USING (inv)
LEFT OUTER JOIN casfri50_coverage.simplified d USING (inv)
LEFT OUTER JOIN casfri50_coverage.smoothed e USING (inv)
WHERE e.nb_points IS NULL;
"

fi