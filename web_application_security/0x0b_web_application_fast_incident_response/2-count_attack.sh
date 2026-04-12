#!/bin/bash

LOG_FILE="${1:-logs.txt}"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: '$LOG_FILE' not found."
  exit 1
fi

grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$LOG_FILE" \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -1 \
  | awk '{print $1}'
