# Common preprocessing for all batch scripts

#echo "######################## Begin pre_processing.sh #######################"

if [[ -v inventoryID ]]; then
  #Create schema if it doesn't exist
  "$gdalFolder/ogrinfo" "$gdalConnectionString" -sql "CREATE SCHEMA IF NOT EXISTS $targetFRISchema";
fi

#echo "######################## End pre_processing.sh #######################"
