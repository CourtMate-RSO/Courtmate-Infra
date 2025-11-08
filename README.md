# Courtmate AKS Cluster Configuration

## Cluster Details
- **Name**: testCluster
- **Resource Group**: RSO
- **Location**: polandcentral
- **Kubernetes Version**: 1.32.7

## Connect to Cluster

```bash
# Login to Azure
az login

# Get cluster credentials
az aks get-credentials \
  --resource-group RSO \
  --name testCluster \
  --overwrite-existing

# Verify connection
kubectl get nodes
```

## Important
Never commit actual kubeconfig files with credentials!
