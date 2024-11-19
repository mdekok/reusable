@description('Name of the Cosmos DB account')
param accountName string

@description('Name of the Cosmos DB database')
param databaseName string

@description('Location of the resource')
param location string = resourceGroup().location

@description('Containers to create. Properties: name, defaultTtl, partitionKey')
param containers array = []

@description('PricipleId of the Managed Identity.')
param principalId string

@description('Tags for the resource.')
param tags object

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' = {
  name: accountName
  location: location
  tags: tags
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    backupPolicy: {
      type: 'Continuous'
    }
    capacityMode: 'Serverless'
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview' = {
  name: databaseName
  parent: cosmosDbAccount
  location: location
  tags: tags
  properties: {
    resource: {
      id: databaseName
    }
  }
}

// Non-data operations (like creating containers) are not allowed using managed identities, so create containers here already.
// https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/troubleshoot-forbidden#nondata-operations-arent-allowed

resource cosmosDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-09-01-preview' = [for container in containers: {
  name: container.name
  parent: cosmosDbDatabase
  location: location
  properties: {
    // Needs union because setting defaultTtl to null will cause an error, although it should be allowed
    // See: https://github.com/Azure/bicep/issues/5938#issuecomment-1888213336
    resource: union({
      id: container.name
      partitionKey: {
        paths: [
          container.partitionKey
        ]
      }
    }, contains(container, 'defaultTtl') ? { defaultTtl: int(container.defaultTtl) } : {})
  }
}]

// https://blog.johnfolberth.com/assigning-cosmos-data-plane-roles-via-rbac-w-bicep/
var roleDefinitionId = '00000000-0000-0000-0000-000000000002' // Azure Cosmos DB Built-in Data Contributor

resource cosmosDbDataContributorRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  name: guid(roleDefinitionId, principalId, cosmosDbAccount.id)
  parent: cosmosDbAccount
  properties:{
    principalId: principalId
    roleDefinitionId: '/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDbAccount.name}/sqlRoleDefinitions/${roleDefinitionId}'
    scope: cosmosDbAccount.id
  }
}
