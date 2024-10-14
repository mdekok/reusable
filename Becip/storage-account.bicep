@description('Name of the Storage Account. Only lowercase leters or numbers are valid.')
@minLength(3)
@maxLength(24)
param name string

@description('Sku name.')
@allowed(['Standard_GRS', 'Standard_LRS'])
param sku string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
}
