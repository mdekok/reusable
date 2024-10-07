@description('Name of the SQL logical server.')
param serverName string

@description('Name of the SQL Database.')
param databaseName string

@description('Location for all resources.')
param location string

@description('Administrator username of the SQL logical server.')
@secure()
param administratorLogin string

@description('Administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

@description('Id of the User Assigned Identity.')
param userAssignedIdentityId string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    primaryUserAssignedIdentityId: userAssignedIdentityId
  }
  identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${userAssignedIdentityId}': {}
      }
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: 'GP_S_Gen5' // S indicates serverless
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1 // Max vCores
  }
  properties: {
    autoPauseDelay: 15 // minutes
    maxSizeBytes: 1073741824 // 1 GB max storage
  }
}
