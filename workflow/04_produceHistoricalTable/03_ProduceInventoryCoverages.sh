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

  "$psqlCmd" $psqlConnectionString -P pager=off -c "SELECT * FROM TT_CoveragePointCount(ARRAY[${quoted_list}]);"

  echo "---------------------------------------------------------------------"
  echo "List inventories for which the smoothed polygon has 0 vertexes...
  "

  "$psqlCmd" $psqlConnectionString -c "
SELECT string_agg(inventory_id, ' ' ORDER BY inventory_id) inventories
FROM TT_CoveragePointCount(ARRAY[${quoted_list}])
WHERE is_in_geo_all AND nb_pts_smoothed = 0;
"

fi