#!/usr/bin/env bash

PARAM_ADMIN=$(circleci env subst "${PARAM_ADMIN}")
PARAM_CLOUD=$(circleci env subst "${PARAM_CLOUD}")
PARAM_ACCOUNT_ID=$(circleci env subst "${PARAM_ACCOUNT_ID}")
ADMIN_FLAG=""

PORTAL_INFO="$(duploctl system info)"

AWS_ENABLED="$(echo "$PORTAL_INFO" | jq -r '.IsAwsCloudEnabled')"
GCP_ENABLED="$(echo "$PORTAL_INFO" | jq -r '.IsGoogleCloudEnabled')"
AZURE_ENABLED="$(echo "$PORTAL_INFO" | jq -r '.IsAzureCloudEnabled')"

echo "export AWS_ENABLED=$AWS_ENABLED" >> "$BASH_ENV"
echo "export GCP_ENABLED=$GCP_ENABLED" >> "$BASH_ENV"
echo "export AZURE_ENABLED=$AZURE_ENABLED" >> "$BASH_ENV"

echo "Portal info discovered"

# if is admin 
if [[ "$PARAM_ADMIN" == "true" ]]; then
  echo "Admin flag detected"
  ADMIN_FLAG="--admin"
  echo "export ADMIN_FLAG=$ADMIN_FLAG" >> "$BASH_ENV"
else
  echo "export ADMIN_FLAG=" >> "$BASH_ENV"
fi

# configure the cloud environments
if [[ "$AWS_ENABLED" == "true" ]]; then
  echo "Configuring AWS Backend"
  PARAM_ACCOUNT_ID="$(echo "$PORTAL_INFO" | jq -r '.DefaultAwsAccount')"
  DUPLO_DEFAULT_REGION="$(echo "$PORTAL_INFO" | jq -r '.DefaultAwsRegion')"
  AWS_STS=$(duploctl jit aws -q '{AWS_ACCESS_KEY_ID: AccessKeyId, AWS_SECRET_ACCESS_KEY: SecretAccessKey, AWS_SESSION_TOKEN: SessionToken, AWS_REGION: Region}' -o env $ADMIN_FLAG)
  for i in $AWS_STS; do 
    echo "export $i" >> "$BASH_ENV"
  done
  echo "export AWS_DEFAULT_REGION=$DUPLO_DEFAULT_REGION" >> "$BASH_ENV"
  echo "export AWS_ACCOUNT_ID=$DUPLO_ACCOUNT_ID" >> "$BASH_ENV"
elif [[ "$GCP_ENABLED" == "true" ]]; then
  echo "Configuring GCP Backend"
elif [[ "$AZURE_ENABLED" == "true" ]]; then
  echo "Configuring Azure Backend"
fi

echo "export DUPLO_ACCOUNT_ID=$PARAM_ACCOUNT_ID" >> "$BASH_ENV"
echo "export DUPLO_DEFAULT_REGION=$DUPLO_DEFAULT_REGION" >> "$BASH_ENV"

# re-export duplo creds as lowercase
echo "export duplo_token=$DUPLO_TOKEN" >> "$BASH_ENV"
echo "export duplo_host=$DUPLO_HOST" >> "$BASH_ENV"
