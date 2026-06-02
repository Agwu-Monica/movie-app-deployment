# Complete Beginner-to-DevOps AKS Movie App Deployment Guide

## This guide teaches you how to:

Create an AKS cluster
Build backend and frontend applications
Dockerize applications
Push images to Azure Container Registry (ACR)
Deploy applications to Kubernetes
Expose applications publicly
Understand how everything connects together

## ARCHITECTURE

User Browser
      ↓
Frontend LoadBalancer Service
      ↓
Frontend Pods
      ↓
Backend ClusterIP Service
      ↓
Backend Pods

## TECHNOLOGIES USED
Microsoft Azure	Cloud platform
Azure Kubernetes Service	
Kubernetes cluster
Docker	Containerization
Kubernetes	Container orchestration
Node.js	Backend/frontend runtime
Express.js	API server
Azure Container Registry	Store Docker images
Visual Studio Code	Development editor
OpenLens	Kubernetes dashboard



### STEP 1 — Create Project Folder 
On your PC:
C:\k8s-azure\

 
### STEP 2 — Open Folder in PowerShell 
cd C:\k8s-azure


### STEP 3 — LOGIN
az login --use-device-code
 Browser opens → sign in


### STEP 4 — CREATE RESOURCE GROUP
Resource group = container for Azure resources.
Create:
az group create `
  --name monica-rg `
  --location eastus


###  Verify:
az group list --output table


## CREATE AKS CLUSTER

Inside:
C:\k8s-azure
create:
aks.bicep
 copy the aks.bicep code in service branch


## DEPLOY AKS
az deployment group create --resource-group monica-rg --template-file aks.bicep
Wait 10–20 minutes.
if it fails go to https://github.com/Azure/bicep/releases/tag/v0.43.8 download bicep-win-x64.exe on your local computer, make sure its in download folder 


## Now in PowerShell:
run cd $HOME\Downloads and this .\bicep-win-x64.exe


## Move it to Azure folder
Run: Move-Item .\bicep-win-x64.exe $HOME\.azure\bin\bicep.exe -Force

Test: az bicep version
az bicep install

### go back to correct folder
Run:
cd "C:\Users\owner\OneDrive\Desktop\K8S-AZURE"
Then check: dir
You should see: aks.bicep
Now run:
az deployment group create --resource-group monica-rg --template-file aks.bicep


if it fails run : az aks get-versions --location eastus -o table pick the highest version usually No 1 edit this line param kubernetesVersion string = '1.35.3' in your code and put it

### This service is needed because your Bicep includes:
Log Analytics
Monitoring (OMS agent)
Run this:
az provider register --namespace Microsoft.OperationsManagement

then wait Registration takes: 1–5 minutes

### Check status:
az provider show --namespace Microsoft.OperationsManagement --query registrationState
You will see: "Registered"

### ALSO register this (important for AKS monitoring)
Run:
az provider register --namespace Microsoft.OperationalInsights

redeploy: az deployment group create --resource-group monica-rg --template-file aks.bicep


## VERIFY CLUSTER
kubectl get nodes

Expected:
aks-systempool...


## CREATE AZURE CONTAINER REGISTRY

Create ACR:
az acr create `
  --resource-group monica-rg `
  --name monicacontainerregistry123 `
  --sku Basic


### LOGIN TO ACR
az acr login `
  --name monicacontainerregistry123



### Open VS Code → terminal and run:
mkdir workloads.k8         
cd workloads.k8       

Create Pod file
Create file:
pod.yaml
copy the pod.yaml code in workloads.k8 folder in service branch

Create ReplicaSet file
Create file:
replicaset.yaml
copy the replica.yaml code in workloads.k8 folder in service branch

Deploy everything
Run these commands:

1. Create Pod
kubectl apply -f pod.yaml

2. Create ReplicaSet
kubectl apply -f replicaset.yaml

Verify
kubectl get pods
kubectl get rs


