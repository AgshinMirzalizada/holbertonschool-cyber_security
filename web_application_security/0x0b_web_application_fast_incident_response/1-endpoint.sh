#!/bin/bash

LOG_FILE="${1:-logs.txt}"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: '$LOG_FILE' not found."
  exit 1
fi

# Extract endpoints (method + URL), count, and sort
ENDPOINT_COUNTS=$(grep -oE '"(GET|POST|PUT|DELETE|HEAD|OPTIONS|PATCH) [^ ]+' "$LOG_FILE" \
  | sed 's/"//g' \
  | sort \
  | uniq -c \
  | sort -rn)

TOP_ENDPOINT=$(echo "$ENDPOINT_COUNTS" | head -1 | awk '{print $2, $3}')
TOP_COUNT=$(echo "$ENDPOINT_COUNTS"    | head -1 | awk '{print $1}')
TOTAL=$(grep -oE '"(GET|POST|PUT|DELETE|HEAD|OPTIONS|PATCH) ' "$LOG_FILE" | wc -l | tr -d ' ')

echo ""
echo "  Endpoint Request Summary"
echo "  ========================"
printf "  %-8s  %s\n" "Requests" "Endpoint"
echo "  --------  --------"
echo "$ENDPOINT_COUNTS" | awk '{printf "  %-8s  %s %s\n", $1, $2, $3}'
echo ""
echo "  Most targeted endpoint"
echo "  ----------------------"
printf "  Endpoint  : %s\n"   "$TOP_ENDPOINT"
printf "  Hits      : %s / %s total requests\n" "$TOP_COUNT" "$TOTAL"
printf "  Share     : %.1f%%\n" "$(echo "scale=2; $TOP_COUNT * 100 / $TOTAL" | bc)"
echo ""
