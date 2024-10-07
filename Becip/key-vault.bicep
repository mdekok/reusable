@description('Name of the Key Vault.')
param name string

@description('Location for all resources.')
param location string

@description('TenantId of Microsoft Entra ID.')
param tenantId string

@description('PricipleId of the User Assigned Identity.')
param principalId string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: name
  location: location
  properties: {
    tenantId: tenantId
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

var keyVaultSecretUserRoleDefinition = '4633458b-17de-408a-b874-0445c86b69e6'

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${name}-roleassignment') // name must be a GUID
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretUserRoleDefinition)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
