#!/bin/bash
hash=$(sha256sum "$1")
if [ "$hash" = "$2" ]; then echo "OK"; else echo "NOT OK"; fi
