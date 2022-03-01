# CI/CD scripts for Azure Databricks

Bash scripts that could be useful for different CI/CD strategies or containers using Azure Databricks.

# Examples

## Deploy notebooks

./configure-aadprofile.sh -u adb-1234567890.22.azuredatabricks.net -n aad && \
    ./deploy-notebooks.sh -a aad -p '/Shared/QA' -n './repos/mydatabricksproject/notebooks'

## Creating an Azure KeyVault Secrets Scope

./configure-aadprofile.sh -u adb-1234567890.22.azuredatabricks.net -n aad && \
    ./init-secretscope.sh -a aad  -p '/subscriptions/8d2cf2aa-bbbb-0000-aaaa-f445f5abe000/resourceGroups/rg-my-rg/providers/Microsoft.KeyVault/vaults/kv-my-kv01234' -k 'https://kv-my-kv01234.vault.azure.net/'