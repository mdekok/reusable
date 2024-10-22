@description('Name of the Key Vault secret.')
param name string

@description('Value of the secret.')
@secure()
param secret string

@description('Name of the Key Vault to add secret to.')
param keyvaultName string

@description('Tags for the resource.')
param tags object

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyvaultName
}

resource keyvaultsecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: name
  tags: tags
  properties: {
    value: secret
  }
}
