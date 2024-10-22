@description('Name of the Communication Services.')
param name string

@description('Tags for the resource.')
param tags object

@description('Email Domain resource Ids.')
param linkedDomains array = []

resource communcationServices 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    dataLocation: 'Europe'
    linkedDomains: linkedDomains
  }
}
