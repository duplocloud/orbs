#!/bin/bash

export DUPLO_TENANT

#Param substitution
DUPLO_TENANT=$(circleci env subst "${PARAM_TENANT}")
PARAM_KIND=$(circleci env subst "${PARAM_KIND}")
PARAM_SERVICE=$(circleci env subst "${PARAM_SERVICE}")
PARAM_IMAGE=$(circleci env subst "${PARAM_IMAGE}")
PARAM_WAIT=$(circleci env subst "${PARAM_WAIT}")

# check if we should wait
DUPLO_WAIT=""
if [ "$PARAM_WAIT" = "true" ]; then
  DUPLO_WAIT="--wait"
fi

echo "Updating ${DUPLO_TENANT}/${PARAM_SERVICE} to ${PARAM_IMAGE}"
duploctl "$PARAM_KIND" update_image "$PARAM_SERVICE" "$PARAM_IMAGE" $DUPLO_WAIT
