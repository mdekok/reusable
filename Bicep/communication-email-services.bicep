@description('Name of the Email Communication Services.')
param name string

@description('Use Custom Domain. Empty string creates Azure Managed Domain.')
param customDomain string = ''

@description('Custom Domain User Name.')
param customDomainUserName string = 'DoNotReply'

@description('Custom Domain Display Name.')
param customDomainDisplayName string = 'DoNotReply'

// https://medium.com/medialesson/deploying-azure-email-communication-service-with-bicep-e52954c47b7
// https://medium.com/medialesson/how-to-send-emails-at-scale-in-net-with-the-azure-communication-service-14565d84147f

resource emailCommuncationServices 'Microsoft.Communication/emailServices@2023-04-01' = {
  name: name
  location: 'global'
  properties: {
    dataLocation: 'Europe'
  }
}

var useAzureManagedDomain = customDomain == ''

// ========== Azure Managed Domain

resource emailServiceAzureDomain 'Microsoft.Communication/emailServices/domains@2023-04-01' =
if (useAzureManagedDomain) {
  parent: emailCommuncationServices
  name: 'AzureManagedDomain'
  location: 'global'
  properties: {
    domainManagement: 'AzureManaged'
    userEngagementTracking: 'Disabled'
  }
}

// ========== Custom Managed Domain

resource emailServiceCustomDomain 'Microsoft.Communication/emailServices/domains@2023-04-01' =
if (!useAzureManagedDomain) {
  parent: emailCommuncationServices
  name: customDomain
  location: 'global'
  properties: {
    domainManagement: 'CustomerManaged'
    userEngagementTracking: 'Disabled'
  }
}

resource senderEmailServiceCustomDomain 'Microsoft.Communication/emailServices/domains/senderUsernames@2023-04-01' =
if (!useAzureManagedDomain) {
  parent: emailServiceCustomDomain
  name: customDomainUserName
  properties: {
    username: customDomainUserName
    displayName: customDomainDisplayName
  }
}

output emailDomainResourceId string = useAzureManagedDomain 
  ? emailServiceAzureDomain.id 
  : emailServiceCustomDomain.id

output emailSenderAddress string = useAzureManagedDomain
  ? 'DoNotReply@${emailServiceAzureDomain.properties.fromSenderDomain}'
  : '${customDomainUserName}@${customDomain}'
