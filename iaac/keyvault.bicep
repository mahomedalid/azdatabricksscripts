param projectName string
param tenantId string = subscription().tenantId

var vaultPrefix = substring(replace('${projectName}', '-', ''), 0, 3)
var vaultName = 'kv-${vaultPrefix}-${uniqueString(resourceGroup().id)}'  // must be globally unique
param location string = resourceGroup().location
param sku string = 'Standard'

param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableRbacAuthorization bool = false
param softDeleteRetentionInDays int = 90

param accessPolicies array = []

resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output vaultName string = vaultName
output keyvault object = keyvault
