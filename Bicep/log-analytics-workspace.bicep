@description('Name of the Log Analytics Workspace.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018' // prevents false positive change
    }
    retentionInDays: 30 // prevents false positive change
    workspaceCapping: {} // prevents false positive change
  }
}

output customerId string = logAnalyticsWorkspace.properties.customerId
