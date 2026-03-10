echo "**************************************************************"
echo "processName: ${processName}"
echo "pgdbname: ${pgdbname}"
if [ "$useMetadataTableLoadingColumn" = True ]; then
  echo "invList defined by: inventory_metadata column"
  echo "metadataTableLoadingColumn: ${metadataTableLoadingColumn}"
elif [ "$useCommandArgumentInvList" = True ]; then
  echo "invList defined by: command line argument"
else
  echo "invList defined by: config.sh"
fi
echo "invList : ${fullList[@]}"
if [ ${processName} = "ProduceGeoHistory" ]; then
  echo "geoHistoryInSeparateTables: ${geoHistoryInSeparateTables}"
  echo "createGeoHistory: ${createGeoHistory}"
fi
echo "processInParallel: ${maxProcessInParallel}"
echo "leaveShellOpen: ${leaveShellOpen}"
echo "**************************************************************"
echo "Press any key to proceed or CTRL-C to cancel..."
read -n 1 -s