@description('Name of the Container App.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Id of the User Assigned Managed Identity.')
param userAssignedManagedIdentityId string

@description('Client Ud of the User Assigned Managed Identity.')
param userAssignedManagedIdentityClientId string

@description('Log Analytics Workspace Customer Id.')
param logAnalyticsWorkspaceCustomerId string

@description('Log Analytics Workspace name.')
param logAnalyticsWorkspaceName string

@description('GitHub Container Registry read token.')
@secure()
param ghcrReadToken string

@description('Sql database connection string.')
@secure()
param sqlConnectionString string

@description('Blob Storage URL.')
@secure()
param blobStorageUrl string

@description('Communication connection string.')
@secure()
param communicationConnectionString string

@description('Security key.')
@secure()
param securityKey string

@description('Syncfusion license key.')
@secure()
param syncfusionLicenseKey string

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${name}-environment'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspaceCustomerId
        sharedKey: listKeys('Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}', '2020-08-01').primarySharedKey
      }
    }
    peerAuthentication: {
      mtls: {
        enabled: false // prevents false positive change
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false // prevents false positive change
      }
    }
  }
}

resource containerapp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  properties: {
    environmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      secrets: [
        {
          name: 'ghcr-read-token-ref'
          value: ghcrReadToken
        }
        {
          name: 'sql-connection-ref'
          value: sqlConnectionString
        }
        {
          name: 'blobstorage-connection-ref'
          value: blobStorageUrl
        }
        {
          name: 'communication-connection-ref'
          value: communicationConnectionString
        }
        {
          name: 'security-key-ref'
          value: securityKey
        }
        {
          name: 'syncfusion-license-key-ref'
          value: syncfusionLicenseKey
        }
      ]
      registries: [
        {
          server: 'ghcr.io'
          username: 'mdekok'
          passwordSecretRef: 'ghcr-read-token-ref'
        }
      ]
      ingress: {
        external: true
        transport: 'auto'
        allowInsecure: false
        targetPort: 8080
      }
    }
    template: {
      containers: [
        {
          name: '${name}-container'
          image: 'ghcr.io/mdekok/bsapp:v2425.2.3'
          resources: {
            cpu: json('0.25')
            memory: '.5Gi'
          }
          env: [
            {
              name: 'AZURE_CLIENT_ID'
              value: userAssignedManagedIdentityClientId
            }
            {
              name: 'ConnectionStrings__Db'
              secretRef: 'sql-connection-ref'
            }
            {
              name: 'ConnectionStrings__BlobStorage'
              secretRef: 'blobstorage-connection-ref'
            }
            {
              name: 'ConnectionStrings__Communication'
              secretRef: 'communication-connection-ref'
            }
            {
              name: 'SecurityKey'
              secretRef: 'security-key-ref'
            }
            {
              name: 'Syncfusion__LicenseKey'
              secretRef: 'syncfusion-license-key-ref'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
}
