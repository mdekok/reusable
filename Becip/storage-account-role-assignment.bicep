@description('Name of the Storage Account to assign the role on.')
param storageAccountName string

@description('PricipleId of the Mangaged Identity.')
param principalId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

var contributorRoleDefinition = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, contributorRoleDefinition)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinition)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
