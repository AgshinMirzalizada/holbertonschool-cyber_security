#!/bin/bash

#1. this part deletes "XOR" format from cipher
input=$(echo "$1" | sed 's/{xor}//g')

#2. this part decodes base64 and XOR every symbol with "_" according to websphere
echo -n "$input" | base64 -d | perl -pe '$_ ^= "_" x length'