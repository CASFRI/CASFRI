#!/bin/bash

echo "######################## Begin test_translation.sh ############################"

source ../../define_invlist.sh

# Create the test schema and load the table of number of test per inventory and layer
set -x
"$psqlCmd" $psqlConnectionString -P pager=off -c "CREATE SCHEMA IF NOT EXISTS casfri50_test;"

"$ogrCmd" -f "PostgreSQL" "$gdalConnectionString" nb_tests_per_layer.csv -nln casfri50_test.nb_tests_per_layer $overwriteTable
set +x

# Determine the list of inventory to test. If a list is provided as arguments, use it. 
# Otherwise, use the fullList from define_invlist.sh

if [ $# -ne 0 ]; then
  echo "fullList defined by argument..."
  fullList=("$@")
fi

echo "Final fullList = ${fullList[@]}"

# Build a list of province codes to test based on the fullList array

declare -A provToTestAssArr # the associative array to track unique province codes
provToTestList=() # the list of unique province codes to test

for invID in "${fullList[@]}"
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

echo "The list of province to test is: ${provToTestList[@]}"

# Translate inventories for each province code in the list
tests_in_parallel=0
casTableList=("cas" "eco" "dst" "nfl" "lyr")
for prov in "${provToTestList[@]}"
do
  echo "######################################################################"
  for casTable in "${casTableList[@]}"
  do
    sqlStatement="CALL TT_RunAllTests('$prov', '$casTable');"
    echo "---------------------------------------------------------------------"
    echo "Running $sqlStatement"

    set -x

    "$bashCmd" -c "$psqlCmd $psqlConnectionString -P pager=off -c \"$sqlStatement\";$dontCloseTestShell" &

    { set +x; } 2>/dev/null
    
    ((tests_in_parallel++))
    if (( tests_in_parallel >= maxTestsInParallel)); then
      wait -n # wait for ANY job to finish
      ((tests_in_parallel--))
    fi
  done
done

# Wait for the whole translation tests to finish before dumping the results
wait

declare -A attributes=(
  [cas]="cas_id, inventory_id, orig_stand_id, stand_structure, num_of_layers, 
         map_sheet_id, casfri_area, casfri_perimeter, src_inv_area, stand_photo_year"
  [eco]="cas_id, wetland_type, wet_veg_cover, wet_landform_mod, wet_local_mod, 
         eco_site, layer"
  [dst]="cas_id, layer, 
         dist_type_1, dist_year_1, dist_ext_upper_1, dist_ext_lower_1, 
         dist_type_2, dist_year_2, dist_ext_upper_2, dist_ext_lower_2, 
         dist_type_3, dist_year_3, dist_ext_upper_3, dist_ext_lower_3"
  [nfl]="cas_id, layer, layer_rank, soil_moist_reg, structure_per, crown_closure_upper, crown_closure_lower, 
         height_upper, height_lower, nat_non_veg, non_for_anth, non_for_veg"
  [lyr]="cas_id, layer, soil_moist_reg, structure_per, layer, layer_rank, crown_closure_upper, crown_closure_lower, height_upper, height_lower, productivity, productivity_type, 
         species_1, species_per_1, species_2, species_per_2, species_3, species_per_3, species_4, species_per_4, species_5, species_per_5, 
         species_6, species_per_6, species_7, species_per_7, species_8, species_per_8, species_9, species_per_9, species_10, species_per_10, 
         origin_upper, origin_lower, site_class, site_index"
)

tests_in_parallel=0
for prov in "${provToTestList[@]}"
do
  echo "######################################################################"
  for casTable in "${casTableList[@]}"
  do
    table_name=${casTable}_${prov,,}
    
    echo "---------------------------------------------------------------------"
    echo "Deleting table ${table_name}.csv"
    rm ./tables/${table_name}_test.csv

    echo "Dumping table ${table_name} to ./tables/${table_name}_test.csv"
    set -x

    $ogrCmd -f "CSV" "./tables/${table_name}_test.csv" "$gdalConnectionString" \
    -lco STRING_QUOTING=IF_NEEDED -sql "SELECT * FROM casfri50_test.${table_name} ORDER BY ${attributes[${casTable}]};" &

    { set +x; } 2>/dev/null
    
    ((tests_in_parallel++))
    if (( tests_in_parallel >= maxTestsInParallel)); then
      wait -n # wait for ANY job to finish
      ((tests_in_parallel--))
    fi
  done
done

wait

echo "######################## End test_translation.sh ############################"
