#!/bin/bash

#Param substitution
SERVICES=$(circleci env subst "${SERVICES}")
DUPLO_TENANT=$(circleci env subst "${DUPLO_TENANT}")

echo "Tenant is: ${DUPLO_TENANT}"
mapfile -t serviceList < <(echo "$SERVICES" | jq -c -r '.[]')
allArgs=""
for item in "${serviceList[@]}"; do
    serviceName=$(echo "$item" | jq -r '.Name')
    serviceImage=$(echo "$item" | jq -r '.Image')
    echo "Service Name: ${serviceName}"
    echo "Service Image: ${serviceImage}"
    allArgs+="-S \"${serviceName}\" \"${serviceImage}\" "
done

echo "allArgs: ${allArgs}"

if [ -n "${allArgs}" ]; then
duploctl service bulk_update_image "${allArgs}"
fi
