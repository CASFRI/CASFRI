#!/bin/bash -x

source ../../config.sh

# uncomment this to prevent the windows from closing at the end of the script for debug purpose
#dontclose="read -p 'Press enter close the command window...';"

"/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_cas.sql;$dontclose" &

"/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_dst.sql;$dontclose" &

"/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_eco.sql;$dontclose" &

"/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_lyr.sql;$dontclose" &

"/c/program files/git/git-bash.exe" -c "$pgFolder/bin/psql -p $pgport -U $pguser -w -d $pgdbname -P pager=off -f ./test_nfl.sql;$dontclose" &
