@description('Name of the Email Communication Services.')
param name string

@description('Tags for the resource.')
param tags object

@description('Domain settings. Object with domain, userName and displayName properties.')
param domainSettings object = {}

// https://medium.com/medialesson/deploying-azure-email-communication-service-with-bicep-e52954c47b7
// https://medium.com/medialesson/how-to-send-emails-at-scale-in-net-with-the-azure-communication-service-14565d84147f

resource emailCommuncationServices 'Microsoft.Communication/emailServices@2023-04-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    dataLocation: 'Europe'
  }
}

var useAzureManagedDomain = !contains(domainSettings, 'domain')

// ========== Azure Managed Domain

resource emailServiceAzureDomain 'Microsoft.Communication/emailServices/domains@2023-04-01' =
if (useAzureManagedDomain) {
  parent: emailCommuncationServices
  name: 'AzureManagedDomain'
  location: 'global'
  tags: tags
  properties: {
    domainManagement: 'AzureManaged'
    userEngagementTracking: 'Disabled'
  }
}

// ========== Custom Managed Domain

var domain = domainSettings.?domain ?? ''
var userName = domainSettings.?userName ?? 'DoNotReply'
var displayName = domainSettings.?displayName ?? 'Do not reply'

resource emailServiceCustomDomain 'Microsoft.Communication/emailServices/domains@2023-04-01' =
if (!useAzureManagedDomain) {
  parent: emailCommuncationServices
  name: domain
  location: 'global'
  tags: tags
  properties: {
    domainManagement: 'CustomerManaged'
    userEngagementTracking: 'Disabled'
  }
}

resource senderEmailServiceCustomDomain 'Microsoft.Communication/emailServices/domains/senderUsernames@2023-04-01' =
if (!useAzureManagedDomain) {
  parent: emailServiceCustomDomain
  name: userName
  properties: {
    username: userName
    displayName: displayName
  }
}

output emailDomainResourceId string = useAzureManagedDomain 
  ? emailServiceAzureDomain.id 
  : emailServiceCustomDomain.id

output emailSenderAddress string = useAzureManagedDomain
  ? 'DoNotReply@${emailServiceAzureDomain.properties.fromSenderDomain}'
  : '${userName}@${domain}'
