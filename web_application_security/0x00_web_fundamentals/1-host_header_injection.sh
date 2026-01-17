#!/bin/bash

my_host=$1
target_host=$2
data=$3

curl "$target_host" -H "Host: "$my_host"" -d "email="$data""