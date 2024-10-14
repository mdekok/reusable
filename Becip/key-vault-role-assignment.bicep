@description('Name of the Key Vault to assign the role on.')
param keyvaultName string

@description('PricipleId of the Managed Identity.')
param principalId string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyvaultName
}

var keyVaultSecretUserRoleDefinition = '4633458b-17de-408a-b874-0445c86b69e6'

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, principalId, keyVaultSecretUserRoleDefinition)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretUserRoleDefinition)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
