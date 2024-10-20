@description('Name of the Email Communication Services.')
param name string

@description('Use Azure Managed Domain instead of Custom Domain.')
param useAzureManagedDomain bool

// https://medium.com/medialesson/deploying-azure-email-communication-service-with-bicep-e52954c47b7
// https://medium.com/medialesson/how-to-send-emails-at-scale-in-net-with-the-azure-communication-service-14565d84147f

resource emailCommuncationServices 'Microsoft.Communication/emailServices@2023-04-01' = {
  name: name
  location: 'global'
  properties: {
    dataLocation: 'Europe'
  }
}

resource emailServiceAzureDomain 'Microsoft.Communication/emailServices/domains@2023-03-31' = if (useAzureManagedDomain) {
  parent: emailCommuncationServices
  name: 'AzureManagedDomain'
  location: 'global'
  properties: {
    domainManagement: 'AzureManaged'
    userEngagementTracking: 'Disabled'
  }
}

output emailDomainResourceId string = useAzureManagedDomain ? emailServiceAzureDomain.id : ''
