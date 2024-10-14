@description('Name of the storage account. Only lowercase leters or numbers are valid.')
@minLength(3)
@maxLength(24)
param name string

@description('Location for all resources.')
param location string

@description('Sku name.')
@allowed(['Standard_GRS', 'Standard_LRS'])
param sku string

@description('PricipleId of the User Assigned Identity.')
param principalId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
}

var contributorRoleDefinition = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${name}-roleassignment') // name must be a GUID
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinition)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
