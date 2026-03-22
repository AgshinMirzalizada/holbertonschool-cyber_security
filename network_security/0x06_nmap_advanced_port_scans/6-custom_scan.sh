#!/bin/bash
sudo nmap --scanflags -p$2 $1 -oN custom_scan.txt 2>/dev/null