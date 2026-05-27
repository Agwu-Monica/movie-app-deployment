# ===============================
# DEPLOY AKS CLUSTER
# monica-cloud-cluster
# ===============================

$RESOURCE_GROUP = "monica-rg"
$LOCATION = "eastus"
$BICEP_FILE = "aks.bicep"
$CLUSTER_NAME = "monica-cloud-cluster"

Write-Host "Starting AKS Cluster Deployment..." -ForegroundColor Green
Write-Host "Cluster: $CLUSTER_NAME" -ForegroundColor Cyan
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor Cyan
Write-Host ""

# Step 1: Login to Azure
Write-Host "Step 1: Login to Azure" -ForegroundColor Cyan
az login --use-device-code

if ($LASTEXITCODE -ne 0) {
    Write-Host "Login failed!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 2: Show subscriptions
Write-Host "Available Subscriptions:" -ForegroundColor Cyan
az account list --output table
Write-Host ""

# Step 3: Create Resource Group
Write-Host "Step 2: Creating Resource Group: $RESOURCE_GROUP" -ForegroundColor Cyan
az group create --name $RESOURCE_GROUP --location $LOCATION

if ($LASTEXITCODE -ne 0) {
    Write-Host "Resource group creation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Resource Group Created" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy Bicep Template
Write-Host "Step 3: Deploying AKS Cluster - This takes 5-10 minutes..." -ForegroundColor Cyan
Write-Host "Please wait..." -ForegroundColor Yellow
Write-Host ""

az deployment group create `
  --resource-group $RESOURCE_GROUP `
  --template-file $BICEP_FILE `
  --parameters clusterName=$CLUSTER_NAME `
  --verbose

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment Failed!" -ForegroundColor Red
    Write-Host "Check the error messages above for details." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Cluster Deployment Successful!" -ForegroundColor Green
Write-Host ""

# Step 5: Get Cluster Credentials
Write-Host "Step 4: Getting Cluster Credentials..." -ForegroundColor Cyan
az aks get-credentials `
  --resource-group $RESOURCE_GROUP `
  --name $CLUSTER_NAME `
  --overwrite-existing

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to get credentials!" -ForegroundColor Red
    exit 1
}
Write-Host "Credentials Configured" -ForegroundColor Green
Write-Host ""

# Step 6: Verify Cluster
Write-Host "Step 5: Verifying Cluster..." -ForegroundColor Cyan
kubectl get nodes

if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: kubectl failed to connect" -ForegroundColor Yellow
    Write-Host "You may need to wait a moment for the cluster to be ready" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "AKS Cluster Ready!" -ForegroundColor Green
    Write-Host "Cluster Name: $CLUSTER_NAME" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  kubectl get nodes" -ForegroundColor White
Write-Host "  kubectl get pods -A" -ForegroundColor White
Write-Host "  kubectl cluster-info" -ForegroundColor White