#!/bin/bash

#Param substitution
SERVICE=$(circleci env subst "${SERVICE}")
DUPLO_TENANT=$(circleci env subst "${DUPLO_TENANT}")
SERVICE_IMAGE=$(circleci env subst "${SERVICE_IMAGE}")

echo "Tenant is: ${DUPLO_TENANT}"
echo "Service Name: ${SERVICE}"
echo "Service Image: ${SERVICE_IMAGE}"

duploctl service update_image "$SERVICE" "$SERVICE_IMAGE"
