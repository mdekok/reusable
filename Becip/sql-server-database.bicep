@description('Name of the SQL logical server.')
param serverName string

@description('Name of the SQL Database.')
param databaseName string

@description('Administrator username of the SQL logical server.')
@secure()
param administratorLogin string

@description('Administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

@description('Local IP address to allow access to the SQL server.')
param localIpAddress string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: resourceGroup().location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      login: 'info@micheldekok.nl'
      principalType: 'User'
      sid: 'cd86b88e-7516-4538-8173-37390325fb59'
      tenantId: subscription().tenantId
    }
  }
}

resource firewallRulesAzure 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  name: '${serverName}-allow-azure-to-access'
  parent: sqlServer
  properties: {
    endIpAddress: '0.0.0.0' // magic ip address to allow all azure services to acces this server
    startIpAddress: '0.0.0.0'
  }
}

resource firewallRulesLocal 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  name: '${serverName}-allow-local-ip-to-access'
  parent: sqlServer
  properties: {
    endIpAddress: localIpAddress
    startIpAddress: localIpAddress
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: resourceGroup().location
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
