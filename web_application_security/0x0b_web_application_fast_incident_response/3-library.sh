#!/bin/bash

LOG_FILE="${1:-logs.txt}"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: '$LOG_FILE' not found."
  exit 1
fi

# Find the top attacker IP
TOP_IP=$(grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$LOG_FILE" \
  | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')

# Filter lines by attacker IP, extract User-Agent, find most common
grep "^$TOP_IP" "$LOG_FILE" \
  | grep -oP '"[^"]*"$' \
  | tr -d '"' \
  | sort | uniq -c | sort -rn \
  | head -1 \
  | awk '{$1=""; print substr($0,2)}'
