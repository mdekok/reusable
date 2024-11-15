@description('Name of the Key Vault.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object

@description('PricipleId of the Managed Identity.')
param principalId string

@description('Name of source Key Vault')
param sourceKeyVaultName string

@description('Resource Group of source Key Vault')
param sourceKeyVaultResourceGroup string

param secretRefs array = []

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

resource sourceKeyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: sourceKeyVaultName
  scope: resourceGroup(sourceKeyVaultResourceGroup)
}

module keyVaultSecret 'key-vault-secret.bicep' = [for secretRef in secretRefs: {
  name: 'key-vault-secret-${secretRef.name}'
  params: {
    keyvaultName: name
    name: secretRef.name
    secret: sourceKeyVault.getSecret(secretRef.sourceName)
    tags: tags
  }
  dependsOn: [
    keyVault
  ]
}]

// Azure built-in roles: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

module keyVaultRoleAssignment 'key-vault-role-assignment.bicep' = {
  name: 'key-vault-role-assignment'
  params: {
    keyvaultName: name
    roleId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
    principalId: principalId
  }
  dependsOn: [
    keyVault
  ]
}
