#!/bin/bash

# Configure a connection to databricks using an AAD Token

DATABRICKS_PROFILE_NAME="aad"
DATABRICKS_AAD_ID="2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"

while getopts :u:p: option
do
    case "${option}" in
    u) DATABRICKS_URL=${OPTARG};;
    esac
done

if [ -z "$DATABRICKS_URL" ]; then
    echo "usage: $0 -u <databricks_url_without_protocol> [-n profilename]"
    echo " ex.: $0 -u adb-12345600.77.azuredatabricks.net -n aad"
    exit 1
fi

echo "- Getting token from Azure AAD for ${DATABRICKS_AAD_ID}"

token_response=$(az account get-access-token --resource $DATABRICKS_AAD_ID)
export DATABRICKS_AAD_TOKEN=$(jq .accessToken -r <<< "$token_response")

echo "- Configuring databricks profile ${DATABRICKS_PROFILE_NAME}"

databricks configure --host https://${DATABRICKS_URL} --aad-token --profile ${DATABRICKS_PROFILE_NAME}