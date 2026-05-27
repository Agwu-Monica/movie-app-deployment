STEP 1 — Create Project Folder 
On your PC:
C:\k8s-azure\
Inside it create:
C:\k8s-azure\aks.bicep

 
STEP 2 — Open Folder in PowerShell 
cd C:\k8s-azure


 STEP 3 — Create ONE FILE  (aks.bicep)
paste the aks.bicep code in service branch


STEP 4 — LOGIN
az login --use-device-code
 Browser opens → sign in


STEP 5 — CREATE RESOURCE GROUP
az deployment group create --resource-group monica-rg --template-file aks.bicep
if it fails go to https://github.com/Azure/bicep/releases/tag/v0.43.8 download bicep-win-x64.exe on your local computer, make sure its in download folder 


Now in PowerShell:
run cd $HOME\Downloads and this .\bicep-win-x64.exe



Move it to Azure folder
Run: Move-Item .\bicep-win-x64.exe $HOME\.azure\bin\bicep.exe -Force

Test: az bicep version
az bicep install

go back to correct folder
Run:
cd "C:\Users\owner\OneDrive\Desktop\K8S-AZURE"
Then check: dir
You should see: aks.bicep
Now run:
az deployment group create --resource-group monica-rg --template-file aks.bicep


if it fails run : az aks get-versions --location eastus -o table pick the highest version usually No 1 edit this line param kubernetesVersion string = '1.35.3' in your code and put it

This service is needed because your Bicep includes:
Log Analytics
Monitoring (OMS agent)
Run this:
az provider register --namespace Microsoft.OperationsManagement

then wait Registration takes: 1–5 minutes

Check status:
az provider show --namespace Microsoft.OperationsManagement --query registrationState
You will see: "Registered"

ALSO register this (important for AKS monitoring)
Run:
az provider register --namespace Microsoft.OperationalInsights

redeploy: az deployment group create --resource-group monica-rg --template-file aks.bicep

Open VS Code → terminal and run:
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

download openlens/freelens and confirm in openlens/freelens
open the pod you created go down you will see forward click on it and add the  pod number   you will see welcome to nginx

SCALE YOUR REPLICASET
First check current ReplicaSet:
kubectl get rs

🔼 Scale UP to 8 replicas
kubectl scale rs app-replicaset --replicas=8

🔽 Scale DOWN to 5 replicas
kubectl scale rs app-replicaset --replicas=5
Verify
kubectl get pods

CREATE DEPLOYMENT FILE
Create deploy.yaml file
copy the DEPLOYMENT 1 (NGINX v1) deploy.yaml code in workloads.k8 folder in service branch

CREATE DEPLOYMENT FILE
Create deploy.yaml file
copy the DEPLOYMENT 2 (LATEST NGINX) deploy.yaml code in workloads.k8 folder in service branch

kubectl apply -f deploy.yaml


ROLLING UPDATE (UPGRADE IMAGE)

Example upgrade v1 → v2:

kubectl set image deployment/nginx-deploy-v1 nginx=nginx:1.25

🔽 ROLLBACK

If something breaks:

kubectl rollout undo deployment/nginx-deploy-v1


CHECK ROLLOUT STATUS
kubectl rollout status deployment/nginx-deploy-v1
📜 CHECK HISTORY
kubectl rollout history deployment/nginx-deploy-v1


check nginx image version
Run:
kubectl get pods -o wide
Then:
kubectl describe pod <pod-name>
Look for:
Image: nginx:1.23


Create service file
Create file:
service.yaml
copy the service.yaml code in workloads.k8 folder in service branch









Create backend.yaml

kubectl port-forward deployment/movie-backend 5000:80

create backend-servive.yaml

az acr login -n monicacontainerregistry123 --expose-token

az acr build \
  --registry monicacontainerregistry123 \
  --image movie-backend:1.0 \
  ./backend

  you will see these
  NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
backend-service      LoadBalancer   10.0.205.0     13.82.166.157    80:30900/TCP   161m
frontend-service     LoadBalancer   10.0.151.231   57.151.30.98     80:31204/TCP   7m15s
kubernetes           ClusterIP      10.0.0.1       <none>           443/TCP        7h27m
nginx-clusterip      ClusterIP      10.0.106.49    <none>           80/TCP         4h51m
nginx-loadbalancer   LoadBalancer   10.0.133.195   20.241.184.145   80:30304/TCP   4h45m

