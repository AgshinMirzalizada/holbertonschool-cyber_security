#!/bin/bash
sudo nmap --reason --host-timeout 1000ms -p $2 -sA $1 