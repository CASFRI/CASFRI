#!/bin/bash -x

echo "######################## Begin define_invlist.sh ########################################"

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $thisScriptDir/common.sh

# Load metadata tables
source $thisScriptDir/metadata/load_metadata.sh

if ! [[ -v fullList ]]; then
  
  echo "fullList is not defined in config.sh so build it from the inventory_metadata table...
  "
  sqlStatement="
  SELECT string_agg(inventory_id, ' ' ORDER BY converted_stand_cnt::int DESC) 
  FROM inventory_metadata 
  WHERE UPPER(TRIM($metadataTableLoadingColumn))='YES'
  "

  echo "---------------------------------------------------------------------"
  echo "Running $sqlStatement"

  set -x

  fullList=($("$psqlCmd" $psqlConnectionString -t -q -A -c "$sqlStatement"))

  { set +x; } 2>/dev/null
fi

echo "fullList as defined by define_invlist.sh = ${fullList[@]}"

echo "######################## End define_invlist.sh ########################################"
