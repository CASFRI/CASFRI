echo "**************************************************************"
echo "processName: ${processName}"
echo "postProcessing: ${postProcessing}"
echo "postProcessingOnly: ${postProcessingOnly}"
echo ""
echo "pgdbname: ${pgdbname}"
echo ""
if [ "$useCommandArgumentInvList" = True ]; then
  echo "invList defined by: command line argument"
elif [ "$useMetadataTableLoadingColumn" = True ]; then
  echo "invList defined by: inventory_metadata column"
  echo "metadataTableLoadingColumn: ${metadataTableLoadingColumn}"
else
  echo "invList defined by: config.sh"
fi
echo "invList : ${fullList[@]}"
if [ ${processName} = "ProduceGeoHistory" ]; then
  echo ""
  echo "geoHistoryInSeparateTables: ${geoHistoryInSeparateTables}"
  echo "createGeoHistory: ${createGeoHistory}"
fi
echo ""
echo "processInParallel: ${maxProcessInParallel}"
echo "leaveShellOpen: ${leaveShellOpen}"
echo "**************************************************************"
echo "Press any key to proceed or CTRL-C to cancel..."
read -n 1 -s