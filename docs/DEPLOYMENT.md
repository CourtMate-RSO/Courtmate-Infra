
# CourtMate Deployment Guide

## Current Production Infrastructure

### Cluster Information
- **AKS Cluster**: CourtMateRSO
- **Resource Group**: CourtMate
- **Region**: Poland Central
- **Kubernetes**: v1.33.5
- **Container Registry**: courtmate603fc8acr.azurecr.io

### Deployed Services
1. **Booking Service** - Port 8080, Python/FastAPI
2. **Court Service** - Port 8001, Python/FastAPI
3. **User Service** - Port 8080, Python/FastAPI
4. **Notification Service** - Port 8000, Python/FastAPI
5. **UI Service** - Port 3000, Next.js 16

### Monitoring Stack
- **Prometheus** - Metrics collection
- **Grafana** - Dashboards and visualization

## Prerequisites

### Required Tools
```bash
# Install Azure CLI
brew install azure-cli

# Install kubectl
brew install kubectl

# Install Helm
brew install helm

# Install Docker
brew install docker
```

### Azure Access
- Azure subscription: "Azure for Students"
- Resource group access: CourtMate
- ACR push/pull permissions

## Deployment Process

### 1. Connect to Cluster

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "6df2c0ff-5907-48da-ba0a-c00b09533506"

# Get AKS credentials
az aks get-credentials \
  --resource-group CourtMate \
  --name CourtMateRSO \
  --overwrite-existing

# Verify connection
kubectl get nodes
```

### 2. Deploy All Services

```bash
# From project root directory
cd /path/to/MAGI/ROS

# Run deployment script
./deploy-courtmate.sh
```

This script will:
- Create namespaces (courtmate-prod, monitoring)
- Deploy all 5 microservices via Helm
- Deploy Prometheus & Grafana monitoring
- Configure ingress with HTTPS
- Show deployment status

### 3. Verify Deployment

```bash
# Check all pods
kubectl get pods -n courtmate-prod
kubectl get pods -n monitoring

# Check ingress
kubectl get ingress -n courtmate-prod
kubectl get ingress -n monitoring

# Check certificates
kubectl get certificate -n courtmate-prod
kubectl get certificate -n monitoring
```

## Access URLs

### Application
- **Main UI**: https://courtmate.duckdns.org
- **Booking API**: https://courtmate.duckdns.org/api/bookings/docs
- **Court API**: https://courtmate.duckdns.org/api/courts/docs
- **User API**: https://courtmate.duckdns.org/api/users/docs
- **Notification API**: https://courtmate.duckdns.org/api/notifications/docs

### Monitoring
- **Grafana**: https://grafana.courtmate.duckdns.org
  - Username: `admin`
  - Password: `CourtMate2026!`
- **Prometheus**: https://prometheus.courtmate.duckdns.org

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    courtmate.duckdns.org                     │
│                  (LoadBalancer: 134.112.145.160)            │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼─────┐
                    │  NGINX   │
                    │ Ingress  │
                    │Controller│
                    └────┬─────┘
                         │
        ┌────────────────┼────────────────┬─────────────┐
        │                │                │             │
   ┌────▼─────┐   ┌─────▼────┐   ┌──────▼───┐  ┌─────▼────┐
   │ Booking  │   │  Court   │   │  User    │  │Notification│
   │ Service  │   │ Service  │   │ Service  │  │  Service  │
   └────┬─────┘   └─────┬────┘   └──────┬───┘  └─────┬────┘
        │               │               │             │
        └───────────────┴───────────────┴─────────────┘
                         │
                    ┌────▼─────┐
                    │ Supabase │
                    │PostgreSQL│
                    └──────────┘

   ┌──────────────────────────────────────────┐
   │         Monitoring Stack                  │
   │  ┌──────────┐        ┌────────────┐     │
   │  │Prometheus│◄───────┤  Grafana   │     │
   │  │          │        │            │     │
   │  └────▲─────┘        └────────────┘     │
   │       │                                  │
   │  ┌────┴─────────────────────────┐       │
   │  │   All Services Metrics       │       │
   │  └──────────────────────────────┘       │
   └──────────────────────────────────────────┘
```

## Environment Configuration

### Secrets Management

Secrets are stored in Kubernetes secrets:

```bash
# View secrets
kubectl get secrets -n courtmate-prod

# Update UI secrets
kubectl create secret generic ui-secrets \
  --namespace courtmate-prod \
  --from-literal=NEXTAUTH_URL="https://courtmate.duckdns.org" \
  --from-literal=AUTH_GOOGLE_ID="..." \
  --from-literal=AUTH_GOOGLE_SECRET="..." \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Service Configuration

All services use Helm values.yaml for configuration:
- Image repository and tags
- Resource limits
- Ingress settings
- Environment variables

## Building and Pushing Images

### Build for AMD64 Architecture

```bash
# Login to ACR
az acr login --name courtmate603fc8acr

# Build and push service (example: booking-service)
cd Courtmate-Booking-Service
docker buildx build --platform linux/amd64 \
  -t courtmate603fc8acr.azurecr.io/booking-service:v1.0 \
  --push .
```

### Build All Services

See `rebuild-images-amd64.sh` for building all services at once.

## Troubleshooting

### Check Pod Logs
```bash
kubectl logs -n courtmate-prod <pod-name>
kubectl logs -n courtmate-prod -l app.kubernetes.io/name=booking-service
```

### Check Pod Status
```bash
kubectl describe pod -n courtmate-prod <pod-name>
```

### Check Ingress
```bash
kubectl describe ingress -n courtmate-prod
```

### Check Certificates
```bash
kubectl get certificate -n courtmate-prod
kubectl describe certificate -n courtmate-prod <cert-name>
```

### Restart Service
```bash
kubectl rollout restart deployment/<service-name> -n courtmate-prod
```