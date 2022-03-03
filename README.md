# CI/CD scripts for Azure Databricks

Bash scripts that could be useful for different CI/CD strategies or containers using Azure Databricks.

# Examples

## Deploy notebooks

```
./configure-aadprofile.sh -u adb-1234567890.22.azuredatabricks.net -a aad && \
    ./deploy-notebooks.sh -a aad -p '/Shared/QA' -n './repos/mydatabricksproject/notebooks'
```

## Creating an Azure KeyVault Secrets Scope

```
./configure-aadprofile.sh -u adb-1234567890.22.azuredatabricks.net -a aad && \
    ./init-secretscope.sh -a aad  -p '/subscriptions/8d2cf2aa-bbbb-0000-aaaa-f445f5abe000/resourceGroups/rg-my-rg/providers/Microsoft.KeyVault/vaults/kv-my-kv01234' -k 'https://kv-my-kv01234.vault.azure.net/'
```

## Init cluster

./configure-aadprofile.sh -u adb-1234567890.22.azuredatabricks.net -a aad && \
    ./init_cluster -a aad -n qa -l clusters/libraries.txt -d clusters/default.json

## Creating the full environment

az account
az login
install python
install azcli
install databricks-cli
[WIP]

... Deploy bicep ... take outputs ... >

```
DATABRICKS_PROFILE_NAME='aad'
DATABRICKS_URL='adb-1234567890.22.azuredatabricks.net'

./configure-aadprofile.sh -u $DATABRICKS_URL -n $DATABRICKS_PROFILE_NAME

./init-cluster.sh -a $DATABRICKS_PROFILE_NAME ...

./init-secretscope.sh -a $DATABRICKS_PROFILE_NAME -p "/subscriptions/${KV_SUBSCRIPTION_ID}/resourceGroups/${KV_RESOURCE_GROUP}/providers/${KV_RESOURCE_ID}" -k "$KV_URI"

./deploy-notebooks.sh -a $DATABRICKS_PROFILE_NAME -p '/Shared/QA' -n './repos/mydatabricksproject/notebooks'
```