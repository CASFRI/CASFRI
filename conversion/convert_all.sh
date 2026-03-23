#!/bin/bash

echo "######################## Begin convert_all.sh ############################"

source ../common.sh
source ../define_invlist.sh

# Read the list of inventory to process from the command line
if [ $# -gt 0 ]; then
  useCommandArgumentInvList=True
  echo "Using inventory list provided as arguments: ${@^^}"
  fullList=("${@^^}")
fi

maxProcessInParallel=${maxConversionInParallel}
leaveShellOpen=${leaveConversionShellOpen}
processName="ConvertInventories"
source ../confirm_config.sh

if [ "$postProcessingOnly" = "False" ]; then
  # Load the photoyear tables first as some conversions are dependent on them (which ones?)
  # Load them only if the list was not provided as argument on the command line
  if [ -z "$invToLoad" &&  ]; then
    echo "Convert the fixed list of photo year tables first..."
    for photoYearFile in "${photoYearList[@]}"
    do
      echo "---------------------------------------------------------------------"
      echo "Converting $photoYearFile..."
      "$bashCmd" -c "./sh/load_${photoYearFile,,}.sh;$dontCloseConversionShell" &
    done
    wait
  fi

  # Iterate over the list of inventory
  echo "---------------------------------------------------------------------"
  echo "Convert the rest of the inventories..."
  conversion_in_parallel=0
  for invID in "${fullList[@]}"
  do
    echo "---------------------------------------------------------------------"
    echo "Converting $invID..."

    "$bashCmd" -c "./sh/load_${invID,,}.sh;$dontCloseConversionShell" &
    
    ((conversion_in_parallel++))
    if (( conversion_in_parallel >= maxConversionInParallel)); then
      wait -n # wait for ANY job to finish
      ((conversion_in_parallel--))
    fi
  done
fi

if [[ "$postProcessing" = "True" || "$postProcessingOnly" = "True" ]]; then

  wait

  # Display the count of rows for inventories in the current list

   # Create a quoted list of inventory IDs for the SQL query
  printf -v quoted_list "'%s', " "${fullList[@]}"
  quoted_list=${quoted_list%, } # Remove the last comma and space

  echo "---------------------------------------------------------------------"
  echo "Counting rows for fullList = ${quoted_list}
  "
  "$psqlCmd" $psqlConnectionString -P pager=off -c "SELECT * FROM TT_ConvertedStandCount(ARRAY[${quoted_list}]);"

  # In pgAdmin
  # SELECT (TT_ConvertedStandCount(ARRAY['ab06', 'ab31'])).*
  # SELECT (TT_ConvertedStandCount('TRANSLATED_BY_CFS')).*
  # SELECT (TT_ConvertedStandCount('TRANSLATED_BY_ULAVAL')).*
  # SELECT (TT_ConvertedStandCount('TRANSLATED_BY_CUSTOM')).*
  # SELECT (TT_ConvertedStandCount()).*

fi

echo "######################## End convert_all.sh #############################"
