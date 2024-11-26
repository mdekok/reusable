@description('Name of the Container App.')
param name string

@description('Location of resource')
param location string = resourceGroup().location

@description('Tags for the resource.')
param tags object

@description('Id of the User Assigned Managed Identity.')
param userAssignedManagedIdentityId string

@description('Client Ud of the User Assigned Managed Identity.')
param userAssignedManagedIdentityClientId string

@description('Log Analytics Workspace Customer Id.')
param logAnalyticsWorkspaceCustomerId string

@description('Log Analytics Workspace name.')
param logAnalyticsWorkspaceName string

@description('Image (ghcr.io/mdekok/bsapp:{version})')
param image string

@description('GitHub Container Registry read token.')
@secure()
param ghcrReadToken string

@description('Environment variables.')
param env array = []

@description('Name of Key Vault holding the secrets.')
param keyVaultName string

// Bicep does not allow secure array parameters
// https://github.com/Azure/bicep/issues/8733
// We use references to key vault secrets for now.
@description('Secret references. Properties: name (of secret), envVar (environment variable for the secret value)')
param secrets array = []

var appSecrets = [for secret in secrets: {
    name: secret.name
    keyVaultUrl: 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/secrets/${secret.name}'
    identity: userAssignedManagedIdentityId
  }]
var appSecretRefs = [for secret in secrets: {
    name: secret.envVar
    secretRef: secret.name
  }]
  
resource environment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${name}-environment'
  location: location
  tags: tags
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
  tags: tags
  properties: {
    environmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      secrets: concat([
        {
          name: 'ghcr-read-token-ref'
          value: ghcrReadToken
        }],
        appSecrets)
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
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          name: '${name}-container'
          image: image
          resources: {
            cpu: json('0.25')
            memory: '.5Gi'
          }
          env: concat([
            {
              name: 'AZURE_CLIENT_ID'
              value: userAssignedManagedIdentityClientId
            }],
            env,
            appSecretRefs)
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

output serviceUrl string = containerapp.properties.configuration.ingress.fqdn
