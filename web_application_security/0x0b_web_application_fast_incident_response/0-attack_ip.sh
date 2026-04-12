#!/bin/bash

# ============================================================
#  DoS Attack Detector - Log Analyzer
#  Usage: ./detect_dos.sh [log file name]
#  Default: logs.txt
# ============================================================

LOG_FILE="${1:-logs.txt}"

# Check if log file exists
if [[ ! -f "$LOG_FILE" ]]; then
  echo "❌ Error: '$LOG_FILE' file not found."
  exit 1
fi

echo "============================================"
echo "  🔍 DoS Attack Detector - Log Analysis"
echo "============================================"
echo "📄 Analyzing file: $LOG_FILE"
echo ""

# Extract IP addresses, count occurrences, and sort by frequency
echo "📊 Request count per IP address:"
echo "--------------------------------------------"
echo "   Count  |  IP Address"
echo "--------------------------------------------"

IP_COUNTS=$(grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$LOG_FILE" \
  | sort \
  | uniq -c \
  | sort -rn)

# Print in table format
echo "$IP_COUNTS" | awk '{printf "  %6s  |  %s\n", $1, $2}'

echo "--------------------------------------------"
echo ""

# Identify the IP with the highest number of requests
TOP_IP=$(echo "$IP_COUNTS" | head -1 | awk '{print $2}')
TOP_COUNT=$(echo "$IP_COUNTS" | head -1 | awk '{print $1}')
TOTAL=$(grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$LOG_FILE" | wc -l | tr -d ' ')

echo "============================================"
echo "  ⚠️  SUSPICIOUS IP ADDRESS DETECTED"
echo "============================================"
echo "  🎯 IP Address    : $TOP_IP"
echo "  📈 Request Count : $TOP_COUNT"
echo "  📦 Total Requests: $TOTAL"
printf  "  📊 Percentage   : %.1f%%\n" "$(echo "scale=2; $TOP_COUNT * 100 / $TOTAL" | bc)"
echo "============================================"
echo ""
echo "💡 Recommendation: Block this IP with firewall:"
echo "   sudo iptables -A INPUT -s $TOP_IP -j DROP"
echo ""
