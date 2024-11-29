@description('Name of the Log Analytics Workspace.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018' // prevents false positive change
    }
    retentionInDays: 30 // prevents false positive change
    workspaceCapping: {} // prevents false positive change
  }
}

output resourceId string = logAnalyticsWorkspace.id
output customerId string = logAnalyticsWorkspace.properties.customerId
