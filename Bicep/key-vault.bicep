@description('Name of the Key Vault.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object

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
