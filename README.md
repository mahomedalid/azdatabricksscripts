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

### Prereqs

install python
install azcli
install databricks-cli

### Sample script

```
SUBSCRIPTION_ID=""
PROJECT_NAME="myproject"
AZ_LOCATION="eastus"
DEPLOYMENT_NAME="${PROJECT_NAME}${LOCATION}"
DATABRICKS_PROFILE_NAME='aad'
DATABRICKS_CLUSTER_NAME="qa"

az login
az account set --subscription $SUBSCRIPTION_ID
az bicep install

az deployment sub create -n $DEPLOYMENT_NAME -f infra/main.bicep -l $AZ_LOCATION --parameters projectName=$PROJECT_NAME

DATABRICKS_URL=`az deployment sub show -n ${DEPLOYMENT_NAME} --query properties.outputs.databricksUrl.value -o tsv`

KV_SUBSCRIPTION_ID=`az deployment sub show -n ${DEPLOYMENT_NAME} --query properties.outputs.keyVault.value.subscriptionId -o tsv`
KV_RESOURCE_GROUP=`az deployment sub show -n ${DEPLOYMENT_NAME} --query properties.outputs.keyVault.value.resourceGroupName -o tsv`
KV_RESOURCE_ID=`az deployment sub show -n ${DEPLOYMENT_NAME} --query properties.outputs.keyVault.value.resourceId -o tsv`
KV_URI=`az deployment sub show -n ${DEPLOYMENT_NAME} --query properties.outputs.keyVault.value.properties.vaultUri -o tsv`

./configure-aadprofile.sh -u $DATABRICKS_URL -n $DATABRICKS_PROFILE_NAME

./init_cluster -a $DATABRICKS_PROFILE_NAME -n $DATABRICKS_CLUSTER_NAME -l clusters/libraries.txt -d clusters/default.json

./init-secretscope.sh -a $DATABRICKS_PROFILE_NAME -p "/subscriptions/${KV_SUBSCRIPTION_ID}/resourceGroups/${KV_RESOURCE_GROUP}/providers/${KV_RESOURCE_ID}" -k "$KV_URI"

./deploy-notebooks.sh -a $DATABRICKS_PROFILE_NAME -p '/Shared/QA' -n './repos/mydatabricksproject/notebooks'
```