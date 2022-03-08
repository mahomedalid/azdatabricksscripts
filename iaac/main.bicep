@minLength(3)
@maxLength(10)
param projectName string = 'qatest'

param resourceGroupName string = 'rg-${projectName}'
param location string = deployment().location

@secure()
param sqldbPassword string

targetScope = 'subscription'

resource mainResourceGroup 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: resourceGroupName
  location: location
}

module keyvault './keyvault.bicep' = {
  name: 'keyvault'
  scope: mainResourceGroup
  params: {
    projectName: projectName
  }
}

module databricks './databricks.bicep' = {
  name: 'databricks'
  scope: mainResourceGroup
  params: {
    workspaceName: 'db-${projectName}'
  }
}

output resourceGroupName string = resourceGroupName
output databricksUrl string = databricks.outputs.workspace.properties.workspaceUrl
output keyVault object = keyvault.outputs.keyvault