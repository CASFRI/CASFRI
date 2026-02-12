#!/bin/bash

source ../../common.sh

set -x

"$psqlCmd" $psqlConnectionString -f 01_createCASFRITables.sql