## Download openlens/freelens and confirm in openlens/freelens
open the pod you created go down you will see forward click on it and add the  pod number   you will see welcome to nginx


## SCALE YOUR REPLICASET
First check current ReplicaSet:
kubectl get rs

🔼 Scale UP to 8 replicas
kubectl scale rs app-replicaset --replicas=8

🔽 Scale DOWN to 5 replicas
kubectl scale rs app-replicaset --replicas=5
Verify
kubectl get pods


## CREATE DEPLOYMENT FILE
Create deploy.yaml file
copy the DEPLOYMENT 1 (NGINX v1) deploy.yaml code in workloads.k8 folder in service branch

## CREATE DEPLOYMENT FILE
Create deploy.yaml file
copy the DEPLOYMENT 2 (LATEST NGINX) deploy.yaml code in workloads.k8 folder in service branch

kubectl apply -f deploy.yaml


### ROLLING UPDATE (UPGRADE IMAGE)

Example upgrade v1 → v2:

kubectl set image deployment/nginx-deploy-v1 nginx=nginx:1.25

🔽 ROLLBACK

If something breaks:

kubectl rollout undo deployment/nginx-deploy-v1


### CHECK ROLLOUT STATUS
kubectl rollout status deployment/nginx-deploy-v1

### CHECK HISTORY
kubectl rollout history deployment/nginx-deploy-v1


check nginx image version
Run:
kubectl get pods -o wide
Then:
kubectl describe pod <pod-name>
Look for:
Image: nginx:1.23


## Create service file
Create file:
service.yaml
copy the service.yaml code in workloads.k8 folder in service branch


## CREATE APPLICATION STRUCTURE

Create folders:
mkdir backend
mkdir frontend
mkdir kubernetes



## CREATE BACKEND APPLICATION

Go into backend: cd backend
Create src folder > data > movie.js
create package.json file
package-lock.json file
server.js file
dockerfile


## TEST BACKEND LOCALLY
Run:
npm install
npm start

Open:
http://localhost:5000/api/v1/movies


## CREATE FRONTEND APPLICATION

Go into frontend:
cd frontend
create dockerfile
index.html file


## BUILD IMAGES INTO ACR

Build Backend Image
az acr build `
  --registry monicacontainerregistry123 `
  --image movie-backend:1.0 `
  ./backend

Build Frontend Image
az acr build `
  --registry monicacontainerregistry123 `
  --image movie-frontend:1.0 `
  ./frontend


## CREATE KUBERNETES MANIFESTS

Go into:
cd kubernetes
create backend.yaml file
backend-service.yaml file
frontend.yaml file
frontend-servive.yaml file


 ## DEPLOY APPLICATIONS

Deploy backend:
kubectl apply -f backend.yaml
kubectl apply -f backend-service.yaml

Deploy frontend
kubectl apply -f frontend.yaml
kubectl apply -f frontend-service.yaml


### VERIFY EVERYTHING
kubectl get pods
kubectl get svc

Expected:

Service	Type
backend-service	ClusterIP
frontend-service	LoadBalancer


### GET PUBLIC IP
kubectl get svc

Example:
frontend-service   LoadBalancer   57.151.30.98

### Open browser:
http://57.151.30.98
Your movie app appears.



## HOW EVERYTHING WORKS

Frontend
Displays webpage
Calls backend API

Backend 
Returns movie data

Docker
Packages applications into containers

ACR
Stores container images

AKS
Runs containers
Kubernetes Services
Create networking between applications


## CHECK IN OPENLENS

Open:
OpenLens
or Freelens

You can now see:
Pods
Services
Deployments
Logs
Events
Containers
Networking



## DELETE EVERYTHING WHEN DONE

Delete resource group:

az group delete `
  --name monica-rg `
  --yes

Everything deletes automatically:

AKS
ACR
LoadBalancers
IPs
Monitoring
Networking
Node pools

