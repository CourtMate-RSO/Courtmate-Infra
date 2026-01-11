# Kubernetes Infrastructure Files

This directory contains the base Kubernetes configuration files for the CourtMate application.

## Current Deployment Method

**⚠️ We use Helm for deployment, not these raw YAML files.**

Deployment is managed through:
- Helm charts in each service's `chart/` directory
- Automated deployment via `deploy-courtmate.sh` script

## Directory Structure

### autoscaling/
Horizontal Pod Autoscaler (HPA) configurations:
- Max 3 pods per service
- CPU trigger: 70%
- Memory trigger: 80%

Apply with:
```bash
kubectl apply -f autoscaling/
```

### base/
Legacy deployment files (not used - kept for reference only)

### cert-manager/
SSL/TLS certificate management:
- `letsencrypt-issuer.yaml` - Let's Encrypt production issuer

Apply with:
```bash
kubectl apply -f cert-manager/letsencrypt-issuer.yaml
```

### cluster-config/
Cluster information and configuration:
- `cluster-info.json` - Current production cluster details

### logging/
Centralized logging with Fluentd:
- `fluentd-daemonset.yaml` - Log collection from all CourtMate services

Apply with:
```bash
kubectl apply -f logging/fluentd-daemonset.yaml
```

### monitoring/
Monitoring stack configuration:
- `monitoring-values.yaml` - Helm values for Prometheus/Grafana stack

Deploy with:
```bash
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values monitoring/monitoring-values.yaml
```

### namespaces/
Namespace definitions:
- `prod-namespace.yaml` - Production namespace (courtmate-prod)
- `monitoring-namespace.yaml` - Monitoring namespace

**Note:** These are created automatically by Helm, but kept for reference.

## Deployment Commands

### Deploy All Services
```bash
# From project root
./deploy-courtmate.sh
```

### Individual Service Deployment
```bash
helm upgrade --install <service-name> ./<Service-Dir>/chart/<service-chart> \
  --namespace courtmate-prod \
  --set image.repository=courtmate603fc8acr.azurecr.io/<service-name> \
  --set image.tag=<version>
```

### Deploy Autoscaling
```bash
kubectl apply -f autoscaling/
```

### Deploy Logging
```bash
kubectl apply -f logging/fluentd-daemonset.yaml
```

## What's Managed by Helm

The following are automatically managed by Helm charts:
- ✅ Deployments
- ✅ Services
- ✅ Ingress resources
- ✅ ConfigMaps (via secrets)
- ✅ Resource limits
- ✅ Environment variables

## Current Infrastructure

**Cluster:** CourtMateRSO  
**Registry:** courtmate603fc8acr.azurecr.io  
**Domain:** courtmate.duckdns.org  
**Namespace:** courtmate-prod  
**Monitoring:** Deployed via Helm (kube-prometheus-stack)  

See `/Courtmate-Infra/README.md` for complete documentation.
