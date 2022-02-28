# CI/CD scripts for Azure Databricks

Bash scripts that could be useful for different CI/CD strategies or containers using Azure Databricks.

# Examples

## Deploy notebooks

./configure-aadprofile.sh -u adb-1234567890.22.azuredatabricks.net -n aad && \
    ./deploy-notebooks.sh -a aad -p '/Shared/QA' -n './repos/mydatabricksproject/notebooks'

