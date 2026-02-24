#!/bin/bash

source ../../common.sh

set -x

time "$pgFolder/bin/psql" $psqlConnectionString -P pager=off -f ./01_PrepareGeoHistory.sql

