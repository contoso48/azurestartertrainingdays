@minLength(5)
@maxLength(8)
@description('Name of environment')
param env string = 'devd4'

@description('The SKU of Windows based App Service Plan, default is B1')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
])
param planWindowsSku string = 'B1'

@description('The SKU of Linux based App Service Plan, default is B1')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
])
param planLinuxSku string = 'B1'

@description('Sql server\'s admin login name')
param sqlUserName string

@secure()
@description('Sql server\'s admin password')
param sqlUserPwd string

module common 'common/main.bicep' = {
  name: 'deployCommon'
  params: {
    env: env
    planWindowsSku: planWindowsSku
    planLinuxSku: planLinuxSku
  }
}

module contacts 'contacts/main.bicep' = {
  name: 'deployContacts'
  params: {
    env: env
    sqlUserName: sqlUserName
    sqlUserPwd: sqlUserPwd
  }
  dependsOn: [
    common
  ]
}

module resources 'resources/main.bicep' = {
  name: 'deployResources'
  params: {
    env: env
  }
  dependsOn: [
    common
  ]
}

module visitreports 'visitreports/main.bicep' = {
  name: 'deployVisitReports'
  params: {
    env: env
  }
  dependsOn: [
    common
  ]
}
