@minLength(5)
@maxLength(8)
@description('Name of environment')
param env string = 'devd4'

@description('Resource tags object to use')
param resourceTag object

var functionName = 'func-textanalytics-${env}-${uniqueString(resourceGroup().id)}'
var planLinuxName = 'plan-scm-linux-${env}-${uniqueString(resourceGroup().id)}'
var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var stForFunctiontName = 'stfn${env}${take(uniqueString(resourceGroup().id), 11)}'
var sbName = 'sb-scm-${env}-${uniqueString(resourceGroup().id)}'
var sbtVisitReportsName = 'sbt-visitreports'
var location = resourceGroup().location
var cosmosAccount = 'cosmos-scm-${env}-${uniqueString(resourceGroup().id)}'

var stgForFunctionConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${stgForFunction.name};AccountKey=${listKeys(stgForFunction.id, stgForFunction.apiVersion).keys[0].value}'

var textAnalyticsName = 'cog-textanalytics-${env}-${uniqueString(resourceGroup().id)}'

resource textAnalytics 'Microsoft.CognitiveServices/accounts@2017-04-18' existing = {
  name: textAnalyticsName
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' existing = {
  name: cosmosAccount
}

resource appi 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appiName
}

resource stgForFunction 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: stForFunctiontName
}

resource planLinux 'Microsoft.Web/serverfarms@2020-12-01' existing = {
  name: planLinuxName
}

resource sb 'Microsoft.ServiceBus/namespaces@2017-04-01' existing = {
  name: sbName
}

resource sbtVisitReports 'Microsoft.ServiceBus/namespaces/topics@2017-04-01' existing = {
  name: '${sb.name}/${sbtVisitReportsName}'
}

resource sbtVisitReportsListenRule 'Microsoft.ServiceBus/namespaces/topics/authorizationRules@2017-04-01' existing = {
  name: '${sbtVisitReports.name}/listen'
}

resource funcapp 'Microsoft.Web/sites@2020-12-01' = {
  name: functionName
  location: location
  tags: resourceTag
  kind: 'functionapp'
  properties: {
    serverFarmId: planLinux.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: stgForFunctionConnectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: stgForFunctionConnectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionName
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~10'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appi.properties.InstrumentationKey
        }
        {
          name: 'ServiceBusConnectionString'
          value: listKeys(sbtVisitReportsListenRule.id, sbtVisitReportsListenRule.apiVersion).primaryConnectionString
        }
        {
          name: 'COSMOSDB'
          value: cosmos.properties.documentEndpoint
        }
        {
          name: 'COSMOSKEY'
          value: listKeys(cosmos.id, cosmos.apiVersion).primaryMasterKey
        }
        {
          name: 'TA_SUBSCRIPTIONENDPOINT'
          value: textAnalytics.properties.endpoint
        }
        {
          name: 'TA_SUBSCRIPTION_KEY'
          value: listKeys(textAnalytics.id, textAnalytics.apiVersion).key1
        }
      ]
    }
  }
}
