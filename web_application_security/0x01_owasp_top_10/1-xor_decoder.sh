#!/bin/bash

#1. this part deletes "XOR" format from cipher
input=$(echo "$1" | sed 's/{xor}//g')

#2. this part decodes base64
decoded_base64=$(echo "$input" | base64 -d)

#3. this part XOR every symbol with "_" according to websphere
result=$(echo -n "$decoded_base64" | perl -pe '$_ ^= "_" x length')

echo "$result"