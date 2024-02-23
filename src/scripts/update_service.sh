#!/bin/bash

echo "Tenant is: ${DUPLO_TENANT}"
serviceList=$(echo "$SERVICES" | jq -c -r '.[]')
for item in "${serviceList[@]}"; do
    serviceName=$(echo "$item" | jq -r '.Name')
    serviceImage=$(echo "$item" | jq -r '.Image')
    echo "Name: ${serviceName}"
    echo "Image: ${serviceImage}"
    duploctl service update_image "${serviceName}" "${serviceImage}"
done
