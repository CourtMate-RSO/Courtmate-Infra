# scripts/deploy.sh
#!/bin/bash

NAMESPACE=${1:-courtmate-dev}
ENVIRONMENT=${2:-dev}

echo "🚀 Deploying to $NAMESPACE..."

# Start cluster if stopped
az aks start --resource-group RSO --name testCluster

# Apply configurations
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/storage/ -n $NAMESPACE
kubectl apply -f k8s/configmaps/ -n $NAMESPACE
kubectl apply -f k8s/secrets/ -n $NAMESPACE
kubectl apply -f k8s/deployments/ -n $NAMESPACE
kubectl apply -f k8s/services/ -n $NAMESPACE
kubectl apply -f k8s/ingress/ -n $NAMESPACE
kubectl apply -f k8s/autoscaling/ -n $NAMESPACE

echo "✅ Deployment complete!"
kubectl get pods -n $NAMESPACE