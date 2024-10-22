@description('Name of the Storage Account. Only lowercase leters or numbers are valid.')
@minLength(3)
@maxLength(24)
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource.')
param tags object

@description('Sku name.')
@allowed(['Standard_GRS', 'Standard_LRS'])
param sku string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
}
