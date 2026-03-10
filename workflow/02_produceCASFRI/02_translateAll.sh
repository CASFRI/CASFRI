#!/bin/bash

source ../../common.sh
source ../../define_invlist.sh

casTableList=("cas" "eco" "dst" "nfl" "lyr" "geo")

if [ $# -gt 0 ]; then
  # Read the list of inventory to translate from the command prompt
  useCommandArgumentInvList=True
  arg2=$2
  if [[ $# -eq 2 && "${arg2,,}" =~ ^(cas|eco|dst|nfl|lyr|geo)$ ]]; then
    echo "Using inventory list provided as argument: ${1^^} ${2^^}"

    fullList=("${1^^}")
    casTableList=("${2^^}")
  else
    echo "Using inventory list provided as arguments: ${@^^}"
    fullList=("${@^^}")
  fi
fi

maxProcessInParallel=${maxTranslationsInParallel}
leaveShellOpen=${leaveTranslationsShellOpen}
processName="TestTranslation"
source ../../confirm_config.sh

# Iterate over the list of inventory 
translation_in_parallel=0
for invID in "${fullList[@]}"
do
  echo "######################################################################"
  for casTable in "${casTableList[@]}"
  do
    sqlStatement="CALL TT_TranslateInventory('$invID', 'T', '$casTable');"
    echo "---------------------------------------------------------------------"
    echo "Executing $sqlStatement"

    "$bashCmd" -c "$psqlCmd $psqlConnectionString -P pager=off -c \"$sqlStatement\";$dontCloseTranslationShell" &
    
    ((translation_in_parallel++))
    if ((translation_in_parallel >= maxTranslationsInParallel)); then
      wait -n # wait for ANY job to finish
      ((translation_in_parallel--))
    fi
  done
done

if [ "$postProcessing" = True ]; then

  wait

  # Display the count of rows for inventories in the current list

  # Create a quoted list of inventory IDs for the SQL query
  printf -v quoted_list "'%s', " "${fullList[@]}"
  quoted_list=${quoted_list%, } # Remove the last comma and space

  echo "---------------------------------------------------------------------"
  echo "Counting translated rows for fullList = ${quoted_list}
  "

  "$psqlCmd" $psqlConnectionString -P pager=off -c "SELECT * FROM TT_TranslatedRowCount(ARRAY[${quoted_list}]);"

fi