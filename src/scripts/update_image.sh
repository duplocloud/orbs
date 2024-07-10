#!/bin/bash

#Param substitution
export DUPLO_TENANT=$(circleci env subst "${PARAM_TENANT}")
PARAM_TYPE=$(circleci env subst "${PARAM_TYPE}")
PARAM_NAME=$(circleci env subst "${PARAM_NAME}")
PARAM_IMAGE=$(circleci env subst "${PARAM_IMAGE}")
PARAM_WAIT=$(circleci env subst "${PARAM_WAIT}")

echo "Updating ${DUPLO_TENANT}/${PARAM_NAME} on ${DUPLO_HOST}"

# check if we should wait
DUPLO_WAIT=""
if [ "$PARAM_WAIT" = "true" ]; then
  DUPLO_WAIT="--wait"
fi

duploctl "$PARAM_TYPE" update_image "$PARAM_NAME" "$PARAM_IMAGE" "$DUPLO_WAIT"
