#!/bin/bash
# Docker Network Range Checker
# Alerts when networks exist outside 10.222.0.0/16

ALLOWED_RANGE="10.222"
CONFLICT_FOUND=0

echo -e "\n\033[1;34m=== Docker Network Check ===\033[0m"

# Get all networks with their subnets
while IFS= read -r line; do
    network_name=$(echo "$line" | awk '{print $1}')
    subnet=$(echo "$line" | awk '{print $2}')

    # Skip empty subnets (host, none networks)
    if [[ -z "$subnet" || "$subnet" == "" ]]; then
        continue
    fi

    # Check if subnet is outside allowed range
    if [[ ! "$subnet" =~ ^$ALLOWED_RANGE\. ]]; then
        if [[ $CONFLICT_FOUND -eq 0 ]]; then
            echo -e "\033[1;31m⚠️  WARNING: Networks found outside 10.222.0.0/16 range!\033[0m"
            CONFLICT_FOUND=1
        fi
        echo -e "  \033[0;31m✗\033[0m $network_name: $subnet"
    fi
done < <(docker network inspect $(docker network ls -q 2>/dev/null) --format='{{.Name}} {{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null)

if [[ $CONFLICT_FOUND -eq 0 ]]; then
    echo -e "\033[0;32m✓ All networks in allowed range (10.222.0.0/16)\033[0m"
fi

echo ""
