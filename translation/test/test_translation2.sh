#!/bin/bash -x

source ../../common.sh

prov_to_test=$@

#dontclose="read -p 'Press enter close the command window...';"

if false; then
"$pgFolder/bin/psql" $psqlConnectionString -P pager=off -c "CREATE SCHEMA IF NOT EXISTS casfri50_test;"

"$gdalFolder/ogr2ogr" \
-f "PostgreSQL" "$gdalConnectionString" nb_tests.csv \
-nln casfri50_test.nb_tests \
$overwriteTable
fi

# Build a list of province codes to test based on the fullList arrays
declare -A provToTestAssArr # the associative array to track unique province codes
declare -n nameRef # nameref for indirect reference to arrays
provToTestList=() # the list of unique province codes to test

for nameRef in "${fullList[@]}"
do
  echo "The ${nameRef} sub list has ${#nameRef[@]} inventories..."
  for invID in "${nameRef[@]}"
  do
    # Skip strings shorter than 2 letters
    (( ${#invID} < 2 )) && continue

    # Extract the province code (first two letters) from the inventory ID
    prov="${invID:0:2}"

    # Skip duplicate prefixes
    [[ -n "${provToTestAssArr[$prov]}" ]] && continue

    # Initialize the associative array entry for this province code
    provToTestAssArr[$prov]=1
    provToTestList+=("$prov")
  done
done

# Define a function to runll tests for a given province code and CASFRI table
runTest() {
  local provCode=$1
  local casTable=$2
  local runInBackground=$3

  echo "Running $casTable tests for all $provCode inventories"

  bashCmd="$gitPath/git-bash.exe"
  psqlCmd="$pgFolder/bin/psql"
  sqlStatement="CALL TT_RunAllTests('$provCode', '$casTable');"
  if [ "$runInBackground" = true ]; then
    "$bashCmd" -c "$psqlCmd $psqlConnectionString -P pager=off -c \"$sqlStatement\";$dontclose" &
  else
    "$bashCmd" -c "$psqlCmd $psqlConnectionString -P pager=off -c \"$sqlStatement\";$dontclose"
  fi
}

# Translate inventories for each province code in the list
for prov in "${provToTestList[@]}"
do
  echo "Testing translation for $prov"

  runInBackground=true
  [ ${#provToTestList[@]} == 1 ] || [ $prov == ${provToTestList[-1]} ] && runInBackground=false
  runTest "$prov" "cas" "true"
  runTest "$prov" "eco" "true"
  runTest "$prov" "dst" "true"
  runTest "$prov" "nfl" "true"
  runTest "$prov" "lyr" "$runInBackground"
 done
