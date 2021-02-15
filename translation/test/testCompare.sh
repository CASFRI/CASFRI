#!/bin/bash -x

source ../../config.sh

"$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_compare.sql" &

