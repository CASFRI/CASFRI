#!/bin/bash

echo "######################## Begin load_all.sh ############################"

source ../define_invlist.sh

# Read the list of inventory to convert from the command prompt
invToLoad=$@

# Load the photoyear tables first as some conversions are dependent on them (which ones?)
if [ -z "$invToLoad" ]; then
  echo "Convert the fixed list of photo year tables first..."
  for photoYearFile in "${photoYearList[@]}"
  do
    echo "---------------------------------------------------------------------"
    echo "Converting $photoYearFile..."
    "$bashCmd" -c "./sh/load_${photoYearFile,,}.sh;$dontCloseConversionShell" &
  done
  wait
else
  echo "Using inventory list provided as arguments: ${@^^}"
  fullList=("${@^^}")
fi

echo "The final list of inventory to convert is : ${fullList[@]}..."
echo "The number of parallel processes for conversion is set to ${maxConversionInParallel}..."
echo "Press any key to proceed or CTRL-C to cancel..."
read -n 1 -s

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

wait

# Display the count of rows for inventories in the current list

echo "---------------------------------------------------------------------"
echo "Counting rows for fullList = ${quoted_list}
"
# Create a quoted list of inventory IDs for the SQL query
printf -v quoted_list "'%s', " "${fullList[@]}"
quoted_list=${quoted_list%, } # Remove the last comma and space

"$psqlCmd" $psqlConnectionString -P pager=off -c "SELECT * FROM TT_ConvertedStandCount(ARRAY[${quoted_list}]);"

# In pgAdmin
# SELECT (TT_ConvertedStandCount(ARRAY['ab06', 'ab31'])).*
# SELECT (TT_ConvertedStandCount('TRANSLATED_BY_CFS')).*
# SELECT (TT_ConvertedStandCount('TRANSLATED_BY_ULAVAL')).*
# SELECT (TT_ConvertedStandCount('TRANSLATED_BY_CUSTOM')).*
# SELECT (TT_ConvertedStandCount()).*

echo "######################## End load_all.sh #############################"
