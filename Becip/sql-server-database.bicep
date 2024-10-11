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

@description('Local IP address to allow access to the SQL server.')
param localIpAddress string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource administrator 'Microsoft.Sql/servers/administrators@2023-08-01-preview' = {
  name: '${serverName}-administrator'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: administratorLogin
    sid: 'cd86b88e-7516-4538-8173-37390325fb59'
    tenantId: subscription().tenantId
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
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
}

#disable-next-line no-hardcoded-env-urls
var server = 'Server=${serverName}.database.windows.net'
var db = 'Database=${databaseName}'
var user = 'User Id=${userAssignedIdentityId}'

output connectionString string = '${server};${db};${user};Authentication=Active Directory Managed Identity;Encrypt=True;'

