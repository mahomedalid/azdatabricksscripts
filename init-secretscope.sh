#!/bin/bash

DB_SECRETS_SCOPENAME="azkeyvault"
SCRIPT_DIR=`dirname "$0"`

while getopts :a:p:k:s: option
do
    case "${option}" in
    a) DATABRICKS_PROFILE_NAME=${OPTARG};;
    p) KV_RESOURCE_PATH=${OPTARG};;
    k) KV_URI=${OPTARG};;
    s) DB_SECRETS_SCOPENAME=${OPTARG};;
    esac
done

if [ -z "$DATABRICKS_PROFILE_NAME" ]; then
    echo "usage: $0 -a <profile name> -p <keyvault_resource_path> -k <keyvault_uri> [-s scopename]"
    echo " ex.: $0 -u aad -p '/subscriptions/XXXX/resourceGroups/rg-my-project/providers/YYYYY' -k 'https://kv-my-kv.vault.azure.net/'"
    echo " "
    echo " Arguments "
    echo "  -a  : Databricks profile to be used. "
    echo "  -p  : Azure KeyVault Resource Path Id."
    echo "  -k  : Azure KeyVault URI."
    echo "  -s  : Databricks scope name. This is a reference to be used in the notebooks."
    echo "        Default: azkeyvault"
    exit 1
fi

echo "- Creating databricks keyvault scope [$DB_SECRETS_SCOPENAME] to [$KV_URI]"

DB_SCOPE_EXISTS=`databricks secrets list-scopes --profile $DATABRICKS_PROFILE_NAME | grep $DB_SECRETS_SCOPENAME`

if [ -z "$DB_SCOPE_EXISTS" ]
then
    echo " ... the scope $DB_SECRETS_SCOPENAME does not exists ..."
else 
    echo " ... the scope $DB_SECRETS_SCOPENAME already exists recreating it ..."
    databricks secrets delete-scope --scope $DB_SECRETS_SCOPENAME --profile $DATABRICKS_PROFILE_NAME
fi

echo " ... creating the scope $DB_SECRETS_SCOPENAME linked to $KV_URI"
databricks secrets create-scope \
        --scope $DB_SECRETS_SCOPENAME --scope-backend-type AZURE_KEYVAULT \
        --resource-id "$KV_RESOURCE_PATH" \
        --dns-name "$KV_URI" --profile $DATABRICKS_PROFILE_NAME \
        --initial-manage-principal "users"