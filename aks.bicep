// ===============================
// AKS CLUSTER: monica-cloud-cluster
// CLEAN PRODUCTION TEMPLATE
// ===============================

@description('AKS cluster name')
param clusterName string = 'monica-cloud-cluster'

@description('Azure region')
param location string = resourceGroup().location

@description('Kubernetes version')
param kubernetesVersion string = '1.35.3'

@description('Tags')
param tags object = {
  Environment: 'Production'
  Project: 'MonicaCloud'
}

// ===============================
// LOG ANALYTICS (for monitoring)
// ===============================
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${clusterName}-logs'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// ===============================
// AKS CLUSTER
// ===============================
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  tags: tags

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'

    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }

    apiServerAccessProfile: {
      enablePrivateCluster: false
    }

    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }

      azurepolicy: {
        enabled: true
      }
    }

    agentPoolProfiles: [
      {
        name: 'systempool'
        mode: 'System'
        count: 2
        vmSize: 'Standard_D2s_v3'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
        osDiskSizeGB: 50
      }

      {
        name: 'userpool'
        mode: 'User'
        count: 2
        vmSize: 'Standard_D2s_v3'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        osDiskSizeGB: 50
      }

      {
        name: 'spotpool'
        mode: 'User'
        count: 1
        vmSize: 'Standard_D2s_v3'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 0
        maxCount: 10
        scaleSetPriority: 'Spot'
        scaleSetEvictionPolicy: 'Delete'
        spotMaxPrice: -1
      }
    ]
  }
}

// ===============================
// OUTPUTS
// ===============================
output clusterName string = aks.name
output fqdn string = aks.properties.fqdn