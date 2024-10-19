@description('Name of the Communication Services.')
param name string

@description('Email Domain resource Ids.')
param linkedDomains array = []

resource communcationServices 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: name
  location: 'global'
  properties: {
    dataLocation: 'Europe'
    linkedDomains: linkedDomains
  }
}
