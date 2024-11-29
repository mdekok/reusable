@description('Name of the Application Insights.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource.')
param tags object

@description('ResourceId of the Log Analytics Workspace.')
param logAnalyticsWorkspaceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'other'
  properties: {
    Application_Type: 'other'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

output resourceId string = applicationInsights.id
