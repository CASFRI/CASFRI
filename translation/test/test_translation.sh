#!/bin/bash -x

source ../../config.sh

prov_to_test=$@

# uncomment this to prevent the windows from closing at the end of the script for debug purpose
#dontclose="read -p 'Press enter close the command window...';"

# if [ ${prov_to_test}x == x ] || [ ${prov_to_test}x == abx ]; then

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "ab" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_ab.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_ab.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_ab.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_ab.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_ab.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "bc" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_bc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_bc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_bc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_bc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_bc.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "ds" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_ds.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_ds.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_ds.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_ds.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_ds.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "mb" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_mb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_mb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_mb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_mb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_mb.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "nb" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_nb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_nb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_nb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_nb.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_nb.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "nl" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_nl.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_nl.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_nl.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_nl.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_nl.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "ns" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_ns.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_ns.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_ns.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_ns.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_ns.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "nt" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_nt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_nt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_nt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_nt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_nt.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "on" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_on.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_on.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_on.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_on.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_on.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "pc" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_pc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_pc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_pc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_pc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_pc.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "pe" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_pe.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_pe.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_pe.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_pe.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_pe.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "qc" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_qc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_qc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_qc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_qc.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_qc.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "sk" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_sk.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_sk.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_sk.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_sk.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_sk.sql;$dontclose" &
fi

if [ -z "$prov_to_test" ] || [ "$prov_to_test" = "yt" ]; then
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas_yt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst_yt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco_yt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr_yt.sql;$dontclose" &
    "/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl_yt.sql;$dontclose" &
fi