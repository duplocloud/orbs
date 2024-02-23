#!/usr/bin/env bash

packagesNeeded=()

# check if python is installed
if ! command -v python &> /dev/null
then
    echo "Python could not be found"
    packagesNeeded+=("python3")
fi

# if pip is not installed
if ! command -v pip3 &> /dev/null
then
    echo "Pip could not be found"
    packagesNeeded+=("python3-pip")
fi


if [ -x "$(command -v apk)" ];       then sudo apk add --no-cache "${packagesNeeded[*]}"
elif [ -x "$(command -v apt-get)" ]; then sudo apt update && sudo apt-get install "${packagesNeeded[*]}"
elif [ -x "$(command -v dnf)" ];     then sudo dnf install "${packagesNeeded[*]}"
elif [ -x "$(command -v zypper)" ];  then sudo zypper install "${packagesNeeded[*]}"
else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: ${packagesNeeded[*]}">&2; fi


pip3 install duplocloud-client