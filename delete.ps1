# ===============================
# DELETE AKS CLUSTER
# monica-cloud-cluster
# ===============================

$RESOURCE_GROUP = "monica-rg"
$CLUSTER_NAME = "monica-cloud-cluster"

Write-Host "WARNING: This will delete the entire resource group!" -ForegroundColor Yellow
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor Yellow
Write-Host "Cluster: $CLUSTER_NAME" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Are you sure you want to delete? Type DELETE to confirm"

if ($confirmation -eq "DELETE") {
    Write-Host "Deleting Resource Group: $RESOURCE_GROUP..." -ForegroundColor Red
    
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Deletion initiated successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "Check deletion status:" -ForegroundColor Cyan
        Write-Host "  az group show --name $RESOURCE_GROUP" -ForegroundColor White
        Write-Host ""
        Write-Host "Monitor deletion progress:" -ForegroundColor Cyan
        Write-Host "  az group list --output table" -ForegroundColor White
    } else {
        Write-Host "Deletion failed!" -ForegroundColor Red
    }
} else {
    Write-Host "Deletion cancelled - you must type DELETE to confirm" -ForegroundColor Yellow
}