
## Prerequisites
- Azure CLI installed
- kubectl configured
- Access to Azure subscription

## Quick Start
1. Start cluster: `az aks start --resource-group RSO --name testCluster`
2. Get credentials: `az aks get-credentials --resource-group RSO --name testCluster`
3. Deploy: `./scripts/deploy.sh courtmate-dev`

## Architecture
[Diagram showing 4 microservices, databases, message queue, ingress]

## Environment Variables
[List all required env vars for each service]