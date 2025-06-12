@description('Name of the Storage Account. Only lowercase leters or numbers are valid.')
@minLength(3)
@maxLength(24)
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource.')
param tags object

@description('PricipleId of the Managed Identity.')
param principalId string

@description('Sku name.')
@allowed(['Standard_GRS', 'Standard_LRS'])
param sku string

@description('Specifies whether public access to blobs is allowed to be set at the container level. Default is false.')
param allowBlobPublicAccess bool = false

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: allowBlobPublicAccess
  }
}

// Azure built-in roles: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

module storageAccountRoleAssignment 'storage-account-role-assignment.bicep' = {
  name: '${name}-blob-storage-account-role-assignment'
  params: {
    storageAccountName: name
    roleId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
    principalId: principalId
  }
}

module funcStorageQueueAccountRoleAssignment 'storage-account-role-assignment.bicep' = {
  name: '${name}-queue-storage-account-role-assignment'
  params: {
    storageAccountName: name
    roleId: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' // Storage Queue Data Contributor
    principalId: principalId
  }
}
