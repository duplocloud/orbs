#!/usr/bin/env bash

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

PARAM_ADMIN=$(circleci env subst "${PARAM_ADMIN}")
PARAM_CLOUD=$(circleci env subst "${PARAM_CLOUD}")
PARAM_ACCOUNT_ID=$(circleci env subst "${PARAM_ACCOUNT_ID}")
PARAM_TENANT=$(circleci env subst "${PARAM_TENANT}")
ADMIN_FLAG=""
export DUPLO_TENANT=${PARAM_TENANT:-$DUPLO_TENANT}

echo "Setting up Duplo environment in $DUPLO_TENANT"

duploctl version -o yaml
duploctl system info -o yaml
PORTAL_INFO="$(duploctl system info)"

AWS_ENABLED="$(echo "$PORTAL_INFO" | jq -r '.IsAwsCloudEnabled')"
GCP_ENABLED="$(echo "$PORTAL_INFO" | jq -r '.IsGoogleCloudEnabled')"
AZURE_ENABLED="$(echo "$PORTAL_INFO" | jq -r '.IsAzureCloudEnabled')"

{
  echo "export AWS_ENABLED=$AWS_ENABLED"
  echo "export GCP_ENABLED=$GCP_ENABLED"
  echo "export AZURE_ENABLED=$AZURE_ENABLED"
} >> "$BASH_ENV"

echo "Portal info discovered"

# if is admin 
if [[ "$PARAM_ADMIN" == "true" ]]; then
  echo "Admin flag detected"
  ADMIN_FLAG="--admin"
  echo "export ADMIN_FLAG=$ADMIN_FLAG" >> "$BASH_ENV"
else
  echo "export ADMIN_FLAG=" >> "$BASH_ENV"
  # DUPLO_TENANT is an empty string or not set
  if [[ -z "$DUPLO_TENANT" ]]; then
    fail "DUPLO_TENANT is required for non-admin users"
  fi
fi

# configure the cloud environments
if [[ "$AWS_ENABLED" == "true" ]]; then
  echo "Configuring AWS Backend"
  PARAM_ACCOUNT_ID="$(echo "$PORTAL_INFO" | jq -r '.DefaultAwsAccount')"
  DUPLO_DEFAULT_REGION="$(echo "$PORTAL_INFO" | jq -r '.DefaultAwsRegion')"
  {
    echo "export AWS_DEFAULT_REGION=$DUPLO_DEFAULT_REGION"
    echo "export AWS_ACCOUNT_ID=$DUPLO_ACCOUNT_ID"
  } >> "$BASH_ENV"

  # set jit credentials in env
  AWS_STS=$(duploctl jit aws -q '{AWS_ACCESS_KEY_ID: AccessKeyId, AWS_SECRET_ACCESS_KEY: SecretAccessKey, AWS_SESSION_TOKEN: SessionToken, AWS_REGION: Region}' -o env $ADMIN_FLAG)
  for i in $AWS_STS; do 
    echo "export $i" >> "$BASH_ENV"
  done
elif [[ "$GCP_ENABLED" == "true" ]]; then
  echo "Configuring GCP Backend"
elif [[ "$AZURE_ENABLED" == "true" ]]; then
  echo "Configuring Azure Backend"
fi

{
  echo "export DUPLO_ACCOUNT_ID=$PARAM_ACCOUNT_ID"
  echo "export DUPLO_DEFAULT_REGION=$DUPLO_DEFAULT_REGION"
  echo "export duplo_token=$DUPLO_TOKEN" 
  echo "export duplo_host=$DUPLO_HOST"
} >> "$BASH_ENV"
