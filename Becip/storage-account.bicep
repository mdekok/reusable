@description('Name of the storage account. Only lowercase leters or numbers are valid.')
@minLength(3)
@maxLength(24)
param name string

@description('Location for all resources.')
param location string

@description('Sku name.')
@allowed(['Standard_GRS', 'Standard_LRS'])
param sku string

@description('Id of the User Assigned Identity.')
param userAssignedIdentityId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
}
