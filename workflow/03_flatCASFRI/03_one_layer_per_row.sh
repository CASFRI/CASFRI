#!/bin/bash

source ../../config.sh

set -x

"$psqlCmd" $psqlConnectionString -f 03_one_layer_per_row.sql

