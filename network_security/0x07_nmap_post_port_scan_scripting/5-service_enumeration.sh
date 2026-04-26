#!/bin/bash
nmap -sV -A --script=banner, ssl-enum-ciphers, default, smb-enum -oN $1 service_enumeration_results.txt 
