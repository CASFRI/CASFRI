#!/bin/bash -x

# This script dumps the random test tables from the database.

# When test tables rightfully differ from original tables they have to be 
# dumped with this script and pushed back in the source tree.

# #################################### Set variables ######################################

source ../../conversion/sh/common.sh

pgversion=${pgversion:=13}
prov_to_dump=$@

# ########################################## Process ######################################

# Run ogr2ogr
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "ab" ]; then
    rm ./data$pgversion/*_ab_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_ab_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_ab_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_ab_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_ab_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_ab_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_ab_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_ab_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_ab_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_ab_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_ab_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "ds" ]; then
    rm ./data$pgversion/*_ds_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_ds_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_ds_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_ds_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_ds_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_ds_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_ds_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_ds_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_ds_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_ds_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_ds_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "mb" ]; then
    rm ./data$pgversion/*_mb_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_mb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_mb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_mb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_mb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_mb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_mb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_mb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_mb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_mb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_mb_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "nb" ]; then
    rm ./data$pgversion/*_nb_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_nb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_nb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_nb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_nb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_nb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_nb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_nb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_nb_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_nb_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_nb_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "nl" ]; then
    rm ./data$pgversion/*_nl_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_nl_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_nl_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_nl_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_nl_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_nl_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_nl_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_nl_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_nl_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_nl_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_nl_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "ns" ]; then
    rm ./data$pgversion/*_ns_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_ns_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_ns_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_ns_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_ns_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_ns_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_ns_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_ns_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_ns_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_ns_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_ns_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "nt" ]; then
    rm ./data$pgversion/*_nt_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_nt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_nt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_nt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_nt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_nt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_nt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_nt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_nt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_nt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_nt_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "on" ]; then
    rm ./data$pgversion/*_on_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_on_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_on_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_on_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_on_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_on_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_on_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_on_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_on_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_on_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_on_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "pc" ]; then
    rm ./data$pgversion/*_pc_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_pc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_pc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_pc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_pc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_pc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_pc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_pc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_pc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_pc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_pc_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "pe" ]; then
    rm ./data$pgversion/*_pe_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_pe_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_pe_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_pe_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_pe_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_pe_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_pe_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_pe_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_pe_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_pe_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_pe_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "qc" ]; then
    rm ./data$pgversion/*_qc_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_qc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_qc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_qc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_qc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_qc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_qc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_qc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_qc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_qc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_qc_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "sk" ]; then
    rm ./data$pgversion/*_sk_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_sk_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_sk_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_sk_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_sk_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_sk_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_sk_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_sk_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_sk_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_sk_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_sk_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "yt" ]; then
    rm ./data$pgversion/*_yt_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_yt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_yt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_yt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_yt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_yt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_yt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_yt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.lyr_yt_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_yt_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_yt_new_ordered" &
fi
if [ -z "$prov_to_dump" ] || [ "$prov_to_dump" = "bc" ]; then
    rm ./data$pgversion/*_bc_test.csv
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\cas_bc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.cas_bc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\dst_bc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.dst_bc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\eco_bc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.eco_bc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\nfl_bc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED "casfri50_test.nfl_bc_new_ordered" &
    "$gdalFolder/ogr2ogr" -f "CSV" ".\data$pgversion\lyr_bc_test.csv" "$pg_connection_string" -lco STRING_QUOTING=IF_NEEDED -progress "casfri50_test.lyr_bc_new_ordered"
fi

wait

echo "Dumping of test tables completed."