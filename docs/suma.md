# Courtmate-Infra: Kubernetes Configuration Documentation

## 📂 Directory Structure Overview

```
Courtmate-Infra/
├── k8s/
│   ├── cluster-config/           # Cluster information and connection details
│   ├── namespaces/               # Environment isolation (dev, staging, prod)
│   ├── deployments/              # Microservice deployment definitions
│   ├── services/                 # Internal networking and service discovery
│   ├── ingress/                  # External access and API Gateway
│   ├── configmaps/               # Non-sensitive configuration
│   ├── secrets/                  # Sensitive data (passwords, tokens)
│   ├── storage/                  # Persistent storage for databases
│   ├── monitoring/               # Observability (Prometheus, Grafana)
│   └── autoscaling/              # Horizontal Pod Autoscaling rules
├── scripts/                      # Deployment and maintenance scripts
├── docs/                         # Documentation
└── .gitignore                    # Protect sensitive files
```

---

## 📄 YAML File Explanations

### 1. **Namespace** (`k8s/namespaces/*.yaml`)

**Purpose**: Isolate resources between environments (dev, staging, production).

**Key Concepts**:
- **Namespace**: Virtual cluster inside physical cluster
- **Isolation**: Resources in different namespaces can't communicate by default
- **Best Practice**: Separate dev/staging/prod to prevent accidents

**Files to Create**:
- `dev-namespace.yaml` - Development environment
- `staging-namespace.yaml` - Pre-production testing
- `prod-namespace.yaml` - Production environment

---

### 2. **ConfigMap** (app-config.yaml)

**Purpose**: Store non-sensitive configuration that services need.


**Key Concepts**:
- **Mounted as**: Environment variables or files in pods
- **Not encrypted**: Don't put passwords here!
- **Shared**: Multiple services can use same ConfigMap
- **Updates**: Changes don't auto-restart pods (need rolling update)

**Files to Create**:
- `app-config.yaml` - Shared application settings
- `database-config.yaml` - Database connection strings
- `feature-flags.yaml` - Feature toggles per environment

---

### 3. **Secret** (`k8s/secrets/*-secrets.yaml`)

**Purpose**: Store sensitive data (passwords, API keys, certificates).

**Key Concepts**:
- **Base64 Encoded**: Not encrypted by default (use sealed-secrets or Azure Key Vault)
- **Access Control**: Only pods in same namespace can access
- **Mounted as**: Environment variables or files
- **⚠️ Security**: NEVER commit to git! Use .gitignore

**Files to Create**:
- `db-secrets.yaml` - Database credentials
- `api-secrets.yaml` - Third-party API keys
- `jwt-secrets.yaml` - Authentication tokens
- .gitignore entry: `k8s/secrets/*-secrets.yaml`

**Better Alternative**:
```bash
# Use Azure Key Vault with CSI driver
# Or sealed-secrets for GitOps
```

---

### 4. **PersistentVolumeClaim** (`k8s/storage/postgres-pvc.yaml`)

**Purpose**: Request persistent storage for databases (survives pod restarts).


**Key Concepts**:
- **PVC vs PV**: 
  - PVC = Request for storage (what you want)
  - PV = Actual storage (what Azure provides)
- **Access Modes**:
  - `ReadWriteOnce` (RWO): One pod at a time
  - `ReadWriteMany` (RWX): Multiple pods (expensive)
- **Storage Classes**: Azure provides managed-premium, azurefile, etc.

**Files to Create**:
- `postgres-pvc.yaml` - PostgreSQL data (10Gi)
- `mongodb-pvc.yaml` - MongoDB data (if using NoSQL)
- `redis-pvc.yaml` - Redis persistence (optional)

---

### 5. **Deployment** (court-service-deployment.yaml)

**Purpose**: Define how to run your microservice (replicas, container image, resources).


**Key Concepts**:
- **Replicas**: Number of pod copies (for high availability)
- **Image**: Docker container from Azure Container Registry
- **Resources**:
  - `requests`: Scheduler uses this to place pods
  - `limits`: Hard cap to prevent resource hogging
- **Probes**:
  - `livenessProbe`: Detects dead pods → restarts
  - `readinessProbe`: Detects unhealthy pods → removes from load balancer

**Files to Create** (one per microservice):
- `court-service-deployment.yaml` - Court management
- `booking-service-deployment.yaml` - Reservation system
- `user-service-deployment.yaml` - User authentication
- notification-service-deployment.yaml - Email/SMS alerts
- `postgres-deployment.yaml` - Database
- `redis-deployment.yaml` - Cache/session store
- `rabbitmq-deployment.yaml` - Message queue

---

### 6. **Service** (court-service.yaml)

**Purpose**: Stable network endpoint for pods (enables service discovery).

---

### 7. **Ingress** (api-gateway.yaml)

**Purpose**: HTTP(S) routing from internet to services (API Gateway).


**Key Concepts**:
- **Ingress Controller**: NGINX, Traefik, or Azure Application Gateway
- **Path-based Routing**: Different URLs → different services
- **TLS**: Automatic HTTPS with cert-manager + Let's Encrypt
- **Annotations**: Controller-specific features (rate limiting, auth, etc.)

**Installation**:

**Files to Create**:
- `api-gateway.yaml` - Main API routing
- `ui-ingress.yaml` - Frontend app routing (if hosting UI in k8s)

---

### 8. **HorizontalPodAutoscaler** (court-service-hpa.yaml)

**Purpose**: Automatically scale pods based on CPU/memory usage.


**Key Concepts**:
- **Metrics**: CPU, memory, custom metrics (requests/sec)
- **Cool-down**: Prevent flapping (rapid scale up/down)
- **Requirements**: Pods must have `resources.requests` defined!

**Files to Create**:
- `court-service-hpa.yaml`
- `booking-service-hpa.yaml`
- `user-service-hpa.yaml`
- `notification-service-hpa.yaml`

---

