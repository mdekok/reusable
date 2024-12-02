@description('Name of the User Assigned Identity.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
}
