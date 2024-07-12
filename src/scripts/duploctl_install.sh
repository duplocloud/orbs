#!/usr/bin/env bash

PARAM_VERSION=$(circleci env subst "${PARAM_VERSION}")

packagesNeeded=()

# check if python is installed
if ! command -v python &> /dev/null
then
    echo "Python could not be found"
    packagesNeeded+=("python3")
fi

# if pip is not installed
if ! command -v pip &> /dev/null
then
    echo "Pip could not be found"
    packagesNeeded+=("python3-pip")
fi

# if jq is not installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    packagesNeeded+=("jq")
fi

if [ -x "$(command -v apk)" ];       then sudo apk add --no-cache "${packagesNeeded[*]}"
elif [ -x "$(command -v apt-get)" ]; then sudo apt update && sudo apt-get install "${packagesNeeded[*]}"
elif [ -x "$(command -v dnf)" ];     then sudo dnf install "${packagesNeeded[*]}"
elif [ -x "$(command -v zypper)" ];  then sudo zypper install "${packagesNeeded[*]}"
else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: ${packagesNeeded[*]}">&2; fi

if ! command -v pip &> /dev/null
then
    if [[ "$PARAM_VERSION" == "latest" ]]; then
        pip install duplocloud-client
    else
        pip install "duplocloud-client==$PARAM_VERSION"
    fi
    echo "Successfully installed duploctl"
fi

echo "Current Duplocloud versions:"
duploctl version -o yaml
