#!/bin/bash

source ../../common.sh

set -x

"$psqlCmd" $psqlConnectionString -f 01_all_layers_same_row.sql

"$psqlCmd" $psqlConnectionString -f 02_all_layers_same_row_test.sql
