# CourtMate Kubernetes Infrastructure

## Current Production Setup

### Azure AKS Cluster
- **Cluster Name**: CourtMateRSO
- **Resource Group**: CourtMate
- **Location**: polandcentral
- **Kubernetes Version**: 1.33.5
- **Node Count**: 2 (auto-scaling enabled)

### Container Registry
- **ACR Name**: courtmate603fc8acr.azurecr.io
- **SKU**: Basic
- **Integrated with AKS**: Yes (AcrPull role assigned)

### Domain Configuration
- **Primary Domain**: https://courtmate.duckdns.org
- **Grafana**: https://grafana.courtmate.duckdns.org
- **Prometheus**: https://prometheus.courtmate.duckdns.org
- **SSL/TLS**: Let's Encrypt (via cert-manager)
- **Ingress Controller**: NGINX
- **LoadBalancer IP**: 134.112.145.160

## Requirements

### Tools
- **Azure CLI** - For managing Azure resources
  ```bash
  brew install azure-cli
  ```
- **kubectl** - Kubernetes command-line tool
  ```bash
  brew install kubectl
  ```
- **Helm** - Package manager for Kubernetes
  ```bash
  brew install helm
  ```
- **Docker** - For building container images
  ```bash
  brew install docker
  ```

## Quick Start

### Connect to Cluster

```bash
# Login to Azure
az login

# Get cluster credentials
az aks get-credentials \
  --resource-group CourtMate \
  --name CourtMateRSO \
  --overwrite-existing

# Verify connection
kubectl get nodes
```

### Deploy All Services

```bash
# From project root directory
./deploy-courtmate.sh
```

## Important
Never commit actual kubeconfig files with credentials!


To add secrets to the cluster, use the following command:

```bash
kubectl create secret generic app-secrets \
  --from-literal=SUPABASE_URL="your_real_supabase_url" \
  --from-literal=SUPABASE_KEY="your_real_supabase_key" \
  --from-literal=AUTH_SECRET="your_real_nextauth_secret" \
  --from-literal=AUTH_GOOGLE_ID="your_real_google_id" \
  --from-literal=AUTH_GOOGLE_SECRET="your_real_google_secret"
```



### How to Deploy Locally (Step-by-Step)

1.  **Start Cluster & Registry:**
    ```bash
    k3d registry create registry.localhost --port 5000
    k3d cluster create courtmate-local --registry-use k3d-registry.localhost:5000 -p "30000:30000@server:0"
    ```
    ```bash
    kubectl create secret generic app-secrets \
  --from-literal=SUPABASE_URL="your_supabase_url" \
  --from-literal=SUPABASE_SERVICE_ROLE_KEY="your_service_role_key" \
  --from-literal=SUPABASE_ANON_KEY="your_anon_key" \
  --from-literal=SUPABASE_JWT_SECRET="your_jwt_secret" \
  --from-literal=AUTH_SECRET="your_nextauth_secret" \
  --from-literal=AUTH_GOOGLE_ID="your_google_id" \
  --from-literal=AUTH_GOOGLE_SECRET="your_google_secret"
    ```

2.  **Build & Push Images:**
    ```bash
    # UI
    cd Courtmate-ui
    docker build -t localhost:5000/courtmate-ui:v1 .
    docker push localhost:5000/courtmate-ui:v1

    # User Service
    cd ../Courtmate-User-Service
    docker build -t localhost:5000/user-service:v1 .
    docker push localhost:5000/user-service:v1

    cd ../Courtmate-Court-Service
    docker build -t localhost:5000/court-service:v1 .
    docker push localhost:5000/court-service:v1
    ```

4.  **Deploy:**
    ```bash
    kubectl apply -f Courtmate-Infra/k8s/deployments/
    kubectl apply -f Courtmate-Infra/k8s/services/

    ```

5.  **Access:**
    Open **http://localhost:30000** in your browser.



6. **Teardown and delete:**
    ```bash
    # Stop and delete the k3d cluster
    k3d cluster delete courtmate-local

    # Stop and delete the registry
    k3d registry delete k3d-registry.localhost
    ```

8. **just stop:**
    ```bash
    k3d cluster stop courtmate-local
    ```
   
9. **just start:**
    ```bash
    k3d cluster start courtmate-local
    ```
10. **See Logs:**
    ```bash
    kubectl get pods
    
    kubectl logs -f deployment/<deployment-name>
    ```