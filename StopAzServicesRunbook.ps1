param (
    [Parameter(Mandatory=$true)]
    [string] $subscriptionId
)

# Login to Azure
Connect-AzAccount

# Select the Azure subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Stop all VMs
$vms = Get-AzVM
foreach ($vm in $vms) {
    Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force
}

# Stop all VM scale sets
$vmss = Get-AzVmss
foreach ($scaleSet in $vmss) {
    Stop-AzVmss -ResourceGroupName $scaleSet.ResourceGroupName -VMScaleSetName $scaleSet.Name -Force
}

# Stop all Azure Container Instances (ACI)
$aci = Get-AzContainerGroup
foreach ($containerGroup in $aci) {
    Stop-AzContainerGroup -ResourceGroupName $containerGroup.ResourceGroupName -Name $containerGroup.Name
}

# Stop all Azure App Services
$appServices = Get-AzWebApp
foreach ($appService in $appServices) {
    Stop-AzWebApp -ResourceGroupName $appService.ResourceGroupName -Name $appService.Name
}

# Stop all Azure Synapse workspaces
$synapseWorkspaces = Get-AzSynapseWorkspace
foreach ($workspace in $synapseWorkspaces) {
    Stop-AzSynapseSparkPool -ResourceGroupName $workspace.ResourceGroupName -WorkspaceName $workspace.Name -Name "default"
    # Add additional pools if needed
}

# Stop all Azure Service Fabric clusters
$serviceFabricClusters = Get-AzServiceFabricCluster
foreach ($cluster in $serviceFabricClusters) {
    Stop-AzServiceFabricCluster -ResourceGroupName $cluster.ResourceGroupName -Name $cluster.Name
}

# Stop all Microsoft Fabric capacities
$fabricCapacities = Get-AzResource -ResourceType "Microsoft.PowerBICapacities/capacities"
foreach ($capacity in $fabricCapacities) {
    Suspend-AzResource -ResourceId $capacity.ResourceId -Force
}

# Stop all Azure Databricks clusters
$databricksWorkspaces = Get-AzResource -ResourceType "Microsoft.Databricks/workspaces"
foreach ($workspace in $databricksWorkspaces) {
    $workspaceUrl = "https://" + $workspace.Properties.workspaceUrl
    $resource = $workspace.Properties.workspaceResourceId
    $tokenResponse = Get-AzAccessToken -ResourceUrl $resource
    $token = $tokenResponse.Token

    $clusters = Invoke-RestMethod -Method Get -Uri "$workspaceUrl/api/2.0/clusters/list" -Headers @{Authorization = "Bearer $token"}
    foreach ($cluster in $clusters.clusters) {
        Invoke-RestMethod -Method Post -Uri "$workspaceUrl/api/2.0/clusters/delete" -Headers @{Authorization = "Bearer $token"} -Body (@{cluster_id=$cluster.cluster_id} | ConvertTo-Json)
    }
}
