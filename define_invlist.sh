#!/bin/bash -x

echo "######################## Begin define_invlist.sh ########################################"

thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $thisScriptDir/common.sh

useMetadataTableLoadingColumn=False

if ! [[ -v fullList ]]; then
  echo "fullList is not defined in config.sh so build it from the inventory_metadata table...
  "

  # Load metadata tables
  thisScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  source $thisScriptDir/metadata/load_metadata.sh
  
  sqlStatement="
  SELECT string_agg(inventory_id, ' ' ORDER BY converted_stand_cnt::int DESC) 
  FROM inventory_metadata 
  WHERE UPPER(TRIM($metadataTableLoadingColumn))='YES'
  "

  echo "---------------------------------------------------------------------"
  echo "Executing $sqlStatement"

  set -x

  fullList=($("$psqlCmd" $psqlConnectionString -t -q -A -c "$sqlStatement"))

  { set +x; } 2>/dev/null

  useMetadataTableLoadingColumn=True
  echo "fullList as defined by define_invlist.sh for column ${metadataTableLoadingColumn} = ${fullList[@]}"
else
  echo "fullList is already defined in config.sh. metadata/load_metadata.sh not used..."
fi

echo "######################## End define_invlist.sh ########################################"
